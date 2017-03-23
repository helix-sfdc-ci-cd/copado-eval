/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/8/2016
    @Purpose: This Controller creates a Super Order, Order and it's Order Line Items
*/
public class CreateOrderController {
   
   //Order for input from page
   public Order ord {get; set;}
   //Order Item for input from page
   public OrderItem ordItem {get; set;}
   
   //List of all Products
   List<Product2> productList;
   
   //List of Select Option for APP or KIT Type of Products
   List<SelectOption> appList {get; set;}
   List<SelectOption> kitList {get; set;}
   
   //Map of Product Id to the Product Record for App Type Products
   Map<Id, Product2> appIdToProductMap;
   
   //selected values of APP and KIT Product
   public Id selectedAppProd {get; set;}
   public Id selectedKitProd {get; set;}
   
   //variables for input from the page CreateOrderPage
   public Integer numOfKits {get; set;}
   public Double appPrice {get; set;}
   public Double helixSeqRevenue {get; set;}
   public Double kitRevenue {get; set;}
   public Double shippingNHandling {get; set;}
   public Double salesTax {get; set;}
   public Double helixReferralFee {get; set;}
   public Double partnerRevenueShare {get; set;}
   
   public CreateOrderController(){
      //Querying Product Object to retrieve products of type APP and KIT
      productList = new List<Product2>();
      productList = [ Select Id, Name, Type__c, AppID__c, Partner_Account__c From Product2 ]; //Where Type__c = 'APP' Or Type__c = 'KIT'
      numOfKits = 0;
   }
   
   //this method returns the List of Select Options for APP Products
   public List<SelectOption> getAppList(){
      appList = new List<SelectOption>();
      appIdToProductMap = new Map<Id, Product2>();
      for(Product2 p :productList){
         if(p.Type__c.equalsIgnoreCase('app')){
            appList.add(new SelectOption(p.Id, p.Name));
            appIdToProductMap.put(p.Id, p);
         }
      }
      return appList;
   }
   
