public class KitShippedEmailNotificationSPI {
    
    
    public static void kitShippedEmailNotification(Set<Id> soIds) {
        try {
            List<Order> ordList = [select SuperOrder__c, BillToContactId, BillToContact.Email, 
                     BillToContact.FirstName, BillToContact.userid__c, SuperOrder__r.Name,
                     (select OB_Tracking_Link__c from OrderItems where Type__c = 'KIT')
                     from Order where SuperOrder__c in :soIds];
            
            Map<Id, Order> soIdOrderMap = new Map<Id, Order>();
            Map<Id, Integer> soIdKitCountMap = new Map<Id, Integer>();
            Map<Id, Set<String>> soIdTrackingLinkMap = new Map<Id, Set<String>>();
            Map<Id, String> soIdWhoIdMap = new Map<Id, String>();
            Map<Id, String> soIdTemplateMap = new Map<Id, String>();
              
            for(Order ord :ordList) {
                Integer kitCount = ord.OrderItems.size();
                if(soIdKitCountMap.containsKey(ord.SuperOrder__c)) {
                    kitCount += soIdKitCountMap.get(ord.SuperOrder__c);
                }
                soIdKitCountMap.put(ord.SuperOrder__c, kitCount);
                soIdOrderMap.put(ord.SuperOrder__c, ord);
                soIdWhoIdMap.put(ord.SuperOrder__c, ord.BillToContactId);
                
                for(OrderItem oi :ord.OrderItems) {
                    
                    if(soIdTrackingLinkMap.containsKey(ord.SuperOrder__c)) {
                        soIdTrackingLinkMap.get(ord.SuperOrder__c).add(oi.OB_Tracking_Link__c);
                    }else{
                        Set<String> trackingLinkSet = new Set<String>();
                        trackingLinkSet.add(oi.OB_Tracking_Link__c);
                        soIdTrackingLinkMap.put(ord.SuperOrder__c, trackingLinkSet);
                    }
                }
            }
            
            Map<String, Marketing_Email_Template_Name__c> templateMap = Marketing_Email_Template_Name__c.getAll();
            String kit_ShippedTemplate = templateMap.get('Kit shipped').Email_Template_Name__c;
            String kits_ShippedTemplate = templateMap.get('Kits shipped').Email_Template_Name__c;
            Set<String> alreadySentSuperOrderIds = getAlreadySentSuperOrderIds(soIdWhoIdMap, kit_ShippedTemplate, kits_ShippedTemplate);
            Sample_Service_Credentials__c serviceCred = HelixApiUtil.getServiceCredentials('BulkEmailService');
            
            if(serviceCred != null) {
                Integer count = 1;
                // total number of super order
                Integer size = soIdOrderMap.keySet().size();
                // total number of super order to be send per upload
                Integer maxRecordCount = Integer.valueOf(serviceCred.Record_Count__c);
                    
                KitShippedEmailNotificationRequest emailNotifRequests = new KitShippedEmailNotificationRequest();
                List<KitShippedRequest> sendEmailRequests = new List<KitShippedRequest>();
                Map<Id, Id> soTaskIdMap = createActivities(soIdOrderMap, alreadySentSuperOrderIds, soIdKitCountMap, kit_ShippedTemplate, kits_ShippedTemplate);
                
                for(Id soId :soIdOrderMap.keySet()) {
                    Order ord = soIdOrderMap.get(soId);
                    if(!alreadySentSuperOrderIds.contains(HelixApiUtil.concatenateString(soId, ord.BillToContactId))) {
                        KitShippedRequest emailNotif = new KitShippedRequest();
                        emailNotif.emailAddress = ord.BillToContact.Email;
                        
                        if(soIdKitCountMap.get(soId) == 1) {
                            emailNotif.emailTemplate = kit_ShippedTemplate;
                        } else if(soIdKitCountMap.get(soId) > 1) {
                            emailNotif.emailTemplate = kits_ShippedTemplate;
                        }
                        soIdTemplateMap.put(soId, emailNotif.emailTemplate);
                        emailNotif.sfdcContactId = ord.BillToContactId;
                        emailNotif.userId = ord.BillToContact.userid__c;
                        emailNotif.emailId = ord.SuperOrder__c;
                        KitShippedTokenData tData = new KitShippedTokenData();
                        tData.firstName = ord.BillToContact.FirstName;
                        
                        // Format of trackingLink should be
                        // <p style="color:#329AF2;font-size:20px;margin:0 auto;">LINK1</p><p style="color:#329AF2;font-size:20px;margin:0 auto;">LINK2</p> 
                        String trackingLink = '';
                        for(String link :soIdTrackingLinkMap.get(soId)) {
                            trackingLink += System.Label.Tracking_Link_Start_Tag + link + System.Label.Tracking_Link_End_Tag;
                        }
                        
                        tData.outboundTrackingLink = trackingLink;
                        tData.superOrderId = ord.SuperOrder__r.Name;
                        emailNotif.tokenData = tData;
                        sendEmailRequests.add(emailNotif);
                        if(Math.mod(count, maxRecordCount) == 0 || count == size) {
                            emailNotifRequests.sendEmailRequests = sendEmailRequests;
                            String emailNotificationJSON = JSON.serializePretty(emailNotifRequests);
                                 
                            sendRequestAsync(emailNotificationJSON, 'BulkEmailService', serviceCred.UserName__c, serviceCred.Password__c, 
                              serviceCred.Auth_Token__c, serviceCred.Login_Service__c, serviceCred.Sample_Status_Service__c, 
                                  serviceCred.Scope__c, soTaskIdMap);
                            sendEmailRequests = new List<KitShippedRequest>();
                        }
                        count++;
                    }
                }
            } else {
                HelixApiUtil.logError('APP_ERR', 'Login Failed', 'KitShippedEmailNotificationSPI', 'Service Credential are null', 'BulkEmailService');
            }
        } catch(Exception e) {
            HelixApiUtil.logError('APP_ERR', e.getTypeName(), 'KitShippedEmailNotificationSPI', e.getMessage(), String.valueOf(e.getCause()));
        }
    }
    
