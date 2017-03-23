@isTest
private class TestSuperOrderController{

   //this method gives code coverage to the class SuperOrderController
   static testMethod void unitTest(){
   
      SuperOrder__c sOrder = new SuperOrder__c(Total_Amount_Charged__c = 100.00);
      insert sOrder;
      
      Product2 testProd = new Product2(Name = 'Test Product', ProductCode = '4172', IsActive = true, Type__c = 'KIT');
      insert testProd;
      
      //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
      Id stdPBId = Test.getStandardPricebookId();
      
      Pricebook2 priceBook = new  Pricebook2(Name = 'Test Price Book', IsActive = true);
      insert priceBook;
    
      PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdPBId /*standardPB.Id*/, Product2Id = testProd.Id, UnitPrice = 10, IsActive = true, UseStandardPrice = false);
      insert standardPrice;
    
      PricebookEntry priceBookEntry = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = testProd.Id, UnitPrice = 50, IsActive = true);
      insert priceBookEntry;
      
      Account a1 = new Account(Name = 'Acc1');
      insert a1;
      
      Order o1 = new Order(SuperOrder__c = sOrder.Id, AccountId = a1.Id, EffectiveDate = system.today(), Status = 'Draft', PriceBook2Id = priceBook.Id);
      insert o1;
      
      OrderItem oi1 = new OrderItem(OrderId = o1.Id, Quantity = 2, UnitPrice = 10.00, PricebookEntryId = priceBookEntry.Id);
      insert oi1;
      
      ApexPages.StandardController controller = new ApexPages.StandardController (sOrder);
      SuperOrderController ctrl = new  SuperOrderController(controller);
      
      ctrl.displayData();
      
      //system.assertEquals(ctrl.orderList.size() , 1);
      system.assertEquals(ctrl.orderItemList.size() , 1);
   }

}