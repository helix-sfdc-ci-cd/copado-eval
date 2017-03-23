trigger cldy_AgreementTrigger on Apttus__APTS_Agreement__c (before update) {
    cldy_AgreementTriggerHandler triggerHandler = new cldy_AgreementTriggerHandler();
    if(trigger.isupdate && trigger.isbefore){
        triggerHandler.beforeUpdate(trigger.oldmap, trigger.newmap);
    }
}