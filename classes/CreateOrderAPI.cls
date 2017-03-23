/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 8/8/2016
    @Purpose: This is the CreateorderList api 
*/
@RestResource(urlMapping='/v10/CreateOrder/*')
global with sharing class CreateOrderAPI {

    @HttpPost
    global static CreateOrderResponse createOrder( Super_Order superOrder) {
        
      try {
          // check whether super order is sent in json or not
          if(superOrder!= null) {
            // object instantiate for Super Order
            SuperOrder__c sOrderRec = new SuperOrder__c(); 
            // variables to store various id values
            Id billToAccId, billToConId, shipToAccId, shipToConId, partnerChannelId, sourcingpartnerId;
            /* variables to check whether partner channel and sourcing partner exist or not,
               values defaults to false */
            Boolean partChnlMatchHelixId = false, srcPartMatchHelixId = false;
            // variable to store userid
            String userId; 
            // object variable to store existing contact details
            Contact existingContact;
            
            if(superOrder.partnerChannel == null || superOrder.partnerChannel == '') {
                CreateOrderResponse res = generateResponse('Partner Channel is required.','PARTNER CHANNEL IS REQUIRED.',null,'');
                return res;
            }
            /*Boolean duplicateSuperOrderExists = HMAPI_SFDC_IntegrationUtil.isDuplicateOrder(superOrder.partnerChannel, superOrder.partnerOrderNumber);
            if(duplicateSuperOrderExists) {
                CreateOrderResponse res = generateResponse('Duplicate Super Order exists.','DUPLICATE SUPER ORDER EXISTS.',null,'');
                return res;
            }*/
            
            Id helixPartnerAccId = HMAPI_SFDC_IntegrationUtil.getHelixPartnerAccId();
            // this map stores the account id of matching partner channel and sourcing partner Id
            partnerChannelId = HMAPI_SFDC_IntegrationUtil.getPartnerAccId(superOrder.partnerChannel);
            // check if partner channel exist
            if(partnerChannelId == null) {
                CreateOrderResponse res = generateResponse('Partner Account Invalid.','PARTNER ACCOUNT INVALID.',null,'');
                return res;
            } else {
                if(partnerChannelId == helixPartnerAccId) {
                    partChnlMatchHelixId = true;
                    srcPartMatchHelixId = true;
                }
                sourcingpartnerId = partnerChannelId;
            }
            
            // store orler list from json in a list variable
            List<HM_Order> orderList = superOrder.orderList;
            
            //get pricebook entries for the products
            Set<String> prodSet = HMAPI_SFDC_IntegrationUtil.getProdSet(orderList);
            Id pricebookId;
            if(Test.isRunningTest()) {
                pricebookId = Test.getStandardPricebookId();
            } else {
                pricebookId = [select id from Pricebook2 where isActive = true and isStandard = true Limit 1].Id;
            }
            Map<String, PricebookEntry> productIdToPricebkEntry = HMAPI_SFDC_IntegrationUtil.getMapPricebookEntry(prodSet, pricebookId);
            System.debug('productIdToPricebkEntry=====' + productIdToPricebkEntry);
            
            // ***VALIDATE*** existing partner records and whether json contains shipping address or not
            CreateOrderResponse resp = HMAPI_SFDC_IntegrationUtil.validateOrder(orderList, prodSet, productIdToPricebkEntry.keySet()); 
            if(resp != null && resp.error.message != null) {
                return resp;
            }
            // check whether billing Account is not null and fetch user id
            if(superOrder.billToAccount != null && superOrder.billToAccount.contact != null)
                userId = superOrder.billToAccount.contact.userId;
            System.debug('userId====' + userId);
            if(userId == null || userId == '') {
                // return error if user id does not exist
                CreateOrderResponse res = generateResponse(System.Label.User_Id_does_not_exist,System.Label.USER_NOT_FOUND,null,'');
                return res;
                
            } else {
                //When userId is not null, get Contact
                existingContact = HMAPI_SFDC_IntegrationUtil.getExistingContact(userId);
                if(existingContact != null) {
                    if(existingContact.Sourcing_Partner__c != null) {
                        if(existingContact.Sourcing_Partner__c == helixPartnerAccId)
                            srcPartMatchHelixId = true;
                        else
                            srcPartMatchHelixId = false;
                    } else {
                        existingContact.Sourcing_Partner__c = sourcingpartnerId;
                    }
                     
                    String addressType = HMAPI_SFDC_IntegrationUtil.getAddressFieldName('Billing');
                    String companyField = HMAPI_SFDC_IntegrationUtil.getCompanyFieldName('Billing');
                    HMAPI_SFDC_IntegrationUtil.mapAddressFieldsOnContact(existingContact, addressType, superOrder.billingAddress, companyField);
                        
                    //checking if the Contact is under Non-Buyer Account
                    if(existingContact.Account.NON_BUYER_Account__c == true) {
                       billToAccId = HMAPI_SFDC_IntegrationUtil.createNewAccount(superOrder.billToAccount);
                       existingContact.AccountId = billToAccId;
                       
                    } else if(!existingContact.Account.NON_BUYER_Account__c ) {
                        billToAccId = existingContact.AccountId;
                    } 
                    update existingContact;
                    billToConId = existingContact.id;
                    //added 11/29/2016 by Shirish Goel to create agreement for existing bill to contact per story: https://www.pivotaltracker.com/n/projects/1535405/stories/134735261
                     HMAPI_SFDC_IntegrationUtil.createAgreement(superOrder.billToAccount.contact, billToConId);
                } else {
                    // if user is not found, then create new account and contact    
                    billToAccId = HMAPI_SFDC_IntegrationUtil.createNewAccount(superOrder.billToAccount);
                    if(billToAccId != null)
                        billToConId = HMAPI_SFDC_IntegrationUtil.createNewContact(superOrder.billToAccount.contact, superOrder.billingAddress, 'Billing', billToAccId, sourcingpartnerId, superOrder.hasOptedOutOfEmail, partChnlMatchHelixId);
                }
            }
            // check for shipping account details and create new shipping account and contact if not already exists
            if(superOrder.shipToAccount != null){
                Contact shipToContact ;
                String shipUserId = superOrder.shipToAccount.contact.userId;
                if(shipUserId != null && shipUserId != '') {
                    shipToContact = HMAPI_SFDC_IntegrationUtil.getExistingContact(shipUserId);
                }
                if(shipToContact != null){
                    shipToConId = shipToContact.Id;
                    String addressType = HMAPI_SFDC_IntegrationUtil.getAddressFieldName('Shipping');
                    String companyField = HMAPI_SFDC_IntegrationUtil.getCompanyFieldName('Shipping');
                    HMAPI_SFDC_IntegrationUtil.mapAddressFieldsOnContact(shipToContact, addressType, superOrder.shippingAddress, companyField);
                    update shipToContact;
                }else{
                    shipToAccId = HMAPI_SFDC_IntegrationUtil.createNewAccount(superOrder.shipToAccount);
                    shipToConId = HMAPI_SFDC_IntegrationUtil.createNewContact(superOrder.shipToAccount.contact, superOrder.shippingAddress, 'Shipping', shipToAccId, null, superOrder.hasOptedOutOfEmail, partChnlMatchHelixId);
                }
            }
            
            
            /*  
               1. identify Kit_type_products
               2. call method from util class getKitProductList(productIdToPricebkEntry)
               3. orderIncludesKit = size of returned list > 1
               4. if orderIncludesKit then identify partnerShippingOption
               5. call method getPartnerShippingOption(partnerChannelId, superOrder.carrier, superOrder.shippingMethod)
               6. shipping_product_id = partnerShippingOption.Shipping_Product__c
               7. validCarrier&ShippingMethod = partnerShippingOption and shipping_product_id != null
               8. if validCarrier&ShippingMethod == false then return error "Invalid Shipping Method for this partner account"
               
            */
            
            Integer kitLinesCount = HMAPI_SFDC_IntegrationUtil.kitLinesCount(orderList, productIdToPricebkEntry);
            Partner_Shipping_Option__c partnerShippingOption;
            
            if(kitLinesCount > Integer.valueOf(System.Label.Number_of_Kits_permitted) ) {
                CreateOrderResponse res = generateResponse('No more than ' + System.Label.Number_of_Kits_permitted + ' kits permitted','NO MORE THAN ' + System.Label.Number_of_Kits_permitted + ' KITS PERMITTED',null,'');
                return res;
            } else if(kitLinesCount > 0) {
                if(superOrder.carrier == null || superOrder.carrier == '' || superOrder.shippingMethod == null ||
                                                                superOrder.shippingMethod == '') {
                    CreateOrderResponse res = generateResponse('Carrier or Shipping Method not found','CARRIER OR SHIPPING METHOD NOT FOUND',null,'');
                    return res;                                                    
                }
                
                partnerShippingOption = HMAPI_SFDC_IntegrationUtil.getPartnerShippingOption(partnerChannelId, 
                                                                        superOrder.carrier, superOrder.shippingMethod);
            
                if(partnerShippingOption == null || partnerShippingOption.Shipping_Product__c == null) {
                    CreateOrderResponse res = generateResponse('Invalid Shipping Method for this partner account','INVALID SHIPPING METHOD FOR THIS PARTNER ACCOUNT',null,'');
                    return res;
                }
                
                for(PricebookEntry  p :[SELECT Product2Id,Product2.name, UnitPrice, Product2.AppID__c, Product2.Minimum_Fee__c, 
                                Product2.Partner_Revenue_Share_PCT__c, Product2.Type__c, Id,ProductCode FROM PricebookEntry 
                                WHERE Product2Id = :partnerShippingOption.Shipping_Product__c AND  PriceBook2Id = :pricebookId]){
                    productIdToPricebkEntry.put(p.Productcode, p);     
                
                }
            }
            
            sOrderRec.Total_Amount_Charged__c = superOrder.totalAmountCharged;
            sOrderRec.Total_Tax__c = superOrder.totalTax;
            sOrderRec.transactionid__c = superOrder.transactionId;
            sOrderRec.Partner_Channel__c = partnerChannelId;
            sOrderRec.Stripe_Customer_ID__c = superOrder.stripeCustomerId;
            sOrderRec.Partner_Order_Number__c = superOrder.partnerOrderNumber;
            sOrderRec.PartnerChannelOrderNumber__c = superOrder.partnerChannel + '' + superOrder.partnerOrderNumber;
            if(superOrder.paymentCaptured != null)
                sOrderRec.Payment_Captured__c = superOrder.paymentCaptured;
            if(superOrder.gift!= null)
                sOrderRec.Gift__c = superOrder.gift;
            // insert super order record
            insert sOrderRec;
            
            /* create a list of order to be created
               Map and integer key is used to store the index of Order to map its id to Order Line
            */
            Map<Integer, Order> mapOrderList = HMAPI_SFDC_IntegrationUtil.createrOrderList(orderList, billToAccId, pricebookId, 
                                        partnerChannelId, superOrder, sOrderRec, billToConId, shipToConId, existingContact);
            insert mapOrderList.values();
            
            // pass list of Kit_type_products, partnerShippingOption as parameters
            // create a list of Order Line
            List<OrderItem> lineList = HMAPI_SFDC_IntegrationUtil.createOrderLineList(orderList, productIdToPricebkEntry, 
                                    mapOrderList, billToConId, shipToConId, srcPartMatchHelixId, partChnlMatchHelixId,
                                    partnerShippingOption, kitLinesCount, superOrder.totalTax);
            System.debug('lineList===' + lineList);
            update mapOrderList.values();
            insert lineList;
            
            //update invitation code as used once the order has been created successfully
            if(superOrder.shipToAccount != null)
                HMAPI_SFDC_IntegrationUtil.updateLead(superOrder.shipToAccount.contact.email);
            
            if(!superOrder.hasOptedOutOfEmail && partChnlMatchHelixId)
                EmailHelper.sendEmail(billToConId, sOrderRec.id);
            // return the details of created super order and Orders
            return HMAPI_SFDC_IntegrationUtil.success(mapOrderList.values(), sOrderRec);
        } else {
            // return error id super order is not found in json
            return generateResponse(System.Label.Super_Order_not_found,System.Label.SUPER_ORDER_NOT_FOUND_BOLD,null,'');
        }
      } catch(DmlException e){
           System.debug('The following exception has occurred: ' + e.getMessage());
           String errMsg = e.getMessage();
           if(errMsg.contains('duplicate value found')) {
               CreateOrderResponse res = generateResponse('Duplicate Super Order exists.','DUPLICATE SUPER ORDER EXISTS.',null,'');
               return res;
           }
           return generateResponse(e.getMessage(),'DML_ERROR',null,'');
       } catch(Exception e){
           System.debug('DmlException caught: ' + e.getMessage()); 
           System.debug('Error = '+e.getStackTraceString());
           return generateResponse(e.getMessage(),'ERROR_OCCURRED',null,'');
       }
       return null;
    }
    
    
    global static CreateOrderResponse generateResponse(String msg, String code, List<String> oIdList, String superOrderNum){
        CreateOrderResponse res = new CreateOrderResponse();
        if(oIdList != null && oIdList.size() > 0){
            res.orderNumberList = oIdList;
            
        }
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