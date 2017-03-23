/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/10/2016
    @Purpose: This is the class for service toolbox initiated from Order page
*/
public class OrderToolboxCtrl {
    // variable for order
    Order orderObj;
    // constructor
    public orderToolboxCtrl(ApexPages.StandardController sc) {
        orderObj = (Order)sc.getRecord();
        
    }
    // redirect to tool box
    public PageReference goToToolbox() {
        orderObj = [select Helix_Order_Number__c from Order where id = :orderObj.id];
        
        // pass helix order number as search keyword in url
        String searchKeyword = '';
        if(orderObj.Helix_Order_Number__c != null)
            searchKeyword = orderObj.Helix_Order_Number__c;
        return new PageReference('/apex/CustomerServicesToolbox?kwrd='+searchKeyword).setRedirect(true);
    }
}