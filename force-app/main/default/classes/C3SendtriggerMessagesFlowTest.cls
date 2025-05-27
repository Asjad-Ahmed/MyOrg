@isTest
private class C3SendtriggerMessagesFlowTest {
    
    @testSetup
    static void testSendTemplate() {

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
        
            Lead testLead = new Lead(LastName = 'Test Lead', Company = 'Testing Lead');
            insert testLead;
            
            Template_Object__c templateRecord = new Template_Object__c();
            
            templateRecord.Category__c = 'Marketing';
            templateRecord.Header_Type__c = 'Text';
            templateRecord.Header__c = 'Demo';
            templateRecord.Template_Label__c = 'Test';
            templateRecord.Language_Code__c = 'English';
            templateRecord.Object__c = 'Lead';
            templateRecord.Template_Message__c = 'Testing';
            
            insert templateRecord;
        
        }
    }

    @isTest
    static void method1() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Lead testLead = [SELECT Id FROM LEAD LIMIT 1];
            Template_Object__c templateRecord = [SELECT Id FROM Template_Object__c LIMIT 1];
            C3SendtriggerMessagesFlow.FlowInput flowInput = new C3SendtriggerMessagesFlow.FlowInput();
            flowInput.recordId = testLead.Id;
            flowInput.templateRecordId = templateRecord.Id;
            List<C3SendtriggerMessagesFlow.FlowInput> flowInputs = new List<C3SendtriggerMessagesFlow.FlowInput>{ flowInput };
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageSendTemplate'));
                C3SendtriggerMessagesFlow.sendTemplate(flowInputs);
            Test.stopTest();
        }
    }
}