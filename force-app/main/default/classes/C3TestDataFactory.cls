@isTest
public with sharing class C3TestDataFactory {
    public static Account createAccount(){
        Account objAccount = new Account();
        objAccount.Name='Test class Account';
        objAccount.AccountNumber='99999999999';
        objAccount.AccountSource='';
        objAccount.BillingCity='Noida';
        objAccount.BillingCountry ='India';
        objAccount.Industry = 'Education';
        objAccount.NumberOfEmployees = 89;
        objAccount.Website = 'www.cccinfotech.com/contact-us';
        objAccount.Type='Customer';
        
        return objAccount;
    }
    public static Template_Object__c createTemplate(){
        Template_Object__c objTemplate = new Template_Object__c();
        objTemplate.Category__c ='UTILITY';
        objTemplate.Language_Code__c ='en';
        objTemplate.Status__c ='APPROVED';
        objTemplate.Name='greeting_message';
        objTemplate.Template_Label__c='greeting_message';
        objTemplate.Status__c='APPROVED';
        objTemplate.TemplateID__c='123465';
        objTemplate.Language_Code__c='en';
        objTemplate.Header_Type__c='IMAGE';
        objTemplate.Object__c='Lead';
        objTemplate.Header__c='Lead';
        objTemplate.Template_Message__c='Hello {{1}},This side {{2}} from salesforce partner if you have the requirement of CRM software to manage your customer list efficiently, along with all the customization we are the Salesforce partner, who provide the fully CRM solution that can significantly enhance your business operations and drive sales growth. I would be more than happy to arrange a personalized demo to showcase how [CRM] can revolutionize your companys sales and customer management efforts. If you are interested, please let me know, and we can find a convenient time to discuss further. Kindly share me your contact number and email id for easy communication.Best regards,{{3}} {{4}}{{5}}Powered By CCC Infotech';
        objTemplate.Whatsapp_Template__c='Hello {{1}},This side {{2}} from salesforce partner if you have the requirement of CRM software to manage your customer list efficiently, along with all the customization we are the Salesforce partner, who provide the fully CRM solution that can significantly enhance your business operations and drive sales growth. I would be more than happy to arrange a personalized demo to showcase how [CRM] can revolutionize your companys sales and customer management efforts. If you are interested, please let me know, and we can find a convenient time to discuss further. Kindly share me your contact number and email id for easy communication.Best regards,{{3}} {{4}}{{5}}Powered By CCC Infotech';
        objTemplate.Media_Handler__c = 'asdasdasd'; 
        Database.INSERT(objTemplate, AccessLevel.SYSTEM_MODE);
        return objTemplate;
    }
    
    public static List<Contact> createContacts(integer num, String accId){
        List<Contact> lstContact = new List<Contact>();
        for(Integer i = 0; i<= num; i++){
            Contact objContact = new Contact();
            objContact.LastName = 'testcontact' + i;
            objContact.FirstName = ' test contact' +i;
            objContact.AccountId = accId;
            objContact.MobilePhone='919911410564';
            objContact.Phone='919911410564';
            objContact.AssistantPhone = '919911410564';
            objContact.Email = 'shreya@cccinfotech.com';
            
            lstContact.add(objContact);
        }
        
        return lstContact;
    }
    
    public static Contact createContacts(){
        List<Contact> lstContact = new List<Contact>();
        Contact objContact = new Contact();
        objContact.LastName = 'testcontact' ;
        objContact.FirstName = 'test contact' ;
        objContact.MobilePhone='919911410564';
        objContact.Phone='919911410564';
        objContact.AssistantPhone = '919911410564';
        objContact.Email = 'shreya@cccinfotech.com';
        Database.INSERT(objContact, AccessLevel.SYSTEM_MODE);
        return objContact;
    }
    
    public static List<Template_Parameter__c> createTemplateMappings(Integer numb, String templateId){
        List<Template_Parameter__c> listTemplateParameter = new List<Template_Parameter__c>();
        
        Template_Parameter__c objTemplateParameter1 = new Template_Parameter__c();
        objTemplateParameter1.Example_Text__c='test';
        objTemplateParameter1.Object_name__c = 'Contact';
        objTemplateParameter1.Parameter_Name__c= '1' ;
        objTemplateParameter1.Field_Name__c= 'FirstName';
        objTemplateParameter1.Template__c = templateId;
        listTemplateParameter.add(objTemplateParameter1);
        
        Template_Parameter__c objTemplateParameter2 = new Template_Parameter__c();
        objTemplateParameter2.Example_Text__c='test';
        objTemplateParameter2.Object_name__c = 'Contact';
        objTemplateParameter2.Parameter_Name__c= '2' ;
        objTemplateParameter2.Field_Name__c= 'LastName';
        objTemplateParameter2.Template__c = templateId;
        listTemplateParameter.add(objTemplateParameter2);
        
        Template_Parameter__c objTemplateParameter3 = new Template_Parameter__c();
        objTemplateParameter3.Example_Text__c='test';
        objTemplateParameter3.Object_name__c = 'Contact';
        objTemplateParameter3.Parameter_Name__c= '3' ;
        objTemplateParameter3.Field_Name__c= 'Name';
        objTemplateParameter3.Template__c = templateId;
        listTemplateParameter.add(objTemplateParameter3);
        
        Template_Parameter__c objTemplateParameter4 = new Template_Parameter__c();
        objTemplateParameter4.Example_Text__c='917948948998';
        objTemplateParameter4.Object_name__c = 'Contact';
        objTemplateParameter4.Parameter_Name__c= '4' ;
        objTemplateParameter4.Field_Name__c= 'MobilePhone';
        objTemplateParameter4.Template__c = templateId;
        listTemplateParameter.add(objTemplateParameter4);
        
        Template_Parameter__c objTemplateParameter5 = new Template_Parameter__c();
        objTemplateParameter5.Example_Text__c='test@gmail.com';
        objTemplateParameter5.Object_name__c = 'Contact';
        objTemplateParameter5.Parameter_Name__c= '5' ;
        objTemplateParameter5.Field_Name__c= 'Email';
        objTemplateParameter5.Template__c = templateId;
        listTemplateParameter.add(objTemplateParameter5);
        return listTemplateParameter;

    }
    
    
    public static List<Template_Button__c> createTemplateButtons( String templateId){
        List<Template_Button__c> listOfTemplateButton = new List<Template_Button__c>();
        Template_Button__c objButton = new Template_Button__c();
        objButton.Button_Type__c = 'call to action';
        objButton.Type_of_Action__c = 'PHONE_NUMBER';
        objButton.Button_text__c = 'asdasd';
        objButton.Country_Code__c = '91';
        objButton.Phone_Number__c = 'objLstAct.phoneNumber';
        
        objButton.URL_Type__c = 'static';
        
        objButton.Website_URL__c = 'objLstAct.websiteUrl';
        
        objButton.Template__c = templateId;
        listOfTemplateButton.add(objButton);
        
        Template_Button__c objButton2 = new Template_Button__c();
        objButton2.Button_Type__c = 'QUICK_REPLY';
        objButton2.Button_text__c = 'asdasd';
        
        
        objButton2.Template__c = templateId;
        listOfTemplateButton.add(objButton2);

        Database.INSERT(listOfTemplateButton, AccessLevel.SYSTEM_MODE);
        return listOfTemplateButton;
    }

    public static WhatsApp_Conversation__b buildConvoRecord(Template_Object__c objTemplate, String toNumber, String recordId, String wamId){
        WhatsApp_Conversation__b objTxtMsg = new WhatsApp_Conversation__b();
        objTxtMsg.Direction__c = 'Outbound';
        objTxtMsg.Status__c = 'Pending';
        objTxtMsg.Record_ID__c = recordId;
        objTxtMsg.Read__c = 'false';
        objTxtMsg.Message__c = 'test Messagae';
        objTxtMsg.Message_formatted__c = 'test Messagae';
        objTxtMsg.From_Phone__c = '919911410564';
        objTxtMsg.Read__c = 'true';
        objTxtMsg.To_Phone__c = toNumber;
        objTxtMsg.Interaction_Type__c='Whatsapp';
        objTxtMsg.Created_date__c = DateTime.now();
        objTxtMsg.sid__c = wamId;
        objTxtMsg.Status__c = 'sent'; 
        objTxtMsg.Media_URL__c = 'testURL.com'; 
        objTxtMsg.File_Name__c = 'Test_file_Name'; 
        objTxtMsg.Media_Type__c = 'image'; 
        objTxtMsg.Interaction_Type__c='MMS';
        objTxtMsg.Unique_Key__c = recordId+'-'+System.Now().formatLong();
        //database.insertImmediate(objTxtMsg);
        return objTxtMsg;
    }


    public static void createWhatsAppConfigRecord(String objectName, String fieldName){
        WhatsApp_Number_Configuration__c objWNC = new WhatsApp_Number_Configuration__c();
        objWNC.Name =  objectName;
        objWNC.Object_Name__c =  objectName;
        objWNC.Field_Name__c =  fieldName;
        objWNC.Object_Label__c =  objectName;
       Database.INSERT(objWNC, AccessLevel.SYSTEM_MODE);
        //return objWNC;
    }

    public static ContentVersion testInsertContentVersion(Blob fileContent, String fileName, String fileType) {
        ContentVersion objCV = new ContentVersion();
        objCV.VersionData = fileContent;
        objCV.Title = fileName;
        objCV.PathOnClient = fileName;
        if(String.isNotBlank(fileType) && fileType.contains('/')){
            String ext = fileType.split('/')[1];
            objCV.PathOnClient = objCV.PathOnClient + ext ;
            objCV.Title = objCV.Title + ext ;
        }
        Database.INSERT(objCV, AccessLevel.SYSTEM_MODE);
        return objCV;
    }

    public static ContentDocumentLink testInsertCDL(String cvId, String recordId) {
        ContentDocumentLink objCDL = new ContentDocumentLink();
        String[] listFields = new String[]{'ContentDocumentId', 'Id'};
        if(C3Utility.checkFieldPermission('ContentVersion', 'isAccessible', null, true) 
            && C3Utility.checkFieldPermission('ContentVersion', 'isAccessible', listFields, false)){
                objCDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cvId].ContentDocumentId;
        }else {
            throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
        }
        objCDL.LinkedEntityId = recordId;
        objCDL.ShareType = 'V';
         Database.INSERT(objCDL, AccessLevel.SYSTEM_MODE);
        return objCDL;
    }

    public static WhatsApp_Admin__c insertWhatsAppAdmin() {
       WhatsApp_Admin__c objAdminConfig = new WhatsApp_Admin__c(Name = 'admin', NumberID__c = 'asdasdasd', WabaId__c = 'dsfgasdas');
       Database.INSERT(objAdminConfig, AccessLevel.SYSTEM_MODE);
        return objAdminConfig;
    }


    public static WhatsApp_Number_Configuration__c insertWhatsNumberConfig() {
        WhatsApp_Number_Configuration__c objNumberConfig = new WhatsApp_Number_Configuration__c(Name = 'Lead', Field_Name__c = 'Mobile', Object_Name__c = 'Lead');
        Database.INSERT(objNumberConfig, AccessLevel.SYSTEM_MODE);
        return objNumberConfig;
    }
}