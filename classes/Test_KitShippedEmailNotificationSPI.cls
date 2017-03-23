@isTest
private class Test_KitShippedEmailNotificationSPI {
    
    @testSetup static void createTestData() {
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
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,
                                                UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Account acc = new Account(Name = 'Test');
        insert acc;
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, UserId__c = '1111', Email = 'test@example.com');
        insert con;
        
        Map<Integer, SuperOrder__c> soMap = new Map<Integer, SuperOrder__c>();
        for(Integer i=1; i <=200; i++) {
            soMap.put(i, new SuperOrder__c(Stripe_Customer_ID__c = 'testdata'));
        }
        insert soMap.values();
        Map<Integer, Order> ordMap = new Map<Integer, Order>();
        for(Integer i :soMap.keySet()){
            Id soId = soMap.get(i).id;
            Order o = new Order(AccountId = acc.id, SuperOrder__c = soId, EffectiveDate = System.today(), Status = 'Draft', Pricebook2Id = pricebookId,
                                    BillToContactId = con.id);
            ordMap.put(i, o);
        }
        insert ordMap.values();
        List<OrderItem> oiList = new List<OrderItem>();
        for(Integer i :ordMap.keySet()) {
            Id ordId = ordMap.get(i).id;
            OrderItem oi = new OrderItem(OrderId = ordId, 
                                         Sample_Status__c = 'Ready for Submission',
                                         PricebookEntryId = standardPrice.id, Quantity = 1, 
                                         UnitPrice = 100);
            oi.Kit_ID__c = 'AAAAAAA' + String.valueOf(i);
            oiList.add(oi);
        }
        insert oiList;
        
        List<Marketing_Email_Template_Name__c> settingList = new List<Marketing_Email_Template_Name__c>();
        Marketing_Email_Template_Name__c setting1 = new Marketing_Email_Template_Name__c(
                    Name = 'Kit shipped', Email_Template_Name__c = 'Kit_shipped');
        Marketing_Email_Template_Name__c setting2 = new Marketing_Email_Template_Name__c(
                    Name = 'Kits shipped', Email_Template_Name__c = 'Kits_shipped');
        
