/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 12/6/2016
    @Purpose: This api is used to set order confirmation sent checkbox on Order
*/
@RestResource(urlMapping='/v10/SetOrderConfirmation/*')
global with sharing class SetOrderConfirmation {

    @HttpPost
    global static SetOrderConfirmationResponse setOrderConfirmation(List<HM_Order> hmOrderList) {
        
      try {
      
          Set<String> orderNumberSet = new Set<String>();
          Map<String,Boolean> orderMap = new Map<String,Boolean>();
          if(hmOrderList != null) {
              for(HM_Order ord :hmOrderList) {
                  if(ord != null && ord.shippingConfirmationSent != null ) {
                      if(ord.orderNumber == null || ord.orderNumber == '') {
                          return generateResponse('Order Number can not be blank', 'ORDER_NUMBER_CAN_NOT_BE_BLANK', null, '');
                      } else {
                          orderNumberSet.add(ord.orderNumber);
                          orderMap.put(ord.orderNumber,ord.shippingConfirmationSent);
                      }
                  }
              }
          }
          
          List<Order> orderList = [select id, Helix_Order_Number__c from Order 
                                              where Helix_Order_Number__c = :orderNumberSet];
          
          Set<String> existingOrdNumSet = new Set<String>();
          List<String> orderNotFoundList = new List<String>();
          if(orderList != null && orderList.size() > 0) {
              for(Order o :orderList) {
                  existingOrdNumSet.add(o.Helix_Order_Number__c);
                  if(orderNumberSet != null && orderNumberSet.contains(o.Helix_Order_Number__c)) {
                      o.Shipping_Confirmation_Sent__c = orderMap.get(o.Helix_Order_Number__c);
                  }
              }
          }
          
          for(String ordNum :orderNumberSet) {
              if(!existingOrdNumSet.contains(ordNum)) {
                  orderNotFoundList.add(ordNum);
              }
          }
          
          if(orderNotFoundList != null && orderNotFoundList.size() > 0)
              return generateResponse('Order not found', 'ORDER_NOT_FOUND', orderNotFoundList, '');
          
          if(orderList != null && orderList.size() > 0)
              update orderList;
          
          return generateResponse('','',null, 'SUCCESSFULLY_UPDATED_ORDER');
      } catch(Exception e) {
          System.debug('-------' + e.getStackTraceString());
          return generateResponse(e.getMessage(),'ERROR_OCCURRED',null, '');
      }
      return null;
    }
    
    global static SetOrderConfirmationResponse generateResponse(String msg, String code, List<String> orderNotFoundList, String successMessage){
        SetOrderConfirmationResponse res = new SetOrderConfirmationResponse();
        
        res.successMessage = successMessage;
        res.orderNotFoundList = orderNotFoundList;
        
        if(msg != null){
            HMAPIError error = new HMAPIError();
            error.message = msg;
            error.errorCode = code;
            res.error = error;
        }
        return res;
    }
}