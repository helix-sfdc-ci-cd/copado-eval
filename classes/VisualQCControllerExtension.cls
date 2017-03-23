/**
* Controller for Accessioning App. page. It handeles scanning, searching, updating of records.
* @author Roman Dovbush (roman@4front.se)
* @LastModified 2016-04-26
* @Comments:
* 2016-04-01 : Roman Dovbush - Original (v.1.0)
* 2016-04-18 : Roman Dovbush - 1. Kit_ID_formatted field is added to display it in Scan History table. Scanned Kit Id goes without dashes,
*                              Kit_ID_formatted is formula field that modifies standard Kit_ID field.
*                              2. Method removeNewLineChar() is modified: remove() changed to left().
* 2016-04-22 : Roman Dovbush - 1. New feature added - prevent store of duplicate Kit ID in Scan History.
*                              New method added findDuplicate(String duplicateKitID).
* 2016-05-25 : Linus Löfberg - Introduced method checkAccessionLocation for checking for access location.
* 2016-07-08 : Roman Dovbush - Introduced method validateWellLocation for checking Well Location value and incrementing it.
* 2016-11-16 : Linus Löfberg - Added check for Accessioning Status " CANCELLED" before processing scanned kits.
* 2017-01-12 : Linus Löfberg - Introducing feature checking attached contact to Kit and Setting status to hold if missing.
*/


