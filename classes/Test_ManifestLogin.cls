@isTest (seealldata=true)
private class Test_ManifestLogin {
    
    static testMethod void manifestLoginTestMethod() {
        ManifestSPI manifest = new ManifestSPI();
        Sample_Service_Credentials__c sampleServCred = manifest.getSampleServiceCredentials();
        
        Organization org = [select isSandbox from Organization limit 1];
        
        Boolean containsStaging = sampleServCred.Sample_Status_Service__c.contains('staging');
        
        if(org.isSandbox) {
            System.assertEquals(true, containsStaging);
        } else {
            System.assertEquals(false, containsStaging);
        }
    }
    
}