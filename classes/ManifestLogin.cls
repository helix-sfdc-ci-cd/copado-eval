/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 8/28/2016
    @Purpose: This is the Manifest Login class. This class will be responsible to login in Manifest Aplication.
*/
public class ManifestLogin {
    
    // method to send login request and generate authentication token
    public static String getAuthToken(String servCredName, String userName, String password, String loginUrl) {
        
        String respBody = login(servCredName, userName, password, loginUrl);
        String authToken;
        
        if(respBody != null) {
            JSONParser parser = JSON.createParser(respBody);
            ManifestLoginResponse loginResponse = (ManifestLoginResponse)parser.readValueAs(ManifestLoginResponse.class);
            authToken =  loginResponse.access_token;
        }
        return authToken;
    }
    
    // method to send login request
    public static String login(String servCredName, String username, String password, String loginUrl) {
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(loginUrl);
        req.setMethod('POST');
        String body = 'grant_type=client_credentials&scope=samplestatus_sfdc';
        req.setbody(body);
        // Specify the required user name and password to access the endpoint 
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        // Create a new http object to send the request object 
        
        // A response object is generated as a result of the request   
        Http http = new Http();
        HTTPResponse res;
        res = http.send(req);
        
        String response;
        if(res != null) {
            Integer statusCode = res.getStatusCode();
            String status = res.getStatus();
            
            // in case of successful login, fetch response
            if(statusCode == 200) {
                response = res.getBody();
                
            } else {
                // create error log if login is failed
                Error_Log__c errLog = HMAPI_SFDC_IntegrationUtil.logError(String.valueOf(statusCode), status, res.getBody(), servCredName, 'Login Failed');
                insert errLog;
            }
        }
        return response;
    }
}