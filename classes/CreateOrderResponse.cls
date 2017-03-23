/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 8/8/2016
    @Purpose: This is the response object for CreateOrder api
*/
global class CreateOrderResponse{
        public List<String> orderNumberList;
        public String superOrderNumber;
        public HMAPIError error;
    }