public with sharing class VisualQCControllerExtension {

    public String kitID {get; set;}
    public String mode {get; set;}
    public String failureReason {get; set;}
    public String changeReason {get; set;}
    public String otherReasonValue {get; set;}
    public String box {get; set;}
    public String wellLocation {get; set;}
    public String searchKitId {get; set;}
    public String letterWL {get; set;}

    public Boolean kitFound {get; set;}
    public Boolean contactFound {get; set;}
    public Boolean initialLoading {get; set;}
    public Boolean selectAll {get; set;}
    public Boolean managerAccess {get; set;}
    public Boolean selectRecord {get; set;}
    public Boolean duplicateFound {get; set;}
    public Boolean invalidWL {get; set;}
    public Boolean isSelected {get; set;}

    public Integer cycleMaximum {get; set;}
    public Integer currentValue {get; set;}
    public Integer tempNumberWL {get; set;}

    public List<VisualQCControllerExtension.ScanHistory> scanHistoryList {get; set;}
    public List<OrderItem> failReviewItems {get; set;}
    public List<OrderItem> failReviewRecord {get; set;}

    public String accessionLocation {get; set;}
    @testVisible
    private String charsForWellLocation {get; set; }

    /**
    * Setting initial values in constructor
    */
    public VisualQCControllerExtension() {
        scanHistoryList = new List<VisualQCControllerExtension.ScanHistory>();
        failReviewItems = new List<OrderItem>();
        failReviewRecord = new List<OrderItem>();
        kitFound = true;
        contactFound = false;
        initialLoading = true;
        selectAll = false;
        managerAccess = false;
        selectRecord = false;
        accessionLocation = null;
        mode = 'pass';
        failureReason = 'Low Volume';  // initial value of Failure Reason pick list on Fail page
        changeReason = 'Low Volume';   // initial value of Failure Reason pick list on Review page
        otherReasonValue = '';         // initial value of Other Reason input field on Review page
        currentValue = 0;
        cycleMaximum = 0;
        accessManagerView();
        charsForWellLocation = 'ABCDEFGH';
        invalidWL = false;
        isSelected = true;
    }


    /**
    * This method is invoked page is loaded.
    * This method checks user's Accessioning Location, if it is not set, method fires an error message.
    * Has no return value.
    */
    public void checkAccessionLocation() {
        //2016-05-25 : Linus Löfberg - Introduced if statement below checking for access location
        if (accessionLocation == null) {
            User currentUser = [SELECT Id, Accession_Location__c FROM User WHERE Id = :UserInfo.getUserId()];

            if (currentUser != null && currentUser.Accession_Location__c != null && currentUser.Accession_Location__c != '') {
                accessionLocation = currentUser.Accession_Location__c;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Accessioning Location on current user is missing.'));
                return;
            }
        }
    }

    /**
    * This method is invoked when you scan Kit. This is the main method where Scan History List is populated.
    * This method updates values of Current Value field, Accessioning_Status__c,
    * Hold_Reason__c, Box__c, Well_Location__c, Failure_Reason__c and Last_Accessioning_Scan__c fields.
    * Has no return value.
    */
    public void findKitIdAndContact() {
        if(accessionLocation == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Accessioning Location on current user is missing.'));
            return;
        }
        kitFound = false;
        contactFound = false;
        initialLoading = false;
        duplicateFound = false;
        if(kitID != '') {
            List<OrderItem> kitList = [Select ID, Kit_ID__c, Kit_ID_formatted__c, Kit_Order_Status__c, registeredBy__c, Accessioning_Status__c, Hold_Reason__c, Last_Accessioning_Scan__c, Box__c, Well_Location__c, Failure_Reviewed_By__c from OrderItem Where Kit_ID__c = :kitID];
            if(!kitList.isEmpty()) {
                if (kitList[0].Accessioning_Status__c != null && kitList[0].Accessioning_Status__c.equalsIgnoreCase('CANCELLED')) {
                    kitFound = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You have scanned a cancelled kit. Cancelled kits cannot be accessioned!'));
                } else {
                    OrderItem itemToUpdate = processKitItem(kitList[0]);
                }
            }
            kitID = '';
        }
    }


    private OrderItem processKitItem(OrderItem oItem) {
        kitFound = true;
        // For every scanned sample ScanHistory obj is created to populate
        // Scan History table on the page
        VisualQCControllerExtension.ScanHistory sh = new VisualQCControllerExtension.ScanHistory();
        if(mode == 'pass') {
            findDuplicate(kitID);
            if(oItem.registeredBy__c != null) { // do I need here (&& != '')
                contactFound = true;
                if(!duplicateFound) {
                    oItem.Accessioning_Status__c = 'Pass';
                    if(currentValue >= cycleMaximum) {
                        currentValue = 1;
                    }
                    else {
                        currentValue++;
                    }
                }
            }
            else {
                oItem.Accessioning_Status__c = 'Hold';
                oItem.Hold_Reason__c = 'Contact Missing';
            }
        }

        if(mode == 'storage') {
            wellLocation = wellLocation.trim();
            validateWellLocation(wellLocation);
            if(!invalidWL) {
                oItem.Box__c = box;
                oItem.Well_Location__c = wellLocation;
                wellLocation = letterWL + tempNumberWL;
            }
            else {
                return oItem;
            }
        }

        if(mode == 'fail') {
            //2017-01-12 : Linus Löfberg - Introduced if statement below checking attached contact to Kit and Setting status to hold if missing.
            if(oItem.registeredBy__c != null) {
                contactFound = true;
                oItem.Accessioning_Status__c = 'FAILURE REVIEW';
                if (failureReason != 'Other') {
                    oItem.Failure_Reason__c = failureReason;
                } else {
                    oItem.Failure_Reason__c = otherReasonValue;
                }
            } else {
                oItem.Accessioning_Status__c = 'Hold';
                oItem.Hold_Reason__c = 'Unregistered Kit';
            }
        }
        oItem.Location__c = accessionLocation;
        oItem.Last_Accessioning_Scan__c = System.now();

        System.debug('This is ' + mode);            // for debug reasons;
        System.debug('This is ' + failureReason);   // for debug reasons;

        if(!duplicateFound) {
            sh.kitId = oItem.Kit_ID__c;
            sh.kitIdform = oItem.Kit_ID_formatted__c;
            sh.kitStatus = oItem.Kit_Order_Status__c;
            sh.accessioningStatus = oItem.Accessioning_Status__c;
            sh.holdReason = oItem.Hold_Reason__c;
            sh.failureReasonScanned = oItem.Failure_Reason__c;
            sh.boxScanned = oItem.Box__c;
            sh.wellLocScanned = oItem.Well_Location__c;
            sh.lastScanDateTime = oItem.Last_Accessioning_Scan__c; // do I need to update SF DB with this value?
            sh.currentValScanned = currentValue;
            scanHistoryList.add(sh);
        }
        update oItem;
        return oItem;
    }


    /**
    * This method validates and increments Well Location value from A1 to H12 (and back to A1).
    * @param wellLocation
    * @return wellLocation
    */
    private void validateWellLocation(String wl) {
        invalidWL = false;
        letterWL = '';
        tempNumberWL = 0;
        if(wl != '') {
            letterWL = wl.substring(0, 1);
        }
        else {
           invalidWL = true;
           return;
        }
        if(wl.length() == 2) {
            tempNumberWL = Integer.valueOf(wl.substring(1, 2));
        }
        else if (wl.length() == 3) {
            try {
                tempNumberWL = Integer.valueOf(wl.substring(1, 3));
            }
            catch (Exception e) {
                invalidWL = true;
                return;
            }
        }
        else {
            invalidWL = true;
            return;
        }
        if(!charsForWellLocation.contains(letterWL)) {
            invalidWL = true;
            return;
        }
        if(tempNumberWL > 0 && tempNumberWL < 13) {
            if(tempNumberWL == 12) {
                tempNumberWL = 1;
                if(letterWL != 'H') {
                    Integer index = charsForWellLocation.indexOf(letterWL);
                    letterWL = charsForWellLocation.substring(index + 1, index + 2);
                }
                else {
                    letterWL = 'A';
                }
            }
            else {
                tempNumberWL++;
            }
        }
        else {
            invalidWL = true;
            return;
        }
    }

    /**
    * This method is invoked when you press Refresh button on the page.
    * This method queries for all records with Accessioning Status 'FAILURE REVIEW'.
    * Has no return value.
    */
    public void refreshFailReviewItems() {
        failReviewItems.clear();
        failReviewItems = new List<OrderItem>([Select ID, Kit_ID__c, Kit_ID_formatted__c, Kit_Order_Status__c, Accessioning_Status__c,
                            Failure_Reason__c, Failure_Reviewed_By__c, Last_Accessioning_Scan__c, Select_Product__c
                            from OrderItem Where Accessioning_Status__c = 'FAILURE REVIEW']);
        selectAll = false;
    }

    /**
    * This method is invoked when you search for particular Kit ID in database.
    * This method queries for the record with particular Kit ID.
    * Has no return value.
    */
    public void getFailReviewItems() {
        failReviewItems.clear();
        kitFound = false;
        //selectRecord = false;
        if(searchKitId != '') {
            failReviewItems = new List<OrderItem>([Select ID, Kit_ID__c, Kit_ID_formatted__c, Kit_Order_Status__c, Accessioning_Status__c,
                                Failure_Reason__c, Failure_Reviewed_By__c, Last_Accessioning_Scan__c, Select_Product__c
                                from OrderItem
                                Where Kit_ID__c = :searchKitId]);
            if(!failReviewItems.isEmpty()) {
                kitFound = true;
                //selectRecord = true;
            }
            selectAll = false;
            searchKitId = '';        }
    }

    /**
    * This method is invoked when you press Update button on the page.
    * Failure Reason of selected records will be updated in the database (SFDC).
    * When user selects Failure Reason = 'Other' then Accessioning Status in record
    * will be updated to 'FAIL' and Failure Reason to any user typed.
    * Has no return value.
    */
    public void selectProductToUpdate() {
        if(!validateSelection()) {
            return;
        }
        for(OrderItem item : failReviewItems) {
            if(item.Select_Product__c) {
                if(changeReason == 'Change to Pass') {
                    item.Accessioning_Status__c = 'PASS';
                    item.Failure_Reason__c = '';
                    item.Failure_Reviewed_By__c = UserInfo.getUserId();
                    item.Last_Accessioning_Scan__c = System.now();
                    item.Select_Product__c = false;
                }
                else if(changeReason == 'Other') {
                    item.Accessioning_Status__c = 'FAIL';
                    item.Failure_Reason__c = otherReasonValue;
                    item.Failure_Reviewed_By__c = UserInfo.getUserId();
                    item.Last_Accessioning_Scan__c = System.now();
                    item.Select_Product__c = false;
                }
                else {
                    item.Accessioning_Status__c = 'FAIL';
                    item.Failure_Reason__c = changeReason;
                    item.Failure_Reviewed_By__c = UserInfo.getUserId();
                    item.Last_Accessioning_Scan__c = System.now();
                    item.Select_Product__c = false;
                }
            }
        }
        selectAll = false;
        update failReviewItems;
    }

    /**
    * This method is invoked when you press Confirm button on the page.
    * Accessioning Status of selected records will be updated to 'FAIL' in SFDC.
    * Has no return value.
    */
    public void selectProductToConfirm() {
        if(!validateSelection()) {
            return;
        }
        for(OrderItem item : failReviewItems) {
            if(item.Select_Product__c) {
                item.Accessioning_Status__c = 'FAIL';
                item.Failure_Reviewed_By__c = UserInfo.getUserId();
                item.Select_Product__c = false;
            }
        }
        selectAll = false;
        update failReviewItems;
    }

    /**
    * This method checks if there is at least one record selected in Scan Table.
    * If not - there is warning message appear on the VF page.
    * return true/false.
    */
    private Boolean validateSelection() {
        for(OrderItem item : failReviewItems) {
            if(item.Select_Product__c) {
                isSelected = true;
                return true;
            }
        }
        isSelected = false;
        return false;
    }

    /**
    * This method is created to select or deselect ALL records in Scan table.
    * This method changes checkbox's value.
    * Has no return value.
    */
    public void unselectAll() {
        if(selectAll) {
            for(OrderItem o : failReviewItems) {
                o.Select_Product__c = false;
            }
            selectAll = false;
        }
        else {
            for(OrderItem o : failReviewItems) {
                o.Select_Product__c = true;
            }
            selectAll = true;
        }
    }

    /**
    * This method checks if Custom Settings exist in SFDC. If yes - method compares
    * list of profiles with curent user's profile - when they match access to Failure Review page
    * is allowed, if not - disallowed. System Administrator's profile ID is used as default
    * if no custom settings speciifed.
    * Has no return value.
    */
    public void accessManagerView() {

        Set_Profile_ID__c pid = Set_Profile_ID__c.getOrgDefaults();
        String setProfileID = pid.Profile_ID__c;
        String currentProfileID = UserInfo.getProfileId();

        System.debug('Custom settings: ' + setProfileID);
        System.debug('Current profile ID: ' + currentProfileID);

        if(setProfileID == '' || setProfileID == null) {
            managerAccess = false;
        }
        else {
            if(setProfileID.contains(currentProfileID)) {
                managerAccess = true;
            }
            else {
                managerAccess = false;
            }
        }
    }

    /**
    * This method clears the Scan History list on the page every time user
    * switches the Accessioning mode.
    * Has no return value.
    */
    public void clearScanList() {
        scanHistoryList.clear();
    }

    /**
    * This method searchs if Kit ID is already added to Scan History list
    * and return duplicateFound = true to prevent increasing Current Value for particular scanning.
    * So on Pass page duplicate Kit IDs can't be added to Scan History list.
    * @param duplicateKitID
    * @return boolean value
    * 2016-04-22 : Roman Dovbush - method is created.
    */
    public Boolean findDuplicate(String duplicateKitID) {
        for(ScanHistory scannedKit : scanHistoryList) {
            if(duplicateKitID == scannedKit.kitId) {
                duplicateFound = true;
                return true;
            }
        }
        return false;
    }

/* ----------------------------------------------------- */
    /**
    * Special class for keeping scanned elements.
    * 2016-04-18 : Roman Dovbush - kitIdform field is added.
    *
    */
    public class ScanHistory {
        public String kitId {get; set;}
        public String kitIdform {get; set;}
        public Integer currentValScanned {get; set;}
        public String boxScanned {get; set;}
        public String wellLocScanned {get; set;}
        public String kitStatus {get; set;}
        public String failureReasonScanned {get; set;}
        public String holdReason {get; set;}
        public String accessioningStatus {get; set;}
        public Datetime lastScanDateTime {get; set;}
    }

}