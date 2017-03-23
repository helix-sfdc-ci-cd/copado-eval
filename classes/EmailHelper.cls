public class EmailHelper {
    
    public static void sendEmail(ID recipient, Id superOrderId) {
        //New instance of a single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :System.Label.Order_Confirmation_Email_Address];
        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        if(recipient != null) {
            // Who you are sending the email to
            mail.setTargetObjectId(recipient);
            mail.setWhatId(superOrderId);
            EmailTemplate template = [select id from EmailTemplate where DeveloperName = 'Order_Confirmation_Email_Template' limit 1];
            // The email template ID used for the email
            mail.setTemplateId(template.id);
            mail.setReplyTo(System.Label.Order_Confirmation_Reply_To_Email);
            mail.setSaveAsActivity(false); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    } 
}