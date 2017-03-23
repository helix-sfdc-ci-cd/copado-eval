/******
Changelog:
	2017-02-02 - Linus Löfberg (llofberg@thirdwaveanalytics.com) - Class created.

******/
@isTest
private class KitSearchController_Test {

	@testSetup
	static void testSetup() {

		Account account = new Account(Name = 'New Account');
		insert account;
		System.assertNotEquals(null, account.Id);

		Id spb = Test.getStandardPricebookId();
		System.assertNotEquals(null, spb);

		Product2 product = new Product2(Name = 'Acme', IsActive = TRUE);
		insert product;
		System.assertNotEquals(null, product.Id);

		PricebookEntry pbe = new PricebookEntry();
		pbe.PriceBook2Id =  spb;
		pbe.Product2Id = product.Id;
		pbe.UnitPrice = 0.00;
		pbe.IsActive=TRUE;
		pbe.UseStandardPrice=FALSE;
		insert pbe;
		System.assertNotEquals(null, pbe.Id);

		Order order = new Order();
		order.AccountId = account.Id;
		order.Pricebook2Id = spb;
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		insert order;
		System.assertNotEquals(null, order.Id);

		List<OrderItem> oiList = new List<OrderItem>();

		// Order Product with no additionals
		OrderItem orderItem1 = new OrderItem();
		orderItem1.OrderId = order.Id;
		orderItem1.Kit_ID__c = 'abcdefg123';
		orderItem1.Quantity = 5;
		orderItem1.PricebookentryId = pbe.Id;
		orderItem1.Quantity = 2;
		orderItem1.UnitPrice = 50.00;
		oiList.add(orderItem1);

		// Order Product with outbound tracking
		OrderItem orderItem2 = new OrderItem();
		orderItem2.OrderId = order.Id;
		orderItem2.Kit_ID__c = 'abcdefg321';
		orderItem2.Quantity = 5;
		OrderItem2.Outbound_Tracking_Number__c = '888888';
		orderItem2.PricebookentryId = pbe.Id;
		orderItem2.Quantity = 2;
		orderItem2.UnitPrice = 50.00;
		oiList.add(orderItem2);

		// Order Product with return tracking
		OrderItem orderItem3 = new OrderItem();
		orderItem3.OrderId = order.Id;
		orderItem3.Kit_ID__c = 'abcdefg456';
		orderItem3.Quantity = 5;
		orderItem3.Return_Tracking_Number__c = '999999';
		orderItem3.PricebookentryId = pbe.Id;
		orderItem3.Quantity = 2;
		orderItem3.UnitPrice = 50.00;
		oiList.add(orderItem3);

		// Order Product with Kit Order Id
		OrderItem orderItem4 = new OrderItem();
		orderItem4.OrderId = order.Id;
		orderItem4.Kit_ID__c = 'abcdefg654';
		orderItem4.Quantity = 5;
		orderItem4.Kit_Order_ID__c = '1111111';
		orderItem4.PricebookentryId = pbe.Id;
		orderItem4.Quantity = 2;
		orderItem4.UnitPrice = 50.00;
		oiList.add(orderItem4);

		insert oilist;
	}

	@isTest
	static void test_search_by_kitid() {

		Map<String, Boolean> searchForMap = new Map<String, Boolean>();
		searchForMap.put('kitid', true);
		searchForMap.put('kitlist', false);
		searchForMap.put('kitorderid', false);
		searchForMap.put('outboundtracking', false);
		searchForMap.put('returntracking', false);

		Test.startTest();

		List<OrderItem> result = KitSearchController.kitSearch('abcdefg123', searchForMap);

		System.assertEquals(1, result.size());
		System.assertEquals('abcdefg123', result[0].Kit_ID__c);

		Test.stopTest();

	}

	@isTest
	static void test_search_by_kitorderid() {

		Map<String, Boolean> searchForMap = new Map<String, Boolean>();
		searchForMap.put('kitid', false);
		searchForMap.put('kitlist', false);
		searchForMap.put('kitorderid', true);
		searchForMap.put('outboundtracking', false);
		searchForMap.put('returntracking', false);

		Test.startTest();

		List<OrderItem> result = KitSearchController.kitSearch('1111111', searchForMap);

		System.assertEquals(1, result.size());
		System.assertEquals('1111111', result[0].Kit_Order_ID__c);

		Test.stopTest();
	}

	@isTest
	static void test_search_by_outboundtracking() {

		Map<String, Boolean> searchForMap = new Map<String, Boolean>();
		searchForMap.put('kitid', false);
		searchForMap.put('kitlist', false);
		searchForMap.put('kitorderid', false);
		searchForMap.put('outboundtracking', true);
		searchForMap.put('returntracking', false);

		Test.startTest();

		List<OrderItem> result = KitSearchController.kitSearch('888888', searchForMap);

		System.assertEquals(1, result.size());
		System.assertEquals('888888', result[0].Outbound_Tracking_Number__c);

		Test.stopTest();
	}

	@isTest
	static void test_search_by_returntracking() {

		Map<String, Boolean> searchForMap = new Map<String, Boolean>();
		searchForMap.put('kitid', false);
		searchForMap.put('kitlist', false);
		searchForMap.put('kitorderid', false);
		searchForMap.put('outboundtracking', false);
		searchForMap.put('returntracking', true);

		Test.startTest();

		List<OrderItem> result = KitSearchController.kitSearch('999999', searchForMap);

		System.assertEquals(1, result.size());
		System.assertEquals('999999', result[0].Return_Tracking_Number__c);

		Test.stopTest();
	}

	@isTest
	static void test_search_by_kitidlist() {

		Map<String, Boolean> searchForMap = new Map<String, Boolean>();
		searchForMap.put('kitid', false);
		searchForMap.put('kitlist', true);
		searchForMap.put('kitorderid', false);
		searchForMap.put('outboundtracking', false);
		searchForMap.put('returntracking', false);

		Test.startTest();

		String searchList = 'abcdefg123 abcdefg321 abcdefg456';

		List<OrderItem> result = KitSearchController.kitSearch(searchList, searchForMap);

		System.assertEquals(3, result.size());

		Integer allFound = 0;
		for (OrderItem oi : result) {
			if (oi.Kit_ID__c == 'abcdefg123' || oi.Kit_ID__c == 'abcdefg321' || oi.Kit_ID__c == 'abcdefg456') {
				allFound++;
			}
		}
		System.assertEquals(3, allFound);

		Test.stopTest();
	}

	@isTest
	static void test_search_by_everything() {

		Map<String, Boolean> searchForMap = new Map<String, Boolean>();
		searchForMap.put('kitid', true);
		searchForMap.put('kitlist', true);
		searchForMap.put('kitorderid', true);
		searchForMap.put('outboundtracking', true);
		searchForMap.put('returntracking', true);

		Test.startTest();

		List<OrderItem> result = KitSearchController.kitSearch('abc', searchForMap);

		System.assertEquals(4, result.size());

		Test.stopTest();
	}

	@isTest
	static void test_search_by_everything_with_nonexisting_value() {

		Map<String, Boolean> searchForMap = new Map<String, Boolean>();
		searchForMap.put('kitid', true);
		searchForMap.put('kitlist', true);
		searchForMap.put('kitorderid', true);
		searchForMap.put('outboundtracking', true);
		searchForMap.put('returntracking', true);

		Test.startTest();

		List<OrderItem> result = KitSearchController.kitSearch('linus', searchForMap);

		System.assertEquals(0, result.size());

		Test.stopTest();
	}

}