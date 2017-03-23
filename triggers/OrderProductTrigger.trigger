/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 10/26/2016
    @Purpose: This is trigger OrderItem events

    revision: Shirish 3/7/2017 9:43 pm : added befor eupdate event
*/
trigger OrderProductTrigger on OrderItem (before insert, after update) {

    if (Trigger.isAfter) {
        OrderProductTriggerHelper.onAfterUpdate(trigger.new, trigger.oldMap);
    } else if (Trigger.isBefore) {
        OrderProductTriggerHelper.onBeforeInsert(trigger.new, trigger.oldMap);
    }

}