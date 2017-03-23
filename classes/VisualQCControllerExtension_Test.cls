/******

Changelog:
	2016-05-05 - Roman Dovbush - Method created.
	2016-08-15 - Roman Dovbush - Variable lastScan changed from System.now() to System.today() because
	                             1 sec difference in assertion caused test fail.



******/

@isTest
public class VisualQCControllerExtension_Test {

	@testSetup
	static void testSetup() {
		Set_Profile_ID__c pid = new Set_Profile_ID__c(Profile_ID__c = '00e36000000oZf1AAE');
		insert pid;
		System.assertNotEquals(null, pid.Id);

		Account account = new Account(Name = 'New Account');
		insert account;
		System.assertNotEquals(null, account.Id);

		Account account2 = new Account(Name = 'Second Account');
		insert account2;
		System.assertNotEquals(null, account2.Id);

		Contact contact = new Contact();
		contact.AccountId = account.Id;
		contact.FirstName = 'Test';
		contact.LastName = 'Contact';
		insert contact;
		System.assertNotEquals(null, contact.Id);

		Id spb = Test.getStandardPricebookId();
		System.assertNotEquals(null, spb);

		Product2 product = new Product2(Name = 'Acme', IsActive = TRUE);
		insert product;
		System.assertNotEquals(null, product.Id);

		// Order with Contact (for OrderItem1)
		Order order1 = new Order();
		order1.AccountId = account.Id;
		order1.Pricebook2Id = spb;
		order1.EffectiveDate = System.today();
		order1.Status = 'Draft';
		//order1.Registered_By__c = contact.Id;
		insert order1;
		System.assertNotEquals(null, order1.Id);

		//Order without Contact (for OrderItem2)
		Order order2 = new Order();
		order2.AccountId = account2.Id;
		order2.Pricebook2Id = spb;
		order2.EffectiveDate = System.today();
		order2.Status = 'Draft';
		order2.BillToContactId = contact.Id;
		insert order2;
		System.assertNotEquals(null, order2.Id);

		PricebookEntry pbe = new PricebookEntry();
		pbe.PriceBook2Id =  spb;
		pbe.Product2Id = product.Id;
		pbe.UnitPrice = 0.00;
		pbe.IsActive=TRUE;
		pbe.UseStandardPrice=FALSE;
		insert pbe;
		System.assertNotEquals(null, pbe.Id);

		// Order Product with Contact and Accessioning Status 'Failure Review'
		OrderItem orderItem1 = new OrderItem();
		orderItem1.OrderId = order1.Id;
		orderItem1.registeredBy__c = contact.Id;
		orderItem1.PricebookentryId = pbe.Id;
		orderItem1.Kit_ID__c = 'abcdefg123';
		orderItem1.Quantity = 5;
		orderItem1.UnitPrice = 23.00;
		orderItem1.Accessioning_Status__c = 'FAILURE REVIEW';
		insert orderItem1;
		System.assertNotEquals(null, orderItem1.Id);

		// Order Product without Contact
		OrderItem orderItem2 = new OrderItem();
		orderItem2.OrderId = order2.Id;
		orderItem2.PricebookentryId = pbe.Id;
		orderItem2.Kit_ID__c = 'kit2';
		orderItem2.Quantity = 2;
		orderItem2.UnitPrice = 50.00;
		insert orderItem2;
		System.assertNotEquals(null, orderItem2.Id);

		// Order Product without Contact and with Accessioning Status 'Failure Review'
		OrderItem orderItem3 = new OrderItem();
		orderItem3.OrderId = order2.Id;
		orderItem3.PricebookentryId = pbe.Id;
		orderItem3.Kit_ID__c = 'kit3';
		orderItem3.Quantity = 5;
		orderItem3.UnitPrice = 23.00;
		orderItem3.Accessioning_Status__c = 'FAILURE REVIEW';
		insert orderItem3;
		System.assertNotEquals(null, orderItem3.Id);

		User u = [SELECT Id, Accession_Location__c FROM User WHERE Id = :UserInfo.getUserId()];
		if (u != null && (u.Accession_Location__c == null || u.Accession_Location__c != '')) {
			u.Accession_Location__c = 'Test';
			update u;
		}
		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		ctrl.checkAccessionLocation();
		System.assertNotEquals(null, ctrl.accessionLocation);
	}

