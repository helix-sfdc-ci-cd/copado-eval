/*
    @author: Martin Haagen (Thirdwave Analytics)
    @Date: 9/30/2016
    @Purpose: This is helper methods for the KitSearch page.

    Changelog:
    2017-01-13 - Linus Löfberg (llofberg@thirdwaveanalytics.com)
    	Added feature to separete search input by whitespace delimiter in order to query specific list of kit id's.
    2017-01-18 - Linus Löfberg (llofberg@thirdwaveanalytics.com)
    	Added additional searchable fields toggled by checkboxes on page.
*/
global with sharing class KitSearchController {

    @RemoteAction
    global static OrderItem[] kitSearch(String searchString, Map<String, Boolean> searchForMap) {

        System.debug(searchForMap);

		List<String> listOfStrings = new List<String>();

        if (searchForMap.get('kitlist')) {
            listOfStrings = searchString.split('\\s');
        }

        // strip out all non alphanumeric characterds
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
        Matcher matcher = nonAlphanumeric.matcher(searchString);
        string s1 = matcher.replaceAll('');
        // return empty list of nothing to search for
        if (string.isEmpty(s1)) {
            return null;
        }
        s1 = '%' + s1 + '%';

        String fuzzyKitId = '@';
        String fuzzyKitOrderId = '@';
        String fuzzyOutboundTrackingNumber = '@';
        String fuzzyReturnTrackingNumber = '@';

        if (searchForMap.get('kitid')) {
            fuzzyKitId = s1;
        }
        if (searchForMap.get('kitorderid')) {
            fuzzyKitOrderId = s1;
        }
        if (searchForMap.get('outboundtracking')) {
            fuzzyOutboundTrackingNumber = s1;
        }
        if (searchForMap.get('returntracking')) {
            fuzzyReturnTrackingNumber = s1;
        }

        return [SELECT 	Id,
                		OrderId,
                		Order.Type,
                		Order.Helix_Order_Number__c,
                		Order.SuperOrder__r.Id,
                		Order.SuperOrder__r.Name,
                		Kit_ID__c,
                		Kit_ID_formatted__c,
                		Location__c,
                		Kit_Order_Status__c,
                		Accessioning_Status__c,
                		Hold_Reason__c,
                		Last_Accessioning_Scan__c,
                		Box__c,
                		Well_Location__c,
                		Failure_Reviewed_By__c,
                        Outbound_Tracking_Number__c,
                        Return_Tracking_Number__c,
                        Kit_Order_ID__c
                FROM
                		OrderItem
                WHERE
                		Kit_ID__c LIKE :fuzzyKitId
                        OR Kit_Order_ID__c LIKE :fuzzyKitOrderId
                        OR Outbound_Tracking_Number__c LIKE :fuzzyOutboundTrackingNumber
                        OR Return_Tracking_Number__c LIKE :fuzzyReturnTrackingNumber
                        OR Kit_ID__c IN :listOfStrings
                        OR Kit_ID_formatted__c IN :listOfStrings
                LIMIT
                		100];
    }

}