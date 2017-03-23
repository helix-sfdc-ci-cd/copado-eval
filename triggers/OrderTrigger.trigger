/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/18/2016
    @Purpose: This is trigger on Order object
*/
trigger OrderTrigger on Order (after update) {
    
    OrderTriggerHandler.onAfterUpdate(trigger.new, System.trigger.oldMap);
}