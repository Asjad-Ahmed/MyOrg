@isTest
global class C3HttpCalloutMockBundleClass implements HttpCalloutMock {
    private String mockType;
    global C3HttpCalloutMockBundleClass(String mockType) {
        this.mockType = mockType;
    }

    global HttpResponse respond(HTTPRequest req) {
        if (mockType == 'WhatsAppMessageText') {
            // Provide a mock response for success scenario
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"messaging_product":"whatsapp","contacts":[{"input":"919911410564","wa_id":"919911410564"}],"messages":[{"id":"asdasdasd"}]}');
            res.setStatusCode(200);
            return res;
        }else if (mockType == 'WhatsAppMessageMedia') {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "messaging_product": "whatsapp", "contacts": [ { "input": "48XXXXXXXXX", "wa_id": "48XXXXXXXXX " } ], "messages": [ { "id": "wamid.gBGGSFcCNEOPAgkO_KJ55r4w_ww" } ] }');
            res.setStatusCode(200);
            return res;
        }else if (mockType == 'WhatsAppMessageSendTemplate') {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "messaging_product": "whatsapp", "contacts": [ { "input": "48XXXXXXXXX", "wa_id": "48XXXXXXXXX " } ], "messages": [ { "id": "wamid.gBGGSFcCNEOPAgkO_KJ55r4w_ww" } ] }');
            res.setStatusCode(200);
            return res;
        }else if (mockType == 'WhatsAppMessageCreateTemplate') {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "success": "true", "id": "1627019861106475", "status": "PENDING", "category": "MARKETING" }');
            res.setStatusCode(200);
            return res;
        }else if (mockType == 'WhatsAppUploadAPI') {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('app/uploads') ) {
                res.setBody('{"id": "asdasdasdasdasd"}');
            }else{
                res.setBody('{"h": "asdasdasdasdasd"}');
            }
            res.setStatusCode(200);
            return res;
        }else if (mockType == 'WhatsAppMessageMediaAPI') {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('phone_number_id') ) {
                res.setBody('{ "messaging_product": "whatsapp", "url": "www.testurl.com", "mime_type": "image/jpeg", "sha256": "<HASH>", "file_size": "303833", "id": "2621233374848975" }');
            }else{
                res.setBody(String.valueOf(Blob.valueOf('Test Content')));
            }
            res.setStatusCode(200);
            return res;
        }else if (mockType == 'templateDeleteApi') {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "message": "Success"}');
            res.setStatusCode(200);
            return res;
        }else if (mockType == 'refreshTemplate') {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data":[{"id":"WhatsAppID1","status":"Approved","name":"Updated Template 1"}]}');
            res.setStatusCode(200);
            return res;
        }
        else {
            // Provide a default mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"messaging_product":"whatsapp","contacts":[{"input":"919911410564","wa_id":"919911410564"}],"messages":[{"id":"asdasdasd"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}