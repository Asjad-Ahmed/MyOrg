public class HttpCallOuts {
	private static Final Blob BASIC_AUTH_CRED = Blob.valueOf('rzp_test_BXza6LlX01Pq9q' + ':' + 'vIS08uNdrZGO8NG2lR0vt8a3');
    public static HTTPResponse sageHttpCallOut(String requestBody){
        HttpRequest req = new HttpRequest();
        Http http = new Http();    
        req.setEndpoint('https://api.razorpay.com/v1/payment_links');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        String username = 'rzp_test_BXza6LlX01Pq9q';
        String password = 'vIS08uNdrZGO8NG2lR0vt8a3';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(BASIC_AUTH_CRED);
        req.setHeader('Authorization', authorizationHeader);
        string body = '{"amount": 1000,"currency": "INR", "accept_partial": false, "expire_by": 1691097057, "reference_id": "TSsd1989", "description": "Payment for policy no #23456", "customer": { "name": "Asjad Ahmed",  "contact": "+919891611767","email": "asjadahmed51@gmail.com" }, "notify": { "sms": true, "email": true},"reminder_enable": true,"notes": {"policy_name": "Jeevan Bima"},"callback_url": "https://example-callback-url.com/","callback_method": "get"}';
       	req.setBody(body);
        req.setTimeout(120000);
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        return res;
    }
}