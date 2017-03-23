@isTest
public class TestKitResend {
    
    public static testmethod void servicesToolboxCtrlTest() {
        Super_Order spOrder = Test_CreateOrderAPI.getSuperOrder();
        CreateOrderAPI.createOrder(spOrder);
        SuperOrder__c so = [select Name from SuperOrder__c limit 1]; 
        ApexPages.currentPage().getParameters().put('kwrd', so.Name);
        CustomerServicesToolboxCtrl ctrl = new CustomerServicesToolboxCtrl();
        ctrl.searchOrder();
        System.assertEquals(so.Name, ctrl.OrderDetails.soName);
        System.assertEquals(2, ctrl.OrderDetails.orderList.size());
        
        for(Order o :ctrl.OrderDetails.orderList) {
            System.assertEquals(1, o.OrderItems.size());
            System.assertEquals('KIT', o.OrderItems[0].Type__c);
        }
        ctrl.resendKit();
    }
    
    public static testmethod void kitResendCtrlTest() {
        Super_Order spOrder = Test_CreateOrderAPI.getSuperOrder();
        CreateOrderAPI.createOrder(spOrder);
        OrderItem oi = [select id from OrderItem where Type__c = 'KIT' limit 1]; 
        ApexPages.currentPage().getParameters().put('kitLineId', oi.id);
        ApexPages.currentPage().getParameters().put('retURL', '/apex/CustomerServicesToolbox');
        ResendKitCtrl ctrl = new ResendKitCtrl();
        
        ctrl.doSave();
        oi = [select Order.ShipToContactId, Order.BillToCOntactId, Kit_Order_Status__c, Sample_Status__c, Accessioning_Status__c, OrderId from OrderItem where id = :oi.id]; 
        System.assertEquals('Cancelled', oi.Sample_Status__c);
        System.assertEquals('CANCELLED', oi.Accessioning_Status__c);
        
        OrderItem clonedOrderItem = [select Kit_Order_Status__c, Resend_Original_Kit__c, Integration_Test__c, 
                    Integrate_with_DNAG__c, UnitPrice, BillTo_Contact__c, ShipTo_Contact__c from OrderItem 
                    where Resend_Original_Kit__c != null and OrderId = :oi.OrderId];
        
        System.assertEquals('Submit', clonedOrderItem.Kit_Order_Status__c);
        System.assertEquals(oi.Id, clonedOrderItem.Resend_Original_Kit__c);
        System.assertEquals(true, clonedOrderItem.Integration_Test__c);
        System.assertEquals(true, clonedOrderItem.Integrate_with_DNAG__c);
        System.assertEquals(0, clonedOrderItem.UnitPrice);
        System.assertNotEquals(null, oi.Order.ShipToContactId);
        System.assertNotEquals(null, oi.Order.BillToContactId);
        System.assertEquals(oi.Order.BillToContactId, clonedOrderItem.BillTo_Contact__c);
        System.assertEquals(oi.Order.ShipToContactId, clonedOrderItem.ShipTo_Contact__c);
        
        Order o = [select Kit_Resends__c from Order where id = :oi.OrderId];
        System.assertEquals(1, o.Kit_Resends__c);
        
        ctrl.doCancel();
    }
    
    public static testmethod void SuperOrderToolboxCtrlTest() {
        Super_Order spOrder = Test_CreateOrderAPI.getSuperOrder();
        CreateOrderAPI.createOrder(spOrder);
        SuperOrder__c so = [select id from SuperOrder__c limit 1]; 
        ApexPages.StandardController sc = new ApexPages.StandardController(so);
        SuperOrderToolboxCtrl ctrl = new SuperOrderToolboxCtrl(sc);
        ctrl.goToToolbox();
    }
    
    public static testmethod void OrderToolboxCtrlTest() {
        Super_Order spOrder = Test_CreateOrderAPI.getSuperOrder();
        CreateOrderAPI.createOrder(spOrder);
        Order o = [select id from Order limit 1]; 
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        OrderToolboxCtrl ctrl = new OrderToolboxCtrl(sc);
        ctrl.goToToolbox();
    }
    
    public static testmethod void OrderItemToolboxCtrlTest() {
        Super_Order spOrder = Test_CreateOrderAPI.getSuperOrder();
        CreateOrderAPI.createOrder(spOrder);
        OrderItem oi = [select id from OrderItem limit 1]; 
        ApexPages.StandardController sc = new ApexPages.StandardController(oi);
        OrderItemToolboxCtrl ctrl = new OrderItemToolboxCtrl(sc);
        ctrl.goToToolbox();
    }
    
    public static testmethod void CaseToolboxCtrlTest() {
        Super_Order spOrder = Test_CreateOrderAPI.getSuperOrder();
        CreateOrderAPI.createOrder(spOrder);
        Order o = [select id from Order limit 1]; 
        Case c = new Case(Order__c = o.id);
        insert c;
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CaseToolboxCtrl ctrl = new CaseToolboxCtrl(sc);
        ctrl.goToToolbox();
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