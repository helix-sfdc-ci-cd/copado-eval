/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex REST class designed to [Insert Summary Description Here].
*
* URL Mapping: [/OrderEventService]
*
* HTTP Verbs Handled:
*
*   POST    -   [Insert Functional Description Here]
*   GET     -   [Not Implemented]
*   PUT     -   [Not Implemented]
*   DELETE  -   [Not Implemented]
*   PATCH   -   [Not Implemented]
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

@RestResource(urlMapping='/OrderEventService')

global with sharing class OrderEventServiceAPI  {

    @HttpPost
    global static OrderEventService.CancelOrRefundResponseModel cancelOrRefund() {

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');

        try {
            OrderEventService.CancelOrRefundRequestModel requestObj = new OrderEventService.CancelOrRefundRequestModel();
            String requestJSONString = request.requestBody.toString().replaceAll('\n','').replaceAll('\r','');

            List<OrderEventService.CancelOrRefundItem> itemList = new List<OrderEventService.CancelOrRefundItem>();
            OrderEventService.CancelOrRefundItem item = new OrderEventService.CancelOrRefundItem();
            Order orderToProcess = null;

            requestObj = (OrderEventService.CancelOrRefundRequestModel) System.JSON.deserialize(requestJSONString, OrderEventService.CancelOrRefundRequestModel.class);

            if (requestObj.OrderId != null && !requestObj.orderId.equals('')) {
                orderToProcess = [
                SELECT
                Id,
                SuperOrder__c,
                Status,
                TotalAmount,
                Amount_Available_to_Refund__c,
                Refund_Reason__c,
                Cancellation_Date__c,
                Cancellation_Reason__c,
                Integration_Test__c,
                Integrate_with_DNAG__c,
                Kit_Order_Product_ERP_Status__c
                FROM
                Order
                WHERE
                Id = :requestObj.OrderId
                LIMIT 1];

                // Incoming Cancellation?
                if (requestObj.cancelOrder) {
                    if (orderToProcess.Cancellation_Date__c == null) {
                        if (requestObj.cancellationReason != null && !requestObj.cancellationReason.equals('')) {
                            item.cancelOrder = true;
                            orderToProcess.Cancellation_Reason__c = requestObj.cancellationReason;
                        }
                    } else {
                        // Order is already cancelled.
                        return new OrderEventService.CancelOrRefundResponseModel('Order is already cancelled.', false, true);
                    }
                }

                // Incoming Refund?
                if (requestObj.refundOrder) {
                    if (requestObj.refundType != null && !requestObj.refundType.equals('') && requestObj.refundReason != null && !requestObj.refundReason.equals('')) {
                        item.refundType = requestObj.refundType;
                        if (item.refundType.equals('Already Shipped')) {
                            item.refundAmount = (orderToProcess.Amount_Available_to_Refund__c - (orderToProcess.Shipping_Handling_Total__c + 25));
                        } else if (item.refundType.equals('Full')) {
                            item.refundAmount = orderToProcess.Amount_Available_to_Refund__c;
                        } else {
                            // Invalid refund reason
                            return new OrderEventService.CancelOrRefundResponseModel('Invalid refund type', false, false);
                        }
                        orderToProcess.Refund_Reason__c = requestObj.refundReason;
                    } else {
                        // Missing refund input data.
                        return new OrderEventService.CancelOrRefundResponseModel('Missing refund input data', false, false);
                    }
                }
                item.order = orderToProcess;
                itemList.add(item);

                if (OrderEventService.doOrderCAncellationsAndRefunds(itemList)) {
                    return new OrderEventService.CancelOrRefundResponseModel('Refund and/or cancellation complete.', requestObj.refundOrder, requestObj.cancelOrder);
                }
            }

        } catch (Exception ex) {
            return new OrderEventService.CancelOrRefundResponseModel(ex.getMessage(), false, false);
        }
        return new OrderEventService.CancelOrRefundResponseModel('Order CancellationOrRefund process failed.', false, false);
    }
}