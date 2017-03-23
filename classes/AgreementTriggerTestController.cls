@isTest
private class AgreementTriggerTestController {
	private static testMethod void numberToWordTestMethod() {
	    
	    String accountHelixB2BRecordtype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Helix B2B Account').getRecordTypeId();
	    
	    Account accRec = new Account();
	    accRec.Name = 'Test Account For Agreement NumberToWord';
        accRec.RecordTypeId = accountHelixB2BRecordtype;
        insert accRec;
        
        String agreementRecordType = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Consulting Agreement').getRecordTypeId();
        Apttus__APTS_Agreement__c agreementRec = new Apttus__APTS_Agreement__c();
        agreementRec.Name = 'Consulting Agreement';
        agreementRec.Apttus__Account__c = accRec.Id;
        agreementRec.APTS_Scope_of_Services__c = 'Test Class Scope';
        agreementRec.Apttus__Total_Contract_Value__c = 99999.99;
        agreementRec.APTS_Time_Material_Fee__c = 99999.99;
        agreementRec.APTS_Fixed_Fee__c = 99999.99;
        agreementRec.APTS_Fixed_Fee_Installment_Amount__c = 99999.99;
        agreementRec.Apttus__Total_Contract_Value__c = 99999.99;
        insert agreementRec;
        
        agreementRec.Apttus__Total_Contract_Value__c = 999999999999999.99;
        agreementRec.APTS_Time_Material_Fee__c = 999999999999999.99;
        agreementRec.APTS_Fixed_Fee__c = 999999999999999.99;
        agreementRec.APTS_Fixed_Fee_Installment_Amount__c = 999999999999999.99;
        agreementRec.Apttus__Total_Contract_Value__c = 999999999999999.99;
        update agreementRec;
        
	}
}