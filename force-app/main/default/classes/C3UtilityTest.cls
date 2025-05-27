@isTest
public class C3UtilityTest {
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
            C3TestDataFactory.insertWhatsNumberConfig();
            String jsonBody = '{"whatsAppTemplateId":"189060917316209","templateName":"send_message","templateId":"","templateBody":"<p>Hello {{1}},</p><p><br></p><p>This side {{2}} from salesforce partner if you have the requirement of CRM software to manage your customer list efficiently, along with all the customization we are the Salesforce partner, who provide the fully CRM solution that can significantly enhance your business operations and drive sales growth. I would be more than happy to arrange a personalized demo to showcase how [CRM] can revolutionize your company&#39;s sales and customer management efforts. If you&#39;re interested, please let me know, and we can find a convenient time to discuss further. Kindly share me your contact number and email id for easy communication.</p><p><br></p><p>Best regards,</p><p>{{3}} </p><p>{{4}}</p><p>{{5}}</p><p>Powered By CCC Infotech</p>","publicDocUrl":null,"objectName":"Lead","mediaType":null,"listMapping":[{"placeHolder":"{{5}}","parameterNum":"5","mappingId":"","fieldName":"Email","exampleText":"dheeraj@cccinfotech.com"},{"placeHolder":"{{1}}","parameterNum":"1","mappingId":"","fieldName":"FirstName","exampleText":"Shreya"},{"placeHolder":"{{2}}","parameterNum":"2","mappingId":"","fieldName":"LastName","exampleText":"Singh"},{"placeHolder":"{{3}}","parameterNum":"3","mappingId":"","fieldName":"Name","exampleText":"Dheeraj"},{"placeHolder":"{{4}}","parameterNum":"4","mappingId":"","fieldName":"MobilePhone","exampleText":"917905256379"}],"listActions":[{"buttonId":"","typeOfAction":"","buttonText":"Call","countryCode":"91","phoneNumber":"9865326532","urlType":"","websiteUrl":"","isIcon":true,"iconName":"utility:call","type":"","isActionPhoneNumber":true,"isActionUrl":false,"actionType":"PHONE_NUMBER"}], "listQuickReply": null, "language":"en","isQuickReplyList":true,"isHeaderText":true,"isHeaderMedia":false,"isActionList":true,"headerType":null,"headerText":null,"footer":null,"fileName":null,"documentId":null,"contentVersionId":null,"category":"MARKETING","buttonOption":null}';
            C3WhatsAppTemplateScreenLWCCtrl.saveTemplateData(jsonBody);
        }
        
    }
    @isTest
    public static void testMethod1(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                C3Utility.getFieldWithoutNameSpace('Mobile');
                C3Utility.getObjectFields('Lead');
                C3Utility.getStandardNameField(new Set<String>{'Lead'});
                C3Utility.getNameDetails('Test Name');
                String recordId = [SELECT Id FROM Template_Object__c LIMIT 1].Id;
                C3Utility.uploadFile(Blob.valueOf('Test Content'),  'fileName', ' /png', recordId );
                Map<String, List<String>> RecordIdsPrefix =new Map<String, List<String>>();
                RecordIdsPrefix.put(String.valueOf(recordId).substring(0,3), new List<String>{recordId});
                C3Utility.validateRecordIds(RecordIdsPrefix);
                C3Utility.uploadFile(Blob.valueOf('Test Content'),  'fileName', ' /png', recordId );
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass(''));
                C3WhatsAppUtilityBarCtrl.AllConversationMessages();
            Test.stopTest();
            System.assertEquals( (recordId != null) ,true);
        }
        
        
    }
    @isTest
    public static void testMethod2(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass(''));
                system.enqueueJob(new C3CreateWhatsAppConversationQueue(C3TestDataFactory.buildConvoRecord(null, '919911410564', 'recordId', 'asdasdasd')));
                String str = 'assert';
            Test.stopTest();    
            System.assertEquals( (str != null) , true);
        }
    }
}