/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 2/23/2017
    @Purpose: This is the Helix API Login class.
*/
public class HelixApiLogin {
    
    // method to send login request and generate authentication token
    public static String getAuthToken(String servCredName, String userName, String password, String loginUrl, String scope) {
        
        String respBody = login(servCredName, userName, password, loginUrl, scope);
        String authToken;
        
        if(respBody != null) {
            JSONParser parser = JSON.createParser(respBody);
            HelixApiLoginResponse loginResponse = (HelixApiLoginResponse)parser.readValueAs(HelixApiLoginResponse.class);
            authToken =  loginResponse.access_token;
        } else {
            // create error log if login is failed
            Error_Log__c errLog = HMAPI_SFDC_IntegrationUtil.logError('', '', servCredName, 'Login Response is Null', 'Login Response is Null');
            insert errLog;
        }
        return authToken;
    }
    
    // method to send login request
    public static String login(String servCredName, String username, String password, String loginUrl, String scope) {
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(loginUrl);
        req.setMethod('POST');
        String body = 'grant_type=client_credentials&scope=' + scope;
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
                Error_Log__c errLog = HMAPI_SFDC_IntegrationUtil.logError(String.valueOf(statusCode), status, servCredName, res.getBody(), 'Login Failed');
                insert errLog;
            }
        }
        return response;
    }
}