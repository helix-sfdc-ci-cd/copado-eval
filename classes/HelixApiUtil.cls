public class HelixApiUtil {
    
    public static void updateAccessToken(String servCredName, String authToken) {
        List<Sample_Service_Credentials__c> serviceCredList = [SELECT EndTime__c, Frequency__c, Login_Service__c, Name, 
                    Password__c, Query_Limit__c, Record_Count__c, Sample_Status_Service__c, StartTime__c, Username__c, 
                    Auth_Token__c FROM Sample_Service_Credentials__c where Name = :servCredName];
        Sample_Service_Credentials__c serviceCred;
        if(serviceCredList != null && serviceCredList.size() > 0) {
            serviceCred = serviceCredList[0];
            serviceCred.Auth_Token__c = authToken;
        }
        update serviceCred;
    }
    
    public static Sample_Service_Credentials__c getServiceCredentials(String serviceName) {
        List<Sample_Service_Credentials__c> serviceCredList = [SELECT EndTime__c, Frequency__c, Login_Service__c, Name, 
                    Password__c, Query_Limit__c, Record_Count__c, Sample_Status_Service__c, StartTime__c, Username__c, 
                    Auth_Token__c, Scope__c FROM Sample_Service_Credentials__c where Name = :serviceName];
        
        Sample_Service_Credentials__c serviceCred;
        if(serviceCredList != null && serviceCredList.size() > 0) {
            serviceCred = serviceCredList[0];
        }
        return serviceCred;
    }
    
    public static String concatenateString(String str1, String str2) {
        return (str1 + '-' + str2);
    }
    
    public static void logError(String statusCode, String status, String typeOfError, String description, String cause) {
        Error_Log__c errLog = HMAPI_SFDC_IntegrationUtil.logError(statusCode, status, typeOfError, description, cause);
        insert errLog;
    }
}