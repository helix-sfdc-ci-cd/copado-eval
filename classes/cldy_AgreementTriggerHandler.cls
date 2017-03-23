public class cldy_AgreementTriggerHandler {
    NumberToWord numberToWordCls = new NumberToWord();
    public void beforeUpdate(Map<Id, Apttus__APTS_Agreement__c> oldAgreementMap, Map<Id, Apttus__APTS_Agreement__c> newAgreementMap){
        for(Apttus__APTS_Agreement__c agreementRec : newAgreementMap.values()){
            if(agreementRec.Apttus__Total_Contract_Value__c != null && agreementRec.Apttus__Total_Contract_Value__c >0){
                Integer covertToLong = Integer.valueOf(agreementRec.Apttus__Total_Contract_Value__c.longValue());
                if(covertToLong != null){
                    if(string.valueOf(covertToLong).length() <= 10 ){
                        agreementRec.Cldy_Total_Agreement_Value_Word_Format__c = NumberToWord.convertNumberToWords(integer.valueOf(covertToLong));
                    }
                    else{
                        agreementRec.Cldy_Total_Agreement_Value_Word_Format__c = 'Number Range is too long to Convert';
                    }
                }
            }    
            if(agreementRec.APTS_Time_Material_Fee__c  != null && agreementRec.APTS_Time_Material_Fee__c > 0){
                Integer MeterialFeeLong = Integer.valueOf(agreementRec.APTS_Time_Material_Fee__c .longValue());
                if(MeterialFeeLong != null){
                    if(string.valueOf(MeterialFeeLong).length() <= 10 ){
                        agreementRec.APTS_Time_Material_Fee_Text__c = NumberToWord.convertNumberToWords(integer.valueOf(MeterialFeeLong));
                    }
                    else{
                        agreementRec.APTS_Time_Material_Fee_Text__c = 'Number Range is too long to Convert';
                    }
                }
            }
                
            if(agreementRec.APTS_Fixed_Fee__c != null && agreementRec.APTS_Fixed_Fee__c > 0){
                Integer fixedFeeLong = Integer.valueOf(agreementRec.APTS_Fixed_Fee__c.longValue());
                if(fixedFeeLong != null){
                    if(string.valueOf(fixedFeeLong).length() <= 10 ){
                        agreementRec.APTS_Fixed_Fee_Text__c = NumberToWord.convertNumberToWords(integer.valueOf(fixedFeeLong));
                    }
                    else{
                        agreementRec.APTS_Fixed_Fee_Text__c = 'Number Range is too long to Convert';
                    }
                }
            }
                
            if(agreementRec.APTS_Fixed_Fee_Installment_Amount__c != null && agreementRec.APTS_Fixed_Fee_Installment_Amount__c > 0){
                Integer FixedFeeInstallmentLong = Integer.valueOf(agreementRec.APTS_Fixed_Fee_Installment_Amount__c.longValue());
                if(FixedFeeInstallmentLong != null){
                    if(string.valueOf(FixedFeeInstallmentLong).length() <= 10 ){
                        agreementRec.APTS_Fixed_Fee_Installment_Text__c = NumberToWord.convertNumberToWords(integer.valueOf(FixedFeeInstallmentLong));
                    }
                    else{
                        agreementRec.APTS_Fixed_Fee_Installment_Text__c = 'Number Range is too long to Convert';
                    }
                }
            }
        //}
        }
    }
}