	// Test case 1 - Contact exist in Order, so Accessioning Status must be PASS;
	@isTest static void findKitId_Contact_Exist() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		ctrl.accessionLocation = 'San Diego';
		OrderItem selectItem1 = [Select Id, Kit_ID__c, Kit_ID_formatted__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		ctrl.kitID = selectItem1.Kit_ID__c;
		ctrl.mode = 'pass';
		ctrl.cycleMaximum = 2;
		System.assertEquals(ctrl.kitID, 'abcdefg123');
		System.assertEquals(selectItem1.Kit_ID_formatted__c, 'abc-defg-123');
		Test.startTest();

		List<VisualQCControllerExtension.ScanHistory> scanHistoryList = ctrl.scanHistoryList;
		ctrl.findKitIdAndContact();
		Datetime lastScan = System.today();
		System.assertNotEquals(null, scanHistoryList);

		// Check if Scan History list was filled in with right values;
		System.assertEquals('abcdefg123', scanHistoryList[0].kitId);
		System.assertEquals('Pass', scanHistoryList[0].accessioningStatus);
		System.assertEquals(null, scanHistoryList[0].boxScanned);
		System.assertEquals(null, scanHistoryList[0].wellLocScanned);
		System.assertEquals(null, scanHistoryList[0].holdReason);
		System.assertEquals(lastScan, scanHistoryList[0].lastScanDateTime.date());

		// Check if DB was updated;
		OrderItem scannedItem1 = [Select Id, Kit_ID__c, Location__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		System.assertEquals('abcdefg123', scannedItem1.Kit_ID__c);
		System.assertEquals('PASS', scannedItem1.Accessioning_Status__c);
		System.assertEquals(lastScan, scannedItem1.Last_Accessioning_Scan__c.date());
		System.assertEquals(null, scannedItem1.Hold_Reason__c);
		System.assertEquals(null, scannedItem1.Box__c);
		System.assertEquals(null, scannedItem1.Well_Location__c);
		System.assertEquals('San Diego', scannedItem1.Location__c);

		Test.stopTest();
	}


	// Test case 2 - Contact is missing in Order, so Accessioning Status must be PASS;
	@isTest static void findKitId_Contact_Missing() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		ctrl.accessionLocation = 'San Diego';
		OrderItem selectItem2 = [Select Id, Kit_ID__c From OrderItem Where Kit_ID__c = 'kit2'];
		ctrl.kitID = selectItem2.Kit_ID__c;
		ctrl.mode = 'pass';

		Test.startTest();

		List<VisualQCControllerExtension.ScanHistory> scanHistoryList = ctrl.scanHistoryList;
		ctrl.findKitIdAndContact();
		Datetime lastScan = System.today();
		System.assertNotEquals(null, scanHistoryList);

		// Check if Scan History list was filled in with right values;
		System.assertEquals('kit2', scanHistoryList[0].kitId);
		System.assertEquals('Hold', scanHistoryList[0].accessioningStatus);
		System.assertEquals(null, scanHistoryList[0].boxScanned);
		System.assertEquals(null, scanHistoryList[0].wellLocScanned);
		System.assertEquals('Contact Missing', scanHistoryList[0].holdReason);
		System.assertEquals(lastScan, scanHistoryList[0].lastScanDateTime.date());

		// Check if DB was updated;
		OrderItem scannedItem2 = [Select Id, Kit_ID__c, Location__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'kit2'];
		System.assertEquals('kit2', scannedItem2.Kit_ID__c);
		System.assertEquals('HOLD', scannedItem2.Accessioning_Status__c);
		System.assertEquals(lastScan, scannedItem2.Last_Accessioning_Scan__c.date());
		System.assertEquals('Contact Missing', scannedItem2.Hold_Reason__c);
		System.assertEquals(null, scannedItem2.Box__c);
		System.assertEquals(null, scannedItem2.Well_Location__c);
		System.assertEquals('San Diego', scannedItem2.Location__c);

		Test.stopTest();
	}

