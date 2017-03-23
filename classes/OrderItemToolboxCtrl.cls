/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/10/2016
    @Purpose: This is the class for service toolbox initiated from Order Product page
*/
public class OrderItemToolboxCtrl {
    // variable for order item
    OrderItem orderItemObj;
    // constructor
    public orderItemToolboxCtrl(ApexPages.StandardController sc) {
        orderItemObj = (OrderItem)sc.getRecord();
        
    }
    // redirect to tool box
    public PageReference goToToolbox() {
        orderItemObj = [select Kit_ID__c from OrderItem where id = :orderItemObj.id];
        
        // pass kit id as search keyword in url
        String searchKeyword = '';
        if(orderItemObj.Kit_ID__c != null)
            searchKeyword = orderItemObj.Kit_ID__c;
        
        return new PageReference('/apex/CustomerServicesToolbox?kwrd='+searchKeyword).setRedirect(true);
    }
}