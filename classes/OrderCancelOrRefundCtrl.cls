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

public class OrderCancelOrRefundCtrl {

    public final static String CANCEL = 'cancel';
    public final static String REFUND = 'refund';

    public String superOrderNumber {get; set;}
    public Decimal totalRefundAmount { get; set; }
    private List<Order> orderList {get; set;}
    public Boolean isCancel = false;
    public Boolean isRefund = false;
    public List<OrderEventService.CancelOrRefundItem> items { get; set; }
    public Boolean hasErrors { get{
        return ApexPages.hasMessages();
    } private set;}

    public OrderCancelOrRefundCtrl() {

        String soId = ApexPages.currentPage().getParameters().get('soId');
        String oId = ApexPages.currentPage().getParameters().get('oId');
        String cancelOrRefund = ApexPages.currentPage().getParameters().get('cancelOrRefund');

        if (cancelOrRefund != null) {
            if (cancelOrRefund.equals('cancel')) {
                isCancel = true;
            } else if (cancelOrRefund.equals('refund')) {
                isRefund = true;
            }
        }

        if (String.isNotBlank(soId)) {
            superOrderNumber = [SELECT Id, Name FROM SuperOrder__c WHERE Id = :soId].Name;
            orderList = [SELECT Id, OrderNumber, TotalAmount, Actual_Order_Total__c, Amount_Available_to_Refund__c, Shipping_Handling_Total__c, Integration_Test__c, Integrate_with_DNAG__c, Refund_Reason__c, Cancellation_Reason__c, Cancellation_Date__c, Total_Amount_Refunded__c, Kit_Order_Product_ERP_Status__c, SuperOrder__c, SuperOrder__r.Name, Partner_Channel__r.Name FROM Order WHERE SuperOrder__c = :soId];

        } else if (String.isNotBlank(oId)) {
            orderList = [SELECT Id, OrderNumber, TotalAmount, Actual_Order_Total__c, Amount_Available_to_Refund__c, Shipping_Handling_Total__c, Integration_Test__c, Integrate_with_DNAG__c, Refund_Reason__c, Cancellation_Reason__c, Cancellation_Date__c, Total_Amount_Refunded__c, Kit_Order_Product_ERP_Status__c, SuperOrder__c, SuperOrder__r.Name, Partner_Channel__r.Name FROM Order WHERE Id = :oId];

            if (!orderList.isEmpty()) {
                superOrderNumber = orderList[0].SuperOrder__r.Name;
            }

        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Unable to find related Order or SuperOrder records'));
        }

        if (orderList != null) {
            items = wrapCancellationOrRefundItems(orderList);
            recalculateRefundAmounts();
        }
    }

    private List<OrderEventService.CancelOrRefundItem> wrapCancellationOrRefundItems(List<Order> orders) {
        List<OrderEventService.CancelOrRefundItem> crItems = new List<OrderEventService.CancelOrRefundItem>();
        for (Order o : orders) {
            crItems.add(new OrderEventService.CancelOrRefundItem(o, isCancel));
        }
        return crItems;
    }

    public void recalculateRefundAmounts() {
        totalRefundAmount = 0;
        for (OrderEventService.CancelOrRefundItem cri : items) {
            if (cri.refundType.equals(OrderEventService.ORDER_REFUND_TYPE_NONE)) {
                cri.refundAmount = 0;
            } else if (cri.refundType.equals(OrderEventService.ORDER_REFUND_TYPE_ALREAD_SHIPPED)) {
                cri.refundAmount = (cri.order.Amount_Available_to_Refund__c - (cri.order.Shipping_Handling_Total__c + OrderEventService.REFUND_HANDLING_FEE));
            } else if (cri.refundType.equals(OrderEventService.ORDER_REFUND_TYPE_FULL)) {
                cri.refundAmount = cri.order.Amount_Available_to_Refund__c;
            }
            totalRefundAmount += cri.refundAmount;

            if (cri.order.Partner_Channel__r.Name.equals('Helix') || cri.order.Partner_Channel__r.Name.equals('Helix Promotional')) {
                cri.isCancelDisabled = false;
                cri.isRefundDisabled = false;
            }
            if (cri.order.Cancellation_Date__c != null) {
                cri.isCancelDisabled = true;
                cri.cancelOrder = false;
            }
            if (cri.order.Kit_Order_Product_ERP_Status__c.equals('Data Delivered')) {
                cri.isCancelDisabled = true;
                cri.cancelOrder = false;
            }
            if (cri.order.Amount_Available_to_Refund__c <= 0) {
                cri.isRefundDisabled = true;
            }
        }
    }

    public PageReference submitCancelOrResendItems() {
        if (validateBeforeSubmit()) {
            Boolean orderCancellationOrRefundIsSuccessful = OrderEventService.DoOrderCancellationsAndRefunds(items);

            if (!orderCancellationOrRefundIsSuccessful) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'There was an error cancelling or refunding orders. Please try again.'));
            } else {
                return returnToToolbox();
            }
        }
        return null;
    }

    private Boolean validateBeforeSubmit() {
        for (OrderEventService.CancelOrRefundItem cri : items) {
            if (cri.cancelOrder && cri.order.Cancellation_Reason__c == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Please select cancellation reason for order: ' + cri.order.OrderNumber));
            }
            if (!cri.refundType.equals('none') && cri.order.Refund_Reason__c == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Please select refund reason for order: ' + cri.order.OrderNumber));
            }
        }
        return !hasErrors;
    }

    public PageReference returnToToolbox() {
        return new PageReference('/apex/CustomerServicesToolbox?kwrd=' + superOrderNumber);
    }

}