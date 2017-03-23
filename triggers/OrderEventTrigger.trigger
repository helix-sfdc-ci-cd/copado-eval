/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Order_Event__c to delete related order event items triggering rollup calculation from
* order event item to order product.
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Linus Löfberg  <llofberg@thirdwaveanalytics.com>
* @modifiedBy     Linus Löfberg  <llofberg@thirdwaveanalytics.com>
* @version        1.0
* @created        2017-03-01
* @modified       2017-03-01
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            llofberg@thirdwaveanalytics.com
* 2017-03-01      Trigger created.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

trigger OrderEventTrigger on Order_Event__c (before insert, before delete) {

	if (Trigger.isDelete) {
		List<Order_Event_Item__c> eventItems = [SELECT Id FROM Order_Event_Item__c WHERE Order_Event__c IN :Trigger.oldMap.keySet()];
		delete eventItems;
	} else if (Trigger.isInsert) {
		Set<Id> orderIds = new Set<Id>();

		for (Order_Event__c oe : Trigger.new) {
			if ((oe.Type__c.equals('Cancel') || oe.Type__c.equals('Cancel & Refund')) && oe.Order_Status_for_ERP_Integration__c.equals('Uploaded to NetSuite but not DNAG')) {
				orderIds.add(oe.Order__c);
			}
		}

		if (!orderIds.isEmpty()) {
			List<Order> orders = [SELECT Id, Integrate_with_DNAG__c FROM Order WHERE Id IN :orderIds];
			for (Order o : orders) {
				o.Integrate_with_DNAG__c = false;
			}

			if (!orders.isEmpty()) {
				update orders;
			}
		}
	}

}