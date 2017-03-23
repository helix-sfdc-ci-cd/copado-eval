@isTest 
private class Test_RegisterKitAPI {

    static testMethod void kitTestMethod() {
            
       //Creating HM_Agreement
       HM_Agreement agreement1 = new HM_Agreement();
       agreement1.key = '1' ;
       agreement1.version = '1' ;
       agreement1.agreed = true ;
       HM_Agreement agreement2 = new HM_Agreement();
       agreement2.key = '2' ;
       agreement2.version = '2' ;
       agreement2.agreed = true ;
       List<HM_Agreement> agreements = new List<HM_Agreement>();
       agreements.add(agreement1);
       agreements.add(agreement2);
       
       HM_Contact buyerHMCon = new HM_Contact();
       buyerHMCon.firstName = 'kit';
       buyerHMCon.lastName = 'account';
       buyerHMCon.email = 'fName@lName.com';
       buyerHMCon.userId = '';
       buyerHMCon.phone = '9902944899';
       buyerHMCon.biologicalSex = 'Male';
       buyerHMCon.blackNaturally = 'Yes';
       buyerHMCon.agreements = agreements;
       
       HM_Account buyerHMAcc = new HM_Account();
       buyerHMAcc.contact = buyerHMCon;
       
       HM_Kit hmkit = new HM_Kit();
       hmkit.account = buyerHMAcc ;
       hmkit.kitId = '12345';
       
       OrderItem oi = [select id from OrderItem limit 1];
       hmkit.orderProductId= oi.id;   //'H01258692';
            
       HM_OrderLine orderLine1 = new HM_OrderLine();
       orderLine1.quantity = 2;
       orderLine1.sku = '';
       orderLine1.appId = '654321';
       
       HM_OrderLine orderLine2 = new HM_OrderLine();
       orderLine2.quantity = 3;
       orderLine2.sku = '';
       orderLine2.appId = '123456';
       
       List<HM_OrderLine> lineList = new List<HM_OrderLine>();
       lineList.add(orderLine1);
       lineList.add(orderLine2);
       
       RegisterKitResponse result1 = RegisterKitAPI.registerKit(hmKit);
       
       hmkit.Account.contact.userId = '123456';
       
       RegisterKitResponse result2 = RegisterKitAPI.registerKit(hmKit);
       
       Account createdAccount = [select Name from Account where Name = 'kit account' limit 1];
       
       System.assertEquals('kit account', createdAccount.Name);
       
       DateTime regDate = DateTime.newInstance(2016, 11, 11, 6, 6, 0);
       
       hmKit.registeredDate = regDate;
       hmkit.account.contact.userId = '456789';  
       RegisterKitResponse result3 = RegisterKitAPI.registerKit(hmKit);
       
       oi = [select Registered_Date__c from OrderItem where id = :oi.id];
       System.assertEquals(regDate, oi.Registered_Date__c);
       
       hmkit.account.contact.userId = '45678909';  
       RegisterKitResponse result4 = RegisterKitAPI.registerKit(hmKit);
       
       RegisterKitResponse result5 = RegisterKitAPI.registerKit(hmKit); 
       RegisterKitAPI.generateResponse('Error', '401', true);
    }

    @testSetup static void createProductTestData() {
        // First, set up test price book entries.
        // Insert a test product.
        Product2 prod = new Product2(Name = 'Alpha DNA Kit', Type__c = 'KIT', Prep_Request__c = 'Helix Saliva Extraction',
            Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva');
        insert prod;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Account acc = new Account(Name = 'Test');
        insert acc;
        Order o = new Order(AccountId = acc.id, EffectiveDate = System.today(), Status = 'Draft', Pricebook2Id = pricebookId);
        insert o;
        List<OrderItem> oiList = new List<OrderItem>();
        for(Integer i = 100; i < 700; i++) {
            OrderItem oi = new OrderItem(OrderId = o.id, Required_Yield__c = 4.5, Project_Name__c = 'TestProject_5-31',
                Analysis_Workflow__c = 'ExomePlusFastq2GvcfV1.0-WFV1.0', Sample_Status__c = 'Ready for Submission',
                PricebookEntryId = standardPrice.id, Quantity = 1, UnitPrice = 100);
            oi.Kit_ID__c = 'AAAAAAA' + String.valueOf(i);
            oiList.add(oi);
        }
        insert oiList;
        System.assertEquals(600, oiList.size());
        // Next, perform some tests with your test price book entries.
    }
}