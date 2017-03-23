@isTest
private class OrderCancelOrRefundCtrl_Test {

	@testSetup
	static void testSetup() {

        Product2 kitProd = new Product2(Name = 'KIT Product', ProductCode = '4172', Type__c = 'KIT',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', IsCancellationAllowed__c = true);

        Product2 appProd = new Product2(Name = 'APP Product', ProductCode = 'APP-001', Type__c = 'APP',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva',
            Processing_Fee__c = 250, App_Content_Value__c = 250, Partner_Revenue_Share_PCT__c = 20, IsCancellationAllowed__c = true);

        Product2 refFeeProd = new Product2(Name = 'Referral Fee', ProductCode = System.Label.Helix_Referral_Fee, Type__c = 'HELIX REFERRAL FEE',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', IsCancellationAllowed__c = true);

        Product2 seqRevProd = new Product2(Name = 'Sequence Revenue', ProductCode = System.Label.Helix_Sequence_Revenue, Type__c = 'HELIX SEQUENCE REVENUE',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', IsCancellationAllowed__c = true);

        Product2 revShareProd = new Product2(Name = 'Revenue Share', ProductCode = System.Label.Partner_Revenue_Share, Type__c = 'PARTNER REVENUE SHARE',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', IsCancellationAllowed__c = true);

        Product2 kitRevProd = new Product2(Name = 'Kit Revenue', ProductCode = System.Label.Kit_Revenue, Type__c = 'OTHER',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', IsCancellationAllowed__c = true);

        Id shippingRTId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('S&H RT').getRecordTypeId();
        Product2 shipProd = new Product2(Name = 'Shipping Product', ProductCode = 'Shipping Product', Type__c = 'S&H',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva',
            RecordTypeId = shippingRTId, IsCancellationAllowed__c = true);
        //create Sales Tax SKU
        Id otherRTId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Other RT').getRecordTypeId();
        Product2 salesTaxProd = new Product2(Name = 'Sales Tax', ProductCode = System.Label.Sales_Tax_Product_Code, Type__c = 'SALES TAX',
            RecordTypeId = otherRTId, IsCancellationAllowed__c = true);
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

        Id pricebookId = Test.getStandardPricebookId();

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
	}

	@isTest
	static void test_constructor() {
		Account hxAccount = new Account(Name = 'Helix');
		insert hxAccount;
		Account account = new Account(Name = 'New Account');
		insert account;
		System.assertNotEquals(null, account.Id, 'Failed to create Account record for test');

		SuperOrder__c so = new SuperOrder__c();
		insert so;

		Order order = new Order();
		order.AccountId = account.Id;
		order.Partner_Channel__c = hxAccount.Id;
		order.SuperOrder__c = so.Id;
		order.Pricebook2Id = Test.getStandardPricebookId();
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		insert order;
		System.assertNotEquals(null, order.Id, 'Failed to create Order record for test');

		List<OrderItem> oiList = new List<OrderItem>();
		for (PricebookEntry pe : [SELECT Id FROM PricebookEntry]) {
			OrderItem orderItem1 = new OrderItem();
			orderItem1.OrderId = order.Id;
			orderItem1.Quantity = 1;
			orderItem1.PricebookentryId = pe.Id;
			orderItem1.UnitPrice = 50.00;
			oiList.add(orderItem1);
		}
		insert oilist;

		Test.startTest();
		PageReference pageRef = Page.OrderCancelOrRefund;
		Test.setCurrentPage(pageRef);

		OrderCancelOrRefundCtrl ctrl = new OrderCancelOrRefundCtrl();
		System.assertEquals(null, ctrl.items, 'Apex controller returns orders with incorrect input data');

		pageRef = Page.OrderCancelOrRefund;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('oId', order.Id);
		ApexPages.currentPage().getParameters().put('cancelOrrefund', 'refund');
		ctrl = new OrderCancelOrRefundCtrl();
		System.assertEquals(1, ctrl.items.size(), 'Apex controller returns unexpected number of orders to cancel and/or refund');
		System.assertEquals(true, ctrl.isRefund, 'Apex controller should be set to refund with refund URL-param going in');
		System.assertEquals(false, ctrl.isCancel, 'Apex controller should set cancellation disabled by default with refund URL-param going in');

		pageRef = Page.OrderCancelOrRefund;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('soId', so.Id);
		ApexPages.currentPage().getParameters().put('cancelOrrefund', 'cancel');
		ctrl = new OrderCancelOrRefundCtrl();
		System.assertEquals(1, ctrl.items.size(), 'Apex controller returns unexpected number of orders to cancel and/or refund');
		System.assertEquals(true, ctrl.isCancel, 'Apex controller should be set to cancel with cancel URL-param going in');
		System.assertEquals(false, ctrl.isRefund,  'Apex controller should set refund disabled by default with cancel URL-param going in');
		Test.stopTest();
	}

	@isTest
	static void test_submit_cancelandrefund() {
		Account hxAccount = new Account(Name = 'Helix');
		insert hxAccount;
		Account account = new Account(Name = 'New Account');
		insert account;
		System.assertNotEquals(null, account.Id, 'Failed to create Account record for test');

		SuperOrder__c so = new SuperOrder__c();
		insert so;

		Order order = new Order();
		order.AccountId = account.Id;
		order.Partner_Channel__c = hxAccount.Id;
		order.SuperOrder__c = so.Id;
		order.Pricebook2Id = Test.getStandardPricebookId();
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		insert order;
		System.assertNotEquals(null, order.Id, 'Failed to create Order record for test');

		List<OrderItem> oiList = new List<OrderItem>();
		for (PricebookEntry pe : [SELECT Id FROM PricebookEntry]) {
			OrderItem orderItem = new OrderItem();
			orderItem.OrderId = order.Id;
			orderItem.Quantity = 1;
			orderItem.PricebookentryId = pe.Id;
			orderItem.UnitPrice = 50.00;
			oiList.add(orderItem);
		}
		insert oilist;

		Test.startTest();

		PageReference pageRef = Page.OrderCancelOrRefund;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('oId', order.Id);
		OrderCancelOrRefundCtrl ctrl = new OrderCancelOrRefundCtrl();

		System.assertEquals(ctrl.totalRefundAmount, 0);
		ctrl.items[0].refundType = 'Already Shipped';
		ctrl.recalculateRefundAmounts();
		System.assertEquals(25, ctrl.totalRefundAmount);
		ctrl.items[0].refundType = 'Full';
		ctrl.recalculateRefundAmounts();
		System.assertEquals(100, ctrl.totalRefundAmount);

		ctrl.items[0].cancelOrder = true;
		ctrl.items[0].order.Cancellation_Reason__c = 'Service Issue';
		ctrl.items[0].order.Refund_Reason__c = 'Service Issue';

		PageReference result = ctrl.submitCancelOrResendItems();

		System.assertNotEquals(null, result, 'Result from OrderEventService-flow is empty');
		System.assertEquals('/apex/CustomerServicesToolbox?kwrd=' + [SELECT Id, Name FROM SuperOrder__c WHERE Id = :so.Id].Name, result.getUrl(), 'Apex controller is reporting a faulty URL back to the services toolbox');

		Order_Event__c orderEvent = [SELECT Id, Type__c FROM Order_Event__c WHERE Order__c = :order.Id LIMIT 1];
		System.assertEquals('Cancel & Refund', orderEvent.Type__c, 'Failed to find expected Order_Event__c record after executing cancellation or refund flow.');

		Test.stopTest();
	}

	@isTest
	static void test_submit_refund() {
		Account hxAccount = new Account(Name = 'Helix');
		insert hxAccount;
		Account account = new Account(Name = 'New Account');
		insert account;
		System.assertNotEquals(null, account.Id, 'Failed to create Account record for test');

		SuperOrder__c so = new SuperOrder__c();
		insert so;

		Order order = new Order();
		order.AccountId = account.Id;
		order.Partner_Channel__c = hxAccount.Id;
		order.SuperOrder__c = so.Id;
		order.Pricebook2Id = Test.getStandardPricebookId();
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		insert order;
		System.assertNotEquals(null, order.Id, 'Failed to create Order record for test');

		List<OrderItem> oiList = new List<OrderItem>();
		for (PricebookEntry pe : [SELECT Id FROM PricebookEntry]) {
			OrderItem orderItem = new OrderItem();
			orderItem.OrderId = order.Id;
			orderItem.Quantity = 1;
			orderItem.PricebookentryId = pe.Id;
			orderItem.UnitPrice = 50.00;
			oiList.add(orderItem);
		}
		insert oilist;

		Test.startTest();

		PageReference pageRef = Page.OrderCancelOrRefund;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('oId', order.Id);
		OrderCancelOrRefundCtrl ctrl = new OrderCancelOrRefundCtrl();

		System.assertEquals(ctrl.totalRefundAmount, 0);
		ctrl.items[0].refundType = 'Full';
		ctrl.recalculateRefundAmounts();
		System.assertEquals(100, ctrl.totalRefundAmount);
		ctrl.items[0].order.Refund_Reason__c = 'Service Issue';

		PageReference result = ctrl.submitCancelOrResendItems();

		System.assertNotEquals(null, result, 'Result from OrderEventService-flow is empty');
		System.assertEquals('/apex/CustomerServicesToolbox?kwrd=' + [SELECT Id, Name FROM SuperOrder__c WHERE Id = :so.Id].Name, result.getUrl(), 'Apex controller is reporting a faulty URL back to the services toolbox');

		Order_Event__c orderEvent = [SELECT Id, Type__c FROM Order_Event__c WHERE Order__c = :order.Id LIMIT 1];
		System.assertEquals('Refund', orderEvent.Type__c, 'Failed to find expected Order_Event__c record after executing cancellation or refund flow.');

		Test.stopTest();
	}

	@isTest
	static void test_submit_cancel() {
		Account hxAccount = new Account(Name = 'Helix');
		insert hxAccount;
		Account account = new Account(Name = 'New Account');
		insert account;
		System.assertNotEquals(null, account.Id, 'Failed to create Account record for test');

		SuperOrder__c so = new SuperOrder__c();
		insert so;

		Order order = new Order();
		order.AccountId = account.Id;
		order.Partner_Channel__c = hxAccount.Id;
		order.SuperOrder__c = so.Id;
		order.Pricebook2Id = Test.getStandardPricebookId();
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		insert order;
		System.assertNotEquals(null, order.Id, 'Failed to create Order record for test');

		List<OrderItem> oiList = new List<OrderItem>();
		for (PricebookEntry pe : [SELECT Id FROM PricebookEntry]) {
			OrderItem orderItem = new OrderItem();
			orderItem.OrderId = order.Id;
			orderItem.Quantity = 1;
			orderItem.PricebookentryId = pe.Id;
			orderItem.UnitPrice = 50.00;
			oiList.add(orderItem);
		}
		insert oilist;

		Test.startTest();

		PageReference pageRef = Page.OrderCancelOrRefund;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('oId', order.Id);
		OrderCancelOrRefundCtrl ctrl = new OrderCancelOrRefundCtrl();

		ctrl.recalculateRefundAmounts();
		ctrl.items[0].cancelOrder = true;
		ctrl.items[0].order.Cancellation_Reason__c = 'Service Issue';

		PageReference result = ctrl.submitCancelOrResendItems();

		System.assertNotEquals(null, result, 'Result from OrderEventService-flow is empty');
		System.assertEquals('/apex/CustomerServicesToolbox?kwrd=' + [SELECT Id, Name FROM SuperOrder__c WHERE Id = :so.Id].Name, result.getUrl(), 'Apex controller is reporting a faulty URL back to the services toolbox');

		Order_Event__c orderEvent = [SELECT Id, Type__c FROM Order_Event__c WHERE Order__c = :order.Id LIMIT 1];
		System.assertEquals('Cancel', orderEvent.Type__c, 'Failed to find expected Order_Event__c record after executing cancellation or refund flow.');

		Test.stopTest();
	}

}