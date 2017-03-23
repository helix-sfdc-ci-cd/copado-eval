/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/10/2016
    @Purpose: This is the class for service toolbox initiated from Super Order page
*/
public class SuperOrderToolboxCtrl {
    // variable for super order
    SuperOrder__c superOrderObj;
    // constructor
    public superOrderToolboxCtrl(ApexPages.StandardController sc) {
        superOrderObj = (SuperOrder__c)sc.getRecord();
        
    }
    // redirect to tool box
    public PageReference goToToolbox() {
        superOrderObj = [select Name from SuperOrder__c where id = :superOrderObj.id];
        // pass super order name as search keyword in url
        String searchKeyword = superOrderObj.Name;
        return new PageReference('/apex/CustomerServicesToolbox?kwrd='+searchKeyword).setRedirect(true);
    }
}