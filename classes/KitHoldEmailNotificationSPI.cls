/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 2/20/2016
    @Purpose: This is the EmailNotification SPI class. This class will be responsible to invoke email notification API.
*/
public class KitHoldEmailNotificationSPI {
    
    // method to send API request when order item status changes to On Hold
    public static void sendKitHoldEmailNotification(Set<Id> orderItemIds) {
        
        try {
            List<OrderItem> ordItemList = [select OrderId, Order.BillToContactId, Order.BillToContact.FirstName, 
                    Order.BillToContact.Email, Order.BillToContact.UserId__c, Order.SuperOrder__r.Name 
                    from OrderItem where id in :orderItemIds];
            
            String kitOnHoldTemplate = Marketing_Email_Template_Name__c.getValues('Kit on hold').Email_Template_Name__c;
            Set<String> alreadySentOrderItemIds = getAlreadySentOrderItemIds(ordItemList, kitOnHoldTemplate);
            Map<Id, String> mapOrderAppName = returnOrderAppNameMap(ordItemList);
            
            Sample_Service_Credentials__c serviceCred = HelixApiUtil.getServiceCredentials('SingleEmailService');
             
            if(serviceCred != null) {
                Map<Id, Id> oiTaskIdMap = createActivities(ordItemList, alreadySentOrderItemIds, kitOnHoldTemplate);
                
                for(OrderItem oi :ordItemList) {
                    String combination = HelixApiUtil.concatenateString(oi.id, oi.Order.BillToContactId);
                    if(!alreadySentOrderItemIds.contains(combination)) {
                        KitHoldRequest emailNotif = new KitHoldRequest();
                        emailNotif.emailAddress = oi.Order.BillToContact.Email;
                        emailNotif.emailTemplate = kitOnHoldTemplate;
                        emailNotif.sfdcContactId = oi.Order.BillToContactId;
                        emailNotif.userId = oi.Order.BillToContact.UserId__c;
                        emailNotif.emailId = oi.id;
                        KitHoldTokenData tData = new KitHoldTokenData();
                        tData.firstName = oi.Order.BillToContact.FirstName;
                        tData.superOrderId = oi.Order.SuperOrder__r.Name;
                        if(mapOrderAppName != null && mapOrderAppName.containsKey(oi.OrderId)) {
                            tData.appProductName = mapOrderAppName.get(oi.OrderId);
                        }
                        emailNotif.tokenData = tData;
                        String emailNotificationJSON = JSON.serializePretty(emailNotif);
                        
                        sendRequestAsync(emailNotificationJSON, 'SingleEmailService', serviceCred.UserName__c, serviceCred.Password__c, 
                           serviceCred.Auth_Token__c, serviceCred.Login_Service__c, 
                              serviceCred.Sample_Status_Service__c, serviceCred.Scope__c, oiTaskIdMap.get(oi.Id));
                    }
                }
            } else {
                HelixApiUtil.logError('APP_ERR', 'Login Failed', 'KitHoldEmailNotificationSPI', 'Service Credential are null', 'SingleEmailService');
            }
            
        } catch(Exception e) {
            HelixApiUtil.logError('APP_ERR', e.getTypeName(), 'KitHoldEmailNotificationSPI', e.getMessage(), String.valueOf(e.getCause()));
        }
    }
    
    public static Map<Id, Id> createActivities(List<OrderItem> ordItemList, Set<String> alreadySentOrderItemIds, String kitOnHoldTemplate) {
        Map<Id, Task> oiIdTaskMap = new Map<Id, Task>();
        for(OrderItem oi :ordItemList) {
            String combination = HelixApiUtil.concatenateString(oi.id, oi.Order.BillToContactId);
            if(!alreadySentOrderItemIds.contains(combination)) {
                oiIdTaskMap.put(oi.Id, new Task(WhatId = oi.OrderId, WhoId = oi.Order.BillToContactId, Order_Product__c = oi.Id, 
                    ActivityDate = System.today(), Subject = 'Contact was targeted to receive email template ' + kitOnHoldTemplate, 
                    Status = 'Pending', Status_Context__c = 'Helix Email Service'));
                
            }
        }
        if(oiIdTaskMap.size() > 0) {
            insert oiIdTaskMap.values();
        }
        
        Map<Id, Id> oiTaskIdMap = new Map<Id, Id>();
        for(Id oiId :oiIdTaskMap.keySet()) {
            oiTaskIdMap.put(oiId, oiIdTaskMap.get(oiId).id);
        }
        return oiTaskIdMap;
    }
    
    // check if there is existing activity record before sending API request
    public static Set<String> getAlreadySentOrderItemIds(List<OrderItem> ordItemList, String kitOnHoldTemplate) {
        Set<Id> oiIdSet = new Set<Id>();
        Set<Id> conIdSet = new Set<Id>();
        for(OrderItem oi :ordItemList) {
            oiIdSet.add(oi.id);
            conIdSet.add(oi.Order.BillToContactId);
        }
        
        String qry = 'select Order_Product__c, WhoId from Task where Order_Product__c in :oiIdSet and WhoId in :conIdSet and Subject like \'%' + kitOnHoldTemplate + '%\'';
        
        List<Task> taskList = Database.query(qry);
    
        Set<String> alreadySentOrderItemIds = new Set<String>();
        for(Task tsk :taskList) {
            alreadySentOrderItemIds.add(HelixApiUtil.concatenateString(tsk.Order_Product__c, tsk.WhoId));
        }
        return alreadySentOrderItemIds;
    }
    
