/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/18/2016
    @Purpose: This is the helper clas for Case trigger
*/
public class CaseTriggerHandler {
    
    //method called when before update event occurs on Case
    public static void onBeforeUpdate(List<Case> caseList, Map<Id, Case> oldMap) {
        reOpenCase(caseList, oldMap);
    }
    
    // method to repoen the closed case if Order is not registered yet
    public static void reOpenCase(List<Case> caseList, Map<Id, Case> oldMap) {
        // map of Case id as key and Order id as value
        Map<Id, Id> caseIdOrderMap = new Map<Id, Id>();
        
        /* Conditions:
          1. Trigger Check is checked from false to true
          2. Status of Case is Closed
          3. Order is not null
          Action: create a map of case and order id
        */
        for(Case c :caseList){
            
            if(c.Check_Order_Registration__c && c.Check_Order_Registration__c != oldmap.get(c.Id).Check_Order_Registration__c 
                && c.Status != null && c.Status.equals('Closed') && c.Order__c != null){
                caseIdOrderMap.put(c.Id, c.Order__c );
            }
        }
        
        if(!caseIdOrderMap.isEmpty()){
            Set<Id> orderIds = new Set<Id>();
            // query orders and create a set of order ids which are not registered
            for(Order o : [Select id , Registered_By__c from Order Where Id in : caseIdOrderMap.values() ]){
                if(o.Registered_By__c == null)
                    orderIds.add(o.Id);     
            }    
            // update case status to New if order is not registered
            for(Case c :caseList){    
                if(orderIds != null && orderIds.contains(c.Order__c)){
                     c.Status = 'New';
                 }
            }
        }
    }
}