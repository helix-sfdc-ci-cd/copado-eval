@isTest
public class Test_APIDataUtil {
    
    public static void createKitHoldFakeResponse() {
        EmailNotificationResponse response = new EmailNotificationResponse();
        response.emailId = '12345';
        response.success = true;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'OK',
                                                 JSON.serializePretty(response),
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    }
    
    public static void createKitHoldErrorFakeResponse() {
        EmailNotificationResponse response = new EmailNotificationResponse();
        response.emailId = '12345';
        response.success = false;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'OK',
                                                 JSON.serializePretty(response),
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    }
    
    public static void createKitShippedFakeResponse() {
        EmailNotificationSPIResponse r = new EmailNotificationSPIResponse();
        List<EmailNotificationResponse> responseList = new List<EmailNotificationResponse>();
        for(SuperOrder__c so :[select id from SuperOrder__c limit 200]) {
            EmailNotificationResponse response = new EmailNotificationResponse();
            response.emailId = so.id;
            response.success = true;
            responseList.add(response);
        }
        r.sendEmailResponses = responseList;
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'OK',
                                                 JSON.serializePretty(r),
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    }
    
    public static void createKitShippedErrorFakeResponse() {
        EmailNotificationSPIResponse r = new EmailNotificationSPIResponse();
        List<EmailNotificationResponse> responseList = new List<EmailNotificationResponse>();
        for(SuperOrder__c so :[select id from SuperOrder__c limit 200]) {
            EmailNotificationResponse response = new EmailNotificationResponse();
            response.emailId = so.id;
            response.success = false;
            response.error = 'Mandatory fields missing';
            responseList.add(response);
        }
        r.sendEmailResponses = responseList;
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'OK',
                                                 JSON.serializePretty(r),
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    }
    
    // create upload manifest settings data
    public static Sample_Service_Credentials__c serviceCredSettings(String serviceName) {
        Sample_Service_Credentials__c ssc = new Sample_Service_Credentials__c();
        ssc.Name = serviceName;
        ssc.Username__c = 'TestUsername';
        ssc.Password__c = 'TestPassword';
        ssc.Login_Service__c = 'www.testlogin.com';
        ssc.Sample_Status_Service__c = 'www.ssc.com';
        ssc.Record_Count__c = 200;
        ssc.Scope__c = 'email_sfdc';
        insert ssc;
        return ssc;
    }
}