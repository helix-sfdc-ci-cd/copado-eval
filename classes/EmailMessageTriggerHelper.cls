/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 9/13/2016
    @Purpose: This is a helper class for EmailMessage Triggers. 
*/
public class EmailMessageTriggerHelper {
    
    // this method is executed on after insert event of EmailMessage
    public static void onAfterInsert(List<EmailMessage> msgList) {
        updateCase(msgList);
    }
    
    // this method is used to populate last activity date on case object when any email message is sent
    public static void updateCase(List<EmailMessage> msgList) {
        List<Case> caseListToUpdate = new List<Case>();
        
        for(EmailMessage msg : msgList) {
            // checking if parent record is of case object
            if(msg.ParentId != null && String.valueOf(msg.ParentId).startswith('500')) {
                caseListToUpdate.add(new Case(
                                    id = msg.ParentId,
                                    Last_Activity_Date__c = System.now()));
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
}