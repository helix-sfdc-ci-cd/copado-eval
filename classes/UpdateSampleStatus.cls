/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 9/6/2016
    @Purpose: This is the UpdateSampleStatus api
*/
@RestResource(urlMapping='/v10/UpdateSampleStatus/*')
global with sharing class UpdateSampleStatus {
    
    // fetch status and date/time fields mapping from custom setting
    private static final Map<String, SampleStatusDateMapping__c> statusDateMap = SampleStatusDateMapping__c.getAll();
    
    @HttpPost
    global static UpdateSampleStatusResponse updateSampleStatus(UpdateSampleStatusRequest updateSampleStatusRequest) {
        if(updateSampleStatusRequest != null) {
            // map of request, to store key as kitid, userid combination and value as list of sample status for each combination
            Map<String, List<UpdateSampleStatusDetail>> kitIdUserIdSampleStatusMap = new Map<String, List<UpdateSampleStatusDetail>>();
            // set of kit id to query OrderItem
            Set<String> kitIdSet = new Set<String>();
            // set of user id to query OrderItem
            Set<String> userIdSet = new Set<String>();
            // declare list of OrderItem to be updated
            List<OrderItem> oiListToUpdate;
            // declare map to store key as kitid, userid combination and value as list of sample status, which are failed to update, for each combination
            Map<String, List<UpdateSampleStatusFailure>> kitIdUserIdFailuresMap;
            
            try {
                // parse the incoming request 
                parseIncomingRequest(updateSampleStatusRequest, kitIdUserIdSampleStatusMap, kitIdSet, userIdSet);
                // get OrderItem map with key as kitid, userid combination and value as OrderItem record for each combination
                Map<String, OrderItem> orderItemMap = getOrderItemMap(kitIdSet, userIdSet);
                // initialize OrderItem list to be updated
                oiListToUpdate = new List<OrderItem>();
                // initialize failure map
                kitIdUserIdFailuresMap = new Map<String, List<UpdateSampleStatusFailure>>();
                
                // loop over kitid, userid key from map of request to check whether kitid, userid combination exist in OrderItem map
                for(String kitIdUserIdKey : kitIdUserIdSampleStatusMap.keySet()) {
                    if(orderItemMap.containsKey(kitIdUserIdKey)) {
                        // if kitid, userid combination exist, then populate values to OrderItem and add it in the update list
                        OrderItem oi = populateOrderItem(kitIdUserIdSampleStatusMap.get(kitIdUserIdKey), orderItemMap.get(kitIdUserIdKey));
                        if(oi != null) {
                            oiListToUpdate.add(oi);
                        }
                        //if oi = null that implies that there is nothing to be updated. Oi is already latest. 
                        //the incoming status messages will be added to success list later.
                    
                    } else {
                        // if kitid, userid combination does not exist, then add to Failure List
                        addToFailureMap(kitIdUserIdFailuresMap, kitIdUserIdSampleStatusMap.get(kitIdUserIdKey), 'Kit Id or User Id does not exist.');
                    }
                }

                // update orderItem list
                if(oiListToUpdate.size() > 0) {
                    Database.update(oiListToUpdate);
                }
                
            } catch(DMLException de) {
                // if dml exception occurs add request sample status in failure list
               for (Integer i = 0; i < de.getNumDml(); i++) {
                   String kitId = String.valueOf(oiListToUpdate[de.getDmlIndex(i)].get('Kit_ID__c'));
                   String userId = String.valueOf(oiListToUpdate[de.getDmlIndex(i)].get('Userid__c'));
                   String kitIdUserIdKey = getkitIdUserIdKey(kitId, userId);
                   System.debug('kitIdUserIdKey====' + kitIdUserIdKey);
                   addToFailureMap(kitIdUserIdFailuresMap, kitIdUserIdSampleStatusMap.get(kitIdUserIdKey), de.getDmlMessage(i));
                   System.debug(Logginglevel.ERROR,'Error in updating record: '+de.getDmlMessage(i));
               }
               
           } catch(Exception e){
               // if exception occurs add all request sample status in failure list
               for(String kitIdUserIdKey :kitIdUserIdSampleStatusMap.keySet()) {
                   addToFailureMap(kitIdUserIdFailuresMap, kitIdUserIdSampleStatusMap.get(kitIdUserIdKey), e.getMessage());
               }
               
           } finally {
               // create response object with success and failure list
               if(kitIdUserIdSampleStatusMap != null && kitIdUserIdFailuresMap != null) {
                   UpdateSampleStatusResponse response = prepareResponse(kitIdUserIdSampleStatusMap, kitIdUserIdFailuresMap);
                   return response;
               }
           }
        }
        return null;
    }
    
    /****************************************************************************************** 
       1. parse the incoming request 
       2. create map of list of sample status which have same combination of kitId and userId
       3. create set of kitId, userId and combination of kitId & userId
    *******************************************************************************************/
    private static void parseIncomingRequest(UpdateSampleStatusRequest updateSampleStatusRequest,
                                             Map<String, List<UpdateSampleStatusDetail>> kitIdUserIdSampleStatusMap,
                                             Set<String> kitIdSet, Set<String> userIdSet) {

        for(UpdateSampleStatusDetail status :updateSampleStatusRequest.sampleStatuses) {
            String kitIdUserIdKey = getkitIdUserIdKey(status.kitId, status.userId);

            List<UpdateSampleStatusDetail> statusList;
            if(kitIdUserIdSampleStatusMap.containsKey(kitIdUserIdKey)) {
                statusList = kitIdUserIdSampleStatusMap.get(kitIdUserIdKey);
            } else {
                statusList = new List<UpdateSampleStatusDetail>();
                kitIdUserIdSampleStatusMap.put(kitIdUserIdKey, statusList);
            }
            statusList.add(status);
            kitIdSet.add(status.kitId);
            userIdSet.add(status.userId);
        }
    }
    
    /****************************************************************************************** 
       1. query OrderItem based on kitid and userid collected from request
       2. create and return map of OrderItem for unique combination of kitId and userId
    *******************************************************************************************/
    public static Map<String, OrderItem> getOrderItemMap(Set<String> kitIdSet, Set<String> userIdSet) {
        List<OrderItem> oiList = [select Kit_ID__c, userid__c, Sample_Status_Updated__c from OrderItem 
                                                            where Kit_ID__c in :kitIdSet and
                                                                    userid__c in :userIdSet];
        Map<String, OrderItem> kitIdUserIdOrderItemMap = new Map<String, OrderItem>();
        for(OrderItem oi :oiList) {
            String kitIdUserIdKey = getkitIdUserIdKey(oi.Kit_ID__c , oi.userid__c);
            kitIdUserIdOrderItemMap.put(kitIdUserIdKey, oi);
        }

        return kitIdUserIdOrderItemMap;
    }
    
    /****************************************************************************************** 
       map the values to OrderItem record, from sample status request
    *******************************************************************************************/
    private static OrderItem populateOrderItem(List<UpdateSampleStatusDetail> sampleStatusList, OrderItem oi) {
        Boolean oiUpdate = false;
        DateTime mostRecentDate;
        for(UpdateSampleStatusDetail sampleStatus :sampleStatusList) {
            /* check whether sample status updated date/time field already have a value
               check whether sample status updated date/time field value is less than request status time stamp
            */
            if(oi.Sample_Status_Updated__c == null || oi.Sample_Status_Updated__c < sampleStatus.actualTimestamp) {
                oiUpdate = true;
                /* check for the most recent date/time stored in a temporary variable
                   if timestamp of this sample status is recent than populate status and date/time field
                */
                if(mostRecentDate == null || mostRecentDate < sampleStatus.actualTimestamp) {
                    mostRecentDate = sampleStatus.actualTimestamp;
                    oi.Sample_Status__c = sampleStatus.sampleStatus;
                    oi.Sample_Status_Updated__c = sampleStatus.actualTimestamp;
                }
            }
            /* populate date/time fields corresponding to each status
               date/time fields to be populated for each status, is stored in custom settings 'SampleStatusDateMapping__c'
            */
            if(statusDateMap != null && statusDateMap.containsKey(sampleStatus.sampleStatus)) {
                oi.put(statusDateMap.get(sampleStatus.sampleStatus).Date_Field_API_Name__c, sampleStatus.actualTimestamp);
                oiUpdate = true;
            }
        }
        // if most recent status is found in request then return OrderItem otherwise return null
        if(oiUpdate) {
            return oi;
        }
        else {
            return null;
        }
    }
    
    // return combination of kitid, userid
    public static String getkitIdUserIdKey(String kitId, String userId) {
        return (kitId + ':' + userId);
    }
    
    /****************************************************************************************************************************** 
       add the sample status request records to failure map
       @parameter1 => kitIdUserIdFailuresMap: key is kitid, userid combination and value is list of failed to update sample status
       @parameter2 => sampleStatusList:       list of all sample status for each kitid, userid combination
       @parameter3 => errorMessage:           error message string
       return map of list of failure sample status for each kitid, userid combination
    *******************************************************************************************************************************/
    private static void addToFailureMap(Map<String, List<UpdateSampleStatusFailure>> kitIdUserIdFailuresMap, List<UpdateSampleStatusDetail> sampleStatusList, String errorMessage) {
        String kitIdUserIdKey;
        List<UpdateSampleStatusFailure> failures = new List<UpdateSampleStatusFailure>();
        for(UpdateSampleStatusDetail sampleStatus :sampleStatusList) {
            if(kitIdUserIdKey == null)
                kitIdUserIdKey = getkitIdUserIdKey(sampleStatus.kitId , sampleStatus.userId);
            UpdateSampleStatusFailure failureResponse = new UpdateSampleStatusFailure();
            failureResponse.messageId = sampleStatus.messageId;
            failureResponse.errorMessage = errorMessage;
            failures.add(failureResponse);
        }
        if(kitIdUserIdKey != null)
            kitIdUserIdFailuresMap.put(kitIdUserIdKey, failures);
    }
    
    /* method to create list of successfully updated records
       @parameter1 => kitIdUserIdSampleStatusMap: map for list of sample status request for kitid, userid combination
       @parameter2 => failedkitIdUserIdKeySet:    set of kitid, userid combination for failed to update records
       return list of successfully updated sample status
    */
    public static List<UpdateSampleStatusSuccess> getSuccesses(Map<String, List<UpdateSampleStatusDetail>> kitIdUserIdSampleStatusMap,
                                                Set<String> failedkitIdUserIdKeySet) {
        
        List<UpdateSampleStatusSuccess> successes = new List<UpdateSampleStatusSuccess>();
        for(String kitUserId :kitIdUserIdSampleStatusMap.keySet()) {
            // if kitid, userid combination doesnot exist in failed key set then add to the success list
            if(!failedkitIdUserIdKeySet.contains(kitUserId)) {
                List<UpdateSampleStatusDetail> smplStatusList = kitIdUserIdSampleStatusMap.get(kitUserId);
                
                for(UpdateSampleStatusDetail smpl :smplStatusList) {
                    UpdateSampleStatusSuccess rec = new UpdateSampleStatusSuccess();
                    rec.messageId = smpl.messageId;
                    successes.add(rec);
                }
            }
        }
        return successes;
    }
    
    // return response object with success and failure list
    private static UpdateSampleStatusResponse prepareResponse(Map<String, List<UpdateSampleStatusDetail>> kitIdUserIdSampleStatusMap,
                                                Map<String, List<UpdateSampleStatusFailure>> kitIdUserIdFailuresMap) {
        // add the remaining records which are not failed in success list
           List<UpdateSampleStatusSuccess> successes = getSuccesses(kitIdUserIdSampleStatusMap, kitIdUserIdFailuresMap.keySet());
           List<UpdateSampleStatusFailure> failures = new List<UpdateSampleStatusFailure>();
           for(String key :kitIdUserIdFailuresMap.keySet()) {
               failures.addAll(kitIdUserIdFailuresMap.get(key));
           }
           
           // create response object
           UpdateSampleStatusResponse resp = new UpdateSampleStatusResponse();
           resp.success = successes;
           resp.failure = failures;
           return resp;
    }
}