	// Test case 3 - mode is Storage -> Box and Well Location values are set;
	@isTest static void findKitId_Box_Well() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		ctrl.accessionLocation = 'San Diego';
		OrderItem selectItem2 = [Select Id, Kit_ID__c From OrderItem Where Kit_ID__c = 'kit2'];
		ctrl.kitID = selectItem2.Kit_ID__c;
		ctrl.mode = 'storage';
		ctrl.box = 'test box';
		ctrl.wellLocation = 'G12\n';

		Test.startTest();

		List<VisualQCControllerExtension.ScanHistory> scanHistoryList = ctrl.scanHistoryList;
		ctrl.findKitIdAndContact();
		Datetime lastScan = System.today();
		System.assertNotEquals(null, scanHistoryList);

		// Check if Scan History list was filled in with right values;
		System.assertEquals('kit2', scanHistoryList[0].kitId);
		System.assertEquals(null, scanHistoryList[0].accessioningStatus);
		System.assertEquals(ctrl.box, scanHistoryList[0].boxScanned);
		System.assertEquals('G12', scanHistoryList[0].wellLocScanned);
		System.assertEquals(null, scanHistoryList[0].holdReason);
		System.assertEquals(lastScan, scanHistoryList[0].lastScanDateTime.date());
		System.assertEquals('H1', ctrl.wellLocation);
		System.assertEquals(false, ctrl.invalidWL);

		// Check if DB was updated;
		OrderItem scannedItem2 = [Select Id, Kit_ID__c, Location__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'kit2'];
		System.assertEquals('kit2', scannedItem2.Kit_ID__c);
		System.assertEquals(null, scannedItem2.Accessioning_Status__c);
		System.assertEquals(lastScan, scannedItem2.Last_Accessioning_Scan__c.date());
		System.assertEquals(null, scannedItem2.Hold_Reason__c);
		System.assertEquals(ctrl.box, scannedItem2.Box__c);
		System.assertEquals('G12', scannedItem2.Well_Location__c);
		System.assertEquals('ABCDEFGH', ctrl.charsForWellLocation);
		System.assertEquals('San Diego', scannedItem2.Location__c);

