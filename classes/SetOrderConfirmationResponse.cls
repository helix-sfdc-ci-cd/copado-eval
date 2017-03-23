/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 12/7/2016
    @Purpose: This is the response object for Set Order Confirmation api
*/
global class SetOrderConfirmationResponse{
        
        public List<String> orderNotFoundList;
        public String successMessage;
        public HMAPIError error;
    }