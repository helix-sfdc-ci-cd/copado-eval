/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 8/31/2016
    @Purpose: This is EmailVerification api to be invoked by Helix Marketplace for sending verification emails to users at the time of registration.
                input: EmailVerificationRequest 
                output: EmailVerificationResponse and an email sent out to the contact/user
*/
@RestResource(urlMapping='/EmailVerification/*')
global with sharing class EmailVerification {

@HttpPost
global static EmailVerificationResponse sendVerificationEmail( EmailVerificationRequest emailVerificationRequest) {
    try{
       
       if (emailVerificationRequest != null){
            
            //send email
            //get email template
            EmailTemplate et = [select id, htmlvalue,body from EmailTemplate where developername = 'Email_Verification' limit 1];
             
            //get org wide email address id
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :System.Label.Order_Confirmation_Email_Address];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {emailVerificationRequest.email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Verify your email address');
            if(owea != null && owea.size() > 0)
                mail.setOrgWideEmailAddressId(owea[0].id);
            mail.setReplyTo(System.Label.Order_Confirmation_Reply_To_Email);
            String htmlBody = et.HtmlValue;
            String plainBody = et.Body;
            htmlBody = htmlBody.replace('{!link}',emailVerificationRequest.verificationLink);
            plainBody = plainBody.replace('{!link}',emailVerificationRequest.verificationLink);
            
            mail.setHtmlBody(htmlBody);
            mail.setPlainTextBody(plainBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            EmailVerificationResponse res = generateResponse(null, null, true);
            return res;
         }
    
    }
      catch(Exception e){
         EmailVerificationResponse res = generateResponse(e.getmessage(), 'ERROR_OCCURRED', false);
         return res;
      }
      
    return null;
   }
   
    global static EmailVerificationResponse generateResponse(String msg, String code, Boolean success){
        EmailVerificationResponse res = new EmailVerificationResponse();
        res.success = success;
        if(msg != null){
            HMAPIError error = new HMAPIError();
            error.message = msg;
            error.errorCode = code;
            res.error = error;
        }
        return res;
    }
    

}