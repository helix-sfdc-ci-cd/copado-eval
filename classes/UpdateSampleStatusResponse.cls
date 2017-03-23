/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 9/6/2016
    @Purpose: This is the response object for UpdateSampleStatus api
*/
global class UpdateSampleStatusResponse {
    public List<UpdateSampleStatusSuccess> success;
    public List<UpdateSampleStatusFailure> failure;
}