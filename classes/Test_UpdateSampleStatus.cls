@isTest
private class Test_UpdateSampleStatus {
    
    static testMethod void multipleRecordsWithSameKitIdUserId() {
        createProductTestData();
        createStatusDateMapSettings();
        UpdateSampleStatusRequest updateSampleStatusRequest = new UpdateSampleStatusRequest();
        List<UpdateSampleStatusDetail> sampleStatuses = new List<UpdateSampleStatusDetail>();
        DateTime recordTimeStamp = DateTime.newInstance(2016, 9, 11, 9, 0, 0);
        
        // request records with same kitid and userid
        // Valid KitId = AAAAAAA111, Valid UserId = 12345
        // create request records =======================>  < MESSAGEID >  < KITID >  < USERID >     < SAMPLESTATUS >           < TIMESTAMP >
        UpdateSampleStatusDetail sampleStatus1 = createSampleStatus('123', 'AAAAAAA111', '12345', 'Data Delivery Complete', recordTimeStamp.addDays(-10));
        UpdateSampleStatusDetail sampleStatus2 = createSampleStatus('124', 'AAAAAAA111', '12345', 'DNA Extraction Started', recordTimeStamp.addDays(-6));
        UpdateSampleStatusDetail sampleStatus3 = createSampleStatus('125', 'AAAAAAA111', '12345', 'Manifest Uploaded', recordTimeStamp.addDays(-8));
        sampleStatuses.add(sampleStatus1);
        sampleStatuses.add(sampleStatus2);
        sampleStatuses.add(sampleStatus3);
        updateSampleStatusRequest.sampleStatuses = sampleStatuses;
        
        UpdateSampleStatusResponse response = UpdateSampleStatus.updateSampleStatus(updateSampleStatusRequest);
        // query order item which has kitid in the req
        OrderItem oi = [select Sample_Status__c, Sample_Status_Updated__c, DNA_Extraction_Start_Date__c from OrderItem where Kit_ID__c = 'AAAAAAA111'];
        System.assertEquals(oi.Sample_Status__c, 'DNA Extraction Started');
        System.assertEquals(recordTimeStamp.addDays(-6), oi.DNA_Extraction_Start_Date__c);
        System.assertEquals(recordTimeStamp.addDays(-6), oi.Sample_Status_Updated__c);
        System.assertEquals(0, response.failure.size());
        System.assertEquals(3, response.success.size());
        System.assertEquals('123', response.success[0].messageId);
        System.assertEquals('124', response.success[1].messageId);
        System.assertEquals('125', response.success[2].messageId);
    }
    
