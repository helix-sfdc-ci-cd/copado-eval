@isTest
public with sharing class Cldy_DocuSignEnvRecpStatTriggerTest {
    static testMethod void forNDAMultiParty(){
    	
    	Account acc = new Account();
        acc.name='Test Account';
        acc.AccountNumber = '26545215';
        insert acc;
        
	    Contact con =  new Contact();
	    con.AccountId = acc.Id;
	    con.LastName = 'Test';
	    insert con;	  
	    
	    Apttus__APTS_Agreement__c agreement =  new Apttus__APTS_Agreement__c();
	   	agreement.Apttus__Account__c = acc.id;
	   	agreement.Name = 'SA';
	  	agreement.Apttus__Company_Signed_By__c = con.id;
	   	insert agreement;	
	   	
	    Apttus_DocuApi__DocuSignEnvelope__c signEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c ();
    	signEnvelope.name = 'Test';
    	signEnvelope.Apttus_DocuApi__EmailSubject__c = '';
    	//signEnvelope.Apttus_CMDSign__Agreement__c = agmt2.id;
    	insert signEnvelope;
    	
    	agreement.Apttus__Agreement_Category__c = 'Multi-Party';
        agreement.Apttus_CMDSign__DocuSignEnvelopeId__c = signEnvelope.id;
        update agreement;
    	
    	
    	List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> statusList = new List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>();
         for(Integer i=1;i<4;i++){            
            Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c statusRec = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c(Apttus_DocuApi__DocuSignEnvelopeId__c = signEnvelope.id,
                                                                        Apttus_DocuApi__Email__c =  'test@test.com', Apttus_DocuApi__SignedDateTime__c = Date.newInstance(2016, 10, 11),
                                                                        Apttus_DocuApi__Status__c = 'completed', Apttus_DocuApi__RecipientName__c = 'Test Name', Apttus_DocuApi__RoutingOrder__c = string.valueOf(i));
           statusList.add(statusRec);
        }
        insert statusList; 	
       	
    	//Cldy_DocuSignEnvRecpStatTriggerHandler handler = new Cldy_DocuSignEnvRecpStatTriggerHandler();
    	//handler.handleAfterInsertEvents(statusList);
    }
}