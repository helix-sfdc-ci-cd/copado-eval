/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/18/2016
    @Purpose: This is trigger on Case object
*/
trigger CaseTrigger on Case (before update) {
    
    CaseTriggerHandler.onBeforeUpdate(trigger.new, System.trigger.oldMap);
}