/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 8/28/2016
    @Purpose: This is the Manifest SPI class. This class will be responsible to invoke different APIs of Manifest Aplication.
*/

public with sharing class ManifestSPI {
    
    /* method to upload manifest data
       @parameter => doSchedule: to check if its manual upload or need to schedule for next upload
    */
    public void sendManifestData(Boolean doSchedule) {
        
        Sample_Service_Credentials__c sampleServCred = getSampleServiceCredentials();
        if(sampleServCred != null) {
            /* assign OrderItem data to biosamples object
               limit of number of Order Items to be assigned is defined in sample service credentials settings
            */
            BioSamples bSamples = getBioSamples(Integer.valueOf(sampleServCred.Query_Limit__c));
            
            Integer count = 1;
            // total number of biosamples fetched to be uploaded
            Integer size = bSamples.bioSamples.size();
            // total number of biosamples to be send per upload
            Integer maxRecordCount = Integer.valueOf(sampleServCred.Record_Count__c);
            
            List<Manifest> manifestList = new List<Manifest>();
            
            if(bSamples != null && bSamples.bioSamples.size() > 0) {
                // loop over all the biosamples fetched and upload them in batches 
                for(Manifest m :bSamples.bioSamples) {
                    manifestList.add(m);
                    if(Math.mod(count, maxRecordCount) == 0 || count == size) {
                        String bioSampleJSON = createBioSampleJSON(manifestList);
                        sendRequestAsync(bioSampleJSON, sampleServCred.Name, sampleServCred.UserName__c, sampleServCred.Password__c, 
                              sampleServCred.Auth_Token__c, sampleServCred.Login_Service__c, sampleServCred.Sample_Status_Service__c);
                 
                        manifestList = new List<Manifest>();
                    }
                    count++;
                }
            } else {
                String bioSampleJSON = createBioSampleJSON(manifestList);
                sendRequestAsync(bioSampleJSON, sampleServCred.Name, sampleServCred.UserName__c, sampleServCred.Password__c, 
                              sampleServCred.Auth_Token__c, sampleServCred.Login_Service__c, sampleServCred.Sample_Status_Service__c);
                 
            }
            
            try {
                // if its scheduled run then schedule for next run
                if(doSchedule)
                    scheduleNextRun(sampleServCred);
            } catch(Exception e) {
                // create error log if any error occurred in scheduling
                Error_Log__c errLog = HMAPI_SFDC_IntegrationUtil.logError('Line Number: ' + e.getLineNumber(), e.getMessage(), 'Schedule Upload Manifest', e.getTypeName(), String.valueOf(e.getCause()));
                insert errLog;
            }
        }
    }
    
    public String createBioSampleJSON(List<Manifest> manifestList) {
        BioSamples bSamples = new BioSamples();
        bSamples.BioSamples = manifestList;
        String bioSampleJSON = JSON.serializePretty(bSamples);
        return bioSampleJSON;
    }
    
    /* This is a future mehtod which send biosamples request in batches. This method is called when we send request asynchronously.
       all queried biosamples are divided into batches as per record count specified in sample service credential settings,
       and uploaded using this method
       We are using future method to send request because we can not do callouts using scheduled classes
    */
    @future(callout=true)
    public static void sendRequestAsync(String bioSampleJSON, String servCredName, String userName, String password, String authToken, String loginUrl, String serviceUrl) {
        sendRequest(bioSampleJSON, servCredName, userName, password, authToken, loginUrl, serviceUrl);
    }
    
    /* This is a NON future mehtod which send biosamples request immediately.
       This method is called when we want to recall request to generate new token
    */ 
    public static void sendRequest(String bioSampleJSON, String servCredName, String userName, String password, String authToken, String loginUrl, String serviceUrl) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(serviceUrl);
        req.setMethod('POST');
        req.setbody(bioSampleJSON);
        
        if(Test.isRunningTest()) authToken = 'test_token';
        
        // generate new authentication token if it does not eist or expired
        Boolean newTokenGenerated = false;
        if(authToken == null || authToken == '') {
            authToken = ManifestLogin.getAuthToken(servCredName, userName, password, loginUrl);
            newTokenGenerated = true;
        }
        
        if(authToken != null) {
            req.setHeader('Authorization', 'Bearer ' + authToken);
            // setTimeOut method takes input in miliseconds, so 20000 means 20 seconds
            req.setTimeOut(20000);
            // Create a new http object to send the request object 
            // A response object is generated as a result of the request   
            Http http = new Http();
            HTTPResponse res;
            res = http.send(req);
            
            if(res != null) {
                Integer statusCode = res.getStatusCode();
                String status = res.getStatus();
                // if biosamples are uploaded successfully and response is returned then parse manifest from json response
                if(statusCode == 200) {
                    parseManifestsFromJsonResponse(res.getBody());
                    // if new authentication token is generated then update it in settings 
                    if(newTokenGenerated) {
                        updateAccessToken(servCredName, authToken);
                    }
                } else {
                    // send request again if failure occured due to expired token
                    if(status == 'Unauthorized' && !newTokenGenerated) {
                        sendRequest(bioSampleJSON, servCredName, userName, password, '', loginUrl, serviceUrl);
                    } else {
                        // log error if failure occurred due to other reasons
                        Error_Log__c errLog = HMAPI_SFDC_IntegrationUtil.logError(String.valueOf(statusCode), status, res.getBody(), servCredName, 'Manifest Response Failed');
                        insert errLog;
                    }
                }
            }
        }
    }
    
    // parse manifests from json response to update biosamples
    public static void parseManifestsFromJsonResponse(String response) {
        
        if(response != null) {
            Map<String, SampleStatus> responseMap = new Map<String, SampleStatus>();
            JSONParser parser = JSON.createParser(response);
            SampleStatusResponse r = (SampleStatusResponse)parser.readValueAs(SampleStatusResponse.class);
            
            for(SampleStatus resp :r.sampleStatuses) {
                responseMap.put(resp.kitId, resp);
            }
            
            updateBioSamples(responseMap);
        }
    } 
    
    // update biosamples records
    public static void updateBioSamples(Map<String, SampleStatus> responseMap) {
        if(responseMap != null) {
            try {
                Map<String, SampleStatusDateMapping__c> statusDateMap = SampleStatusDateMapping__c.getAll();
                List<OrderItem> manifestToUpdate = new List<OrderItem>();
                
                List<OrderItem> lineList = [select id, Kit_ID__c, Data_Delivery_Date__c from OrderItem where Kit_ID__c in :responseMap.keySet()];
                for(OrderItem oi :lineList) {
                    SampleStatus rec = responseMap.get(oi.Kit_ID__c);
                    oi.Sample_Status__c = rec.sampleStatus;
                    
                    // assign values to corresponding date fields based on sample status
                    if(statusDateMap != null && statusDateMap.containsKey(rec.sampleStatus)){
                        String dateFieldApiName = statusDateMap.get(rec.sampleStatus).Date_Field_API_Name__c;
                        //Added condition for Only set Data Delivery Date once , Dated on 24-2-2017
                        if(dateFieldApiName.equals('Data_Delivery_Date__c')){
                            if(oi.get('Data_Delivery_Date__c') == null)
                                oi.put(dateFieldApiName, rec.statusTimestamp);
                        } else {
                            oi.put(dateFieldApiName, rec.statusTimestamp);
                        }
                        //End Dated on 24-2-2017
                    }
                    oi.Sample_Status_Updated__c = rec.statusTimestamp;
                    if(rec.sampleStatus == 'Error')
                        oi.Sample_Error_Detail__c = rec.errorMessage;
                    manifestToUpdate.add(oi);
                }
            
                if(manifestToUpdate != null && manifestToUpdate.size() > 0) {
                    update manifestToUpdate;
                }
            } catch(DMLException de){
                // log error if dml exception occurs
                List<Error_Log__c> errList = new List<Error_Log__c>();
                for (Integer i = 0; i < de.getNumDml(); i++) {
                    Error_Log__c errLog = HMAPI_SFDC_IntegrationUtil.logError('DML Failed', de.getDmlMessage(i), 'ManifestSPI Order Item Update', de.getTypeName(), String.valueOf(de.getCause()));
                    errList.add(errLog);
                }
                insert errList;
               
            } catch(Exception e){
                // log error if exception occurs
                Error_Log__c errLog = HMAPI_SFDC_IntegrationUtil.logError('Line Number: ' + e.getLineNumber(), e.getMessage(), 'ManifestSPI Order Item Update', e.getTypeName(), String.valueOf(e.getCause()));
                insert errLog;
            }
        }
    }
    
    // query OrderItem and return list of biosamples
    public BioSamples getBioSamples(Integer queryLimit) {
        
        String query = 'select Kit_ID__c, Prep_Request__c, Required_Yield__c, '
                                    + 'Project_Name__c, Analysis_Workflow__c, Delivery_Mode__c, Sample_Source__c, '
                                    + 'registeredBy__r.UserId__c, registeredBy__r.Biological_Sex__c, '
                                    + 'registeredBy__r.Customer_Age_Range__c '
                                    + 'from OrderItem where Type__c = \'KIT\' '
                                    + 'and Kit_ID__c != null '
                                    + 'and registeredBy__c != null '
                                    + 'and Sample_Status__c = \'Ready For Submission\' '
                                    + 'order by Last_Accessioning_Scan__c '
                                    + 'limit ' + queryLimit;
        List<OrderItem> orderLineList = Database.query(query);
        
        List<Manifest> bioSamples = new List<Manifest>();
        for(OrderItem ol :orderLineList) {
            Manifest m = new Manifest();
            m.kitId = ol.Kit_ID__c;
            m.userId = ol.registeredBy__r.UserId__c;
            m.prepRequest = ol.Prep_Request__c;
            m.requiredYieldGb = ol.Required_Yield__c;
            m.defaultProjectName = ol.Project_Name__c;
            m.analysisWorkflow = ol.Analysis_Workflow__c;
            m.deliveryMode = ol.Delivery_Mode__c;
            Properties p = new Properties();
            p.sampleSource = ol.Sample_Source__c;
            p.ageRange = ol.registeredBy__r.Customer_Age_Range__c;
            p.biologicalSex = ol.registeredBy__r.Biological_Sex__c;
            m.properties = p;
            bioSamples.add(m);
        }
        
        BioSamples b = new BioSamples();
        b.BioSamples = bioSamples;
        return b;
    }
    
    // query and retrun sample service credential settings
    public Sample_Service_Credentials__c getSampleServiceCredentials() {
        List<Sample_Service_Credentials__c> sampleServCredList = [SELECT EndTime__c, Frequency__c, Login_Service__c, Name, 
                    Password__c, Query_Limit__c, Record_Count__c, Sample_Status_Service__c, StartTime__c, Username__c, 
                    Auth_Token__c, Scope__c FROM Sample_Service_Credentials__c where Name = 'UploadManifest'];
        
        Sample_Service_Credentials__c sampleServCred;
        if(sampleServCredList != null && sampleServCredList.size() > 0) {
            sampleServCred = sampleServCredList[0];
        }
        return sampleServCred;
    }
    
    // update new generated authentication token in sample service credential settings
    public static void updateAccessToken(String servCredName, String authToken) {
        List<Sample_Service_Credentials__c> sampleServCredList = [SELECT EndTime__c, Frequency__c, Login_Service__c, Name, 
                    Password__c, Query_Limit__c, Record_Count__c, Sample_Status_Service__c, StartTime__c, Username__c, 
                    Auth_Token__c FROM Sample_Service_Credentials__c where Name = :servCredName];
        Sample_Service_Credentials__c sampleServCred;
        if(sampleServCredList != null && sampleServCredList.size() > 0) {
            sampleServCred = sampleServCredList[0];
            sampleServCred.Auth_Token__c = authToken;
        }
        update sampleServCred;
    }
    
    // method to schedule next upload of biosamples
    public void scheduleNextRun(Sample_Service_Credentials__c sampleServCred) {
        ManifestScheduleUtil schUtil = new ManifestScheduleUtil();
        schUtil.scheduleUploadManifest(sampleServCred);
    }
}