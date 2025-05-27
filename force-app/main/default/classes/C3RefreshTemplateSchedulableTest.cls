@isTest
private class C3RefreshTemplateSchedulableTest {

    @testSetup
    public static void makeData() {
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
            List<Template_Object__c> listTemplates = new List<Template_Object__c>();
            for (Integer i = 0; i < 10; i++) {
                Template_Object__c template = new Template_Object__c(
                    Name = 'Template ' + i,
                    TemplateID__c = 'WhatsAppID' + i,
                    Status__c = 'Pending'
                );
                listTemplates.add(template);
            }
            insert listTemplates;
        }
    }

    @isTest
    static void testExecuteWithCurrentUserPermissions() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('refreshTemplate'));
                C3RefreshTemplateSchedulable schedulable = new C3RefreshTemplateSchedulable();
                schedulable.execute(null);
            Test.stopTest();
            List<Template_Object__c> updatedTemplates = [SELECT Id, Name, TemplateID__c, Status__c FROM Template_Object__c];
            System.assertEquals(10, updatedTemplates.size(), 'Number of templates should remain the same');
        }
    } 
}