   //this method returns the List of Select Options for KIT Products
   public List<SelectOption> getKitList(){
      kitList = new List<SelectOption>();
      for(Product2 p :productList){
         if(p.Type__c.equalsIgnoreCase('kit')){
            kitList.add(new SelectOption(p.Id, p.Name));
         }
      }
      return kitList;
   }
   //this method is called as an action from the VF page CreateOrderPage
   public PageReference createOrder(){
      
      //Order for input from page
      ord = new Order();
      
      //Order Item for input from page
      ordItem = new OrderItem();
      return null;
   }
   
   
   //method called when "Submit" button is pressed on the VF page CreateOrderPage
   public PageReference submit(){
      try {
         SuperOrder__c sOrder = new SuperOrder__c();
         insert sOrder;
         
         //PriceBook
         Id pricebookId = getStandardPricebookId();
         //Partner Channel Id to be set on Order
         Id partChannelId = getHelixPartnerAccId();
         if(partChannelId == null) {
             ApexPages.Message eMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Partner Channel not found.');
             ApexPages.addMessage(eMsg);
             return null;
         }
         //Finding Account for orders to be inserted
         List<Contact> conList = new List<Contact>([Select Id, AccountId From Contact Where Id = :ord.BillToContactId]);
         Contact con = new Contact();
         if(conList.size() > 0){
            con = conList[0];
         }
      
         List<Order> ordersToBeInserted = new List<Order>();
         for (Integer i = 1; i <= numOfKits ; i++){
           Order o = new Order();
           o = ord.clone();
           o.SuperOrder__c = sOrder.Id;
           o.AccountId = con.AccountId;
           o.Status = 'Draft';
           o.EffectiveDate = system.today();
           o.Pricebook2Id = pricebookId ;
           o.Partner_Channel__c = partChannelId ;
           o.Type = 'Promotional';
           o.App_Partner__c = appIdToProductMap.get(selectedAppProd).Partner_Account__c ;
           o.ShippingCountry = 'US';
           ordersToBeInserted.add(o);
         }
         
         if(ordersToBeInserted.size() > 0){
            insert ordersToBeInserted;
         }
      
         //Set of Product Ids for which PriceBookEntryId is required
         Set<Id> prodIdSet = new Set<Id>();
      
         //Map of Product Name to its Id (except App and Kit)
         Map<String, Id> prodNameToIdMap = new Map<String, Id>();
      
         prodIdSet.add(selectedAppProd);
         prodIdSet.add(selectedKitProd);
         for(Product2 p :productList){
            if(p.Name == 'Helix Sequence Revenue' || p.Name == 'Kit Revenue' || p.Name == 'Shipping & Handling' || p.Name == 'Sales Tax'
                          || p.Name == 'Helix Referral Fee' || p.Name == 'Partner Revenue Share'){
               prodIdSet.add(p.Id);
               prodNameToIdMap.put(p.Name, p.Id);
            }
         }
      
         Map<Id, Id> prodIdToPbeId = getProductPbeIdMap(prodIdSet, pricebookId);
         createOrderItems(ordersToBeInserted, prodIdToPbeId, prodNameToIdMap);
         
         PageReference submitPage = new PageReference('/'+sOrder.Id);
         return submitPage;
      } catch(Exception e){
         ApexPages.Message eMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+e.getMessage());
         ApexPages.addMessage(eMsg);
      }
      return null;
   }
   
   // method to create order line items
   public void createOrderItems(List<Order> ordersToBeInserted, Map<Id, Id> prodIdToPbeId, Map<String, Id> prodNameToIdMap) {
     //List of Order  Items to be inserted
     List<OrderItem> orderItemList = new List<OrderItem>();
      
     if(ordersToBeInserted.size() > 0){
        for(Order ordr :ordersToBeInserted){
           //App Product
           OrderItem oItem1 = newOrderItem(ordr.Id, prodIdToPbeId.get(selectedAppProd), appPrice);
           oItem1.AppID__c = appIdToProductMap.get(selectedAppProd).AppID__c;
           orderItemList.add(oItem1);
        
           //Kit Product
           OrderItem oItem2 = newOrderItem(ordr.Id, prodIdToPbeId.get(selectedKitProd), 0);
           oItem2.Carrier__c = ordItem.Carrier__c;
           oItem2.Service_Level__c = ordItem.Service_Level__c;
           oItem2.ShipTo_Contact__c = ord.ShipToContactId;
           oItem2.BillTo_Contact__c = ord.BillToContactId;
           orderItemList.add(oItem2);
        
           //Helix Sequence Revenue Product
           OrderItem oItem3 = newOrderItem(ordr.Id, prodIdToPbeId.get(prodNameToIdMap.get('Helix Sequence Revenue')), helixSeqRevenue);
           orderItemList.add(oItem3);
        
           //Shipping & Handling Product
           OrderItem oItem5 = newOrderItem(ordr.Id, prodIdToPbeId.get(prodNameToIdMap.get('Shipping & Handling')), shippingNHandling);
           orderItemList.add(oItem5);
        
           //Sales Tax Product
           OrderItem oItem6 = newOrderItem(ordr.Id, prodIdToPbeId.get(prodNameToIdMap.get('Sales Tax')), salesTax);
           orderItemList.add(oItem6);
           
           //Helix Referral Fee Product
           OrderItem oItem7 = newOrderItem(ordr.Id, prodIdToPbeId.get(prodNameToIdMap.get('Helix Referral Fee')), helixReferralFee);
           orderItemList.add(oItem7);
           
           //Partner Revenue Share Product
           OrderItem oItem8 = newOrderItem(ordr.Id, prodIdToPbeId.get(prodNameToIdMap.get('Partner Revenue Share')), partnerRevenueShare);
           orderItemList.add(oItem8);
        }
     }
  
     if(orderItemList.size() > 0){
        insert orderItemList;
     }
   }
   
   // return map of product id and its pricebookentry id
   public Map<Id, Id> getProductPbeIdMap(Set<Id> prodIdSet, Id pricebookId) {
       //Querying the PriceBookEntry
       List<PriceBookEntry> pbeList = new List<PriceBookEntry>([ Select Id, Product2Id, Product2.Name From PriceBookEntry 
                                                                   Where Product2Id In :prodIdSet and PriceBook2Id = :pricebookId ]);
       //Map of Product Id to its PricebookEntryId
       Map<Id, Id> prodIdToPbeId = new Map<Id, Id>();
      
       
       for(PricebookEntry pbe :pbeList){
           prodIdToPbeId.put(pbe.Product2Id, pbe.Id);
       }
       
       return prodIdToPbeId;
   }
   
   //method to called to instantiate and populate a new Order Item
   public OrderItem newOrderItem(Id orderId, Id pbeId, Double price){
      OrderItem temp = new OrderItem();
      temp.OrderId = orderId;
      temp.PriceBookEntryId = pbeId;
      temp.UnitPrice = price;
      temp.Quantity = 1;
      return temp;
   }
   
   //method to be called when "Cancel" button is pressed on the VF page CreateOrderPage
   public PageReference cancel(){
      PageReference cancelPage = new PageReference('/home/home.jsp');
      return cancelPage;
   }
   
   // return helix partner account id
   public Id getHelixPartnerAccId() {
        List<Account> accList = [select id from Account where Partner_Id__c = :System.Label.Helix_Promotional_Account];
        Id accId;
        if(accList != null && accList.size() > 0) {
            accId = accList[0].id;
        }
        return accId;
   }
   
   // return standard pricebook id
   public Id getStandardPricebookId() {
       Id pricebookId;
       if(Test.isRunningTest()) {
           pricebookId = Test.getStandardPricebookId();
       } else {
           pricebookId = [select id from Pricebook2 where isActive = true and isStandard = true Limit 1].Id;
       }
       return pricebookId;
   }
}