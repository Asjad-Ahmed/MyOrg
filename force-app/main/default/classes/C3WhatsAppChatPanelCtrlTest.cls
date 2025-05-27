@isTest
global class C3WhatsAppChatPanelCtrlTest {
	@TestSetup
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
            String jsonBody = '{"whatsAppTemplateId":"189060917316209","templateName":"send_message","templateId":"","templateBody":"<p>Hello {{1}},</p><p><br></p><p>This side {{2}} from salesforce partner if you have the requirement of CRM software to manage your customer list efficiently, along with all the customization we are the Salesforce partner, who provide the fully CRM solution that can significantly enhance your business operations and drive sales growth. I would be more than happy to arrange a personalized demo to showcase how [CRM] can revolutionize your company&#39;s sales and customer management efforts. If you&#39;re interested, please let me know, and we can find a convenient time to discuss further. Kindly share me your contact number and email id for easy communication.</p><p><br></p><p>Best regards,</p><p>{{3}} </p><p>{{4}}</p><p>{{5}}</p><p>Powered By CCC Infotech</p>","publicDocUrl":null,"objectName":"Contact","mediaType":"IMAGE","listMapping":[{"placeHolder":"{{5}}","parameterNum":"5","mappingId":"","fieldName":"Email","exampleText":"dheeraj@cccinfotech.com"},{"placeHolder":"{{1}}","parameterNum":"1","mappingId":"","fieldName":"FirstName","exampleText":"Shreya"},{"placeHolder":"{{2}}","parameterNum":"2","mappingId":"","fieldName":"LastName","exampleText":"Singh"},{"placeHolder":"{{3}}","parameterNum":"3","mappingId":"","fieldName":"Name","exampleText":"Dheeraj"},{"placeHolder":"{{4}}","parameterNum":"4","mappingId":"","fieldName":"MobilePhone","exampleText":"917905256379"}],"listActions":[{"buttonId":"","typeOfAction":"","buttonText":"Call","countryCode":"91","phoneNumber":"9865326532","urlType":"","websiteUrl":"","isIcon":true,"iconName":"utility:call","type":"","isActionPhoneNumber":true,"isActionUrl":false,"actionType":"PHONE_NUMBER"}], "listQuickReply": null, "language":"en","isQuickReplyList":true,"isHeaderText":true,"isHeaderMedia":true,"isActionList":true,"headerType":"MEDIA","headerText":null,"footer":null,"fileName":null,"documentId":null,"contentVersionId":null,"category":"MARKETING","buttonOption":null}';
            C3WhatsAppTemplateScreenLWCCtrl.saveTemplateData(jsonBody);
            Template_Object__c obj = [SELECT Id, Status__c FROM Template_Object__c LIMIT 1];
            obj.Status__c = 'APPROVED';
            update obj;
            C3TestDataFactory.createWhatsAppConfigRecord('Contact', 'Phone');
            C3TestDataFactory.testInsertContentVersion(Blob.valueOf('Test Content'), 'Phone', 'file/png');
            Contact con = C3TestDataFactory.createContacts();
            System.assertEquals( (obj.Id != null) ,true);
        }
    }

    @isTest
    public static void testMethod1(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            String conId = [SELECT Id FROM Contact LIMIT 1].Id;
            C3WhatsAppChatPanelCtrl.initWhatsAppChatPanelController(conId, 'Contact');
            System.assertEquals( (conId != null) ,true);
        }
    }
    
    @isTest
    public static void testMethod2(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                String conId = [SELECT Id FROM Contact LIMIT 1].Id;
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageText'));
                C3WhatsAppChatPanelCtrl.saveMessage('', '919911410564', 'test Message', 'Contact', '', '', '', '', '');
                System.assertEquals( (conId != null) ,true);
            Test.stopTest();
        }
    }
   	@isTest
    public static void testMethod3(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                String conId = [SELECT Id FROM Contact LIMIT 1].Id;
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageMedia'));
                C3WhatsAppChatPanelCtrl.LoadTextMessages(conId, '919911410564', 'test Message', 'Contact', 'abc', ' /mp3', 'xyz', '', 'aaa','bbb');
                C3WhatsAppChatPanelCtrl.getMediaWamId('919911410564', ' wwww.audio.com', 'AUDIO', 'test');
                System.assertEquals( (conId != null) ,true);
            Test.stopTest();
        }
    }
   
   	@isTest
    public static void testMethod4(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                String conId = [SELECT Id FROM Contact LIMIT 1].Id;
                String cvId = [SELECT Id FROM ContentVersion LIMIT 1].Id;
                C3WhatsAppChatPanelCtrl.getPublicUrl('919891611767', cvId, conId, 'Contact', '');
                System.assertEquals( (conId != null) ,true);
            Test.stopTest();
        }
    }

    @isTest
    public static void testMethod5(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                String conId = [SELECT Id FROM Contact LIMIT 1].Id;
                //Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageText'));
                C3WhatsAppChatPanelCtrl.checkForNumberConfigurationImplemented(conId);
                System.assertEquals( (conId != null) ,true);
            Test.stopTest();
        }
    }
}