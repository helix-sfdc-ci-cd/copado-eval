/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 8/8/2016
    @Purpose: This is the SuperOrder object for CreateOrder api
*/

global class Super_Order {
           public List<HM_Order> orderList;       
           public String partnerChannel;
           public String partnerOrderNumber;
           public String partnerAffiliatedCustomerId;
           public String sourcingPartner;
           public Boolean hasOptedOutOfEmail;
           public String taxDocId;
           public String transactionId;
           public HM_Account billToAccount;
           public HM_Account shipToAccount;
           public HM_Address shippingAddress;
           public HM_Address billingAddress;
           public String carrier;
           public String shippingMethod;
           public Decimal totalAmountCharged;
           public Decimal totalTax;
           public Boolean paymentCaptured;
           public String stripeCustomerId;
           public Boolean gift;
}