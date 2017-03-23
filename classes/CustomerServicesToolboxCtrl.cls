/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/8/2016
    @Purpose: This is the base class for services toolbox
*/
public class CustomerServicesToolboxCtrl {
    
    // search keyword to search kit/ order/ superorder
    public String searchKeyword {get; set;}
    // information of order and its kit lines
    public OrderDetail orderDetails {get; set;}
    // display results on page after search is performed
    public Boolean showResults {get; set;}
    // display super order section when super order exists
    public Boolean showSuperOrder {get; set;}
    
    // constructor
    public customerServicesToolboxCtrl() {
        
        showResults = false;
        
        // get search keyword from url
        String keyword = ApexPages.currentPage().getParameters().get('kwrd');
        if(keyword != null && keyword != '') {
            searchKeyword = keyword;
            searchOrder();
        }
    }
    
    // method to query and search order
    public PageReference searchOrder() {
        orderDetails = new OrderDetail();
        try {
            showResults = false;
            
            // if search keyword is not entered, display error message
            if(searchKeyword == null || searchKeyword == '') {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'Please enter a search keyword.'));
                return null;
            }
            
            // query order, kit lines and super order
            List<Order> orderLineList = [select SuperOrder__c, SuperOrder__r.Name, SuperOrder__r.CreatedDate, Status,
                SuperOrder__r.Total_Amount_Charged__c, Helix_Order_Number__c, Partner_Channel__c, Partner_Channel__r.Name, 
                App_Partner__c, App_Partner__r.Name, Netsuite_Sales_Order_Number__c, 
                            (select Kit_ID__c, Kit_Order_Status__c, Accessioning_Status__c, Type__c, Sample_Status__c
                             from OrderItems where Type__c = 'KIT') 
                    from Order 
                    where Helix_Order_Number__c = :searchKeyword 
                OR (SuperOrder__c != null and SuperOrder__c = :[select Order.SuperOrder__c from OrderItem where Kit_Id__c = :searchKeyword 
                    OR Order.Helix_Order_Number__c = :searchKeyword OR Order.SuperOrder__r.Name = :searchKeyword limit 1].Order.SuperOrder__c)
                OR id = :[select OrderId from OrderItem where Kit_Id__c = :searchKeyword 
                    OR Order.Helix_Order_Number__c = :searchKeyword OR Order.SuperOrder__r.Name = :searchKeyword limit 1].OrderId];
        
            Integer orderCount = 0;
            for(Order o :orderLineList) {
                // if super order exists then add its details to wrapper variables
                if(o.SuperOrder__c != null) {
                    showSuperOrder = true;
                    orderDetails.soName = o.SuperOrder__r.Name;
                    orderDetails.soId = o.SuperOrder__c;
                    orderDetails.soCreatedDate = o.SuperOrder__r.CreatedDate.format();
                    orderDetails.soTotalAmountPaid = o.SuperOrder__r.Total_Amount_Charged__c;
                }
                orderCount++;
                orderDetails.orderList.add(o);
            }
            orderDetails.soTotalOrders = orderCount;
            showResults = true;
        
        } catch(Exception e) {
            // if an error occurred during search then display message
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Search for Super Orders, Orders, or Kits by using the full ID. Partial search terms are not currently supported.'));
        }
        return null;
    }
    
    // go to kit resend page
    public PageReference resendKit() {
        String kitId = ApexPages.currentPage().getParameters().get('kitId');
        System.debug('kitId===' + kitId);
        return new PageReference('/apex/ResendKit?kitLineId=' + kitId + '&kwrd=' + searchKeyword + '&retURL=/apex/CustomerServicesToolbox?kwrd=' + searchKeyword).setRedirect(true);
    }
    
    // order details wrapper class
    public class OrderDetail {
        public String soName { get; set; }
        public String soId { get; set; }
        public String soCreatedDate { get; set; }
        public Decimal soTotalAmountPaid { get; set; }
        public Integer soTotalOrders { get; set; }
        public List<Order> orderList { get; set; }
        
        public OrderDetail() {
            orderList = new List<Order>();
        }
    }
}