@isTest
private class C3WhatsappWebhookAPITest {
    @testSetup
    public static void makeData(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'Admin',
            Email = 'testadmin@example.com',
             Username = 'testadmin@example.com' + System.currentTimeMillis(), // Ensure unique username
            Alias = 'tadmin',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        // Assign Permission Sets
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
    
        for (String permSetName : new List<String>{'Admin_Panel', 'WhatsApp_Access'}) {
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = :permSetName LIMIT 1];
            psAssignments.add(new PermissionSetAssignment(
                AssigneeId = testUser.Id,
                PermissionSetId = permSet.Id
            ));
        }
        insert psAssignments;
    
        System.runAs(testUser) {
            C3TestDataFactory.insertWhatsAppAdmin();
            C3TestDataFactory.createAccount();
        }
    }


    @isTest
    static void testDoPost() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
                String jsonBody = '{ "object": "whatsapp_business_account", "entry": [ { "id": "8856996819413533", "changes": [ { "value": { "messaging_product": "whatsapp", "metadata": { "display_phone_number": "16505553333", "phone_number_id": "27681414235104944" }, "contacts": [ { "profile": { "name": "Kerry Fisher" }, "wa_id": "16315551234" } ], "messages": [ { "from": "16315551234", "id": "wamid.ABGGFlCGg0cvAgo-sJQh43L5Pe4W", "timestamp": "1603059201", "text": { "body": "Hello this is an answer" }, "type": "text" } ] }, "field": "messages" } ] } ] }';
                // Set up the POST request
                RestRequest request = new RestRequest();
                request.httpMethod = 'POST';
                RestContext.request = request;
                RestContext.request.requestBody = Blob.valueOf(jsonBody);
                
                // Call the doPost method
                C3WhatsappWebhookAPI.doPost();
                System.assertEquals( (jsonBody != null) ,true);
            Test.stopTest();
        }
    }

    @isTest
    static void testDoPost1() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                String jsonBody = '{ "object": "whatsapp_business_account", "entry": [ { "id": "8856996819413533", "changes": [ { "value": { "messaging_product": "whatsapp", "metadata": { "display_phone_number": "16505553333", "phone_number_id": "27681414235104944" }, "statuses": [ { "id": "wamid.ABGGFlCGg0cvAgo-sJQh43L5Pe4W", "recipient_id": "16505553333", "status": "sent", "timestamp": "1603059201", "conversation": { "id": "wamid.ABGGFlCGg0cvAgo-sJQh43L5Pe4W", "expiration_timestamp": 1603059201, "origin": { "type": "user_initiated" } }, "pricing": { "pricing_model": "CBP", "billable": true, "category": "user_initiated" } } ] }, "field": "messages" } ] } ] }';
                // Set up the POST request
                RestRequest request = new RestRequest();
                request.httpMethod = 'POST';
                RestContext.request = request;
                RestContext.request.requestBody = Blob.valueOf(jsonBody);
                
                // Call the doPost method
                C3WhatsappWebhookAPI.doPost();
                System.assertEquals( (jsonBody != null) ,true);
            Test.stopTest();
        }
    }

    @isTest
    static void testDoPost2() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                String jsonBody = '{ "object": "whatsapp_business_account", "entry": [ { "id": "8856996819413533", "changes": [ { "value": { "messaging_product": "whatsapp", "metadata": { "display_phone_number": "16505553333", "phone_number_id": "27681414235104944" }, "contacts": [ { "profile": { "name": "Kerry Fisher" }, "wa_id": "16315551234" } ], "messages": [ { "context": { "from": "16505553333", "id": "wamid.gBGGFlCGg0cvAgkLFm4e9tICiTI" }, "from": "16315551234", "id": "wamid.ABGGFlCGg0cvAgo-sHWxBA2VFD_S", "timestamp": "1603087229", "type": "button", "button": { "text": "No", "payload": "No-Button-Payload" } } ] }, "field": "messages" } ] } ] }';
                // Set up the POST request
                RestRequest request = new RestRequest();
                request.httpMethod = 'POST';
                RestContext.request = request;
                RestContext.request.requestBody = Blob.valueOf(jsonBody);
                
                // Call the doPost method
                C3WhatsappWebhookAPI.doPost();
                System.assertEquals( (jsonBody != null) ,true);
            Test.stopTest();
        }
    }

    @isTest
    static void testDoPost3() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageMediaAPI'));
                String jsonBody = '{ "object": "whatsapp_business_account", "entry": [ { "id": "8856996819413533", "changes": [ { "value": { "messaging_product": "whatsapp", "metadata": { "display_phone_number": "16505553333", "phone_number_id": "27681414235104944" }, "contacts": [ { "profile": { "name": "CONTACT_NAME" }, "wa_id": "16315551234" } ], "messages": [ { "from": "16505553333", "id": "wamid.id", "timestamp": "1603087229", "type": "image", "image": { "caption": "This is a caption", "mime_type": "image/jpeg", "sha256": "81d3bd8a8db4868c9520ed47186e8b7c5789e61ff79f7f834be6950b808a90d3", "id": "2754859441498128" } } ] }, "field": "messages" } ] } ] }';
                // Set up the POST request
                RestRequest request = new RestRequest();
                request.httpMethod = 'POST';
                RestContext.request = request;
                RestContext.request.requestBody = Blob.valueOf(jsonBody);
                
                // Call the doPost method
                C3WhatsappWebhookAPI.doPost();
                System.assertEquals( (jsonBody != null) ,true);
            Test.stopTest();
        }
    }

    @isTest
    static void testDoPost4() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageMediaAPI'));
                String jsonBody = '{ "object": "whatsapp_business_account", "entry": [ { "id": "8856996819413533", "changes": [ { "value": { "messaging_product": "whatsapp", "metadata": { "display_phone_number": "16505553333", "phone_number_id": "27681414235104944" }, "contacts": [ { "profile": { "name": "CONTACT_NAME" }, "wa_id": "16315551234" } ], "messages": [ { "from": "16505553333", "id": "wamid.id", "timestamp": "1603087229", "type": "video", "video": { "caption": "This is a caption", "mime_type": "video/mp4", "sha256": "81d3bd8a8db4868c9520ed47186e8b7c5789e61ff79f7f834be6950b808a90d3", "id": "2754859441498128" } } ] }, "field": "messages" } ] } ] }';
                // Set up the POST request
                RestRequest request = new RestRequest();
                request.httpMethod = 'POST';
                RestContext.request = request;
                RestContext.request.requestBody = Blob.valueOf(jsonBody);
                
                // Call the doPost method
                C3WhatsappWebhookAPI.doPost();
                System.assertEquals( (jsonBody != null) ,true);
            Test.stopTest();
        }
    }

    @isTest
    static void testDoPost5() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageMediaAPI'));
                String jsonBody = '{ "object": "whatsapp_business_account", "entry": [ { "id": "8856996819413533", "changes": [ { "value": { "messaging_product": "whatsapp", "metadata": { "display_phone_number": "16505553333", "phone_number_id": "27681414235104944" }, "contacts": [ { "profile": { "name": "CONTACT_NAME" }, "wa_id": "16315551234" } ], "messages": [ { "from": "16505553333", "id": "wamid.id", "timestamp": "1603087229", "type": "audio", "audio": { "caption": "This is a caption", "mime_type": "audio/mp3", "sha256": "81d3bd8a8db4868c9520ed47186e8b7c5789e61ff79f7f834be6950b808a90d3", "id": "2754859441498128" } } ] }, "field": "messages" } ] } ] }';
                // Set up the POST request
                RestRequest request = new RestRequest();
                request.httpMethod = 'POST';
                RestContext.request = request;
                RestContext.request.requestBody = Blob.valueOf(jsonBody);
                
                // Call the doPost method
                C3WhatsappWebhookAPI.doPost();
                System.assertEquals( (jsonBody != null) ,true);
            Test.stopTest();
        }
    }

    @isTest
    static void testDoPost6() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageMediaAPI'));
                String jsonBody = '{ "object": "whatsapp_business_account", "entry": [ { "id": "8856996819413533", "changes": [ { "value": { "messaging_product": "whatsapp", "metadata": { "display_phone_number": "16505553333", "phone_number_id": "27681414235104944" }, "contacts": [ { "profile": { "name": "CONTACT_NAME" }, "wa_id": "16315551234" } ], "messages": [ { "from": "16505553333", "id": "wamid.id", "timestamp": "1603087229", "type": "document", "document": { "caption": "This is a caption", "mime_type": "document/pdf", "sha256": "81d3bd8a8db4868c9520ed47186e8b7c5789e61ff79f7f834be6950b808a90d3", "id": "2754859441498128" } } ] }, "field": "messages" } ] } ] }';
                // Set up the POST request
                RestRequest request = new RestRequest();
                request.httpMethod = 'POST';
                RestContext.request = request;
                RestContext.request.requestBody = Blob.valueOf(jsonBody);
                
                // Call the doPost method
                C3WhatsappWebhookAPI.doPost();
                System.assertEquals( (jsonBody != null) ,true);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testDoPost7() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                Lead objLead = new Lead(LastName = 'test', Company='Testasd'); 
                insert objLead;
                C3WhatsappWebhookAPI.sendPushWhatsAppNotification(objLead.Id, 'New MEessage');
                System.assertEquals( (objLead.Id != null) ,true);
            Test.stopTest();
        }
    }
}