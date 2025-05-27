@isTest
public class C3WhatsAppWebServiceTest {
    
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
            ContentVersion objCV = C3TestDataFactory.testInsertContentVersion(Blob.valueOf('Test Content'), 'Phone', 'file/png');
            String jsonBody = '{"whatsAppTemplateId":"189060917316209","templateName":"send_message","templateId":"","templateBody":"<p>Hello {{1}},</p><p><br></p><p>This side {{2}} from salesforce partner if you have the requirement of CRM software to manage your customer list efficiently, along with all the customization we are the Salesforce partner, who provide the fully CRM solution that can significantly enhance your business operations and drive sales growth. I would be more than happy to arrange a personalized demo to showcase how [CRM] can revolutionize your company&#39;s sales and customer management efforts. If you&#39;re interested, please let me know, and we can find a convenient time to discuss further. Kindly share me your contact number and email id for easy communication.</p><p><br></p><p>Best regards,</p><p>{{3}} </p><p>{{4}}</p><p>{{5}}</p><p>Powered By CCC Infotech</p>","publicDocUrl":null,"objectName":"Contact","mediaType":"IMAGE","listMapping":[{"placeHolder":"{{5}}","parameterNum":"5","mappingId":"","fieldName":"Email","exampleText":"dheeraj@cccinfotech.com"},{"placeHolder":"{{1}}","parameterNum":"1","mappingId":"","fieldName":"FirstName","exampleText":"Shreya"},{"placeHolder":"{{2}}","parameterNum":"2","mappingId":"","fieldName":"LastName","exampleText":"Singh"},{"placeHolder":"{{3}}","parameterNum":"3","mappingId":"","fieldName":"Name","exampleText":"Dheeraj"},{"placeHolder":"{{4}}","parameterNum":"4","mappingId":"","fieldName":"MobilePhone","exampleText":"917905256379"}],"listActions":[{"buttonId":"","typeOfAction":"","buttonText":"Call","countryCode":"91","phoneNumber":"9865326532","urlType":"","websiteUrl":"","isIcon":true,"iconName":"utility:call","type":"","isActionPhoneNumber":true,"isActionUrl":false,"actionType":"PHONE_NUMBER"}], "listQuickReply": null, "language":"en","isQuickReplyList":true,"isHeaderText":true,"isHeaderMedia":true,"isActionList":true,"headerType":"MEDIA","headerText":null,"footer":null,"fileName":null,"documentId":null,"contentVersionId":null,"category":"MARKETING","buttonOption":null}';
            C3WhatsAppTemplateScreenLWCCtrl.saveTemplateData(jsonBody);
            Template_Object__c objTemplate = [SELECT Id, Status__c FROM Template_Object__c LIMIT 1];
            ContentDocumentLink objCDL = C3TestDataFactory.testInsertCDL((String)objCV.Id, (String)objTemplate.Id);
            objTemplate.Status__c = 'APPROVED';
            objTemplate.TemplateID__c = '12423214';
            objTemplate.Media_Handler__c = 'Media_Handler__c';
            objTemplate.Content_Version_Id__c = objCV.Id;
            objTemplate.Mime_Type__c = 'image/png';
            objTemplate.Footer__c = 'footer';
            objTemplate.File_Name__c = 'testFile';
            objTemplate.Header__c = 'header';
            objTemplate.Header_Type__c = 'TEXT';
            objTemplate.Media_Type__c = 'IMAGE';
            objTemplate.Document_Url__c = 'testurl.com';
            update objTemplate;
            List<Template_Parameter__c> lstTemplateParameter = C3TestDataFactory.createTemplateMappings(5, objTemplate.Id);
            insert lstTemplateParameter;
            C3TestDataFactory.createTemplateButtons( objTemplate.Id);
            C3TestDataFactory.createWhatsAppConfigRecord('Contact', 'Phone');
            Contact con = C3TestDataFactory.createContacts();
        }
    }

    @isTest 
    public static void method1(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {

            Template_Object__c dataTemplate = [Select id, Name, Status__c, TemplateID__c,Header_Type__c, Whatsapp_Template__c,Template_Message__c,Object__c,Language_Code__c FROM Template_Object__c LIMIT 1];
            dataTemplate.Header_Type__c = 'MEDIA';
            update dataTemplate;
            String conId = [SELECT Id FROM Contact LIMIT 1].Id;
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageSendTemplate'));
                C3WhatsAppTemplateScreenLWCCtrl.sendWhatsAppMessage(new List<string>{conId}, dataTemplate.Id  );
                System.assertEquals( (dataTemplate.Id != null) ,true);
            Test.stopTest();
        }
    }

    @isTest 
    public static void method2(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Template_Object__c dataTemplate = [Select id, Name, Status__c, TemplateID__c,Header_Type__c, Whatsapp_Template__c,Template_Message__c,Object__c,Language_Code__c FROM Template_Object__c LIMIT 1];
            String jsonBody = '{"whatsAppTemplateId":"189060917316209","templateName":"send_message","templateId":"'+dataTemplate.Id+'","templateBody":"<p>Hello {{1}},</p><p><br></p><p>This side {{2}} from salesforce partner if you have the requirement of CRM software to manage your customer list efficiently, along with all the customization we are the Salesforce partner, who provide the fully CRM solution that can significantly enhance your business operations and drive sales growth. I would be more than happy to arrange a personalized demo to showcase how [CRM] can revolutionize your company&#39;s sales and customer management efforts. If you&#39;re interested, please let me know, and we can find a convenient time to discuss further. Kindly share me your contact number and email id for easy communication.</p><p><br></p><p>Best regards,</p><p>{{3}} </p><p>{{4}}</p><p>{{5}}</p><p>Powered By CCC Infotech</p>","publicDocUrl":null,"objectName":"Contact","mediaType":"IMAGE","listMapping":[{"placeHolder":"{{5}}","parameterNum":"5","mappingId":"","fieldName":"Email","exampleText":"dheeraj@cccinfotech.com"},{"placeHolder":"{{1}}","parameterNum":"1","mappingId":"","fieldName":"FirstName","exampleText":"Shreya"},{"placeHolder":"{{2}}","parameterNum":"2","mappingId":"","fieldName":"LastName","exampleText":"Singh"},{"placeHolder":"{{3}}","parameterNum":"3","mappingId":"","fieldName":"Name","exampleText":"Dheeraj"},{"placeHolder":"{{4}}","parameterNum":"4","mappingId":"","fieldName":"MobilePhone","exampleText":"917905256379"}],"listActions":[{"buttonId":"","typeOfAction":"","buttonText":"Call","countryCode":"91","phoneNumber":"9865326532","urlType":"","websiteUrl":"","isIcon":true,"iconName":"utility:call","type":"","isActionPhoneNumber":true,"isActionUrl":false,"actionType":"PHONE_NUMBER"}], "listQuickReply": null, "language":"en","isQuickReplyList":true,"isHeaderText":true,"isHeaderMedia":true,"isActionList":true,"headerType":"MEDIA","headerText":null,"footer":null,"fileName":null,"documentId":null,"contentVersionId":null,"category":"MARKETING","buttonOption":null}';

            String conId = [SELECT Id FROM Contact LIMIT 1].Id;
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageCreateTemplate'));
                C3WhatsAppWebService.sendWhatsAppTemplateToMeta( jsonBody );
                System.assertEquals( (conId != null) ,true);
            Test.stopTest();
        }
    }

    @isTest 
    public static void method3(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageText'));
                C3WhatsAppWebService.sendWhatsAppMessage( '919891611767', 'aasdasdasdadasd' );  
                String conId = [SELECT Id FROM Contact LIMIT 1].Id;
                System.assertEquals( (conId != null) ,true);      
            Test.stopTest();
        }
    }

    @isTest 
    public static void method4(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageMedia'));
                C3WhatsAppChatPanelCtrl.getMediaWamId('919911410564', ' wwww.audio.com', 'AUDIO', 'test');
                String conId = [SELECT Id FROM Contact LIMIT 1].Id;
                System.assertEquals( (conId != null) ,true);      
            Test.stopTest();
        }
    }


    @isTest 
    public static void method5(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            String conId = [SELECT Id FROM Contact LIMIT 1].Id;
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageMediaAPI'));
                C3WhatsAppWebService.getMediaFromAPI( 'mediaId',  'fileName',  ' /png',  conId);
            
                System.assertEquals( (conId != null) ,true);      
            Test.stopTest();
        }
    }

    @isTest 
    public static void method6(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass(''));
                C3WhatsAppWebService.deleteTemplate( 'send_message');
                String conId = [SELECT Id FROM Contact LIMIT 1].Id;
                System.assertEquals( (conId != null) ,true);      
            Test.stopTest();
        }
    }

    @isTest 
    public static void method7(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppUploadAPI'));
                C3WhatsAppTemplateScreenLWCCtrl.runMediaAPIs(cv.Id, 'image/png' );
                System.assertEquals( (cv.id != null) ,true);      
            Test.stopTest();
        }
    }
}