    static testMethod void multipleRecordsWithMultipleKitIdUserId() {
        createProductTestData();
        createStatusDateMapSettings();
        UpdateSampleStatusRequest updateSampleStatusRequest = new UpdateSampleStatusRequest();
        List<UpdateSampleStatusDetail> sampleStatuses = new List<UpdateSampleStatusDetail>();
        DateTime recordTimeStamp = DateTime.newInstance(2016, 9, 11, 9, 0, 0);
        
        // request records with same kitid and userid
        // Valid KitId = AAAAAAA111, Valid UserId = 12345
        // create request records =======================>  < MESSAGEID >  < KITID >  < USERID >     < SAMPLESTATUS >           < TIMESTAMP >
        UpdateSampleStatusDetail sampleStatus1 = createSampleStatus('123', 'AAAAAAA111', '12345', 'DNA Extraction Started', recordTimeStamp.addDays(-6));
        UpdateSampleStatusDetail sampleStatus2 = createSampleStatus('124', 'AAAAAAA111', '12345', 'Data Delivery Complete', recordTimeStamp.addDays(-10));
        UpdateSampleStatusDetail sampleStatus3 = createSampleStatus('125', 'AAAAAAA111', '12345', 'Manifest Uploaded', recordTimeStamp.addDays(-8));
        sampleStatuses.add(sampleStatus1);
        sampleStatuses.add(sampleStatus2);
        sampleStatuses.add(sampleStatus3);
        
        // request records with different kitid
        // Valid KitId = AAAAAAA121, Valid UserId = 12345
        // create request records =======================>  < MESSAGEID >  < KITID >  < USERID >     < SAMPLESTATUS >           < TIMESTAMP >
        UpdateSampleStatusDetail sampleStatus4 = createSampleStatus('126', 'AAAAAAA121', '12345', 'Manifest Uploaded', recordTimeStamp.addDays(-8));
        sampleStatuses.add(sampleStatus4);
        
        // request records with same kitid and userid where kitid does not exist
        
        // Invalid KitId = AAAAAAA000, Valid UserId = 12345
        // create request records =======================>  < MESSAGEID >  < KITID >  < USERID >     < SAMPLESTATUS >           < TIMESTAMP >
        UpdateSampleStatusDetail sampleStatus5 = createSampleStatus('127', 'AAAAAAA000', '12345', 'Manifest Uploaded', recordTimeStamp.addDays(-8));
        UpdateSampleStatusDetail sampleStatus6 = createSampleStatus('128', 'AAAAAAA000', '12345', 'DNA Extraction Started', recordTimeStamp.addDays(-6));
        sampleStatuses.add(sampleStatus5);
        sampleStatuses.add(sampleStatus6);
        
        updateSampleStatusRequest.sampleStatuses = sampleStatuses;
        
        UpdateSampleStatusResponse response = UpdateSampleStatus.updateSampleStatus(updateSampleStatusRequest);
        OrderItem oi = [select Sample_Status__c, Sample_Status_Updated__c, DNA_Extraction_Start_Date__c from OrderItem where Kit_ID__c = 'AAAAAAA111'];
        System.assertEquals(oi.Sample_Status__c, 'DNA Extraction Started');
        System.assertEquals(recordTimeStamp.addDays(-6), oi.DNA_Extraction_Start_Date__c);
        System.assertEquals(recordTimeStamp.addDays(-6), oi.Sample_Status_Updated__c);
        
        oi = [select Sample_Status__c, Sample_Status_Updated__c, Manifest_Upload_Date__c from OrderItem where Kit_ID__c = 'AAAAAAA121'];
        System.assertEquals(oi.Sample_Status__c, 'Manifest Uploaded');
        System.assertEquals(recordTimeStamp.addDays(-8), oi.Sample_Status_Updated__c);
        System.assertEquals(recordTimeStamp.addDays(-8), oi.Manifest_Upload_Date__c);
        
        System.assertEquals(2, response.failure.size());
        System.assertEquals(4, response.success.size());
        System.assertEquals('123', response.success[0].messageId);
        System.assertEquals('124', response.success[1].messageId);
        System.assertEquals('125', response.success[2].messageId);
        System.assertEquals('126', response.success[3].messageId);
        System.assertEquals('127', response.failure[0].messageId);
        System.assertEquals('128', response.failure[1].messageId);
    }
    
    static testMethod void kitIdUserIdNotFound() {
        createProductTestData();
        DateTime recordTimeStamp = DateTime.newInstance(2016, 9, 11, 9, 0, 0);
        UpdateSampleStatusRequest updateSampleStatusRequest = new UpdateSampleStatusRequest();
        List<UpdateSampleStatusDetail> sampleStatuses = new List<UpdateSampleStatusDetail>();
        
        // request records with different kitid and userid where either kitid or userid does not exist
        // Invalid KitId = AAAAAAA011, AAAAAAA000, Valid KitId = AAAAAAA111, Valid UserId = 12345, Invalid UserId = 11111, 00000
        // create request records =======================>  < MESSAGEID >  < KITID >  < USERID >     < SAMPLESTATUS >           < TIMESTAMP >
        UpdateSampleStatusDetail sampleStatus1 = createSampleStatus('123', 'AAAAAAA011', '12345', 'Data Delivery Complete', recordTimeStamp.addDays(-10));
        UpdateSampleStatusDetail sampleStatus2 = createSampleStatus('124', 'AAAAAAA111', '11111', 'Manifest Uploaded', recordTimeStamp.addDays(-6));
        UpdateSampleStatusDetail sampleStatus3 = createSampleStatus('125', 'AAAAAAA000', '00000', 'DNA Extraction Started', recordTimeStamp.addDays(-8));
        sampleStatuses.add(sampleStatus1);
        sampleStatuses.add(sampleStatus2);
        sampleStatuses.add(sampleStatus3);
        updateSampleStatusRequest.sampleStatuses = sampleStatuses;
        
        UpdateSampleStatusResponse response = UpdateSampleStatus.updateSampleStatus(updateSampleStatusRequest);
        
        System.assertEquals(3, response.failure.size());
        System.assertEquals(0, response.success.size());
        System.assertEquals('Kit Id or User Id does not exist.', response.failure[0].errorMessage);
        System.assertEquals('123', response.failure[0].messageId);
        System.assertEquals('124', response.failure[1].messageId);
        System.assertEquals('125', response.failure[2].messageId);
    }
    
