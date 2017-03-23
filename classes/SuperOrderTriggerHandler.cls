public class SuperOrderTriggerHandler {
    
    public static void onAfterUpdate(List<SuperOrder__c> soList, Map<Id, SuperOrder__c> soMap) {
        sendEmailNotification(soList, soMap);
    }
    
    public static void sendEmailNotification(List<SuperOrder__c> soList, Map<Id, SuperOrder__c> soMap) {
        Set<Id> soIds = new Set<Id>();
        for(SuperOrder__c so :soList) {
            SuperOrder__c soOld = soMap.get(so.id);
            if(so.Fully_Shipped__c && !soOld.Fully_Shipped__c) {
                soIds.add(so.id);
            }
        }
        if(soIds.size() > 0)
            KitShippedEmailNotificationSPI.kitShippedEmailNotification(soIds);
    }
}