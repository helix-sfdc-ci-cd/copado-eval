/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 10/26/2016
    @Purpose: This is helper class for OrderProductTrigger
*/
public class OrderProductTriggerHelper {

    // 2017-03-02 (llofberg@thirdwaveanalytics.com)
    // add onbeforeinsert method setting field to track shipping cost
    public static void onBeforeInsert(List<OrderItem> oiList, Map<Id, OrderItem> oldMap) {
        for (OrderItem oi : oiList) {
            if (oi.Type__c == 'S&H') {
                oi.Shipping_Handling_Amount__c = oi.Net_Amount__c;
            }
        }
    }

    // define actions to be executed on after update event
    public static void onAfterUpdate(List<OrderItem> oiList, Map<Id, OrderItem> oldMap) {
        updateShipStatusOnSuperOrder(oiList, oldMap);

        if(RunOnceTriggerUtil.orderProductTriggerRunOnce())
            sendEmailNotification(oiList, oldMap);
    }

    public static void sendEmailNotification(List<OrderItem> oiList, Map<Id, OrderItem> oiMap) {
        Set<Id> orderItemIds = new Set<Id>();
        for(OrderItem oi :oiList) {
            OrderItem oiOld = oiMap.get(oi.id);
            if(oi.Type__c == 'KIT' && (oi.Accessioning_Status__c != null && oi.Accessioning_Status__c.equals('HOLD')
                    && (oiOld.Accessioning_Status__c == null || !oiOld.Accessioning_Status__c.equals('HOLD')))) {
                orderItemIds.add(oi.id);
            }
        }
        if(orderItemIds.size() > 0) {
            KitHoldEmailNotificationSPI.sendKitHoldEmailNotification(orderItemIds);
        }

    }

    // method to update Fully Shipped checkbox on Super Order
    public static void updateShipStatusOnSuperOrder(List<OrderItem> oiList, Map<Id, OrderItem> oldMap) {
        // set of order ids whose Order Item status is updated to Shipped
        Set<Id> orderIdSet = new Set<Id>();
        for(OrderItem oi :oiList) {
            OrderItem oiOld = oldMap.get(oi.id);
            System.debug('oi.Kit_Order_Status__c===' + oi.id);
            System.debug('oi.Kit_Order_Status__c===' + oi.Kit_Order_Status__c);
            System.debug('oiOld.Kit_Order_Status__c===' + oiOld.Kit_Order_Status__c);
            if(oi.Kit_Order_Status__c != null && oi.Kit_Order_Status__c.equals('Shipped') && oiOld.Kit_Order_Status__c != 'Shipped') {
                orderIdSet.add(oi.OrderId);
            }
        }

        // set of Super Order ids queried from Order whose Order Item status is updated to Shipped
        Set<Id> soIdSet = new Set<Id>();
        for(Order ord : [select SuperOrder__c from Order where id in :orderIdSet]) {
            soIdSet.add(ord.SuperOrder__c);
        }

        // query all Orders and their KIT Order Items related to Super Order Ids in set
        List<Order> orderList = [select SuperOrder__c, (select Kit_Order_Status__c from OrderItems where Type__c = 'KIT')
                                            from Order where SuperOrder__c in :soIdSet];
        Set<Id> notShippedSOIdsSet = new Set<Id>();
        for(Order ord : orderList) {
            for(OrderItem oi: ord.OrderItems) {
                // if any of the Order Item status is not Shipped it means that its Super Order is not valid for fully shipped
                // collecting those super order ids in a set
                if(oi.Kit_Order_Status__c == null || !oi.Kit_Order_Status__c.equals('Shipped')) {
                    notShippedSOIdsSet.add(ord.SuperOrder__c);
                }
            }
        }

        List<SuperOrder__c> soListToUpdate = new List<SuperOrder__c>();
        // loop over all queried super order ids
        for(Id soId :soIdSet) {
            /* if super order id is not there in invalid (notShippedSOIdsSet) super order id set,
               then its valid for fully shipped status,
               creating a list of super order to be updated
            */
            if(!notShippedSOIdsSet.contains(soId)) {
                soListToUpdate.add(new SuperOrder__c(id = soId, Fully_Shipped__c = true));
            }
        }

        // update super order
        try {
            if(soListToUpdate != null && soListToUpdate.size() > 0)
                update soListToUpdate;
        } catch(Exception e) {
            System.debug('--- Error ---' + e.getMessage());
        }

    }
}