    @future(callout=true)
    public static void sendRequestAsync(String emailNotificationJSON, String servCredName, String userName, String password, 
                            String authToken, String loginUrl, String serviceUrl, String scope, String taskId) {
    
        sendRequest(emailNotificationJSON, servCredName, userName, password, authToken, loginUrl, serviceUrl, scope, taskId);                        
    }
    
    public static void sendRequest(String emailNotificationJSON, String servCredName, String userName, String password, 
                            String authToken, String loginUrl, String serviceUrl, String scope, String taskId) {
        
        System.debug('emailNotificationJSON===' + emailNotificationJSON);
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(serviceUrl);
            req.setMethod('POST');
            req.setbody(emailNotificationJSON);
            
            if(Test.isRunningTest()) authToken = 'test_token';
            
            // generate new authentication token if it does not eist or expired
            Boolean newTokenGenerated = false;
            if(authToken == null || authToken == '') {
                authToken = HelixApiLogin.getAuthToken(servCredName, userName, password, loginUrl, scope);
                newTokenGenerated = true;
            }
            
            if(authToken != null) {
                req.setHeader('Authorization', 'Bearer ' + authToken);
                req.setTimeout(120000);
                // Create a new http object to send the request object 
                // A response object is generated as a result of the request   
                Http http = new Http();
                HTTPResponse res;
                res = http.send(req);
                System.debug('resp====' + res);
                if(res != null) {
                    Integer statusCode = res.getStatusCode();
                    String status = res.getStatus();
                    // if uploaded successfully and response is returned then parse from json response
                    if(statusCode == 200) {
                        System.debug('respBody====' + res.getBody());
                        
                        // if new authentication token is generated then update it in settings 
                        if(newTokenGenerated) {
                            HelixApiUtil.updateAccessToken(servCredName, authToken);
                        }
                        
                        String responseBody = res.getBody();
                        if(responseBody != null) {
                            processResponse(responseBody, taskId);
                        } else {
                            HelixApiUtil.logError('APP_ERR', 'Response Failed', 'KitHoldEmailNotificationSPI', 'Response body is null', 'Response body is null');
                        }
                        
                    } else {
                        // send request again if failure occured due to expired token
                        if(status == 'Unauthorized' && !newTokenGenerated) {
                            sendRequest(emailNotificationJSON, servCredName, userName, password, '', loginUrl, serviceUrl, scope, taskId);
                        } else {
                            // log error if failure occurred due to other reasons
                            HelixApiUtil.logError(String.valueOf(statusCode), status, 'KitHoldEmailNotificationSPI', res.getBody(), status);
                        }
                    }
                } else {
                    HelixApiUtil.logError('APP_ERR', 'Response Failed', 'KitHoldEmailNotificationSPI', 'Response is null', 'Response is null');
                }
            } else {
                // create error log if login is failed
                HelixApiUtil.logError('APP_ERR', 'Login Failed', 'KitHoldEmailNotificationSPI', 'Authentication token is null', 'Authentication token is null');
            }
        } catch(Exception e) {
            HelixApiUtil.logError('APP_ERR', e.getTypeName(), 'KitHoldEmailNotificationSPI', e.getMessage(), String.valueOf(e.getCause()));
        }
    }
    
    public static void processResponse(String response, String taskId) {
    
        EmailNotificationResponse resp = parseJsonResponse(response);
        updateActivity(resp, taskId);
    } 
    
    public static EmailNotificationResponse parseJsonResponse(String response) {
        Set<String> successIds = new Set<String>();
        JSONParser parser = JSON.createParser(response);
        EmailNotificationResponse r = (EmailNotificationResponse)parser.readValueAs(EmailNotificationResponse.class);
        return r;
    } 
    
    public static void updateActivity(EmailNotificationResponse resp, String taskId) {
        Task taskToUpdate = new Task();
        taskToUpdate.id = taskId;
        if(resp.success != null && resp.success) {
            taskToUpdate.Status = 'Sent';
        } else {
            taskToUpdate.Status = 'Error';
            taskToUpdate.Description = resp.error;
        }
        update taskToUpdate;
    }
    
    public static Map<Id, String> returnOrderAppNameMap(List<OrderItem> ordItemList) {
        Map<Id, String> mapOrderAppName = new Map<Id, String>();
        Set<Id> ordIds = new Set<Id>();
        for(OrderItem oi :ordItemList) {
            ordIds.add(oi.OrderId);
        }
        List<OrderItem> appOrderItem = [select Product2.Name, OrderId from OrderItem 
                        where OrderId in :ordIds and Type__c = 'APP'];
        
        for(OrderItem oi :appOrderItem) {
            mapOrderAppName.put(oi.OrderId, oi.Product2.Name);
        }
        return mapOrderAppName;
    }
}