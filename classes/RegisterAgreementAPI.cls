/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 5/30/2016
    @Purpose: This is the Register Legal Agreement api
*/
@RestResource(urlMapping='/v10/RegisterAgreements/*')
global with sharing class RegisterAgreementAPI{   
    
@HttpPost
global static RegisterAgreementResponse registerAgreement( HM_Contact hmContact) {
    try{
        Contact contact;
        String userId = hmContact.userId;
        if(userId == null || userId == ''){
            //return error
            RegisterAgreementResponse res = generateResponse('User Id is null. Please send a userId to register agreement.','MISSING_USER_ID',false);
            return res;
        }else{
            //When userId is not null, get Contact
            contact = HMAPI_SFDC_IntegrationUtil.getExistingContact(userId);
            
            if(contact != null ){
                //Create Legal Agreement record for the contact
                HMAPI_SFDC_IntegrationUtil.createAgreement(hmContact, contact.Id);
                
                RegisterAgreementResponse response = generateResponse(null,null,true);
                return response;
            }else{
            //return error
                RegisterAgreementResponse response = generateResponse('Contact does not exist with this user Id','CONTACT_NOT_FOUND',false);
                return response;            }
        }
        
//        GetAppsOwnedByUserResponse res = generateResponse(null, null, appid, state, ctturl);
 //       return res;
    }catch(DMLException d){
         //System.debug('DmlException caught: ' + e.getMessage()); 
         RegisterAgreementResponse response = generateResponse(d.getDMLMessage(0),'DML_ERROR',false);
         return response;
      }catch(Exception e){
         //System.debug('DmlException caught: ' + e.getMessage()); 
         RegisterAgreementResponse response = generateResponse(e.getMessage(),'ERROR_OCCURRED',false);
         return response;
      }
    return null;
}
    global static RegisterAgreementResponse generateResponse(String msg, String code, Boolean registered){
        RegisterAgreementResponse res = new RegisterAgreementResponse();
        res.isAgreementRegistered = registered;
        if(msg != null){
            HMAPIError error = new HMAPIError();
            error.message = msg;
            error.errorCode = code;
            res.error = error;
        }
        return res;
    }
    
}