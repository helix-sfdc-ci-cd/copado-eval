@isTest
private class Test_ManifestSPI {
    
    // test login method to generate authentication token
    static testMethod void manifestLoginTestMethod() {
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'OK',
                                                 '{"access_token":"test_auth_token"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Sample_Service_Credentials__c sampleServCred = Test_ManifestDataUtil.uploadManifestSettings();
        
        Test.startTest();
        String authToken = ManifestLogin.getAuthToken(sampleServCred.Name, sampleServCred.UserName__c, sampleServCred.Password__c, 
                                                                    sampleServCred.Login_Service__c);
        Test.stopTest();
        System.assertEquals('test_auth_token', authToken);
    }
    
    
    
    
    // to test the positive scenario when manifest are uploaded successfully
    static testMethod void uploadManifestTestMethod() {
        
        Test_ManifestDataUtil.createProductTestData();
        Test_ManifestDataUtil.uploadManifestSettings();
        Test_ManifestDataUtil.createFakeResponse();
        
        ManifestSPI mspi = new ManifestSPI();
        Test.startTest();
        mspi.sendManifestData(true);
        Test.stopTest();
        
        for(OrderItem oi :[select Sample_Status__c, Sample_Status_Updated__c from OrderItem]) {
            System.assertEquals('Manifest Uploaded', oi.Sample_Status__c);
            System.assertEquals(DateTime.newInstance(2016, 9, 9, 1, 1, 1), oi.Sample_Status_Updated__c);
        }
    }
    
    // to test the positive scenario when manifest are uploaded successfully
    static testMethod void setProductIdTestMethod() {
        ManifestSPI mspi = new ManifestSPI();
        Test_ManifestDataUtil.createProductTestData();
        BioSamples bSamples = mspi.getBioSamples(1);
        
        String prodId = bSamples.BioSamples[0].properties.productId;
        
        System.assertEquals('20010958_20010959', prodId);
        
    }
    
    // to test the scenario when manifest are not uploaded successfully and error is returned
    static testMethod void uploadManifestErroResponseTest() {
        
        Test_ManifestDataUtil.createProductTestData();
        Test_ManifestDataUtil.uploadManifestSettings();
        SampleStatusResponse response = new SampleStatusResponse();
        List<SampleStatus> ssList = new List<SampleStatus>();
        for(Integer i = 100; i < 700; i++) {
            SampleStatus s = new SampleStatus();
            s.kitId = 'AAAAAAA' + String.valueOf(i);
            s.sampleStatus = 'Error';
            s.errorMessage = 'Error description';
            ssList.add(s);
        }
        response.sampleStatuses = ssList;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'OK',
                                                 JSON.serializePretty(response),
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        ManifestSPI mspi = new ManifestSPI();
        Test.startTest();
        mspi.sendManifestData(true);
        Test.stopTest();
        
        for(OrderItem oi :[select Sample_Status__c, Sample_Error_Detail__c from OrderItem]) {
            System.assertEquals('Error', oi.Sample_Status__c);
            System.assertEquals('Error description', oi.Sample_Error_Detail__c);
        }
    }
    
    // to test in case of manual upload
    static testMethod void manifestUploadManualCtrlTest() {
        
        Test_ManifestDataUtil.createProductTestData();
        Test_ManifestDataUtil.uploadManifestSettings();
        Test_ManifestDataUtil.createFakeResponse();
        
        ManifestUploadManualCtrl ctrl = new ManifestUploadManualCtrl();
        Test.startTest();
        ctrl.uploadManifest();
        Test.stopTest();
        
        for(OrderItem oi :[select Sample_Status__c, Sample_Status_Updated__c from OrderItem]) {
            System.assertEquals('Manifest Uploaded', oi.Sample_Status__c);
            System.assertEquals(DateTime.newInstance(2016, 9, 9, 1, 1, 1), oi.Sample_Status_Updated__c);
        }
    }
    
