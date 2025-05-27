@isTest
global class C3BulkTemplateSenderLwcControllerTest {
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
            C3TestDataFactory.createTemplate();
            C3TestDataFactory.createWhatsAppConfigRecord('Contact', 'Phone');
            C3TestDataFactory.insertWhatsAppAdmin();
            Account objAcc = C3TestDataFactory.createAccount();
            INSERT objAcc;
            INSERT C3TestDataFactory.createContacts(2, objAcc.Id);
        }
    }

    @isTest
    public static void testMethod1(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            String templateId = [SELECT Id FROM Template_Object__c LIMIT 1].Id;

            Test.startTest();
                C3BulkTemplateSenderLwcController.getObjectsfromNumberConfig();
                C3BulkTemplateSenderLwcController.validateObject('Contact');
                List<Map<String, Object>> jsonMap =  C3BulkTemplateSenderLwcController.fetchObjectRecords('Contact');
                System.assertEquals( (jsonMap != null) ,true);
            Test.stopTest();
        }
    }

    
}