		Test.stopTest();
	}

	// Test case 3-1 - mode is Storage -> Box and Well Location values are set;
	@isTest static void validate_WellLocation() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		ctrl.accessionLocation = 'San Diego';
		OrderItem selectItem2 = [Select Id, Kit_ID__c From OrderItem Where Kit_ID__c = 'kit2'];
		ctrl.kitID = selectItem2.Kit_ID__c;
		ctrl.mode = 'storage';
		ctrl.box = 'test box';
		ctrl.wellLocation = 'M1\n';

		Test.startTest();

		List<VisualQCControllerExtension.ScanHistory> scanHistoryList = ctrl.scanHistoryList;
		ctrl.findKitIdAndContact();
		System.assertNotEquals(null, scanHistoryList);

		// Check if Scan History list was filled in with right values;
		System.assertEquals('M1', ctrl.wellLocation);
		System.assertEquals(true, ctrl.invalidWL);

		// Check if DB was updated;
		OrderItem scannedItem2 = [Select Id, Kit_ID__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'kit2'];
		System.assertNotEquals(null, scannedItem2);
		System.assertEquals(null, scannedItem2.Well_Location__c);
		System.assertEquals('ABCDEFGH', ctrl.charsForWellLocation);

		ctrl.kitID = selectItem2.Kit_ID__c;
		ctrl.mode = 'storage';
		ctrl.wellLocation = '';
		ctrl.findKitIdAndContact();
		System.assertNotEquals(null, scanHistoryList);
		OrderItem scannedItem6 = [Select Id, Kit_ID__c, Location__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'kit2'];
		System.assertNotEquals(null, scannedItem6);
		System.assertEquals(null, scannedItem6.Well_Location__c);
		System.assertEquals('', ctrl.wellLocation);
		System.assertEquals(true, ctrl.invalidWL);
		System.assertEquals(null, scannedItem6.Location__c);


		ctrl.kitID = selectItem2.Kit_ID__c;
		ctrl.mode = 'storage';
		ctrl.wellLocation = 'Aaaa';
		ctrl.findKitIdAndContact();
		System.assertNotEquals(null, scanHistoryList);
		OrderItem scannedItem3 = [Select Id, Kit_ID__c, Location__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'kit2'];
		System.assertNotEquals(null, scannedItem3);
		System.assertEquals(null, scannedItem3.Well_Location__c);
		System.assertEquals(null, scannedItem3.Location__c);
		System.assertEquals('Aaaa', ctrl.wellLocation);
		System.assertEquals(true, ctrl.invalidWL);
		ctrl.clearScanList();

		ctrl.kitID = selectItem2.Kit_ID__c;
		ctrl.mode = 'storage';
		ctrl.wellLocation = 'A12';
		ctrl.findKitIdAndContact();
		System.assertNotEquals(null, scanHistoryList);
		OrderItem scannedItem4 = [Select Id, Kit_ID__c, Location__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'kit2'];
		System.assertNotEquals(null, scannedItem4);
		System.assertEquals('A12', scannedItem4.Well_Location__c);
		System.assertEquals('San Diego', scannedItem4.Location__c);
		System.assertEquals('B1', ctrl.wellLocation);
		System.assertEquals('ABCDEFGH', ctrl.charsForWellLocation);
		System.assertEquals(false, ctrl.invalidWL);

		ctrl.kitID = selectItem2.Kit_ID__c;
		ctrl.mode = 'storage';
		ctrl.wellLocation = 'H12\n';
		ctrl.findKitIdAndContact();
		System.assertNotEquals(null, scanHistoryList);
		OrderItem scannedItem5 = [Select Id, Kit_ID__c, Location__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'kit2'];
		System.assertNotEquals(null, scannedItem5);
		System.assertEquals('H12', scannedItem5.Well_Location__c);
		System.assertEquals('San Diego', scannedItem5.Location__c);
		System.assertEquals('A1', ctrl.wellLocation);
		System.assertEquals(false, ctrl.invalidWL);
		ctrl.clearScanList();

		ctrl.kitID = selectItem2.Kit_ID__c;
		ctrl.mode = 'storage';
		ctrl.wellLocation = 'H14\n';
		ctrl.findKitIdAndContact();
		System.assertNotEquals(null, scanHistoryList);
		OrderItem scannedItem7 = [Select Id, Kit_ID__c, Location__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'kit2'];
		System.assertNotEquals(null, scannedItem7);
		System.assertEquals('H12', scannedItem7.Well_Location__c); //in Order Item old value is stored
		System.assertEquals('San Diego', scannedItem7.Location__c);//in Order Item old value is stored
		System.assertEquals('H14', ctrl.wellLocation);
		System.assertEquals(true, ctrl.invalidWL);
		Test.stopTest();
	}

	// Test case 4 - mode = Fail, so Accessioning Status must be Hold;
	@isTest static void findKitId_Hold_On_Unregistered() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		ctrl.accessionLocation = 'San Diego';
		OrderItem selectItem2 = [Select Id, Kit_ID__c From OrderItem Where Kit_ID__c = 'kit2'];
		ctrl.kitID = selectItem2.Kit_ID__c;
		ctrl.mode = 'fail';
		ctrl.failureReason = 'Color Off';

		Test.startTest();

		List<VisualQCControllerExtension.ScanHistory> scanHistoryList = ctrl.scanHistoryList;
		ctrl.findKitIdAndContact();
		Datetime lastScan = System.today();
		System.assertNotEquals(null, scanHistoryList);

		// Check if Scan History list was filled in with right values;
		System.assertEquals('kit2', scanHistoryList[0].kitId);
		System.assertEquals('Hold', scanHistoryList[0].accessioningStatus);
		System.assertEquals(lastScan, scanHistoryList[0].lastScanDateTime.date());

		// Check if DB was updated;
		OrderItem scannedItem2 = [Select Id, Kit_ID__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Failure_Reason__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'kit2'];
		System.assertEquals('kit2', scannedItem2.Kit_ID__c);
		System.assertEquals('HOLD', scannedItem2.Accessioning_Status__c);
		System.assertEquals(lastScan, scannedItem2.Last_Accessioning_Scan__c.date());

		Test.stopTest();

	}

	// Test case 5 - mode = Failure Review, Select all records with /
	//Accessioning Status = Failure Review;
	@isTest static void refresh_FailReviewItems() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();

		Test.startTest();

		ctrl.refreshFailReviewItems();

		Integer count = ctrl.failReviewItems.size();

		System.assertNotEquals(null, ctrl.failReviewItems);
		System.assertEquals(2, count);
		Test.stopTest();

	}

	// Test case 6 - mode = Failure Review, Select all records with /
	//Accessioning Status = Failure Review;
	@isTest static void getFailReviewItems_Test() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		ctrl.kitFound = true;
		ctrl.searchKitId = 'abcdefg123';

		Test.startTest();
		ctrl.getFailReviewItems();

		Integer count = ctrl.failReviewItems.size();

		System.assertNotEquals(null, ctrl.failReviewItems);
		System.assertEquals(1, count);
		System.assertEquals(false, ctrl.selectAll);
		System.assertEquals('', ctrl.searchKitId);
		Test.stopTest();

	}

	// Test case 7 - Update selected record with Accessioning mode 'PASS'
	@isTest static void selectProductToUpdate_Test() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();

		OrderItem selectItem1 = [Select Id, Kit_ID__c, Select_Product__c, Failure_Reason__c, Accessioning_Status__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		System.assertNotEquals(null, selectItem1);
		System.assertEquals('FAILURE REVIEW', selectItem1.Accessioning_Status__c);

		ctrl.changeReason = 'Change to Pass';

		Test.startTest();
		ctrl.refreshFailReviewItems();
		System.assertNotEquals(null, ctrl.failReviewItems);
		System.assertEquals('abcdefg123', ctrl.failReviewItems[0].Kit_ID__c);

		ctrl.failReviewItems[0].Select_Product__c = true;
		ctrl.failReviewItems[0].Failure_Reason__c = 'Low Volume';
		ctrl.selectProductToUpdate();

		OrderItem orderItemUpdated = [Select Id, Kit_ID__c, Select_Product__c, Failure_Reason__c, Accessioning_Status__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		System.assertNotEquals(null, orderItemUpdated);
		System.assertEquals('PASS', orderItemUpdated.Accessioning_Status__c);
		System.assertEquals(null, orderItemUpdated.Failure_Reason__c);
		System.assertEquals(false, orderItemUpdated.Select_Product__c);

		Test.stopTest();

	}


	// Test case 8 - Update selected record with new Failure Reason
	@isTest static void selectProductToUpdate_Test1() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();

		OrderItem selectItem1 = [Select Id, Kit_ID__c, Select_Product__c, Failure_Reason__c, Accessioning_Status__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		System.assertNotEquals(null, selectItem1);
		System.assertEquals('FAILURE REVIEW', selectItem1.Accessioning_Status__c);

		ctrl.changeReason = 'Color Off / Opacity';

		Test.startTest();
		ctrl.refreshFailReviewItems();
		System.assertNotEquals(null, ctrl.failReviewItems);
		System.assertEquals('abcdefg123', ctrl.failReviewItems[0].Kit_ID__c);

		ctrl.failReviewItems[0].Select_Product__c = true;
		ctrl.failReviewItems[0].Failure_Reason__c = 'Low Volume';
		ctrl.selectProductToUpdate();

		OrderItem orderItemUpdated = [Select Id, Kit_ID__c, Select_Product__c, Failure_Reason__c, Accessioning_Status__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		System.assertNotEquals(null, orderItemUpdated);
		System.assertEquals('FAIL', orderItemUpdated.Accessioning_Status__c);
		System.assertEquals('Color Off / Opacity', orderItemUpdated.Failure_Reason__c);
		System.assertEquals(false, orderItemUpdated.Select_Product__c);

		Test.stopTest();

	}


	// Test case 9 - Confirm selected record with Accessioning status 'FAIL'
	@isTest static void selectProductToConfirm_Test() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();

		OrderItem selectItem3 = [Select Id, Kit_ID__c, Select_Product__c, Failure_Reason__c, Accessioning_Status__c From OrderItem Where Kit_ID__c = 'kit3'];
		System.assertNotEquals(null, selectItem3);
		System.assertEquals('FAILURE REVIEW', selectItem3.Accessioning_Status__c);

		Test.startTest();
		ctrl.refreshFailReviewItems();
		System.assertNotEquals(null, ctrl.failReviewItems);
		System.assertEquals('kit3', ctrl.failReviewItems[1].Kit_ID__c);

		String currentUserName = UserInfo.getUserId();
		ctrl.failReviewItems[1].Select_Product__c = true;
		ctrl.failReviewItems[1].Failure_Reason__c = 'High Volume';
		ctrl.failReviewItems[1].Failure_Reviewed_By__c = currentUserName;

		ctrl.selectProductToConfirm();

		OrderItem orderItemConfirmed = [Select Id, Kit_ID__c, Select_Product__c, Failure_Reviewed_By__c, Accessioning_Status__c From OrderItem Where Kit_ID__c = 'kit3'];
		System.assertEquals('FAIL', orderItemConfirmed.Accessioning_Status__c);
		System.assertEquals(currentUserName, orderItemConfirmed.Failure_Reviewed_By__c);
		System.assertEquals(false, orderItemConfirmed.Select_Product__c);

		Test.stopTest();

	}

	// Test case 10 - Change Select All checkbox to true
	@isTest static void unselectAll_True() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();

		ctrl.selectAll = null;

		Test.startTest();
		ctrl.refreshFailReviewItems();
		System.assertNotEquals(null, ctrl.failReviewItems);
		System.assertEquals(false, ctrl.selectAll);
		System.assertEquals('abcdefg123', ctrl.failReviewItems[0].Kit_ID__c);
		ctrl.failReviewItems[0].Select_Product__c = false;

		ctrl.unselectAll();

		OrderItem orderItemSelected = [Select Id, Kit_ID__c, Select_Product__c, Failure_Reviewed_By__c, Accessioning_Status__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		System.assertEquals(true, ctrl.failReviewItems[0].Select_Product__c);
		System.assertEquals(true, ctrl.selectAll);

		Test.stopTest();

	}

	// Test case 11 - Change Select All checkbox to false
	@isTest static void unselectAll_False() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();

		ctrl.selectAll = null;

		Test.startTest();
		ctrl.refreshFailReviewItems();
		System.assertNotEquals(null, ctrl.failReviewItems);
		System.assertEquals(false, ctrl.selectAll);
		System.assertEquals('abcdefg123', ctrl.failReviewItems[0].Kit_ID__c);
		ctrl.selectAll = true;
		System.assertEquals(true, ctrl.selectAll);
		ctrl.failReviewItems[0].Select_Product__c = true;
		System.assertEquals(true, ctrl.failReviewItems[0].Select_Product__c);

		ctrl.unselectAll();

		OrderItem orderItemSelected = [Select Id, Kit_ID__c, Select_Product__c, Failure_Reviewed_By__c, Accessioning_Status__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		System.assertEquals(false, ctrl.failReviewItems[0].Select_Product__c);
		System.assertEquals(false, ctrl.selectAll);

		Test.stopTest();

	}

	// Test case 12 - Clear Scan History List;
	@isTest static void clearScanList_Test() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();

		ctrl.kitID = 'abcdefg123';
		Test.startTest();

		List<VisualQCControllerExtension.ScanHistory> scanHistoryList = ctrl.scanHistoryList;
		ctrl.findKitIdAndContact();
		System.assertNotEquals(null, scanHistoryList);

		ctrl.clearScanList();
		Integer emptyList = scanHistoryList.size();
		// Check if Scan History list is empty;
		System.assertEquals(0, emptyList);

		Test.stopTest();

	}

	// Test case 13 - No custom profiles specified
	@isTest static void accessManagerView_NoProfile() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		Set_Profile_ID__c pid1 = new Set_Profile_ID__c(Profile_ID__c = '');
		insert pid1;
		System.assertNotEquals(null, pid1.Id);
		System.assertEquals('', pid1.Profile_ID__c);

		Test.startTest();
		ctrl.managerAccess = false;
		System.assertEquals(false, ctrl.managerAccess);
		ctrl.accessManagerView();
		System.assertEquals(false, ctrl.managerAccess);
		Test.stopTest();

	}

	// Test case 14 - Not valid custom profiles are specified
	@isTest static void accessManagerView_WithProfile() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		Set_Profile_ID__c pid1 = new Set_Profile_ID__c(Profile_ID__c = 'abcdefg1234');
		insert pid1;
		System.assertNotEquals(null, pid1.Id);
		System.assertEquals('abcdefg1234', pid1.Profile_ID__c);

		Test.startTest();
		System.assertEquals(true, ctrl.managerAccess);
		ctrl.accessManagerView();
		System.assertEquals(false, ctrl.managerAccess);
		Test.stopTest();

	}

	// Test case 14 - Not valid custom profiles are specified
	@isTest static void findDuplicate_Test() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		ctrl.accessionLocation = 'San Diego';
		OrderItem selectItem1 = [Select Id, Kit_ID__c, Kit_ID_formatted__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		ctrl.kitID = selectItem1.Kit_ID__c;
		ctrl.mode = 'pass';
		ctrl.cycleMaximum = 2;
		System.assertEquals(ctrl.kitID, 'abcdefg123');
		System.assertEquals(selectItem1.Kit_ID_formatted__c, 'abc-defg-123');
		Test.startTest();

		List<VisualQCControllerExtension.ScanHistory> scanHistoryList = ctrl.scanHistoryList;
		ctrl.findKitIdAndContact();
		System.assertNotEquals(null, scanHistoryList);
		System.assertEquals(false, ctrl.duplicateFound);
		ctrl.kitID = selectItem1.Kit_ID__c;
		ctrl.findKitIdAndContact();
		System.assertEquals(true, ctrl.duplicateFound);

	}

	// Test case15 - mode = Fail, so Accessioning Status must be Failure Review;
	@isTest static void findKitId_Failure_Reason() {

		VisualQCControllerExtension ctrl = new VisualQCControllerExtension();
		ctrl.accessionLocation = 'San Diego';
		OrderItem selectItem3 = [Select Id, Kit_ID__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		ctrl.kitID = selectItem3.Kit_ID__c;
		ctrl.mode = 'fail';
		ctrl.failureReason = 'Color Off';

		Test.startTest();

		List<VisualQCControllerExtension.ScanHistory> scanHistoryList = ctrl.scanHistoryList;
		ctrl.findKitIdAndContact();
		Datetime lastScan = System.today();
		System.assertNotEquals(null, scanHistoryList);

		// Check if Scan History list was filled in with right values;
		System.assertEquals('abcdefg123', scanHistoryList[0].kitId);
		System.assertEquals('FAILURE REVIEW', scanHistoryList[0].accessioningStatus);
		System.assertEquals('Color Off', scanHistoryList[0].failureReasonScanned);
		System.assertEquals(lastScan, scanHistoryList[0].lastScanDateTime.date());

		// Check if DB was updated;
		OrderItem scannedItem2 = [Select Id, Kit_ID__c, Accessioning_Status__c, Hold_Reason__c, Box__c, Well_Location__c, Failure_Reason__c, Last_Accessioning_Scan__c From OrderItem Where Kit_ID__c = 'abcdefg123'];
		System.assertEquals('abcdefg123', scannedItem2.Kit_ID__c);
		System.assertEquals('FAILURE REVIEW', scannedItem2.Accessioning_Status__c);
		System.assertEquals('Color Off', scannedItem2.Failure_Reason__c);
		System.assertEquals(lastScan, scannedItem2.Last_Accessioning_Scan__c.date());

		Test.stopTest();

	}

}