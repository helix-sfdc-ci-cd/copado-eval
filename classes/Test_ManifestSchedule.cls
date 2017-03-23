@isTest
private class Test_ManifestSchedule {
    
    // when start time + frequency is more than end time
    static testMethod void manifestScheduleNegativeTestMethod() {
        //Sample_Service_Credentials__c sampleServCred = uploadManifestSettings();
        Sample_Service_Credentials__c sampleServCred = Test_ManifestDataUtil.uploadManifestSettings();
        sampleServCred.Frequency__c = 1000;
        ManifestScheduleUtil sch = new ManifestScheduleUtil();
        String schTimer = sch.schedule(sampleServCred, System.now());
        // no scheduled time is returned by this method for the day
        System.assertEquals(null, schTimer);
    }
    
    // when start time + frequency is less than end time
    static testMethod void manifestSchedulePositiveTestMethod() {
        Sample_Service_Credentials__c sampleServCred = Test_ManifestDataUtil.uploadManifestSettings();
        //Sample_Service_Credentials__c sampleServCred = uploadManifestSettings();
        sampleServCred.Frequency__c = 5;
        update sampleServCred;
        ManifestScheduleUtil sch = new ManifestScheduleUtil();
        
        //When current time is 2:00 PM
        DateTime dt = DateTime.newInstance(2016, 9, 15, 14, 0, 0);  // 9.15.2016 14:00
        String schTimer = sch.schedule(sampleServCred, dt);
        // since the start time is 9:00 so next scheduled time will be 9.15.2016 15:00
        System.assertEquals(sch.returnTimer(DateTime.newInstance(2016, 9, 15, 14, 5, 0)), schTimer);
        
        //When current time is 9:00 AM
        dt = DateTime.newInstance(2016, 9, 15, 9, 0, 0);  // 9.15.2016 9:00
        schTimer = sch.schedule(sampleServCred, dt);
        // since the start time is 9:00 so next scheduled time will be 9.15.2016 11:00
        System.assertEquals(sch.returnTimer(DateTime.newInstance(2016, 9, 15, 9, 5, 0)), schTimer);
        
        //When current time is 9:00 PM
        dt = DateTime.newInstance(2016, 9, 15, 21, 0, 0);  // 9.15.2016 21:00
        schTimer = sch.schedule(sampleServCred, dt);
        // it should return null because end time is 21:00 and next scheduling will start next day
        System.assertEquals(null, schTimer);
        
    }
}