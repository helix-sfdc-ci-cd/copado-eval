/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 9/13/2016
    @Purpose: This is a helper class for Task Triggers.
*/
public class TaskTriggerHelper {
    
    // this method is executed on after insert event of task
    public static void onAfterInsert(List<Task> tskList) {
        updateCase(tskList, null);
    }
    
    // this method is executed on after update event of task
    public static void onAfterUpdate(List<Task> tskList, Map<Id, Task> oldMap) {
        updateCase(tskList, oldMap);
    }
    
    /*  This method is used to populate last activity date on case object when: 
        1. Task is created 
        2. Task status is updated
    */
    public static void updateCase(List<Task> tskList, Map<Id, Task> oldMap) {
        List<Case> caseListToUpdate = new List<Case>();
        for(Task tsk : tskList) {
            // checking if parent record is of case object
            if(tsk.WhatId != null && String.valueOf(tsk.WhatId).startswith('500')) {
                if(Trigger.isUpdate){
                    Task tskOld = oldMap.get(tsk.id);
                    if(tsk.Status != tskOld.Status) {
                        addCaseToUpdateList(caseListToUpdate, tsk.WhatId);
                    }
                } else {
                    addCaseToUpdateList(caseListToUpdate, tsk.WhatId);
                }
            }
        }
        
        // update case list
        try {
            if(caseListToUpdate != null && caseListToUpdate.size() > 0) {
                update caseListToUpdate;
            }
        } catch (Exception e) {
            System.debug('=== ERROR MESSAGE ===' + e.getMessage());
        }
    }
    
    public static void addCaseToUpdateList(List<Case> caseListToUpdate, Id caseId) {
        
        caseListToUpdate.add(new Case(
                                id = caseId,
                                Last_Activity_Date__c = System.now()));
    }
}