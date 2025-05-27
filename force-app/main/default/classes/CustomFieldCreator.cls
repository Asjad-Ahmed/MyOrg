public class CustomFieldCreator {
    
    private static final String TOOLING_API_ENDPOINT = '/services/data/v59.0/tooling/sobjects/CustomField';

    /**
     * Creates a custom field on the Account object
     * @param fieldName - API name of the custom field (e.g., 'My_Custom_Field__c')
     * @param fieldLabel - Label of the custom field (e.g., 'My Custom Field')
     * @param fieldType - Type of the field (e.g., 'Text', 'Number', 'Checkbox')
     * @param fieldLength - Length of the field (applicable for Text type)
     * @return API Response as a String
     */
    public static String createCustomField(String fieldName, String fieldLabel, String fieldType, Integer fieldLength) {
        // Prepare request body
        Map<String, Object> metadata = new Map<String, Object>();
        metadata.put('fullName', 'Account.' + fieldName);
        metadata.put('label', fieldLabel);
        metadata.put('type', fieldType);
        
        if (fieldType == 'Text') {
            metadata.put('length', fieldLength);
        }

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('Metadata', metadata);
        requestBody.put('FullName', 'Account.' + fieldName);

        // Convert to JSON
        String requestBodyJson = JSON.serialize(requestBody);
        
        // Call Tooling API
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainURL().toExternalForm() + TOOLING_API_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBodyJson);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        // Return API response
        return res.getBody();
    }
}