        settingList.add(setting1);
        settingList.add(setting2);
        insert settingList;
        // Next, perform some tests with your test price book entries.
    }
    
    // test login method to generate authentication token
    static testMethod void manifestLoginTestMethod() {
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'OK',
                                                 '{"access_token":"test_auth_token"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Sample_Service_Credentials__c sampleServCred = Test_ApiDataUtil.serviceCredSettings('BulkEmailService');
        
        Test.startTest();
        String authToken = HelixApiLogin.getAuthToken(sampleServCred.Name, sampleServCred.UserName__c, sampleServCred.Password__c, 
                                                                    sampleServCred.Login_Service__c, sampleServCred.Scope__c);
        Test.stopTest();
        System.assertEquals('test_auth_token', authToken);
    }
    
    static testmethod void testKitShippedEmailNotification() {
        Test_APIDataUtil.serviceCredSettings('BulkEmailService');
        Test_APIDataUtil.createKitShippedFakeResponse();
        
        Test.startTest();
        Set<Id> soIds = new Set<Id>();
        List<SuperOrder__c> soList = [select id, (select BillToContactId from Orders__r) from SuperOrder__c];
        Map<Id, Id> mapWhatIdWhoId = new Map<Id, Id>();
        for(SuperOrder__c so :soList) {
            for(Order o :so.Orders__r) {
                mapWhatIdWhoId.put(so.id, o.BillToContactId);
            }
            soIds.add(so.id);
        }
        
        List<OrderItem> oiList = [select id from OrderItem where Order.SuperOrder__c in :soIds];
        for(OrderItem oi :oiList) {
            oi.Kit_Order_Status__c = 'Shipped';
        }
        update oiList;
        Test.stopTest();
        
        List<Task> tskList = [select WhatId, WhoId, Subject, Status from Task where WhatId in :soIds];
        
        System.assertEquals(soList.size(), tskList.size());
        
        for(Task tsk :tskList) {
            if(mapWhatIdWhoId != null && mapWhatIdWhoId.containsKey(tsk.WhatId)) {
                System.assertEquals(mapWhatIdWhoId.get(tsk.WhatId), tsk.WhoId);
                System.assert(tsk.Subject.contains('Kit_shipped'));
                System.assertEquals('Sent', tsk.Status);
            }
        }
    }
    
    static testmethod void testKitShippedEmailNotificationError() {
        Test_APIDataUtil.serviceCredSettings('BulkEmailService');
        Test_APIDataUtil.createKitShippedErrorFakeResponse();
        
        Test.startTest();
        Set<Id> soIds = new Set<Id>();
        List<SuperOrder__c> soList = [select id, (select BillToContactId from Orders__r) from SuperOrder__c];
        Map<Id, Id> mapWhatIdWhoId = new Map<Id, Id>();
        for(SuperOrder__c so :soList) {
            for(Order o :so.Orders__r) {
                mapWhatIdWhoId.put(so.id, o.BillToContactId);
            }
            soIds.add(so.id);
        }
        
        List<OrderItem> oiList = [select id from OrderItem where Order.SuperOrder__c in :soIds];
        for(OrderItem oi :oiList) {
            oi.Kit_Order_Status__c = 'Shipped';
        }
        update oiList;
        Test.stopTest();
        
        List<Task> tskList = [select WhatId, WhoId, Subject, Status from Task where WhatId in :soIds];
        
        System.assertEquals(soList.size(), tskList.size());
        
        for(Task tsk :tskList) {
            if(mapWhatIdWhoId != null && mapWhatIdWhoId.containsKey(tsk.WhatId)) {
                System.assertEquals(mapWhatIdWhoId.get(tsk.WhatId), tsk.WhoId);
                System.assert(tsk.Subject.contains('Kit_shipped'));
                System.assertEquals('Error', tsk.Status);
            }
        }
    }
    
    static testmethod void testActivityAlreadyExistScenario() {
        Test_APIDataUtil.serviceCredSettings('BulkEmailService');
        Test_APIDataUtil.createKitShippedFakeResponse();
        
        Test.startTest();
        Set<Id> soIds = new Set<Id>();
        List<SuperOrder__c> soList = [select id, (select BillToContactId from Orders__r) from SuperOrder__c];
        Map<Id, Id> mapWhatIdWhoId = new Map<Id, Id>();
        for(SuperOrder__c so :soList) {
            for(Order o :so.Orders__r) {
                mapWhatIdWhoId.put(so.id, o.BillToContactId);
            }
            soIds.add(so.id);
        }
        
        List<OrderItem> oiList = [select id from OrderItem where Order.SuperOrder__c in :soIds];
        for(OrderItem oi :oiList) {
            oi.Kit_Order_Status__c = 'Shipped';
        }
        update oiList;
        Test.stopTest();
        
        List<Task> tskList = [select WhatId, WhoId, Subject, Status from Task where WhatId in :soIds];
        
        // assert task count
        System.assertEquals(soList.size(), tskList.size());
        
        // update Kit status to something else other than Shipped
        for(OrderItem oi :oiList) {
            oi.Kit_Order_Status__c = 'New';
        }
        update oiList;
        
        // update fully shipped checkbox to false
        for(SuperOrder__c so :soList) {
            so.Fully_Shipped__c = false;
        }
        update soList;
        
        // again update kit status to Shipped to execute trigger again
        for(OrderItem oi :oiList) {
            oi.Kit_Order_Status__c = 'Shipped';
        }
        update oiList;
        
        tskList = [select WhatId, WhoId, Subject, Status from Task where WhatId in :soIds];
        // task count remain same  
        System.assertEquals(soList.size(), tskList.size());
    }
    
    static testmethod void testTrackingLinkLabels() {
        System.assertEquals('<p style="color:#329AF2;font-size:20px;margin:0 auto;">', System.Label.Tracking_Link_Start_Tag);
        System.assertEquals('</p>', System.Label.Tracking_Link_End_Tag);
    }
}