@isTest
private class Test_UpdateOrderAPI {

    static testMethod void superOrderNotFoundTestMethod() {
        Super_Order spOrder = Test_CreateOrderAPI.getSuperOrder();
        spOrder.transactionId = '123456';
        spOrder.paymentCaptured = false;
        
        UpdateOrderResponse result = UpdateOrderAPI.updateOrder('HX001', spOrder);
        System.assertEquals('Super Order not found', result.error.message);
    }
    
    static testMethod void superOrderUpdateMethod() {
        Super_Order spOrder = Test_CreateOrderAPI.getSuperOrder();
        createOrderResponse result1 = CreateOrderAPI.createOrder(spOrder);
        //System.assertEquals('Super Order not found.', result1.error.message);
        spOrder.transactionId = '123456';
        spOrder.paymentCaptured = true;
        
        SuperOrder__c spRecord = [select Name, (select Helix_Order_Number__c from Orders__r) from SuperOrder__c limit 1];
        
        spOrder.orderList[0].orderNumber = spRecord.Orders__r[0].Helix_Order_Number__c;
        spOrder.orderList[1].orderNumber = spRecord.Orders__r[1].Helix_Order_Number__c;
        
        UpdateOrderResponse result = UpdateOrderAPI.updateOrder(spRecord.Name, spOrder);
        
        spRecord = [select TransactionId__c, Payment_Captured__c, Gift__c, 
                            (select TransactionId__c, LDT__c, LDT_Approved__c from Orders__r) 
                                    from SuperOrder__c where Name = :spRecord.Name];
        
        System.assertEquals('123456', spRecord.TransactionId__c);
        System.assertEquals(true, spRecord.Payment_Captured__c);
        System.assertEquals(true, spRecord.Gift__c);
        System.assertEquals(false, spRecord.Orders__r[0].LDT__c);
        System.assertEquals(false, spRecord.Orders__r[0].LDT_Approved__c);
        System.assertEquals('123456', spRecord.Orders__r[0].TransactionId__c);
        System.assertEquals(true, spRecord.Orders__r[1].LDT__c);
        System.assertEquals(true, spRecord.Orders__r[1].LDT_Approved__c);
        System.assertEquals('123456', spRecord.Orders__r[1].TransactionId__c);
        
    }
    
    static testMethod void setOrderConfirmationNotFoundTestMethod() {
        Super_Order spOrder = Test_CreateOrderAPI.getSuperOrder();
        createOrderResponse result1 = CreateOrderAPI.createOrder(spOrder);
        
        // shipping confirmation sent is true but order number is not sent in JSON
        spOrder.orderList[0].shippingConfirmationSent = true;
        spOrder.orderList[1].shippingConfirmationSent = false;
        
        SuperOrder__c spRecord = [select Name from SuperOrder__c limit 1];
        
        SetOrderConfirmationResponse result = SetOrderConfirmation.setOrderConfirmation(spOrder.orderList);
        // order number not found message will be sent in response
        System.assertEquals('Order Number can not be blank', result.error.message);
        
        // passing incorrect order number in JSON
        spOrder.orderList[0].orderNumber = '1234';
        spOrder.orderList[1].orderNumber = '4321';
        
        List<String> orderNotFoundList = new List<String>();
        orderNotFoundList.add(spOrder.orderList[0].orderNumber);
        orderNotFoundList.add(spOrder.orderList[1].orderNumber);
        
        result = SetOrderConfirmation.setOrderConfirmation(spOrder.orderList);
        // order not found message will be sent in response
        System.assertEquals('Order not found', result.error.message);
        System.assertEquals(orderNotFoundList, result.orderNotFoundList);
    }
    
    static testMethod void setOrderConfirmationTestMethod() {
        Super_Order spOrder = Test_CreateOrderAPI.getSuperOrder();
        createOrderResponse result1 = CreateOrderAPI.createOrder(spOrder);
        //System.assertEquals('Super Order not found.', result1.error.message);
        
        SuperOrder__c spRecord = [select Name, (select Helix_Order_Number__c from Orders__r) from SuperOrder__c limit 1];
        
        // passing the correct order number for 1 order and shipping confirmation sent is true
        spOrder.orderList[0].orderNumber = spRecord.Orders__r[0].Helix_Order_Number__c;
        spOrder.orderList[0].shippingConfirmationSent = true;
        
        SetOrderConfirmationResponse result = SetOrderConfirmation.setOrderConfirmation(spOrder.orderList);
        System.assertEquals('', result.error.message);
        spRecord = [select TransactionId__c, Payment_Captured__c, (select TransactionId__c, 
                            Helix_Order_Number__c, Shipping_Confirmation_Sent__c from Orders__r) 
                                    from SuperOrder__c where Name = :spRecord.Name];
        
        
        for(Order o :spRecord.Orders__r) {
            // shipping confirmation sent will be update to true on order for the order number sent in JSON
            if(o.Helix_Order_Number__c == spOrder.orderList[0].orderNumber)
                System.assertEquals(true, o.Shipping_Confirmation_Sent__c);
        }
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