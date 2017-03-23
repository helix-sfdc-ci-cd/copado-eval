/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 9/13/2016
    @Purpose: This is a trigger for doing actions on Task object events. 
*/
trigger TaskTrigger on Task (after insert, after update) {
    
    // insert event check
    if(Trigger.isInsert) {
        TaskTriggerHelper.onAfterInsert(trigger.new);
    }
    
    // update event check
    if(Trigger.isUpdate) {
        TaskTriggerHelper.onAfterUpdate(trigger.new, trigger.oldMap);
    }
}