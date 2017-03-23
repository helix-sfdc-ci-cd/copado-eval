/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/18/2016
    @Purpose: This is the helper clas for Order trigger
*/
public class OrderTriggerHandler {
    
    //method called when after update event occurs on Order
    public static void onAfterUpdate(List<Order> orderList, Map<Id, Order> oldMap) {
        closeCaseOnRegistration(orderList, oldMap);
    }
    
    // method to close case when order is registered
    public static void closeCaseOnRegistration(List<Order> orderList, Map<Id, Order> oldMap) {
        Set<Id> orderIds = new Set<Id>();
        // create a set of ordered registered ids
        for(Order o : orderList){
            if(o.Registered_By__c  != oldmap.get(o.Id).Registered_By__c 
                    && o.Registered_By__c != null){
                orderIds.add(o.Id);     
            }
        }
        
        // query cases related to registered order Ids and update their status to Closed
        if(!orderIds.isEmpty()){
            List<Case> caseList = new List<Case>();
            for(Case c : [Select id, Order__c, Status from Case Where Order__c in : orderIds]){
                c.Status = 'Closed';
                caseList.add(c); 
            }
            try {
                if(caseList != null && caseList.size()>0)
                    update caseList;
            } catch(Exception e) {
                System.debug('-- Error Message --' + e.getMessage());
            }
        }
    }   
}