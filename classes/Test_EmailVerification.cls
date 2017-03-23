/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 8/31/2016
    @Purpose: This is the Test Class for Email Verification api
*/

@isTest(SeeAllData=true)
  private class Test_EmailVerification {

  static {
    // setup test data  
  }

static testMethod void SendEmailTestMethod() {

   EmailVerificationRequest req = new EmailVerificationRequest();
   
   EmailVerificationResponse res = EmailVerification.sendVerificationEmail(req);
   
   req.email = 'testuser@yahoo.com';
   req.verificationLink = 'www.google.com';
   
   EmailVerificationResponse res2 = EmailVerification.sendVerificationEmail(req);
   
}
}