    public static Map<Id, Id> createActivities(Map<Id, Order> soIdOrderMap, Set<String> alreadySentSuperOrderIds, Map<Id, Integer> soIdKitCountMap,
                                                        String kit_ShippedTemplate, String kits_ShippedTemplate) {
        Map<Id, Task> soIdTaskMap = new Map<Id, Task>();
        for(Id soId :soIdOrderMap.keySet()) {
            Order ord = soIdOrderMap.get(soId);
            String emailTemplate;
            if(soIdKitCountMap.get(soId) == 1) {
                emailTemplate = kit_ShippedTemplate;
            } else if(soIdKitCountMap.get(soId) > 1) {
                emailTemplate = kits_ShippedTemplate;
            }
            if(!alreadySentSuperOrderIds.contains(HelixApiUtil.concatenateString(soId, ord.BillToContactId))) {
                soIdTaskMap.put(soId, new Task(WhatId = soId, WhoId = ord.BillToContactId, ActivityDate = System.today(),
                    Subject = 'Contact was targeted to receive email template ' + emailTemplate, Status = 'Pending',
                    Status_Context__c = 'Helix Email Service'));
            }
        }
        if(soIdTaskMap.size() > 0) {
            insert soIdTaskMap.values();
        }
        
        Map<Id, Id> soTaskIdMap = new Map<Id, Id>();
        for(Id soId :soIdTaskMap.keySet()) {
            soTaskIdMap.put(soId, soIdTaskMap.get(soId).id);
        }
        return soTaskIdMap;
    }
    
