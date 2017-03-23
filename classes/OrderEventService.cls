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

global virtual with sharing class OrderEventService {

    public static Decimal REFUND_HANDLING_FEE = 25.0;
    public static String ORDER_REFUND_TYPE_NONE = 'none';
    public static String ORDER_REFUND_TYPE_FULL = 'Full';
    public static String ORDER_REFUND_TYPE_ALREAD_SHIPPED = 'Already Shipped';
    public static String ORDER_KIT_ERP_STATUS_NOT_SUBMITTED_TO_NS = 'Not Submitted to Netsuite';

	public static Boolean doOrderCancellationsAndRefunds(List<CancelOrRefundItem> cancelOrRefundItems) {
		OrderCancelOrRefundHandler ocrH = new OrderCancelOrRefundHandler();
		return ocrH.cancelOrRefundOrders(cancelOrRefundItems);
	}

    public class OrderEventsServiceException extends Exception {}

	public class CancelOrRefundItem {
        public CancelOrRefundItem(Order o, Boolean isCancel) {
            this.order = o;
            this.refundAmount = 0;
            this.refundType = ORDER_REFUND_TYPE_NONE;
            this.cancelOrder = isCancel;
			this.isRefundDisabled = true;
        }
		public CancelOrRefundItem() {
			cancelOrder = false;
		}
        public Order order { get; set; }
        public String refundType { get; set; }
        public Decimal refundAmount { get; set; }
        public Boolean cancelOrder { get; set; }
		public Boolean isRefundDisabled { get; set; }
		public Boolean isCancelDisabled { get; set; }
    }

	public class CancelOrRefundRequestModel {
		public CancelOrRefundRequestModel() {

		}
		public String orderId { get; set; }
		public Boolean cancelOrder { get; set; }
		public String cancellationReason { get; set; }
		public Boolean refundOrder { get; set; }
		public String refundType { get; set; }
		public String refundReason { get; set; }
	}

	global class CancelOrRefundResponseModel {
        public CancelOrRefundResponseModel(String status, Boolean isRefunded, Boolean isCancelled) {
            this.status = status;
            this.orderRefunded = isRefunded;
            this.orderCancelled = isCancelled;
        }
        public String status { get; set; }
        public Boolean orderRefunded { get; set; }
        public Boolean orderCancelled { get; set; }
    }
}