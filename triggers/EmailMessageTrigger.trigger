/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 9/13/2016
    @Purpose: This is a trigger for doing actions on EmailMessage object events. 
*/
trigger EmailMessageTrigger on EmailMessage (after insert) {
    
    // insert event check
    if(Trigger.isInsert) {
        EmailMessageTriggerHelper.onAfterInsert(trigger.new);
    }
}