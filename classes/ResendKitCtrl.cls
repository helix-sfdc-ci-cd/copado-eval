/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/8/2016
    @Purpose: This is the class for resending the kit
*/
public class ResendKitCtrl {
    
    // selected kit line id to resend
    String kitLineId = ApexPages.currentPage().getParameters().get('kitLineId');
    
    // variable to clone order item
    public OrderItem clonedOrderItem { get; set; }
    // variable to store order information
    public Order orderRecord { get; set; }
    public String selectedKit { get; set; }
    // order item to be cloned
    public OrderItem oi { get; set; }
    // return url to redirect to when resend is clicked or on Cancel
    String retURL = ApexPages.currentPage().getParameters().get('retURL');
    
    // constructor
    public resendKitCtrl() {
        clonedOrderItem = new OrderItem();
        
        // create order item (to be cloned) query
        String soql = 'select Order.AccountId, BillTo_Contact__c, ShipTo_Contact__c, AppID__c, Carrier__c, Kit_Resend_Reason__c, Service_Level__c, PricebookEntryId, PricebookEntry.Product2Id, OrderId, Quantity ' +
                        'from OrderItem where id = :kitLineId';
        // query order item
        oi = (OrderItem)Database.query(soql);
        
        selectedKit = oi.PricebookEntry.Product2Id;
        // clone order item
        clonedOrderItem = oi.clone(false, true);
        // query order record
        orderRecord = [select OrderNumber, ShippingStreet, ShippingCity, ShippingState, ShipToContactId, BillToContactId,
                                ShippingPostalCode, Kit_Resends__c from Order where id = :oi.OrderId];
    
        
    }
    
    /* 1. create new order item
       2. update existing order item
       3. update order
    */
    public PageReference doSave() {
        
        try {
            Id pbeId;
            List<PricebookEntry> pbe = [select id from PricebookEntry where Product2Id = :selectedKit and Pricebook2.isStandard = true];
            if(pbe != null && pbe.size() > 0) {
                clonedOrderItem.PricebookEntryId = pbe[0].id;
            }
            
            clonedOrderItem.Kit_Order_Status__c = 'Submit';
            clonedOrderItem.Resend_Original_Kit__c = oi.id;
            clonedOrderItem.Integration_Test__c = true;
            clonedOrderItem.Integrate_with_DNAG__c = true;
            clonedOrderItem.UnitPrice = 0;
            clonedOrderItem.BillTo_Contact__c = orderRecord.BillToContactId;
            clonedOrderItem.ShipTo_Contact__c = orderRecord.ShipToContactId;
            insert clonedOrderItem;
            
            oi.Sample_Status__c = 'Cancelled';
            oi.Accessioning_Status__c = 'Cancelled';
            oi.Integration_Test__c = true;
            update oi;
            
            orderRecord.Service_Level__c = clonedOrderItem.Service_Level__c;
            orderRecord.Kit_Resends__c = (orderRecord.Kit_Resends__c != null ? orderRecord.Kit_Resends__c : 0) + 1;
            update orderRecord;
            
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference(retURL).setRedirect(true);
    }
    
    public List<SelectOption> getKitProducts() {
        List<SelectOption> kitOptions = new List<SelectOption>();
        for(Product2 prod :[select Name, ProductCode from Product2 where Type__c = 'KIT']) {
            kitOptions.add(new SelectOption(prod.id, prod.Name + ' (' + prod.ProductCode + ') '));
        }
        return kitOptions;
    }
    
    // return to previous page on cancel
    public PageReference doCancel() {
        return new PageReference(retURL).setRedirect(true);
    }
}