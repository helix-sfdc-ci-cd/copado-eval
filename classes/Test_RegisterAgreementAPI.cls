@isTest 
private class Test_RegisterAgreementAPI {

   static testMethod void unitTestMethod() {
      
      //Creating HM_Agreement
      HM_Agreement agreement1 = new HM_Agreement();
      agreement1.key = 'key1' ;
      agreement1.version = 'Ver1' ;
      agreement1.appid = 'app1' ;
      agreement1.agreed = true ;
      HM_Agreement agreement2 = new HM_Agreement();
      agreement2.key = 'key2' ;
      agreement2.version = 'Ver2' ;
      agreement2.appid = 'app2' ;
      agreement2.agreed = false ;
      
      List<HM_Agreement> agreements = new List<HM_Agreement>();
      agreements.add(agreement1);
      agreements.add(agreement2);
      
      HM_Contact hmCon = new HM_Contact();
      hmCon.firstName = 'fName';
      hmCon.lastName = 'lName';
      hmCon.email = 'fName@lName.com';
      hmCon.userId = '';
      hmCon.phone = '9902944899';
      hmCon.biologicalSex = 'Male';
      hmCon.blackNaturally = 'Yes';
      hmCon.agreements = agreements;
      
      RegisterAgreementResponse result = RegisterAgreementAPI.registerAgreement(hmCon);
      System.assertEquals('User Id is null. Please send a userId to register agreement.', result.error.message);
      
      Account acc = new Account(Name = 'Test Acc');
      insert acc;
      
      List<Contact> conList = new List<Contact>();
      // creating first contact
      Contact con1 = new Contact(LastName = 'Test Con', AccountId = acc.Id);
      conList.add(con1);
      // creating second contact
      Contact con2 = new Contact(LastName = 'Test Con', AccountId = acc.Id);
      conList.add(con2);
      insert conList;
      
      hmCon.userId = 'abcd';
      
      RegisterAgreementResponse result2 = RegisterAgreementAPI.registerAgreement(hmCon);
      System.assertEquals('Contact does not exist with this user Id', result2.error.message);
      
      // associating user with first contact
      con1.userId__c = 'abcd';
      update con1;
      
      RegisterAgreementResponse result3 = RegisterAgreementAPI.registerAgreement(hmCon);
      
      List<Legal_Agreement__c> agreeList = [select id, Contact__c, version__c , key__c, appId__c, agreed__c from Legal_Agreement__c];
      // 2 records of agreement created with different keys so legal agreement count should be 2
      System.assertEquals(2, agreeList.size());
      
      // both agreement related to first contact
      System.assertEquals(con1.id, agreeList[0].Contact__c);  
      System.assertEquals(con1.id, agreeList[1].Contact__c);
      
      // version, key and appid mapping assertion
      System.assertEquals('Ver1', agreeList[0].version__c);
      System.assertEquals('Ver2', agreeList[1].version__c);
      System.assertEquals('key1', agreeList[0].key__c);
      System.assertEquals('key2', agreeList[1].key__c);
      System.assertEquals('app1', agreeList[0].appId__c);
      System.assertEquals('app2', agreeList[1].appId__c);
      System.assertEquals(true, agreeList[0].agreed__c);
      System.assertEquals(false, agreeList[1].agreed__c);
      
      // creating third aggrement with existing key, version, appid, agreed values
      HM_Agreement agreement3 = new HM_Agreement();
      agreement3.key = 'key1' ;
      agreement3.version = 'Ver1' ;
      agreement3.appid = 'app1' ;
      agreement3.agreed = true ;
      agreements = new List<HM_Agreement>();
      agreements.add(agreement3);
      
      hmCon = new HM_Contact();
      hmCon.firstName = 'fName';
      hmCon.lastName = 'lName';
      hmCon.email = 'fName@lName.com';
      hmCon.userId = 'abcd';
      hmCon.phone = '9902944899';
      hmCon.biologicalSex = 'Male';
      hmCon.blackNaturally = 'Yes';
      hmCon.agreements = agreements;
      
      RegisterAgreementResponse result4 = RegisterAgreementAPI.registerAgreement(hmCon);
      
      agreeList = [select id from Legal_Agreement__c where Contact__c = :con1.id];
      // agreement count increased to 3
      System.assertEquals(3, agreeList.size());
      
      // creating agreement for another user with id 'xyzw' and different key combination
      HM_Agreement agreement4 = new HM_Agreement();
      agreement4.key = 'key4' ;
      agreement4.version = 'Ver4' ;
      agreement4.appid = 'app4' ;
      agreement4.agreed = false ;
      agreements = new List<HM_Agreement>();
      agreements.add(agreement4);
      
      hmCon = new HM_Contact();
      hmCon.firstName = 'fName';
      hmCon.lastName = 'lName';
      hmCon.email = 'fName@lName.com';
      hmCon.userId = 'xyzw';
      hmCon.phone = '9902944899';
      hmCon.biologicalSex = 'Male';
      hmCon.blackNaturally = 'Yes';
      hmCon.agreements = agreements;
      
      // associating user with second contact
      con2.userId__c = 'xyzw';
      update con2;
      
      RegisterAgreementResponse result5 = RegisterAgreementAPI.registerAgreement(hmCon);
      
      agreeList = [select id, Contact__c, version__c , key__c, appId__c, agreed__c from Legal_Agreement__c];
      // new agreement created and total count increased to 3
      System.assertEquals(4, agreeList.size());
      
      // agreement related to second contact
      System.assertEquals(con2.id, agreeList[3].Contact__c);
      
      // version, key and appid mapping assertion
      System.assertEquals('Ver4', agreeList[3].version__c);
      System.assertEquals('key4', agreeList[3].key__c);
      System.assertEquals('app4', agreeList[3].appId__c);
      System.assertEquals(false, agreeList[3].agreed__c);
   }
}