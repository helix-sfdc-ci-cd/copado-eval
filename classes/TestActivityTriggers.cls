/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 9/18/2016
    @Purpose: This is a test class to verify working of Task and EmailMessage triggers to populate Last Activity Date. 
*/
@isTest
private class TestActivityTriggers {
    
    // method to validate last activity date update on Task events
    private static testmethod void testTaskTrigger() {
        
        // case created
        Case caseRecord = new Case(Subject = 'Test', Description = 'Test');
        insert caseRecord;
        
        // current date time
        DateTime expectedTime = System.now();
        
        // task created
        Task tsk = new Task(WhatId = caseRecord.id, Subject = 'Test', Status = 'Open');
        insert tsk;
        
        List<Case> caseList = [select id from Case where Last_Activity_Date__c >= :expectedTime limit 1];
        
        // checking if there is any case whose last activity date is greater than or equal to expectedTime
        System.assertEquals(1, caseList.size());
        // checking if it is the same case record
        System.assertEquals(caseRecord.id, caseList[0].id);
        
        // status of case updated 
        tsk.Status = 'Closed';
        update tsk;
        
        caseList = [select Last_Activity_Date__c from Case where Last_Activity_Date__c >= :expectedTime limit 1];
        
        // checking if there is any case whose last activity date is greater than or equal to expectedTime
        System.assertEquals(1, caseList.size());
        // checking if it is the same case record
        System.assertEquals(caseRecord.id, caseList[0].id);
    }
    
    // method to validate last activity date updation on EmailMessage events
    private static testmethod void testEmailMessageTrigger() {
        
        // case created
        Case caseRecord = new Case(Subject = 'Test', Description = 'Test');
        insert caseRecord;
        
        // current date time
        DateTime expectedTime = System.now();
        
        // email sent and EmailMessage record created
        EmailMessage eml = new EmailMessage(ParentId = caseRecord.id, Subject = 'Test', ToAddress = 'test@test.com');
        insert eml;
        
        
        List<Case> caseList = [select id from Case where Last_Activity_Date__c >= :expectedTime limit 1];
        
        // checking if there is any case whose last activity date is greater than or equal to expectedTime
        System.assertEquals(1, caseList.size());
        // checking if it is the same case record
        System.assertEquals(caseRecord.id, caseList[0].id);
    }
}