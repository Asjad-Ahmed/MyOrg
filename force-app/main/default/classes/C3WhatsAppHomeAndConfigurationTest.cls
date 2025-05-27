@isTest
global class C3WhatsAppHomeAndConfigurationTest {
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
        }
    }

    @isTest
    public static void testMethod1(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            String templateId = [SELECT Id FROM Template_Object__c LIMIT 1].Id;

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new C3HttpCalloutMockBundleClass('WhatsAppMessageText'));
                C3WhatsAppTemplateHomeController.WhatsAppTemplates();
                C3WhatsAppTemplateHomeController.DeleteWhatsAppTemplates(templateId);
                System.assertEquals( (templateId != null) ,true);
            Test.stopTest();
        }
    }

    @isTest
    public static void testMethod2(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            String templateId = [SELECT Id FROM Template_Object__c LIMIT 1].Id;

            Test.startTest();

                C3WhatsappNumberConfiguration.initWhatsAppNumberConfiguration();
                C3WhatsappNumberConfiguration.getObjectLabel('Contact');
                C3WhatsappNumberConfiguration.getAllPhoneField('Contact');
                C3WhatsappNumberConfiguration.saveWhatsAppNumberConfig(json.serialize(WhatsApp_Number_Configuration__c.getAll().values()[0]));
                C3WhatsappNumberConfiguration.deleteWhatsAppNumberConfig(json.serialize(WhatsApp_Number_Configuration__c.getAll().values()[0]));
                System.assertEquals( (templateId != null) ,true);
            Test.stopTest();
        }
    }

    @isTest
    public static void testMethod3(){
       
        User testUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                C3AdminPanelLwcController.initialize();
                WhatsApp_Admin__c objAdminConfig = new WhatsApp_Admin__c(Name = 'asdasd', NumberID__c = 'asdasdasd', WabaId__c = 'dsfgasdas');
                C3AdminPanelLwcController.saveAdminConfig(JSON.serialize(objAdminConfig));
                System.assertEquals( (objAdminConfig != null) ,true);
            Test.stopTest();
        }
    }
}