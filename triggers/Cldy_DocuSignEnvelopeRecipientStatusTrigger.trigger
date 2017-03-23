trigger Cldy_DocuSignEnvelopeRecipientStatusTrigger on Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c (after insert) {
    Cldy_DocuSignEnvRecpStatTriggerHandler  handler = new Cldy_DocuSignEnvRecpStatTriggerHandler();
     if(Trigger.isInsert && Trigger.isAfter)
    {
        handler.handleAfterInsertEvents(Trigger.New);
    }
}