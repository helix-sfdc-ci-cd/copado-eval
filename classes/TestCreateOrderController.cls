@isTest//(seeAllData = true)
public class TestCreateOrderController {
    
    //This method provides code coverage for the class CreateOrderController
    public static testmethod void unitTest() {
       
       //Creating test data
       /* Partner_Id__c added on 2/22/2017 due to test class failure */
       Account partnerAcc = new Account(Name = 'Partner Acc', Partner_Id__c = System.Label.Helix_Promotional_Account);
       insert partnerAcc;
       
       Product2 appProd = new Product2(Name = 'Test App Prod', Type__c = 'APP', Partner_Account__c = partnerAcc.Id, AppID__c = '23456');
       insert appProd;
       
       Product2 kitProd = new Product2(Name = 'Test kit Prod', Type__c = 'KIT', Partner_Account__c = partnerAcc.Id);
       insert kitProd;
       
       Account shippingAcc = new Account(Name = 'Shipping Acc');
       insert shippingAcc;
       
       Contact shipToCon = new Contact(LastName = 'ShippingContact', AccountId = shippingAcc.Id);
       insert shipToCon;
       
       Account billingAcc = new Account(Name = 'Billing Acc');
       insert billingAcc;
       
       Contact billToCon = new Contact(LastName = 'BillingContact', AccountId = billingAcc.Id);
       insert billToCon; 
       
       CreateOrderController ctrl = new CreateOrderController();
       ctrl.getAppList();
       ctrl.getKitList();
       ctrl.createOrder();
       ctrl.cancel();
                  
       ctrl.numOfKits = 2;
       ctrl.appPrice = 1.00;
       ctrl.helixSeqRevenue = 1.00;
       ctrl.kitRevenue =1.00;
       ctrl.shippingNHandling = 1.00;
       ctrl.salesTax = 1.00;
       ctrl.helixReferralFee = 1.00;
       ctrl.partnerRevenueShare = 1.00;
       ctrl.selectedAppProd = appProd.Id;
       ctrl.selectedKitProd = kitProd.Id;
       ctrl.ord.BillToContactId = billToCon.Id;
       ctrl.ord.ShipToContactId = shipToCon.Id;
       ctrl.ord.ShippingStreet = '876 Meteor Dr';
       ctrl.ord.ShippingCity = 'Sunnyvalw';
       ctrl.ord.ShippingState = 'CA';
       ctrl.ord.ShippingPostalCode = '94087';
       ctrl.ord.Company_ShipTo__c = 'Test Company';
       ctrl.ordItem.Carrier__c = 'USPS';
       ctrl.ordItem.Service_Level__c = '2-day';
       
       ctrl.submit();
       
       List<Order> orderList = [ Select Id, ShippingCountry, (select id, ShipTo_Contact__c, BillTo_Contact__c from orderitems) From Order ];
       system.assertEquals(orderList.size() , 2);
       system.assertEquals(orderList[0].ShippingCountry, 'US');
       for(Order o : orderList){
           for(OrderItem item : o.orderItems){
               system.assertEquals(item.Shipto_Contact__c , shipToCon.Id);
               system.assertEquals(item.Billto_Contact__c , billToCon.Id);
           }
           
       }
    }
}