    static testMethod void orderItemWithMostRecentTimestamp() {
        createProductTestData();
        UpdateSampleStatusRequest updateSampleStatusRequest = new UpdateSampleStatusRequest();
        List<UpdateSampleStatusDetail> sampleStatuses = new List<UpdateSampleStatusDetail>();
        DateTime recordTimeStamp = DateTime.newInstance(2016, 9, 11, 9, 0, 0);
        // update orderItem to most recent date
        OrderItem oi = [select Sample_Status__c, Sample_Status_Updated__c from OrderItem where Kit_ID__c = 'AAAAAAA111'];
        oi.Sample_Status_Updated__c = recordTimeStamp;
        oi.Sample_Status__c = 'Manifest Uploaded';
        update oi;
        // request records with same kitid and userid
        // Valid KitId = AAAAAAA111, Valid UserId = 12345
        // create request records =======================>  < MESSAGEID >  < KITID >  < USERID >     < SAMPLESTATUS >           < TIMESTAMP >
        UpdateSampleStatusDetail sampleStatus1 = createSampleStatus('123', 'AAAAAAA111', '12345', 'Data Delivery Complete', recordTimeStamp.addDays(-2));
        sampleStatuses.add(sampleStatus1);
        updateSampleStatusRequest.sampleStatuses = sampleStatuses;
        
        UpdateSampleStatusResponse response = UpdateSampleStatus.updateSampleStatus(updateSampleStatusRequest);
        // query order item which has kitid in the req
        oi = [select Sample_Status__c, Sample_Status_Updated__c from OrderItem where Kit_ID__c = 'AAAAAAA111'];
        // OrderItem status and date remained same since timestamp of request is not most recent
        // below asserts implies that there is nothing to be updated. Oi is already latest. 
        System.assertEquals(oi.Sample_Status__c, 'Manifest Uploaded');
        System.assertEquals(oi.Sample_Status_Updated__c, recordTimeStamp);
        
        //the incoming status messages is added to success list.
        System.assertEquals(0, response.failure.size());
        System.assertEquals(1, response.success.size());
        System.assertEquals('123', response.success[0].messageId);
    }
    
    static UpdateSampleStatusDetail createSampleStatus(String messageId, String kitId, String userId, String sampleStatus,
                                                            DateTime actualTimestamp) {
        UpdateSampleStatusDetail statusDetail = new UpdateSampleStatusDetail();
        statusDetail.messageId = messageId;
        statusDetail.kitId = kitId;
        statusDetail.userId = userId;
        statusDetail.sampleStatus = sampleStatus;
        statusDetail.actualTimestamp = actualTimestamp;
        return statusDetail;
    }
    
    static void createStatusDateMapSettings() {
        List<SampleStatusDateMapping__c> statusDateList = new List<SampleStatusDateMapping__c>();
        SampleStatusDateMapping__c statusDate1 = new SampleStatusDateMapping__c();
        statusDate1.Name = 'Data Delivery Complete';
        statusDate1.Date_Field_API_Name__c = 'Data_Delivery_Date__c';
        statusDateList.add(statusDate1);
        SampleStatusDateMapping__c statusDate2 = new SampleStatusDateMapping__c();
        statusDate2.Name = 'Manifest Uploaded';
        statusDate2.Date_Field_API_Name__c = 'Manifest_Upload_Date__c';
        statusDateList.add(statusDate2);
        SampleStatusDateMapping__c statusDate3 = new SampleStatusDateMapping__c();
        statusDate3.Name = 'DNA Extraction Started';
        statusDate3.Date_Field_API_Name__c = 'DNA_Extraction_Start_Date__c';
        statusDateList.add(statusDate3);
        insert statusDateList;
    }
    
    static void createProductTestData() {
        
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
        Contact con = new Contact(LastName = 'Test', AccountId = acc.id, UserId__c = '12345');
        insert con;
        Order o = new Order(AccountId = acc.id, EffectiveDate = System.today(), Status = 'Draft', Pricebook2Id = pricebookId);
        insert o;
        List<OrderItem> oiList = new List<OrderItem>();
        for(Integer i = 100; i < 200; i++) {
            OrderItem oi = new OrderItem(OrderId = o.id, Required_Yield__c = 4.5, Project_Name__c = 'TestProject_5-31',
                Analysis_Workflow__c = 'ExomePlusFastq2GvcfV1.0-WFV1.0', Sample_Status__c = 'Ready for Submission',
                PricebookEntryId = standardPrice.id, Quantity = 1, UnitPrice = 100, RegisteredBy__c = con.id);
            oi.Kit_ID__c = 'AAAAAAA' + String.valueOf(i);
            oiList.add(oi);
        }
        insert oiList;
        System.assertEquals(100, oiList.size());
        // Next, perform some tests with your test price book entries.
    }
}