    // to test when class is scheduled for uploading
    static testMethod void manifestUploadScheduleTest() {
        
        Test_ManifestDataUtil.createProductTestData();
        Test_ManifestDataUtil.uploadManifestSettings();
        Test_ManifestDataUtil.createFakeResponse();
        
        ManifestUploadSchedule sch = new ManifestUploadSchedule();
        SchedulableContext sc;
        
        Test.startTest();
        sch.execute(sc);
        Test.stopTest();
        
        for(OrderItem oi :[select Sample_Status__c, Sample_Status_Updated__c from OrderItem]) {
            System.assertEquals('Manifest Uploaded', oi.Sample_Status__c);
            System.assertEquals(DateTime.newInstance(2016, 9, 9, 1, 1, 1), oi.Sample_Status_Updated__c);
        }
    }
    
    // to test the positive scenario when manifest are uploaded successfully
    static testMethod void dataDeliveryDateTestMethod() {
        
        Test_ManifestDataUtil.createProductTestData();
        Test_ManifestDataUtil.uploadManifestSettings();
        Test_ManifestDataUtil.uploadStatusDateMapping();
        Test_ManifestDataUtil.createResponse();
        
        DateTime alreadyPopulatedDate = DateTime.newInstance(2015, 10, 9, 1, 1, 1);
        List<OrderItem> oiList = [select id from OrderItem];
        for(OrderItem oi :oiList) {
            oi.Data_Delivery_Date__c = alreadyPopulatedDate;
        }
        update oiList;
        
        oiList = [select Data_Delivery_Date__c from OrderItem];
        System.debug('oiList===' + oiList);
        ManifestSPI mspi = new ManifestSPI();
        Test.startTest();
        mspi.sendManifestData(true);
        Test.stopTest();
        
        // assert that Data Delivery date doesnot get updated
        for(OrderItem oi :[select Sample_Status__c, Sample_Status_Updated__c, Data_Delivery_Date__c from OrderItem]) {
            System.debug('Data_Delivery_Date__c===' + oi.Data_Delivery_Date__c);
            System.assertEquals('Data Delivery Complete', oi.Sample_Status__c);
            System.assertEquals(alreadyPopulatedDate, oi.Data_Delivery_Date__c);
        }
    }
    
    // to test that property attribute are set properly
    static testMethod void setPropertiesTestMethod() {
        ManifestSPI mspi = new ManifestSPI();
        Test_ManifestDataUtil.createProductTestData();
        BioSamples bSamples = mspi.getBioSamples(2);
        
        String ageRange = bSamples.BioSamples[0].properties.ageRange;
        String biologicalSex = bSamples.BioSamples[0].properties.biologicalSex;
        
        System.assertEquals('11-15', ageRange);
        System.assertEquals('Female', biologicalSex);
        
        ageRange = bSamples.BioSamples[1].properties.ageRange;
        biologicalSex = bSamples.BioSamples[1].properties.biologicalSex;
        
        System.assertEquals('11-15', ageRange);
        System.assertEquals('Female', biologicalSex);
        
    }
    
    // to test that manifest are sent in order based on Last Accession Scan Date
    static testMethod void manifestOrderTestMethod() {
        ManifestSPI mspi = new ManifestSPI();
        Test_ManifestDataUtil.createProductTestData();
        BioSamples bSamples = mspi.getBioSamples(2);
        
        String kitId1 = bSamples.BioSamples[0].kitId;
        String kitId2 = bSamples.BioSamples[1].kitId;
        
        Integer kitNumber1 = Integer.valueOf(kitId1.replace('AAAAAAA', ''));
        Integer kitNumber2 = Integer.valueOf(kitId2.replace('AAAAAAA', ''));
        System.assertEquals(100, kitNumber1);
        System.assertEquals(101, kitNumber2);
        System.assert(kitNumber1 < kitNumber2);
        
    }
}