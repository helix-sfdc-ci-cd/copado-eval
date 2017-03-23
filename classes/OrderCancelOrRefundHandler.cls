/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Class Description here
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
* 2017-03-01      Class created.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class OrderCancelOrRefundHandler {

	public Boolean cancelOrRefundOrders(List<OrderEventService.CancelOrRefundItem> cancelOrRefundItems) {

		Map<Id, Order_Event__c> orderEventsToInsertMap = new Map<Id, Order_Event__c>();
		List<Order_Event_Item__c> orderEventItemsToInsert = new List<Order_Event_Item__c>();
		List<Order> ordersToUpdate = new List<Order>();
		List<OrderItem> orderProductsToUpdate = new List<OrderItem>();

		try {
			Set<Id> orderIds = new Set<Id>();
			for (OrderEventService.CancelOrRefundItem item : cancelOrRefundItems) {
				orderIds.add(item.order.Id);
			}

			Map<Id, List<OrderItem>> orderProductsMap = new Map<Id, List<OrderItem>>();
			for (OrderItem oi : [SELECT Id, IsCancellable__c, Sample_Status__c, Kit_Resend_Reason__c, Order_Product_Status__c, Type__c, Net_Amount__c, OrderId FROM OrderItem WHERE OrderId IN :orderIds]) {
				if (orderProductsMap.containsKey(oi.OrderId)) {
					orderProductsMap.get(oi.OrderId).add(oi);
				} else {
					List<OrderItem> oiList = new List<OrderItem>();
					oilist.add(oi);
					orderProductsMap.put(oi.OrderId, oiList);
				}
			}

			for (OrderEventService.CancelOrRefundItem item : cancelOrRefundItems) {

				Order_Event__c oe = new Order_Event__c();
				//Order is Cancel & Refund
				if ((item.cancelOrder && item.order.Cancellation_Date__c == null) && (item.refundAmount > 0 && !item.refundType.equals('none'))) {
					//Common
					oe.SuperOrder__c = item.order.SuperOrder__c;
					oe.Order__c = item.order.Id;
					oe.Type__c = 'Cancel & Refund';
					oe.Is_Ready_For_ERP_Integration__c = true;

					//Refund
					oe.Refund_Type__c = item.refundType;
					oe.Refund_Amount_Requested__c = item.refundAmount;
					orderEventsToInsertMap.put(item.order.Id, oe);

					//Cancellation
					item.order.Status = 'Cancelled';
					item.order.Cancellation_Date__c = Datetime.now();
					if (item.order.Kit_Order_Product_ERP_Status__c.equals(OrderEventService.ORDER_KIT_ERP_STATUS_NOT_SUBMITTED_TO_NS)) {
						item.order.Integrate_with_DNAG__c = false;
						//item.order.Integration_Test__c = false;
					}
					ordersToUpdate.add(item.order);

					if (orderProductsMap.containsKey(item.order.Id)) {
						for (OrderItem oi : orderProductsMap.get(item.order.Id)) {

							//Cancellation
							if (oi.IsCancellable__c && oi.Type__c.equalsIgnoreCase('KIT')) {
								oi.Sample_Status__c = 'Cancelled';
								oi.Order_Product_Status__c = 'Cancelled';
								oi.Accessioning_Status__c = 'Cancelled';
							} else if (oi.IsCancellable__c) {
								oi.Order_Product_Status__c = 'Cancelled';
							}

							//Refund
							Order_Event_Item__c oei = new Order_Event_Item__c();
							oei.Order__c = item.order.Id;
							oei.SuperOrder__c = item.order.SuperOrder__c;
							oei.Order_Product__c = oi.Id;

							if (oi.Type__c.equalsIgnoreCase('KIT')) {
								if (oi.Kit_Resend_Reason__c == null || oi.Kit_Resend_Reason__c.equals('')) {
									oei.Refund_Amount__c = oi.Net_Amount__c;
									orderEventItemsToInsert.add(oei);
								}
							} else if (oi.Type__c.equalsIgnoreCase('S&H')) {
								if (!item.refundType.equals('Already Shipped')) {
									oei.Refund_Amount__c = oi.Net_Amount__c;
									orderEventItemsToInsert.add(oei);
								}
							} else if (oi.Type__c.equalsIgnoreCase('SALES TAX')) {
								oei.Refund_Amount__c = oi.Net_Amount__c;
								orderEventItemsToInsert.add(oei);
							} else if (oi.Type__c.equalsIgnoreCase('APP')) {

							} else if (oi.Type__c.equalsIgnoreCase('HELIX REFERRAL FEE')) {
								oei.Refund_Amount__c = oi.Net_Amount__c;
								orderEventItemsToInsert.add(oei);
							} else if (oi.Type__c.equalsIgnoreCase('PARTNER REVENUE SHARE')) {
								oei.Refund_Amount__c = oi.Net_Amount__c;
								orderEventItemsToInsert.add(oei);
							} else if (oi.Type__c.equalsIgnoreCase('HELIX SEQUENCE REVENUE')) {
								if (item.refundType.equals('Already Shipped')) {
									oei.Refund_Amount__c = (oi.Net_Amount__c - OrderEventService.REFUND_HANDLING_FEE);
								} else {
									oei.Refund_Amount__c = oi.Net_Amount__c;
								}
								orderEventItemsToInsert.add(oei);
							}
							orderProductsToUpdate.add(oi);
						}
					}
				}

				//Order is Refund
				else if (item.refundAmount > 0 && !item.refundType.equals('none')) {
					//Common
					oe.SuperOrder__c = item.order.SuperOrder__c;
					oe.Order__c = item.order.Id;
					oe.Type__c = 'Refund';
					oe.Is_Ready_For_ERP_Integration__c = true;

					//Refund
					oe.Refund_Type__c = item.refundType;
					oe.Refund_Amount_Requested__c = item.refundAmount;
					orderEventsToInsertMap.put(item.order.Id, oe);

					ordersToUpdate.add(item.order);

					if (orderProductsMap.containsKey(item.order.Id)) {
						for (OrderItem oi : orderProductsMap.get(item.order.Id)) {
							Order_Event_Item__c oei = new Order_Event_Item__c();
							oei.Order__c = item.order.Id;
							oei.SuperOrder__c = item.order.SuperOrder__c;
							oei.Order_Product__c = oi.Id;

							if (oi.Type__c.equalsIgnoreCase('KIT')) {
								if (oi.Kit_Resend_Reason__c == null || oi.Kit_Resend_Reason__c.equals('')) {
									oei.Refund_Amount__c = oi.Net_Amount__c;
									orderEventItemsToInsert.add(oei);
								}
							} else if (oi.Type__c.equalsIgnoreCase('S&H')) {
								if (!item.refundType.equals('Already Shipped')) {
									oei.Refund_Amount__c = oi.Net_Amount__c;
									orderEventItemsToInsert.add(oei);
								}
							} else if (oi.Type__c.equalsIgnoreCase('SALES TAX')) {
								oei.Refund_Amount__c = oi.Net_Amount__c;
								orderEventItemsToInsert.add(oei);
							} else if (oi.Type__c.equalsIgnoreCase('APP')) {

							} else if (oi.Type__c.equalsIgnoreCase('HELIX REFERRAL FEE')) {
								oei.Refund_Amount__c = oi.Net_Amount__c;
								orderEventItemsToInsert.add(oei);
							} else if (oi.Type__c.equalsIgnoreCase('PARTNER REVENUE SHARE')) {
								oei.Refund_Amount__c = oi.Net_Amount__c;
								orderEventItemsToInsert.add(oei);
							} else if (oi.Type__c.equalsIgnoreCase('HELIX SEQUENCE REVENUE')) {
								if (item.refundType.equals('Already Shipped')) {
									oei.Refund_Amount__c = (oi.Net_Amount__c - OrderEventService.REFUND_HANDLING_FEE);
								} else {
									oei.Refund_Amount__c = oi.Net_Amount__c;
								}
								orderEventItemsToInsert.add(oei);
							}
						}
					}
				}

				//Order is Cancel
				else if (item.cancelOrder && item.order.Cancellation_Date__c == null) {
					//Common
					oe.SuperOrder__c = item.order.SuperOrder__c;
					oe.Order__c = item.order.Id;
					oe.Type__c = 'Cancel';
					oe.Is_Ready_For_ERP_Integration__c = true;
					orderEventsToInsertMap.put(item.order.Id, oe);

					//Cancellation
					item.order.Status = 'Cancelled';
					item.order.Cancellation_Date__c = Datetime.now();
					if (item.order.Kit_Order_Product_ERP_Status__c.equals(OrderEventService.ORDER_KIT_ERP_STATUS_NOT_SUBMITTED_TO_NS)) {
						item.order.Integrate_with_DNAG__c = false;
						//item.order.Integration_Test__c = false;
					}
					ordersToUpdate.add(item.order);

					if (orderProductsMap.containsKey(item.order.Id)) {
						for (OrderItem oi : orderProductsMap.get(item.order.Id)) {
							if (oi.IsCancellable__c && oi.Type__c.equalsIgnoreCase('KIT')) {
								oi.Sample_Status__c = 'Cancelled';
								oi.Order_Product_Status__c = 'Cancelled';
								oi.Accessioning_Status__c = 'Cancelled';
							} else if (oi.IsCancellable__c) {
								oi.Order_Product_Status__c = 'Cancelled';
							}
							orderProductsToUpdate.add(oi);
						}
					}
				}
			}
			if (!orderEventsToInsertMap.isEmpty()) {
				insert orderEventsToInsertMap.values();
			}

			if (!orderEventItemsToInsert.isEmpty()) {
				for (Order_Event_Item__c oei : orderEventItemsToInsert) {
					oei.Order_Event__c = orderEventsToInsertMap.get(oei.Order__c).Id;
				}
				insert orderEventItemsToInsert;
			}

			if (!ordersToUpdate.isEmpty()) {
				update ordersToUpdate;
			}

			if (!orderProductsToUpdate.isEmpty()) {
				update orderProductsToUpdate;
			}
		} catch (Exception ex) {
			System.debug(ex);
			return false;
		}
		return true;
	}
}