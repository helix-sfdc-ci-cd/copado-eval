public class OrderController {
    
    public String soId {get; set;}
    
    public SuperOrder__c getSuperOrder() {
        SuperOrder__c superOrder;
        if(soId != null)
            superOrder = [select Name, Total_Tax__c from SuperOrder__c where id = :soId];
        
        return superOrder;
    }
    
    public OrderDetails getOrderDetails() {
        OrderDetails orderDetail = new OrderDetails();
        List<OrderItem> orderItemList = [select UnitPrice, PricebookEntry.Product2.Type__c, PricebookEntry.Product2.Name, 
                                        Order.BillToContact.FirstName, Order.ShipToContact.Name, Service_Level_Customer_Facing__c,
                                        Order.ShipToContact.MailingStreet, Order.ShipToContact.MailingCity, Order.ShipToContact.MailingState, 
                                        Order.ShipToContact.MailingCountry, Order.ShipToContact.MailingPostalCode, App_Partner_Account__c 
                                        from OrderItem where Order.SuperOrder__c = :soId
                                        and (PricebookEntry.Product2.Type__c = 'APP' 
                                            or PricebookEntry.Product2.Type__c = 'S&H'
                                            or PricebookEntry.Product2.Type__c = 'KIT')];
        Decimal subTotal = 0;
        Decimal shippingCost = 0;
        Integer quantity = 0;
        Integer numberOfKits = 0;
        
        for(OrderItem oi :orderItemList) {
            if(oi.PricebookEntry.Product2.Type__c == 'APP') {
                orderDetail.productName = oi.PricebookEntry.Product2.Name;
                subTotal += oi.UnitPrice;
                orderDetail.partnerChannel = oi.App_Partner_Account__c;
                quantity++;
            } else if(oi.PricebookEntry.Product2.Type__c == 'S&H') {
                shippingCost += oi.UnitPrice;
            } else if(oi.PricebookEntry.Product2.Type__c == 'KIT') {
                orderDetail.shipType = oi.Service_Level_Customer_Facing__c;
                numberOfKits++;
            }
            
            orderDetail.billToContactName = oi.Order.BillToContact.FirstName;
            orderDetail.shipToContactName = oi.Order.ShipToContact.Name;
            orderDetail.shipToStreet = oi.Order.ShipToContact.MailingStreet;
            orderDetail.shipToCity = oi.Order.ShipToContact.MailingCity;
            orderDetail.shipToState = oi.Order.ShipToContact.MailingState;
            orderDetail.shipToCountry = oi.Order.ShipToContact.MailingCountry;
            orderDetail.shipToPostalCode = oi.Order.ShipToContact.MailingPostalCode;
        }
        orderDetail.subTotal = subTotal.setScale(2);
        orderDetail.shippingCost = shippingCost.setScale(2);
        orderDetail.quantity = quantity;
        orderDetail.numberOfKits = numberOfKits;
        return orderDetail;
    }
    
    public class OrderDetails {
        public Decimal subTotal {get; set;}
        public Integer quantity {get; set;}
        public Decimal shippingCost {get; set;}
        public Decimal grandTotal {get; set;}
        public String productName {get; set;}
        public String partnerChannel {get; set;}
        public String billToContactName {get; set;}
        public String shipToContactName {get; set;}
        public String shipToStreet {get; set;}
        public String shipToCity {get; set;}
        public String shipToState {get; set;}
        public String shipToCountry {get; set;}
        public String shipToPostalCode {get; set;}
        public String shipType {get; set;}
        public Integer numberOfKits {get; set;}
    }
}