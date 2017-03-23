@isTest
public class Test_ManifestDataUtil {
    
    public static void createProductTestData() {
        
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
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, UserId__c = '1111', 
                            BirthDate = System.today().addYears(-12), Biological_Sex__c = 'Female');
        insert con;
        Order o = new Order(AccountId = acc.id, EffectiveDate = System.today(), Status = 'Draft', Pricebook2Id = pricebookId,
                        BillToContactId = con.id, ShipToContactId = con.id);
        insert o;
        List<OrderItem> oiList = new List<OrderItem>();
        for(Integer i = 100; i < 700; i++) {
            OrderItem oi = new OrderItem(OrderId = o.id, Required_Yield__c = 4.5, Project_Name__c = 'TestProject_5-31',
                Analysis_Workflow__c = 'ExomePlusFastq2GvcfV1.0-WFV1.0', Sample_Status__c = 'Ready for Submission',
                PricebookEntryId = standardPrice.id, Quantity = 1, UnitPrice = 100, BillTo_Contact__c = con.id, ShipTo_Contact__c = con.id,
                registeredBy__c = con.id, Last_Accessioning_Scan__c = System.now().addMinutes(i));
            oi.Kit_ID__c = 'AAAAAAA' + String.valueOf(i);
            oiList.add(oi);
        }
        insert oiList;
        System.assertEquals(600, oiList.size());
        // Next, perform some tests with your test price book entries.
    }
    
    public static void createFakeResponse() {
        SampleStatusResponse response = new SampleStatusResponse();
        List<SampleStatus> ssList = new List<SampleStatus>();
        for(Integer i = 100; i < 700; i++) {
            SampleStatus s = new SampleStatus();
            s.kitId = 'AAAAAAA' + String.valueOf(i);
            s.sampleStatus = 'Manifest Uploaded';
            s.statusTimestamp = DateTime.newInstance(2016, 9, 9, 1, 1, 1);
            ssList.add(s);
        }
        response.sampleStatuses = ssList;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'OK',
                                                 JSON.serializePretty(response),
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    }
    
    
    public static void createResponse() {
        SampleStatusResponse response = new SampleStatusResponse();
        List<SampleStatus> ssList = new List<SampleStatus>();
        for(Integer i = 100; i < 700; i++) {
            SampleStatus s = new SampleStatus();
            s.kitId = 'AAAAAAA' + String.valueOf(i);
            s.sampleStatus = 'Data Delivery Complete';
            s.statusTimestamp = DateTime.newInstance(2016, 10, 9, 1, 1, 1);
            ssList.add(s);
        }
        response.sampleStatuses = ssList;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'OK',
                                                 JSON.serializePretty(response),
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    }
    
    // create upload manifest settings data
    public static Sample_Service_Credentials__c uploadManifestSettings() {
        Sample_Service_Credentials__c ssc = new Sample_Service_Credentials__c();
        ssc.Name = 'UploadManifest';
        ssc.Username__c = 'TestUsername';
        ssc.Password__c = 'TestPassword';
        ssc.Login_Service__c = 'www.testlogin.com';
        ssc.Sample_Status_Service__c = 'www.ssc.com';
        ssc.Frequency__c = 5;
        ssc.StartTime__c = '9:00';
        ssc.EndTime__c = '21:00';
        ssc.Record_Count__c = 1000;
        ssc.Query_Limit__c = 1000;
        ssc.Scope__c = 'samplestatus_sfdc';
        insert ssc;
        return ssc;
    }
    
    public static void uploadStatusDateMapping() {
        SampleStatusDateMapping__c statusDateMap = new SampleStatusDateMapping__c(
                Name = 'Data Delivery Complete',
                Date_Field_API_Name__c = 'Data_Delivery_Date__c'
        );
        insert statusDateMap;
    }
}