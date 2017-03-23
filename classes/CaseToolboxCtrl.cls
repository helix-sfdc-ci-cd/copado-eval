/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 11/10/2016
    @Purpose: This is the class for service toolbox initiated from Case page
*/
public class CaseToolboxCtrl {
    // variable for case
    Case caseObj;
    // constructor
    public caseToolboxCtrl(ApexPages.StandardController sc) {
        caseObj = (Case)sc.getRecord();
        
    }
    // redirect to tool box
    public PageReference goToToolbox() {
        caseObj = [select Order__r.Helix_Order_Number__c from Case where id = :caseObj.id];
        
        // pass helix order number as search keyword in url
        String searchKeyword = '';
        if(caseObj != null && caseObj.Order__c != null && caseObj.Order__r.Helix_Order_Number__c != null)
            searchKeyword = caseObj.Order__r.Helix_Order_Number__c;
        return new PageReference('/apex/CustomerServicesToolbox?kwrd='+searchKeyword).setRedirect(true);
    }
}