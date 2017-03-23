public class SuperOrderController{

   public Id tempId {get; set;}
   public List<OrderItem> orderItemList {get; set;}
   
   //Constructor
   public SuperOrderController(ApexPages.StandardController controller){
      //tempId = 'a024C0000014als';
      this.tempId = controller.getId();
      system.debug('tempId--'+tempId);
   }
   
   //This method queries and collects all the Orders and Order Products (Type = KIT) to be displayed
   public PageReference displayData(){
         orderItemList = [Select Id, OrderId,Order.OrderNumber, OrderItemNumber, Kit_ID_formatted__c, Kit_Order_Status__c, Accessioning_Status__c, Sample_Status__c,
                          registeredBy__c, Kit_Order_Updated__c ,Last_Accessioning_Scan__c, Sample_Status_Updated__c, OB_Tracking_Link__c, RTRN_Tracking_Link__c,
                          PriceBookEntryId, PriceBookEntry.Product2.Name
                          From OrderItem Where Type__c in ('KIT','APP') and Order.superOrder__c = :tempId ];
      
      return null;
   }
}