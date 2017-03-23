/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 02/19/2016
    @Purpose: This is trigger on Order object
*/
trigger SuperOrderTrigger on SuperOrder__c (after update) {
    
    SuperOrderTriggerHandler.onAfterUpdate(trigger.new, System.trigger.oldMap);
}