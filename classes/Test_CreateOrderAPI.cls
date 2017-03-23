@isTest
public class Test_CreateOrderAPI {
    
    static testMethod void superOrderBlankTestMethod() {
        Super_Order spOrder;
        createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
        System.assertEquals('Super Order not found.', result.error.message);
    }
    
    static testMethod void partnerChannelRequiredTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       spOrder.partnerChannel = '';
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       System.assertEquals('Partner Channel is required.', result.error.message);
    }
    
    static testMethod void partnerAccountInvalidTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       spOrder.partnerChannel = '12346';
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       System.assertEquals('Partner Account Invalid.', result.error.message);
    }
    
    static testMethod void userIdNotExistTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       spOrder.billToAccount.contact.userId = '';
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       System.assertEquals(System.Label.User_Id_does_not_exist, result.error.message);
    }
    
    static testMethod void invalidShippingMethodTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       spOrder.shippingMethod = 'overnight';
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       System.assertEquals('Invalid Shipping Method for this partner account', result.error.message);
    }
    
    static testMethod void productNotAvailableTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       spOrder.orderList[0].lines[0].sku = 'Test';
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       System.assertEquals('Product Not Available', result.error.message);
    }
    
    static testMethod void qtyNotMoreThan1TestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       spOrder.orderList[0].lines[0].quantity = 2;
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       System.assertEquals('Quantity should not be more than 1', result.error.message);
    }
    
    static testMethod void duplicateCheckTestMethod() {
       Super_Order spOrder = getSuperOrder();
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       
       List<SuperOrder__c> soList = [select id from SuperOrder__c];
       System.assertEquals(1, soList.size());
       
       spOrder = getSuperOrder();
       result = CreateOrderAPI.createOrder(spOrder);
       
       System.assertEquals('Duplicate Super Order exists.', result.error.message);
       
       soList = [select id from SuperOrder__c];
       System.assertEquals(1, soList.size());
    }
    
    static testmethod void orderController() {
       Super_Order spOrder = getSuperOrder();
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       
       List<SuperOrder__c> soList = [select id from SuperOrder__c];
       System.assertEquals(1, soList.size());
       
       OrderController ctrl = new OrderController();
       ctrl.soId = soList[0].id;
       ctrl.getSuperOrder();
       ctrl.getOrderDetails();
        
    }
    
    static testMethod void amountAndTaxOnSOTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       spOrder.totalAmountCharged = 100;
       spOrder.totalTax = 20;
       spOrder.paymentCaptured = true;
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       SuperOrder__c so = [select Total_Amount_Charged__c, Total_Tax__c, Payment_Captured__c from SuperOrder__c limit 1];
       System.assertEquals(100, so.Total_Amount_Charged__c);
       System.assertEquals(20, so.Total_Tax__c);
       System.assertEquals(true, so.Payment_Captured__c);
    }
    
    static testMethod void transactionAndPartnerChannelOnSOTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       spOrder.transactionId = '2345';
       
       String partnerChannelId  = HMAPI_SFDC_IntegrationUtil.getPartnerAccId(spOrder.partnerChannel);
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       SuperOrder__c so = [select Transactionid__c, Partner_Channel__c from SuperOrder__c limit 1];
       System.assertEquals('2345', so.Transactionid__c);
       System.assertEquals(partnerChannelId, so.Partner_Channel__c);
       
    }
    
    static testMethod void agreedDateTimeTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       spOrder.billToAccount.contact.userId = '121212';
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       Legal_Agreement__c la = [select agreedDateTime__c from Legal_Agreement__c where agreedDateTime__c != null limit 1];
       DateTime estimatedDate = DateTime.newInstance(2016, 11, 11, 6, 6, 0);
       System.assertEquals(estimatedDate, la.agreedDateTime__c);
    }
    
    static testMethod void numberOfKitsCheckTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       
       HM_OrderLine orderLine = new HM_OrderLine();
       orderLine.quantity = 1;
       orderLine.sku = '4172';
       
       List<HM_OrderLine> lineList = new List<HM_OrderLine>();
       
       Integer numberOfOrderLines = 21;
       for(Integer i = 0; i < numberOfOrderLines; i ++) {
           lineList.add(orderLine);
       }
       
       // there are 2 product lines in first order
       System.assertEquals(2, spOrder.orderList[0].lines.size());
       // one of them is app product line
       System.assertEquals('APP-001', spOrder.orderList[0].lines[0].sku);
       // another one of them is kit product line
       System.assertEquals('4172', spOrder.orderList[0].lines[1].sku);
       // adding 21 more kit lines to this order
       spOrder.orderList[0].lines.addAll(lineList);
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       System.assertEquals('No more than 20 kits permitted', result.error.message);
    }
    
    static testMethod void multipleOrderAndLineCreationTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       SuperOrder__c so = [select id from SuperOrder__c limit 1];
       List<Order> oList = [select SuperOrder__c from Order where SuperOrder__c = :so.id];
       
       System.assertEquals(2, oList.size());
       System.assertEquals(so.id, oList[0].SuperOrder__c);
       System.assertEquals(so.id, oList[1].SuperOrder__c);
       
       List<OrderItem> olineList = [select OrderId, PricebookEntry.Product2.ProductCode from OrderItem where Order.SuperOrder__c = :so.id];
       
       // total number of order line created for superorder
       System.assertEquals(14, olineList.size());
       
       olineList = [select id from OrderItem where OrderId = :oList[0].id];
       // total number orderlines created for each order
       System.assertEquals(7, olineList.size());
       
       olineList = [select id from OrderItem where OrderId = :oList[1].id];
       // total number orderlines created for each order
       System.assertEquals(7, olineList.size());
    }
    
    static testMethod void productLineCreatedTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       SuperOrder__c so = [select id from SuperOrder__c limit 1];
       List<Order> oList = [select SuperOrder__c from Order where SuperOrder__c = :so.id];
       
       List<OrderItem> olineList = [select OrderId, PricebookEntry.Product2.Type__c, PricebookEntry.Product2.ProductCode, UnitPrice, Carrier__c, Service_Level__c from OrderItem where OrderId = :oList[1].id];
       System.assertEquals(7, olineList.size());
       
       for(OrderItem oi :olineList) {
           if(oi.PricebookEntry.Product2.Type__c != null && oi.PricebookEntry.Product2.Type__c.equals('KIT')) {
               System.assert(true);
           }
           if(oi.PricebookEntry.Product2.Type__c != null && oi.PricebookEntry.Product2.Type__c.equals('APP')) {
               System.assert(true);
           }
           if(oi.PricebookEntry.Product2.ProductCode == System.Label.Helix_Sequence_Revenue) {
               System.assert(true);
           }
           if(oi.PricebookEntry.Product2.ProductCode == System.Label.Helix_Referral_Fee) {
               System.assert(true);
           }
           if(oi.PricebookEntry.Product2.ProductCode == System.Label.Partner_Revenue_Share) {
               System.assert(true);
           }
           if(oi.PricebookEntry.Product2.ProductCode == 'Shipping Product') {
               System.assert(true);
           }
       }
    }
    
    
    static testMethod void unitPriceCalculationTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       SuperOrder__c so = [select id from SuperOrder__c limit 1];
       List<Order> oList = [select SuperOrder__c from Order where SuperOrder__c = :so.id];
       
       List<OrderItem> olineList = [select OrderId, PricebookEntry.Product2.Type__c, PricebookEntry.Product2.ProductCode, UnitPrice, Carrier__c, Service_Level__c from OrderItem where OrderId = :oList[1].id];
       System.assertEquals(7, olineList.size());
       
       for(OrderItem oi :olineList) {
           
           if(oi.PricebookEntry.Product2.Type__c != null && oi.PricebookEntry.Product2.Type__c.equals('KIT')) {
               // check whether carrier and shipping method is updated on kit line
               System.assertEquals(spOrder.carrier, oi.Carrier__c);
               System.assertEquals(spOrder.shippingMethod, oi.Service_Level__c);
               System.assertEquals(2000, oi.UnitPrice);
           
           } else if(oi.PricebookEntry.Product2.Type__c != null && oi.PricebookEntry.Product2.Type__c.equals('APP')) {
               System.assertEquals(1000, oi.UnitPrice);
           
           } else if(oi.PricebookEntry.Product2.ProductCode == System.Label.Helix_Sequence_Revenue) {
               // unit price = appPbe.Product2.Minimum_Fee = 250
               System.assertEquals(250, oi.UnitPrice); 
           
           } else if(oi.PricebookEntry.Product2.ProductCode == System.Label.Helix_Referral_Fee) {
               /*  
                   appPrice = appUnitPrice - appPbe.Product2.Minimum_Fee__c;
                            = 1000 - 250 = 750
                   ReferalFeeUnitPrice = appPrice -  (appPrice * appPbe.Product2.Partner_Revenue_Share_PCT__c/100);
                                       = 750 - (750 * 20/100)
                                       = 750 - 150
                   ReferalFeeUnitPrice = 600
               */
               System.assertEquals(600, oi.UnitPrice); 
          
           } else if(oi.PricebookEntry.Product2.ProductCode == System.Label.Partner_Revenue_Share) {
               /*  
                   appPrice = appUnitPrice - appPbe.Product2.Minimum_Fee__c;
                            = 1000 - 250 = 750
                   partnerRevenueUnitPrice = appPrice * appPbe.Product2.Partner_Revenue_Share_PCT__c/100;
                                       = 750 * 20/100
                                       = 150
                   partnerRevenueUnitPrice = 150
               */
               System.assertEquals(150, oi.UnitPrice); 
           
           } else if(oi.PricebookEntry.Product2.ProductCode == 'Shipping Product') {
               /*
                   number of kit lines = 2
                   unit price = Shipping_Product_Option__c.Rate_2_kits__c / 2
                              = 30/ 2 = 15
               */
               System.assertEquals(15, oi.UnitPrice); 
           }
       }
    }
    
    static testMethod void fullyShippedCheckTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       SuperOrder__c so = [select id from SuperOrder__c limit 1];
       List<Order> oList = [select SuperOrder__c from Order where SuperOrder__c = :so.id];
       System.assertEquals(2, oList.size());
       
       List<OrderItem> olineList = [select OrderId, PricebookEntry.Product2.ProductCode 
                   from OrderItem where Order.SuperOrder__c = :so.id and Type__c = 'KIT'];
       
       System.assertEquals(2, olineList.size());
       System.assertEquals(oList[0].id, olineList[0].OrderId);
       System.assertEquals(oList[1].id, olineList[1].OrderId);
       
       olineList[0].Kit_Order_Status__c = 'Shipped';
       update olineList[0];
       
       so = [select Fully_Shipped__c from SuperOrder__c where id = :so.id];
       System.assertEquals(false, so.Fully_Shipped__c);
       
      // RunOnceTriggerUtil.orderProductTriggerRun = true;
       olineList[1].Kit_Order_Status__c = 'Shipped';
       update olineList[1];
       
       so = [select Fully_Shipped__c from SuperOrder__c where id = :so.id];
       System.assertEquals(true, so.Fully_Shipped__c);
       
    }
    
    //test method to check the mapping of Gift on Super Order and LDT, LDT Approved on Order
    //Added on 2/14/2017
    static testMethod void giftCheckTestMethod() {
       Super_Order spOrder = getSuperOrder(); 
       
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       SuperOrder__c so = [select id, Gift__c from SuperOrder__c limit 1];
       List<Order> oList = [select LDT__c, LDT_Approved__c from Order where SuperOrder__c = :so.id];
       System.assertEquals(so.Gift__c, true);
       system.assertEquals(oList[1].LDT__c , true);
       system.assertEquals(oList[1].LDT_Approved__c , true);
    }
    
    public static Super_Order getSuperOrder() {
       //Creating HM_Agreement
       HM_Agreement agreement1 = new HM_Agreement();
       agreement1.key = '11' ;
       agreement1.version = '1112' ;
       agreement1.agreed = true ;
       agreement1.appId = 'A-APP-0001' ;
       agreement1.agreedDateTime = DateTime.newInstance(2016, 11, 11, 6, 6, 0);
       
       HM_Agreement agreement2 = new HM_Agreement();
       agreement2.key = '12' ;
       agreement2.version = '1212' ;
       agreement2.agreed = true ;
       agreement2.appId = 'A-APP-0001' ;
       
       List<HM_Agreement> agreements = new List<HM_Agreement>();
       agreements.add(agreement1);
       agreements.add(agreement2);
       
       HM_Contact billToHMCon = new HM_Contact();
       billToHMCon.firstName = 'fName';
       billToHMCon.lastName = 'lName';
       billToHMCon.email = 'fName@lName.com';
       billToHMCon.userId = System.Label.Helix_Partner_Id;
       billToHMCon.phone = '9902944899';
       billToHMCon.agreements = agreements;
       
       HM_Account billToHMAcc = new HM_Account();
       billToHMAcc.contact = billToHMCon;
       
       HM_Contact shipToHMCon = new HM_Contact();
       shipToHMCon.firstName = 'firstName';
       shipToHMCon.lastName = 'lastName';
       shipToHMCon.email = 'f1Name@l1Name.com';
       shipToHMCon.userId = System.Label.Helix_Partner_Id;
       shipToHMCon.phone = '9902944899';
       shipToHMCon.agreements = agreements;
       
       HM_Account shipToHMAcc = new HM_Account();
       shipToHMAcc.contact = shipToHMCon;
       
       HM_Address shippingAddress = new HM_Address();
       shippingAddress.street1 = 'street 1';
       shippingAddress.street2 = 'street 2';
       shippingAddress.city = 'city';
       shippingAddress.state = 'state';
       shippingAddress.zip = '';
       shippingAddress.country = 'India';
       shippingAddress.company = 'ABC';
       shippingAddress.userSpecifiedAddress = true;
       
       HM_Address billingAddress = new HM_Address();
       billingAddress.street1 = 'street 4';
       billingAddress.street2 = 'street 5';
       billingAddress.city = 'city';
       billingAddress.state = 'state';
       billingAddress.zip = '98765';
       billingAddress.country = 'US';
       billingAddress.company = 'ABC';
       billingAddress.userSpecifiedAddress = true;
       
       HM_OrderLine orderLine1 = new HM_OrderLine();
       orderLine1.quantity = 1;
       orderLine1.unitPrice = 1000;
       orderLine1.sku = 'APP-001';
       
       HM_OrderLine orderLine2 = new HM_OrderLine();
       orderLine2.quantity = 1;
       orderLine2.unitPrice = 2000;
       orderLine2.sku = '4172';
       
       List<HM_OrderLine> lineList = new List<HM_OrderLine>();
       lineList.add(orderLine1);
       lineList.add(orderLine2);
       
       HM_OrderLine orderLine3 = new HM_OrderLine();
       orderLine3.quantity = 1;
       orderLine3.unitPrice = 1000;
       orderLine3.sku = 'APP-001';
       
       HM_OrderLine orderLine4 = new HM_OrderLine();
       orderLine4.quantity = 1;
       orderLine4.unitPrice = 2000;
       orderLine4.sku = '4172';
       
       List<HM_OrderLine> lineList2 = new List<HM_OrderLine>();
       lineList2.add(orderLine3);
       lineList2.add(orderLine4);
       
       HM_Order hmOrder = new HM_Order();
       hmOrder.totalPrice = 100;
       hmOrder.transactionId = '';
       hmOrder.purchaseDateTime = null;     //'2016-03-20 22:34:00';
       hmOrder.lines = lineList;
       hmOrder.isShipToSameAsBillTo = false;
       hmOrder.ldt = false;
       hmOrder.ldtApproved = false;
       
       HM_Order hmOrder2 = new HM_Order();
       hmOrder2.totalPrice = 100;
       hmOrder2.transactionId = '';
       hmOrder2.purchaseDateTime = null;     //'2016-03-20 22:34:00';
       hmOrder2.lines = lineList2;
       hmOrder2.isShipToSameAsBillTo = false;
       hmOrder2.ldt = true;
       hmOrder2.ldtApproved = true;
       
       Super_Order spOrder = new Super_order();
       spOrder.sourcingPartner = '12346';
       spOrder.partnerOrderNumber = '1234123';
       spOrder.partnerChannel = System.Label.Helix_Partner_Id;
       spOrder.partnerAffiliatedCustomerID = 'abcd';
       spOrder.hasOptedOutOfEmail = false;
       spOrder.taxDocId = '12121';
       spOrder.transactionId = '98765';
       spOrder.billToAccount = billToHMAcc;
       spOrder.billingAddress = billingAddress;
       spOrder.shipToAccount = shipToHMAcc;
       spOrder.shippingAddress = shippingAddress;
       spOrder.carrier = 'Fedex';
       spOrder.shippingMethod = 'standard_overnight';
       spOrder.paymentCaptured = false;
       spOrder.gift = true;
       
       List<HM_Order> hmOrdList = new List<HM_Order>();
       hmOrdList.add(hmOrder);
       hmOrdList.add(hmOrder2);
       spOrder.orderList = hmOrdList;
       return spOrder;
    }

    static testMethod void partnerChnlSourcingPartnerMatch() {
       Super_Order spOrder = getSuperOrderWithDiffPartners(); 
       createOrderResponse result = CreateOrderAPI.createOrder(spOrder);
       
    }
    
    public static Super_Order getSuperOrderWithDiffPartners() {
        Id helixPartnerAccId = HMAPI_SFDC_IntegrationUtil.getHelixPartnerAccId();
         Contact c = new Contact(firstname = 'fname', lastname = 'lname', userid__c='98765', email='fName@lName.com', Sourcing_Partner__c = helixPartnerAccId );
         insert c;
       //Creating HM_Agreement
       HM_Agreement agreement1 = new HM_Agreement();
       agreement1.key = '11' ;
       agreement1.version = '1112' ;
       agreement1.agreed = true ;
       agreement1.appId = 'A-APP-0001' ;
       agreement1.agreedDateTime = DateTime.newInstance(2016, 11, 11, 6, 6, 0);
       
       HM_Agreement agreement2 = new HM_Agreement();
       agreement2.key = '12' ;
       agreement2.version = '1212' ;
       agreement2.agreed = true ;
       agreement2.appId = 'A-APP-0001' ;
       
       List<HM_Agreement> agreements = new List<HM_Agreement>();
       agreements.add(agreement1);
       agreements.add(agreement2);
       
       HM_Contact billToHMCon = new HM_Contact();
       billToHMCon.firstName = 'fName';
       billToHMCon.lastName = 'lName';
       billToHMCon.email = 'fName@lName.com';
       billToHMCon.userId = '98765';
       billToHMCon.phone = '9902944899';
       billToHMCon.agreements = agreements;
       
       HM_Account billToHMAcc = new HM_Account();
       billToHMAcc.contact = billToHMCon;
       
       HM_Contact shipToHMCon = new HM_Contact();
       shipToHMCon.firstName = 'firstName';
       shipToHMCon.lastName = 'lastName';
       shipToHMCon.email = 'f1Name@l1Name.com';
       shipToHMCon.userId = System.Label.Helix_Partner_Id;
       shipToHMCon.phone = '9902944899';
       shipToHMCon.agreements = agreements;
       
       HM_Account shipToHMAcc = new HM_Account();
       shipToHMAcc.contact = shipToHMCon;
       
       HM_Address shippingAddress = new HM_Address();
       shippingAddress.street1 = 'street 1';
       shippingAddress.street2 = 'street 2';
       shippingAddress.city = 'city';
       shippingAddress.state = 'state';
       shippingAddress.zip = '';
       shippingAddress.country = 'India';
       shippingAddress.company = 'ABC';
       shippingAddress.userSpecifiedAddress = true;
       
       HM_Address billingAddress = new HM_Address();
       billingAddress.street1 = 'street 4';
       billingAddress.street2 = 'street 5';
       billingAddress.city = 'city';
       billingAddress.state = 'state';
       billingAddress.zip = '98765';
       billingAddress.country = 'US';
       billingAddress.company = 'ABC';
       billingAddress.userSpecifiedAddress = true;
       
       HM_OrderLine orderLine1 = new HM_OrderLine();
       orderLine1.quantity = 1;
       orderLine1.unitPrice = 1000;
       orderLine1.sku = 'APP-001';
       
       HM_OrderLine orderLine2 = new HM_OrderLine();
       orderLine2.quantity = 1;
       orderLine2.unitPrice = 2000;
       orderLine2.sku = '4172';
       
       List<HM_OrderLine> lineList = new List<HM_OrderLine>();
       lineList.add(orderLine1);
       lineList.add(orderLine2);
       
       HM_OrderLine orderLine3 = new HM_OrderLine();
       orderLine3.quantity = 1;
       orderLine3.unitPrice = 1000;
       orderLine3.sku = 'APP-001';
       
       HM_OrderLine orderLine4 = new HM_OrderLine();
       orderLine4.quantity = 1;
       orderLine4.unitPrice = 2000;
       orderLine4.sku = '4172';
       
       List<HM_OrderLine> lineList2 = new List<HM_OrderLine>();
       lineList2.add(orderLine3);
       lineList2.add(orderLine4);
       
       HM_Order hmOrder = new HM_Order();
       hmOrder.totalPrice = 100;
       hmOrder.transactionId = '';
       hmOrder.purchaseDateTime = null;     //'2016-03-20 22:34:00';
       hmOrder.lines = lineList;
       hmOrder.isShipToSameAsBillTo = false;
       hmOrder.ldt = false;
       hmOrder.ldtApproved = false;
       
       HM_Order hmOrder2 = new HM_Order();
       hmOrder2.totalPrice = 100;
       hmOrder2.transactionId = '';
       hmOrder2.purchaseDateTime = null;     //'2016-03-20 22:34:00';
       hmOrder2.lines = lineList2;
       hmOrder2.isShipToSameAsBillTo = false;
       hmOrder2.ldt = false;
       hmOrder2.ldtApproved = false;
       
       Super_Order spOrder = new Super_order();
       spOrder.partnerOrderNumber = '1234123';
       spOrder.partnerChannel = '12346';
       spOrder.partnerAffiliatedCustomerID = 'abcd';
       spOrder.hasOptedOutOfEmail = false;
       spOrder.taxDocId = '12121';
       spOrder.transactionId = '98765';
       spOrder.billToAccount = billToHMAcc;
       spOrder.billingAddress = billingAddress;
       spOrder.shipToAccount = shipToHMAcc;
       spOrder.shippingAddress = shippingAddress;
       spOrder.carrier = 'Fedex';
       spOrder.shippingMethod = 'standard_overnight';
       spOrder.paymentCaptured = false;
       
       List<HM_Order> hmOrdList = new List<HM_Order>();
       hmOrdList.add(hmOrder);
       hmOrdList.add(hmOrder2);
       spOrder.orderList = hmOrdList;
       spOrder.gift = false;
       return spOrder;
    }
    
    @testSetup static void createProductTestData() {
        
        // First, set up test price book entries.
        // Insert a test product.
        Product2 kitProd = new Product2(Name = 'KIT Product', ProductCode = '4172', Type__c = 'KIT', 
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva');
        
        Product2 appProd = new Product2(Name = 'APP Product', ProductCode = 'APP-001', Type__c = 'APP', 
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', 
            Processing_Fee__c = 250, App_Content_Value__c = 250, Partner_Revenue_Share_PCT__c = 20);
        
        Product2 refFeeProd = new Product2(Name = 'Referral Fee', ProductCode = System.Label.Helix_Referral_Fee, Type__c = 'OTHER', 
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva');
        
        Product2 seqRevProd = new Product2(Name = 'Sequence Revenue', ProductCode = System.Label.Helix_Sequence_Revenue, Type__c = 'OTHER', 
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva');
        
        Product2 revShareProd = new Product2(Name = 'Revenue Share', ProductCode = System.Label.Partner_Revenue_Share, Type__c = 'OTHER', 
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva');
        
        Product2 kitRevProd = new Product2(Name = 'Kit Revenue', ProductCode = System.Label.Kit_Revenue, Type__c = 'OTHER', 
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva');
        
        Id shippingRTId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('S&H RT').getRecordTypeId();
        Product2 shipProd = new Product2(Name = 'Shipping Product', ProductCode = 'Shipping Product', Type__c = 'S&H', 
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva',
            RecordTypeId = shippingRTId);
        //create Sales Tax SKU
        Id otherRTId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Other RT').getRecordTypeId();
        Product2 salesTaxProd = new Product2(Name = 'Sales Tax', ProductCode = System.Label.Sales_Tax_Product_Code, Type__c = 'OTHER', 
            RecordTypeId = otherRTId);           
        List<Product2> prodList = new List<Product2>();
        prodList.add(kitProd);
        prodList.add(appProd);
        prodList.add(refFeeProd);
        prodList.add(seqRevProd);
        prodList.add(revShareProd);
        prodList.add(kitRevProd);
        prodList.add(shipProd);
        prodList.add(salesTaxProd);
        insert prodList;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPriceKit = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = kitProd.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPriceApp = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = appProd.Id, UnitPrice = 20000, IsActive = true);
        PricebookEntry standardPriceRefFee = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = refFeeProd.Id, UnitPrice = 30000, IsActive = true);
        PricebookEntry standardPriceSeqRev = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = seqRevProd.Id, UnitPrice = 40000, IsActive = true);
        PricebookEntry standardPriceRevShare = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = revShareProd.Id, UnitPrice = 50000, IsActive = true);
        PricebookEntry standardPriceKitRev = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = kitRevProd.Id, UnitPrice = 60000, IsActive = true);
        PricebookEntry standardPriceShipProd = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = shipProd.Id, UnitPrice = 70000, IsActive = true);
        PricebookEntry standardPriceSalesTaxProd = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = salesTaxProd.Id, UnitPrice = 70000, IsActive = true);
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        pbeList.add(standardPriceKit);
        pbeList.add(standardPriceApp);
        pbeList.add(standardPriceRefFee);
        pbeList.add(standardPriceSeqRev);
        pbeList.add(standardPriceRevShare);
        pbeList.add(standardPriceKitRev);
        pbeList.add(standardPriceShipProd);
        pbeList.add(standardPriceSalesTaxProd);
        insert pbeList;
        
        Account acc = new Account(Name = 'Test', Partner_ID__c = System.Label.Helix_Partner_Id);
        insert acc;
        Contact con = new Contact(LastName = 'Test', AccountId = acc.id, Email = 'test@test.com', UserId__c = System.Label.Helix_Partner_Id, Sourcing_Partner__c = acc.id);
        insert con;
        
        Partner_Shipping_Option__c shipOption = new Partner_Shipping_Option__c(Carrier__c = 'Fedex', Service_Level__c = 'standard_overnight',
                    Partner_Account__c = acc.id, Shipping_Product__c = shipProd.id, Default_Price__c = 100, Rate_1_kit__c = 20,
                    Rate_2_kits__c = 30, Rate_3_kits__c = 48, Rate_4_kits__c = 120, Rate_5_kits__c = 200);
        insert shipOption;
        // Next, perform some tests with your test price book entries.
    }
}