    // check if there is existing activity record before sending API request
    public static Set<String> getAlreadySentSuperOrderIds(Map<Id, String> soIdWhoIdMap, String kit_ShippedTemplate, String kits_ShippedTemplate) {
        Set<Id> whatIds = new Set<Id>();
        whatIds.addAll(soIdWhoIdMap.keySet());
        
        List<String> whoIds = new List<String>();
        whoIds.addAll(soIdWhoIdMap.values());
        
        String qry = 'select Order_Product__c, WhoId, WhatId from Task where WhatId in :whatIds and WhoId in :WhoIds ';
        qry += ' and (Subject like \'%' + kit_ShippedTemplate + '%\' or Subject like \'%' + kits_ShippedTemplate + '%\')';
        List<Task> taskList = Database.query(qry);
    
        Set<String> alreadySentSuperOrderIds = new Set<String>();
        for(Task tsk :taskList) {
            alreadySentSuperOrderIds.add(HelixApiUtil.concatenateString(tsk.WhatId, tsk.WhoId));
        }
        return alreadySentSuperOrderIds;
    }
    
    @future(callout=true)
    public static void sendRequestAsync(String emailNotificationJSON, String servCredName, String userName, String password, 
                            String authToken, String loginUrl, String serviceUrl, String scope, Map<Id, Id> soTaskIdMap) {
    
        sendRequest(emailNotificationJSON, servCredName, userName, password, authToken, loginUrl, serviceUrl, scope,
                            soTaskIdMap);                        
    }
    
    public static void sendRequest(String emailNotificationJSON, String servCredName, String userName, String password, 
                            String authToken, String loginUrl, String serviceUrl, String scope, Map<Id, Id> soTaskIdMap) {
        
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
                
                if(res != null) {
                    Integer statusCode = res.getStatusCode();
                    String status = res.getStatus();
                    // if response is returned then parse from json response
                    if(statusCode == 200) {
                        
                        String responseBody = res.getBody();
                        if(responseBody != null) {
                            processResponse(responseBody, soTaskIdMap);
                        } else {
                            HelixApiUtil.logError('APP_ERR', 'Response Failed', 'KitShippedEmailNotificationSPI', 'Response body is null', 'Response body is null');
                        }
                        // if new authentication token is generated then update it in settings 
                        if(newTokenGenerated) {
                            HelixApiUtil.updateAccessToken(servCredName, authToken);
                        }
                        
                    } else {
                        // send request again if failure occured due to expired token
                        if(status == 'Unauthorized' && !newTokenGenerated) {
                            sendRequest(emailNotificationJSON, servCredName, userName, password, '', loginUrl, serviceUrl, scope, soTaskIdMap);
                        } else {
                            // log error if failure occurred due to other reasons
                            HelixApiUtil.logError(String.valueOf(statusCode), status, 'KitShippedEmailNotificationSPI', res.getBody(), status);
                        }
                    }
                } else {
                    HelixApiUtil.logError('APP_ERR', 'Response Failed', 'KitShippedEmailNotificationSPI', 'Response is null', 'Response is null');
                }
            } else {
                HelixApiUtil.logError('APP_ERR', 'Login Failed', 'KitShippedEmailNotificationSPI', 'Authentication token is null', 'Authentication token is null');
            }
        } catch(Exception e) {
            HelixApiUtil.logError('APP_ERR', e.getTypeName(), 'KitShippedEmailNotificationSPI', e.getMessage(), String.valueOf(e.getCause()));
        }
    }
    
    public static void processResponse(String response, Map<Id, Id> soTaskIdMap) {
        EmailNotificationSPIResponse resp = parseJsonResponse(response);
        updateActivities(resp, soTaskIdMap);
    }
    
    public static EmailNotificationSPIResponse parseJsonResponse(String response) {
        EmailNotificationSPIResponse resp;
        JSONParser parser = JSON.createParser(response);
        resp = (EmailNotificationSPIResponse)parser.readValueAs(EmailNotificationSPIResponse.class);
        return resp;
    } 
    
    public static void updateActivities(EmailNotificationSPIResponse resp, Map<Id, Id> soTaskIdMap) {
        List<Task> tskList = new List<Task>();
        for(EmailNotificationResponse r :resp.sendEmailResponses) {
            Task taskToUpdate = new Task();
            taskToUpdate.id = soTaskIdMap.get(r.emailId);
            if(r.success) {
                taskToUpdate.Status = 'Sent';
            } else {
                taskToUpdate.Status = 'Error';
                taskToUpdate.Description = r.error;
            }
            tskList.add(taskToUpdate);
        }
        update tskList;
    }
}