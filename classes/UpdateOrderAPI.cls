/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 10/26/2016
    @Purpose: This is the update super order api 
*/
@RestResource(urlMapping='/v10/UpdateOrder/*')
global with sharing class UpdateOrderAPI {

    @HttpPost
    global static UpdateOrderResponse updateOrder(String superOrderNumber, Super_Order superOrder) {
        
      try {
          List<SuperOrder__c> soList = [select id, (select id from Orders__r) from SuperOrder__c where Name = :superOrderNumber];
          
          SuperOrder__c so = new SuperOrder__c();
          List<Order> orderList = new List<Order>();
          if(soList != null && soList.size() > 0) {
              so = soList[0];
              if(superOrder.orderList == null){
                 for(Order o :so.Orders__r) {
                     o.TransactionId__c = superOrder.transactionId;
                    // o.LDT__c = superOrder.
                     //o.LDT_Approved__c = 
                     orderList.add(o);
                 }
              }else{
                  //List of Order Numbers from the HM Order list of the Super Order
                  List<String> orderNumberList = new List<String>();
                  for(HM_Order hmo : superOrder.orderList){
                     if((hmo.orderNumber == null || hmo.orderNumber == '') && hmo.ldt != null && hmo.ldtApproved != null){
                        return generateResponse('Please provide Order Number to update LDT information.', 'ORDER_NUMBER_NOT_FOUND', '', '');
                     }
                     orderNumberList.add(hmo.orderNumber);
                  }
                  
                  //Map of helix Order Number and the corresponding Order Record
                  Map<String, Order> ordNumToOrdMap = new Map<String, Order>();
                  
                  //populating this map
                  for(Order o :[ Select Id, LDT__c, LDT_Approved__c, Helix_Order_Number__c From Order Where Helix_Order_Number__c In :orderNumberList ]){
                     ordNumToOrdMap.put(o.Helix_Order_Number__c, o);
                  }
                  
                  //mapping values of LDT and LDTApproved
                  for(HM_Order hmo : superOrder.orderList){
                     if(ordNumToOrdMap.containsKey(hmo.orderNumber)){
                        Order temp = ordNumToOrdMap.get(hmo.orderNumber);
                        if(hmo.ldt != null)
                            temp.LDT__c = hmo.ldt;
                        if(hmo.ldtApproved != null)
                            temp.LDT_Approved__c = hmo.ldtApproved;
                        temp.TransactionId__c = superOrder.transactionId;
                        orderList.add(temp);
                     }
                  }
              }
          } else {
              return generateResponse('Super Order not found', 'SUPER_ORDER_NOT_FOUND', superOrderNumber, '');
          }
          
          so.TransactionId__c = superOrder.transactionId;
          so.Payment_Captured__c = superOrder.paymentCaptured;
          if(superOrder.gift != null){
              so.Gift__c = superOrder.gift;
          }      
          update so;
          if(orderList != null && orderList.size() > 0)
              update orderList;
              
          return generateResponse('','',superOrderNumber, 'SUCCESSFULLY_UPDATED_ORDER');
      } catch(Exception e) {
          return generateResponse(e.getMessage(),'ERROR_OCCURRED','', '');
      }
      return null;
    }
    
    global static UpdateOrderResponse generateResponse(String msg, String code, String superOrderNum, String successMessage){
        UpdateOrderResponse res = new UpdateOrderResponse();
        
        res.successMessage = successMessage;
        res.superOrderNumber = superOrderNum;
        
        if(msg != null){
            HMAPIError error = new HMAPIError();
            error.message = msg;
            error.errorCode = code;
            res.error = error;
        }
        return res;
    }
}