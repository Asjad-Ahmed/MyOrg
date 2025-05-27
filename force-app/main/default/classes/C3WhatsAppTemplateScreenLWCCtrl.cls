public with sharing class C3WhatsAppTemplateScreenLWCCtrl {    
    @AuraEnabled(cacheable=true)
    public static List<Template_Object__c> searchTemplates(String searchTerm) {
        try{
            String searchKey = '%' + searchTerm + '%';
            String [] FieldsToQuery = new String [] {'Id', 'Name', 'Whatsapp_Template__c'};
                if((!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',null,true)) && (!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',FieldsToQuery,false))){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    return [SELECT Id, Name, Whatsapp_Template__c FROM Template_Object__c WHERE Name LIKE :searchKey WITH SECURITY_ENFORCED];
                }
        }catch(exception ex){ C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppTemplateScreenLWCCtrl','searchTemplates',''); return null; }
    }
    
    @AuraEnabled(cacheable=true)
    public static Template_Object__c getRecordData(String recordId, String objectName) {
        try{
            System.debug('recordId -- '+recordId);
            System.debug('objectName -- '+objectName);
            String [] FieldsToQuery = new String [] {'Id', 'Name', 'Language_Code__c', 'Status__c', 'Template_Message__c', 'Header_Type__c', 'File_Name__c', 'Media_Type__c', 'Media_Handler__c', 'Footer__c', 'Header__c', 'Document_Url__c'  };
            String [] FieldsToQuery2 = new String [] {'Id', 'Field_Name__c', 'Object_name__c', 'Parameter_Name__c'  };
            String [] FieldsToQuery3 = new String [] {'Id', 'Button_text__c', 'Button_Type__c', 'Country_Code__c', 'Phone_Number__c', 'Type__c', 'Type_of_Action__c', 'URL_Type__c', 'Website_URL__c'  };
            Boolean b1 = (!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',null, true));
            Boolean b12 = (!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',FieldsToQuery,False));
            Boolean b2 = (!C3Utility.checkFieldPermission('Template_Mapping__c','isAccessible',null, true));
            Boolean b22 = (!C3Utility.checkFieldPermission('Template_Mapping__c','isAccessible',FieldsToQuery2,False));
            Boolean b3 = (!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',null, true));
            Boolean b32 = (!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',FieldsToQuery3,False));
            if(b1 && b2 && b3 && b12 && b22 && b32){
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');                
            }else{
                return [SELECT Id, Name, Language_Code__c, Whatsapp_Template__c, Status__c, Template_Message__c, Header_Type__c, File_Name__c, Media_Type__c, Media_Handler__c, Footer__c, Header__c, Document_Url__c, (SELECT Id, Field_Name__c, Object_name__c, Parameter_Name__c FROM Template_Mappings__r WHERE Object_name__c =: objectName ), (SELECT Id, Button_text__c, Button_Type__c, Country_Code__c, Phone_Number__c, Type__c, Type_of_Action__c, URL_Type__c, Website_URL__c FROM Template_Buttons__r) FROM Template_Object__c WHERE Id = :recordId WITH SECURITY_ENFORCED];
            }
        }catch(exception ex){ C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppTemplateScreenLWCCtrl','getRecordData',''); return null; }
    }
    
    @AuraEnabled
    public static String sendWhatsAppMessage(List<String> recordIds, String templateRecordId){
        try{
            if(recordIds != null && (!recordIds.isEmpty()) && String.isNotBlank(templateRecordId)){
                string resbody='';
                string phoneField ='';
                set<String> setOfIds;
                
                List<String> lstIds = recordIds ;
                setOfIds = new Set<String>(lstIds);
                
                Id recordId = Id.valueOf(lstIds[0]);
                String objectName = recordId.getSObjectType().getDescribe().getName();
                Map<String, String> mapParamNumWithFieldName = new Map<String, String>();
                Template_Object__c objTemplate = getRecordData(templateRecordId, objectName);
                List<SObject> lstSObject = new List<SObject>();
                
                if((objTemplate != null) && (objTemplate.Template_Mappings__r != null) && objTemplate.Template_Mappings__r.size()>0 ){
                    for(Template_Parameter__c objTempMapping : objTemplate.Template_Mappings__r ){
                        mapParamNumWithFieldName.put(objTempMapping.Parameter_Name__c, objTempMapping.Field_Name__c );
                    }
                }
                set<String> fieldSet = new Set<String>(mapParamNumWithFieldName.values());
                phoneField = C3Utility.getFieldName(objectName);
                fieldSet.add(phoneField);
                fieldSet.add('Name');
                String query = 'SELECT Id, '+ String.join(fieldSet, ',') + ' FROM '+objectName+' WHERE Id IN: setOfIds';
                List<SObject> listOfSObject = new List<SObject>();                
                List<String> fieldsToQuery = new List<String>(fieldSet);
                Boolean b1 = (!C3Utility.checkFieldPermission(objectName,'isAccessible',null, true));
                Boolean b2 = (!C3Utility.checkFieldPermission(objectName,'isAccessible',fieldsToQuery,false));
                if(b1 && b2){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    listOfSObject = database.query(String.escapeSingleQuotes(query));
                }
                if(!listOfSObject.isEmpty())
                    resbody = C3WhatsAppWebService.createWebserviceBody(listOfSObject, mapParamNumWithFieldName, objTemplate, phoneField);
                return resbody;            
            }
            return null;
        }catch(exception ex){ C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppTemplateScreenLWCCtrl','sendWhatsAppMessage',''); return null; }
    }
    
    @AuraEnabled
    public static void sendWhatsAppMessageBulk(List<String> recordIds, String templateRecordId){
        try{
            System.debug('recordIds '+ recordIds);
            System.debug('templateRecordId '+ templateRecordId);
            if(recordIds != null && (!recordIds.isEmpty()) && String.isNotBlank(templateRecordId)){
                Set<String> setRecordIds = new Set<String>(recordIds);
                Id recordId = Id.valueOf(recordIds[0]);
                String objectName = recordId.getSObjectType().getDescribe().getName();
                Map<String, String> mapParamNumWithFieldName = new Map<String, String>();
                Template_Object__c objTemplate = getRecordData(templateRecordId, objectName);
                List<SObject> lstSObject = new List<SObject>();
                if((objTemplate != null) && (objTemplate.Template_Mappings__r != null) && objTemplate.Template_Mappings__r.size()>0 ){
                    for(Template_Parameter__c objTempMapping : objTemplate.Template_Mappings__r ){
                        mapParamNumWithFieldName.put(objTempMapping.Parameter_Name__c, objTempMapping.Field_Name__c );
                    }
                }
                set<String> fieldSet = new Set<String>(mapParamNumWithFieldName.values());
                String phoneField = C3Utility.getFieldName(objectName);
                fieldSet.add(phoneField);
                fieldSet.add('Name');
                String query = 'SELECT Id, '+ String.join(fieldSet, ',') + ' FROM '+objectName+' WHERE Id IN: setRecordIds WITH SECURITY_ENFORCED';
                List<String> FieldsToQuery = new List<String>(fieldSet);
                Boolean b1 = (!C3Utility.checkFieldPermission(objectName,'isAccessible',null,true));
                Boolean b2 = (!C3Utility.checkFieldPermission(objectName,'isAccessible',FieldsToQuery,False));
                if(b1 && b2){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    Database.executeBatch(new C3WhatsAppSendTemplateBulkBatch(setRecordIds, query, mapParamNumWithFieldName, objTemplate,  phoneField), 50);
                }
            }
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppTemplateScreenLWCCtrl','sendWhatsAppMessageBulk','');          
        }
    }
    
    
    @AuraEnabled
    public static String saveTemplateData(String jsonData) {
        try{
            String strDocUrl = '';
            if(String.isNotBlank(jsonData)){
                TemplateWrapper objTemplateWrapper = (TemplateWrapper)JSON.deserialize(jsonData, TemplateWrapper.class);
                Template_Object__c objSFTemplate = new Template_Object__c();
                List<Template_Parameter__c> listTemplateMapping = new List<Template_Parameter__c>();
                if(String.isNotBlank(objTemplateWrapper.templateId)){
                    objSFTemplate.Id = objTemplateWrapper.templateId;
                }
                objSFTemplate.Name = objTemplateWrapper.templateName.replaceAll(' ' , '_').toLowerCase();
                objSFTemplate.Template_Label__c = objTemplateWrapper.templateName;
                objSFTemplate.Language_Code__c = objTemplateWrapper.language;
                objSFTemplate.Object__c = objTemplateWrapper.objectName;
                objSFTemplate.Whatsapp_Template__c = objTemplateWrapper.templateBody;
                objSFTemplate.Template_Message__c = getFormattedBody(objTemplateWrapper.templateBodyText);
                objSFTemplate.Category__c = objTemplateWrapper.category;
                if(String.isNotBlank(objTemplateWrapper.headerText)){
                    objSFTemplate.Header__c = objTemplateWrapper.headerText;
                    objSFTemplate.Header_Type__c = 'TEXT';
                }
                if(String.isNotBlank(objTemplateWrapper.publicDocUrl))
                    objSFTemplate.Document_Url__c = objTemplateWrapper.publicDocUrl;	
                if(String.isNotBlank(objTemplateWrapper.mediaHandler))
                    objSFTemplate.Media_Handler__c = objTemplateWrapper.mediaHandler;	
                if(String.isNotBlank(objTemplateWrapper.headerType)){
                    objSFTemplate.Header_Type__c = objTemplateWrapper.headerType;
                }
                if(String.isNotBlank(objTemplateWrapper.mediaType)){
                    objSFTemplate.Media_Type__c = objTemplateWrapper.mediaType;
                }
                if(String.isNotBlank(objTemplateWrapper.footer)){
                    objSFTemplate.footer__c = objTemplateWrapper.footer;
                }
                if(String.isNotBlank(objTemplateWrapper.contentVersionId)){
                    objSFTemplate.Content_Version_Id__c = objTemplateWrapper.contentVersionId;
                }
                if(String.isNotBlank(objTemplateWrapper.mimeType)){
                    objSFTemplate.Mime_Type__c = objTemplateWrapper.mimeType;
                }
                String[] FieldsToQuery = new String[]{'Id', 'Name', 'Template_Label__c', 'Language_Code__c', 'Object__c', 'Whatsapp_Template__c', 'Template_Message__c', 'Category__c', 'Header__c', 'File_Name__c', 'Header_Type__c', 'Document_Url__c', 'Media_Handler__c', 'Header_Type__c', 'Media_Type__c', 'footer__c', 'Content_Version_Id__c', 'Mime_Type__c'};
                Boolean b1 = (!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',null,true));
                Boolean b11 = (!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',FieldsToQuery,false));
                Boolean b2 = (!C3Utility.checkFieldPermission('Template_Object__c','isCreateable',null,true));
                Boolean b22 = (!C3Utility.checkFieldPermission('Template_Object__c','isCreateable',FieldsToQuery,false));
                Boolean b3 = (!C3Utility.checkFieldPermission('Template_Object__c','isUpdateable',null,true));
                Boolean b33 = (!C3Utility.checkFieldPermission('Template_Object__c','isUpdateable',FieldsToQuery,false));
                if(b1 && b2 && b3 && b11 && b22 && b33){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    Database.UPSERT( objSFTemplate, AccessLevel.SYSTEM_MODE);
                }
                if(objTemplateWrapper.listMapping != null && objTemplateWrapper.listMapping.size()>0){
                    for (ListMapping objMapping : objTemplateWrapper.listMapping) {
                        if(String.isNotBlank(objMapping.fieldName)){
                            Template_Parameter__c objTempParam = new Template_Parameter__c();
                            if(String.isNotBlank(objMapping.mappingId))
                                objTempParam.Id = objMapping.mappingId;
                            objTempParam.Field_Name__c = objMapping.fieldName;
                            objTempParam.Parameter_Name__c = objMapping.parameterNum;
                            objTempParam.Example_Text__c = objMapping.exampleText;
                            objTempParam.Object_name__c = objTemplateWrapper.objectName;
                            if(String.isBlank(objMapping.mappingId))
                                objTempParam.Template__c = objSFTemplate.Id;
                            listTemplateMapping.add(objTempParam);
                        }
                    }
                    if(!listTemplateMapping.isEmpty()){
                        String[] objTempParamFields = new String[]{'Id', 'Field_Name__c', 'Parameter_Name__c', 'Example_Text__c', 'Object_name__c', 'Template__c'};
                            if(!C3Utility.checkFieldPermission('Template_Parameter__c','isAccessible',null,true) && (!C3Utility.checkFieldPermission('Template_Parameter__c','isAccessible',objTempParamFields, false)) && (!C3Utility.checkFieldPermission('Template_Parameter__c','isCreateable',null, true)) && (!C3Utility.checkFieldPermission('Template_Parameter__c','isCreateable',objTempParamFields, false)) && (!C3Utility.checkFieldPermission('Template_Parameter__c','isUpdateable',null, true)) && (!C3Utility.checkFieldPermission('Template_Parameter__c','isUpdateable',objTempParamFields, true)) ){
                                   throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                               }else{
                                   Database.UPSERT( listTemplateMapping, AccessLevel.SYSTEM_MODE);
                               }
                    }
                    set<Id> mappingIds = new set<Id>();
                    List<Template_Parameter__c> listParam = new List<Template_Parameter__c>();
                    for(integer i = 0; i < listTemplateMapping.size(); i++){
                        objTemplateWrapper.listMapping[i].mappingId = listTemplateMapping[i].Id;
                        mappingIds.add(listTemplateMapping[i].Id);
                    }
                    String[] objTempParamFields = new String[]{'Id', 'Field_Name__c', 'Parameter_Name__c', 'Example_Text__c', 'Object_name__c', 'Template__c'};
                        if(!C3Utility.checkFieldPermission('Template_Parameter__c','isAccessible',null,true) 
                           && (!C3Utility.checkFieldPermission('Template_Parameter__c','isAccessible', objTempParamFields, false))){
                               throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                           }else{
                               for (Template_Parameter__c obj : [SELECT Id, Template__c FROM Template_Parameter__c WHERE Template__c =: objSFTemplate.Id WITH SECURITY_ENFORCED]) {
                                   if (!mappingIds.contains(obj.Id)) {
                                       listParam.add(obj);
                                   }
                               }
                           }
                    
                    if (!listParam.isEmpty()) {
                        if((!C3Utility.checkFieldPermission('Template_Parameter__c','isAccessible',null,true)) && (!C3Utility.checkFieldPermission('Template_Parameter__c','isDeletable',null,true))){
                               throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                           }else{
                               Database.Delete(listParam, AccessLevel.SYSTEM_MODE);
                           }
                    }
                }
                
                if(objTemplateWrapper.isActionList || objTemplateWrapper.isQuickReplyList){
                    List<Template_Button__c> listOfTemplateButton = new List<Template_Button__c>();
                    if(objTemplateWrapper.listActions !=null){
                        for(C3WhatsAppTemplateScreenLWCCtrl.ListActions objLstAct : objTemplateWrapper.listActions){
                            Template_Button__c objButton = new Template_Button__c();
                            if(String.isNotBlank(objLstAct.buttonId))
                                objButton.Id = objLstAct.buttonId;
                            objButton.Button_Type__c = objTemplateWrapper.buttonOption;
                            objButton.Type_of_Action__c = objLstAct.actionType;
                            objButton.Button_text__c = objLstAct.buttonText;
                            if(String.isNotBlank(objLstAct.countryCode))
                                objButton.Country_Code__c = objLstAct.countryCode;
                            if(String.isNotBlank(objLstAct.phoneNumber))
                                objButton.Phone_Number__c = objLstAct.phoneNumber;
                            if(String.isNotBlank(objLstAct.urlType))
                                objButton.URL_Type__c = objLstAct.urlType;
                            if(String.isNotBlank(objLstAct.websiteUrl))
                                objButton.Website_URL__c = objLstAct.websiteUrl;
                            if(String.isBlank(objLstAct.buttonId))
                                objButton.Template__c = objSFTemplate.Id;
                            listOfTemplateButton.add(objButton);
                        }
                    }
                    
                    if(objTemplateWrapper.listQuickReply !=null){
                        for(C3WhatsAppTemplateScreenLWCCtrl.ListQuickReply objLstAct : objTemplateWrapper.listQuickReply){
                            Template_Button__c objButton = new Template_Button__c();
                            if(String.isNotBlank(objLstAct.buttonId))
                                objButton.Id = objLstAct.buttonId;
                            objButton.Button_Type__c = objTemplateWrapper.buttonOption;
                            objButton.Type__c = objLstAct.type;
                            objButton.Button_text__c = objLstAct.buttonText;
                            if(String.isBlank(objLstAct.buttonId))
                                objButton.Template__c = objSFTemplate.Id;
                            listOfTemplateButton.add(objButton);
                        }
                    }
                    
                    if(!listOfTemplateButton.isEmpty()){
                        String[] objButtonFields = new String[]{'Id', 'Button_Type__c', 'Type_of_Action__c', 'Button_text__c', 'Country_Code__c', 'Phone_Number__c', 'URL_Type__c', 'Website_URL__c', 'Type__c', 'Template__c'};
                            if(!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',null,true) && (!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',objButtonFields,false)) && (!C3Utility.checkFieldPermission('Template_Button__c','isCreateable',null,true)) && (!C3Utility.checkFieldPermission('Template_Button__c','isCreateable',objButtonFields,false)) && (!C3Utility.checkFieldPermission('Template_Button__c','isUpdateable',null,true)) && (!C3Utility.checkFieldPermission('Template_Button__c','isUpdateable',objButtonFields,false))){
                                   throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                               }else{
                                   Database.UPSERT(listOfTemplateButton, AccessLevel.SYSTEM_MODE);
                               }
                    }
                    set<id> templateButtonIds = new set<id>();
                    for(integer i = 0; i < listOfTemplateButton.size(); i++){
                        if(objTemplateWrapper.isActionList && objTemplateWrapper.listActions.size() > i){
                            objTemplateWrapper.listActions[i].buttonId = listOfTemplateButton[i].Id;
                        } else if(!objTemplateWrapper.isActionList && objTemplateWrapper.listQuickReply.size() > i){
                            objTemplateWrapper.listQuickReply[i].buttonId = listOfTemplateButton[i].Id;
                        }
                        templateButtonIds.add(listOfTemplateButton[i].Id);                  			
                    }
                    list<id> templateButtonsToDelete = new list<id>();
                    String[] fields = new String[]{'Id', 'Template__c'};
                        if(!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',null,true) 
                           && (!C3Utility.checkFieldPermission('Template_Button__c','isAccessible', fields, false))){
                               throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                           }else{
                               for(Template_Button__c tempButtons :[Select id,Template__c from Template_Button__c where Template__c=:objSFTemplate.id WITH SECURITY_ENFORCED]){
                                   if(!templateButtonIds.contains(tempButtons.id)){
                                       templateButtonsToDelete.add(tempButtons.id);
                                   }
                               }
                           }
                    if(!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',null,true) && (!C3Utility.checkFieldPermission('Template_Button__c','isDeletable',null,true))){
                        throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                    }else{
                        Database.Delete(templateButtonsToDelete, AccessLevel.SYSTEM_MODE);
                    }
                }
                if(objTemplateWrapper.isHeaderMedia && String.isNotBlank(objTemplateWrapper.documentId) && String.isNotBlank(objTemplateWrapper.contentVersionId)){
                    strDocUrl = getPublicUrl(objTemplateWrapper.documentId, objTemplateWrapper.contentVersionId, objSFTemplate.Id, objTemplateWrapper.fileName );
                }
                LwcReturnResponse objLwcReturnResponse = new LwcReturnResponse();
                if(String.isNotBlank(strDocUrl)){
                    objTemplateWrapper.publicDocUrl = strDocUrl;
                    objSFTemplate.Document_Url__c = strDocUrl;
                    objSFTemplate.File_Name__c = objTemplateWrapper.fileName;
                    if(b1 && b2 && b3 && b11 && b22 && b33){
                        throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                    }else{
                        Database.UPSERT( objSFTemplate, AccessLevel.SYSTEM_MODE);
                    }
                }
                objTemplateWrapper.templateId = objSFTemplate.Id;
                return json.serialize(objTemplateWrapper);
            }
            return null;
        }catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getPublicUrl(String docId, String cVId, String relatedId, String fileName){
        try{
            String strDocUrl = '';
            List<ContentDocumentLink> listCDL = new List<ContentDocumentLink>();
            String[] listCDFields = new String[]{'Id', 'LinkedEntityId', 'ContentDocumentId'};
                if(!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',null,true) && (!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',listCDFields,false) )){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    if(!Test.isRunningTest()){
                        listCDL = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =: docId AND LinkedEntityId =: relatedId WITH SECURITY_ENFORCED LIMIT 1 ];
                        
                    }
                    else{
                        listCDL.clear();
                    }
                }
            if(listCDL.isEmpty()){
                ContentDocumentLink objCDL = new ContentDocumentLink();
                objCDL.ContentDocumentId = docId;
                objCDL.LinkedEntityId = relatedId;
                objCDL.Visibility='AllUsers';
                objCDL.ShareType = 'V';
                String[] listFields = new String[]{ 'LinkedEntityId', 'ContentDocumentId', 'Visibility', 'ShareType'};
                    if(!C3Utility.checkFieldPermission('ContentDocumentLink','isAccessible',null,true) && (!C3Utility.checkFieldPermission('ContentDocumentLink','isAccessible',listFields,false)) && (!C3Utility.checkFieldPermission('ContentDocumentLink','isCreateable',null,true)) && (!C3Utility.checkFieldPermission('ContentDocumentLink','isCreateable',listFields,false))){
                           throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                       }else{
                           Database.INSERT(objCDL, AccessLevel.SYSTEM_MODE);
                       }
                ContentDistribution objCD = new ContentDistribution();
                objCD.Name = fileName;
                objCD.ContentVersionId = cVId;
                objCD.PreferencesAllowViewInBrowser= true;
                objCD.PreferencesAllowOriginalDownload=true;
                objCD.RelatedRecordId = relatedId;
                String[] listFields2 = new String[]{ 'Name', 'ContentVersionId', 'PreferencesAllowViewInBrowser', 'PreferencesAllowOriginalDownload', 'RelatedRecordId'};
                    if(!C3Utility.checkFieldPermission('ContentDistribution','isAccessible',null,true) && (!C3Utility.checkFieldPermission('ContentDistribution','isAccessible',listFields2,false)) && (!C3Utility.checkFieldPermission('ContentDistribution','isCreateable',null,true)) && (!C3Utility.checkFieldPermission('ContentDistribution','isCreateable',listFields2,false))){
                           throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                       }else{
                           Database.INSERT(objCD, AccessLevel.SYSTEM_MODE);
                       }
                if(!C3Utility.checkFieldPermission('ContentDistribution','isAccessible', null, true) 
                   && (!C3Utility.checkFieldPermission('ContentDistribution','isAccessible', new List<String>{'Id','ContentDownloadUrl' }, false))){
                       throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                   }else{
                       list<ContentDistribution> listContentDistributions = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE Id=: objCD.Id WITH SECURITY_ENFORCED]; 
                       return listContentDistributions[0].ContentDownloadUrl;
                   }
            }
            return null;
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppTemplateScreenLWCCtrl','getPublicUrl','');
            return null;
        } 
    }
    
    @AuraEnabled
    public static String runMediaAPIs(String contentVersionId, String fileType ){
        ContentVersion objCV = new ContentVersion();
        FileUploadWrapper objFileUploadWrapper = new FileUploadWrapper();
        String[] listFields = new String[]{'Id', 'LinkedEntityId', 'ContentDocumentId', 'ContentUrl',  'ContentSize', 'VersionData', 'Title', 'FileType'};
            if(!C3Utility.checkFieldPermission('ContentVersion','isAccessible',null,true) && (!C3Utility.checkFieldPermission('ContentVersion','isAccessible',listFields,false)) ){
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }else{
                objCV = [SELECT Id, ContentDocumentId, ContentUrl, ContentSize, VersionData, Title, FileType FROM ContentVersion WHERE Id =: contentVersionId WITH SYSTEM_MODE];
            }
        String uploadSessionId = C3WhatsAppWebService.getUploadSessionIdFromWebService(fileType, objCV.ContentSize, objCV.Title.replaceAll(' ','_') );
        String mediaHandler = '';
        if(String.isNotBlank(uploadSessionId)){
            mediaHandler = C3WhatsAppWebService.getFileHandlerFromWebService(objCV.VersionData, uploadSessionId, fileType );
        }
        return mediaHandler;
    }
    
    @AuraEnabled
    public static Boolean verifyUpload(String contentVersionId){
        try{
            ContentVersion objCV = new ContentVersion();
            String[] listFields = new String[]{'Id', 'LinkedEntityId', 'ContentDocumentId', 'ContentUrl',  'ContentSize', 'VersionData', 'Title', 'FileType'};
                if(!C3Utility.checkFieldPermission('ContentVersion','isAccessible',null, true) && (!C3Utility.checkFieldPermission('ContentVersion','isAccessible',listFields, false))){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    objCV = [SELECT Id, ContentDocumentId, ContentUrl, ContentSize, VersionData, Title, FileType FROM ContentVersion WHERE Id =: contentVersionId WITH SYSTEM_MODE];
                }
            
            if(objCV.ContentSize > 4300000 || test.isRunningTest()){
                ContentDocument objDoc = new ContentDocument();
                String[] listFields2 = new String[]{'Id'};
                    if(!C3Utility.checkFieldPermission('ContentDocument','isAccessible',null, true) && (!C3Utility.checkFieldPermission('ContentDocument','isAccessible',listFields2, false))){
                        throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                    }else{
                        objDoc = [SELECT Id FROM ContentDocument WHERE Id =: objCV.ContentDocumentId WITH SYSTEM_MODE];
                    }
                
                if(!C3Utility.checkFieldPermission('ContentDocument','isAccessible',null,true) && (!C3Utility.checkFieldPermission('ContentDocument','isDeletable',null,true))){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    Database.Delete(objDoc, AccessLevel.SYSTEM_MODE);
                }
                return false;
            }
            return true;
        }catch(exception ex){ C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppTemplateScreenLWCCtrl','verifyUpload',''); return null; }
    }

    @AuraEnabled
    public static Boolean deleteUploadedDocument(String documentId){
        try{
            if(!C3Utility.checkFieldPermission('ContentDocument','isAccessible',null,true) && (!C3Utility.checkFieldPermission('ContentDocument','isDeletable',null,true))){
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }else{
                Database.Delete(new List<String>{documentId}, true, AccessLevel.SYSTEM_MODE);
            }
            return true;
        }catch(exception ex){ C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppTemplateScreenLWCCtrl','verifyUpload',''); return null; }
    }
    
    @AuraEnabled
    public static String getExistingTemplate(String templateId){
        try{
            if(String.isNotBlank(templateId)){
                TemplateWrapper objTemplateWrapper = new TemplateWrapper();
                Template_Object__c objTemplate = new Template_Object__c();
                String [] FieldsToQuery = new String [] {'Id', 'Name', 'Language_Code__c', 'Category__c', 'Template_Label__c', 'TemplateID__c', 'Mime_Type__c', 'Status__c', 'Content_Version_Id__c', 'Template_Message__c', 'Header_Type__c', 'File_Name__c', 'Media_Type__c', 'Object__c', 'Whatsapp_Template__c', 'Media_Handler__c', 'Footer__c', 'Header__c', 'Document_Url__c'  };
                    String [] FieldsToQuery2 = new String [] {'Id', 'Field_Name__c', 'Object_name__c', 'Parameter_Name__c'  };
                        String [] FieldsToQuery3 = new String [] {'Id', 'Button_text__c', 'Button_Type__c', 'Country_Code__c', 'Phone_Number__c', 'Type__c', 'Type_of_Action__c', 'URL_Type__c', 'Website_URL__c'  };
                            Boolean b1 = (!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',null,true));
                Boolean b11 = (!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',FieldsToQuery,False));
                Boolean b2 = (!C3Utility.checkFieldPermission('Template_Mapping__c','isAccessible',null,true));
                Boolean b22 = (!C3Utility.checkFieldPermission('Template_Mapping__c','isAccessible',FieldsToQuery2,False));
                Boolean b3 = (!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',null,true));
                Boolean b33 = (!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',FieldsToQuery3,False));
                if(b1 && b2 && b3 && b11 && b22 && b33){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    objTemplate = [SELECT Id, Name, Template_Label__c, Template_Message__c, Content_Version_Id__c, Mime_Type__c, File_Name__c, Media_Handler__c, Media_Type__c, Document_Url__c, Header_Type__c, Category__c, Object__c, Status__c, Footer__c, Header__c, Language_Code__c, Whatsapp_Template__c, TemplateID__c, (SELECT Id,Example_Text__c, Field_Name__c, Object_name__c, Parameter_Name__c FROM Template_Mappings__r), (SELECT Id, Button_text__c, Button_Type__c, Country_Code__c, Phone_Number__c, Type__c, Type_of_Action__c, URL_Type__c, Website_URL__c FROM Template_Buttons__r) FROM Template_Object__c WHERE Id =: templateId WITH SECURITY_ENFORCED LIMIT 1];
                }
                
                objTemplateWrapper.templateName = objTemplate.Name;
                if (String.isNotBlank(objTemplate.Template_Label__c)) {
                    objTemplateWrapper.templateName = objTemplate.Template_Label__c;
                }
                objTemplateWrapper.templateName = objTemplate.Name;
                objTemplateWrapper.templateId = objTemplate.Id;
                objTemplateWrapper.isHeaderText = false;
                objTemplateWrapper.isHeaderMedia = false;
                objTemplateWrapper.isActionList = false;
                objTemplateWrapper.isQuickReplyList = false;
                if(String.isNotBlank(objTemplate.TemplateID__c))
                    objTemplateWrapper.whatsAppTemplateId = objTemplate.TemplateID__c;
                
                if(String.isNotBlank(objTemplate.Media_Handler__c))
                    objTemplateWrapper.mediaHandler = objTemplate.Media_Handler__c;	
                
                if(String.isNotBlank(objTemplate.Category__c))
                    objTemplateWrapper.category = objTemplate.Category__c;
                
                if(String.isNotBlank(objTemplate.Object__c))
                    objTemplateWrapper.objectName = objTemplate.Object__c;
                
                if(String.isNotBlank(objTemplate.Content_Version_Id__c))
                    objTemplateWrapper.contentVersionId = objTemplate.Content_Version_Id__c;
                
                if(String.isNotBlank(objTemplate.Mime_Type__c))
                    objTemplateWrapper.mimeType = objTemplate.Mime_Type__c;
                
                if(String.isNotBlank(objTemplate.Footer__c))
                    objTemplateWrapper.footer = objTemplate.Footer__c;
                
                if(String.isNotBlank(objTemplate.File_Name__c))
                    objTemplateWrapper.fileName = objTemplate.File_Name__c;
                
                if(String.isNotBlank(objTemplate.Header__c)){
                    objTemplateWrapper.headerText = objTemplate.Header__c;
                    objTemplateWrapper.headerType = 'TEXT';
                    objTemplateWrapper.isHeaderText = true;
                    objTemplateWrapper.isHeaderMedia = false;
                }
                if(String.isNotBlank(objTemplate.Header_Type__c)){
                    objTemplateWrapper.headerType = objTemplate.Header_Type__c;	
                }
                if(String.isNotBlank(objTemplate.Media_Type__c)){
                    objTemplateWrapper.mediaType = objTemplate.Media_Type__c;	
                }
                if(String.isNotBlank(objTemplate.Document_Url__c))
                    objTemplateWrapper.publicDocUrl = objTemplate.Document_Url__c;	
                
                if(String.isNotBlank(objTemplate.Language_Code__c))
                    objTemplateWrapper.language = objTemplate.Language_Code__c;
                
                if(String.isNotBlank(objTemplate.Whatsapp_Template__c))
                    objTemplateWrapper.templateBody = objTemplate.Whatsapp_Template__c;
                
                if(String.isNotBlank(objTemplate.Template_Message__c))
                    objTemplateWrapper.templateBodyText = objTemplate.Template_Message__c;
                
                if(objTemplate.Template_Mappings__r != null && objTemplate.Template_Mappings__r.size()>0){
                    objTemplateWrapper.listMapping = new List<ListMapping>();
                    for(Template_Parameter__c objParam : objTemplate.Template_Mappings__r){
                        ListMapping objMapping = new ListMapping();
                        objMapping.mappingId = objParam.Id;
                        objMapping.fieldName = objParam.Field_Name__c;
                        objMapping.exampleText = objParam.Example_Text__c;
                        objMapping.parameterNum = objParam.Parameter_Name__c;
                        objMapping.placeHolder = '{{'+objParam.Parameter_Name__c+'}}';
                        objTemplateWrapper.listMapping.add(objMapping);
                    }
                }    
                if(objTemplate.Template_Buttons__r != null && objTemplate.Template_Buttons__r.size()>0){
                    objTemplateWrapper.listActions = new List<ListActions>();
                    objTemplateWrapper.listQuickReply = new List<ListQuickReply>();
                    for(Template_Button__c objButton : objTemplate.Template_Buttons__r){
                        ListActions objAction = new ListActions();
                        objAction.buttonId = objButton.Id;
                        objAction.isActionPhoneNumber = false;
                        objAction.isActionUrl = false;
                        objAction.isIcon = false;
                        objTemplateWrapper.buttonOption = objButton.Button_Type__c;
                        objAction.buttonText = objButton.Button_text__c;
                        if(objButton.Button_Type__c == 'call to action'){
                            objTemplateWrapper.listQuickReply = null;
                            objAction.isIcon = true;
                            objTemplateWrapper.isActionList = true;
                            objAction.actionType = objButton.Type_of_Action__c;
                            if(objButton.Type_of_Action__c == 'PHONE_NUMBER'){
                                objAction.isActionPhoneNumber = true;
                                objAction.iconName = 'utility:call';
                                objAction.phoneNumber = objButton.Phone_Number__c;
                                objAction.countryCode = objButton.Country_Code__c;
                            }else{
                                objAction.iconName = 'utility:new_window';
                                objAction.isActionUrl = true;
                                objAction.urlType = objButton.URL_Type__c;
                                objAction.websiteUrl = objButton.Website_URL__c;
                            }
                            objTemplateWrapper.listActions.add(objAction);
                        }
                        if(objButton.Button_Type__c  == 'QUICK_REPLY'){
                            objTemplateWrapper.listActions = null;
                            objTemplateWrapper.isQuickReplyList = true;
                            ListQuickReply objActions = new ListQuickReply();
                            objActions.buttonId = objButton.Id;
                            objActions.isIcon = false;
                            objActions.type = 'Custom';
                            objActions.buttonText = objButton.Button_text__c;
                            if(objTemplateWrapper.listQuickReply != null)
                                objTemplateWrapper.listQuickReply.add(objActions);
                        }
                    }
                }
                return json.serialize(objTemplateWrapper);
            }
            return null;   
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppTemplateScreenLWCCtrl','getExistingTemplate','');
            return null;
        }
    }
    
    @AuraEnabled
    public static String getRecordsToSelect(String sObjectName) {
        Boolean b1 = (!C3Utility.checkFieldPermission(sObjectName,'isAccessible',new List<String>{'Id', 'Name' },false));
        Boolean b2 = (!C3Utility.checkFieldPermission(sObjectName,'isAccessible',null,true));
        if(b2 && b1){
            throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
        }else{
            String query = 'SELECT Id, Name FROM '+ sObjectName +' LIMIT 1000';
            Map<String, Object> bindVariablesMap = new Map<String, Object>{'sObjectName' => sObjectName  };
                List<SObject> listObject = Database.queryWithBinds(
                    String.escapeSingleQuotes(query),
                    bindVariablesMap,
                    AccessLevel.SYSTEM_MODE
                );
            return JSON.Serialize(listObject);
        }
    }
    
    public static string getFormattedBody(string strText){
        String input='';
        
        if(!string.isBlank(strText)){
            input = strText.replaceAll('<b>','*');
            input = input.replaceAll('</b>','*');
            input = input.replaceAll('</p>','\n');
            input = input.replaceAll('<p>','');
            input = input.replaceAll('<em>','_');
            input = input.replaceAll('</em>','_');
            input = input.replaceAll('<br>',' \n ');
            input = input.replaceAll('</strong>','*');
            input = input.replaceAll('<strong>','*');
            input = input.replaceAll('<strike>','~');
            input = input.replaceAll('</strike>','~');
        }
        return input;
    }
    public class TemplateRow {
        @AuraEnabled
        public String field { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }
    
    public class ResponseBody{
        public list<DropdownWrapper> sfFieldsPickList;
        public string objectName;
    }
    public class DropdownWrapper{
        public string label;
        public string value;
    }
    public class RequestBody{
        public String campaignId;
        public String ameyoLeadId;
        public dateTime scheduleDateTime;
        public List<FilterWrapper> filterCondition;
    }
    public class FilterWrapper{
        public string fieldApiName;
        public string operator;
        public string fieldValue;
        public boolean isDateField;
    }
    
    public class TemplateWrapper{
        public String templateId;
        public String whatsAppTemplateId;
        public String publicDocUrl;
        public String mediaHandler;
        public String headerType;	
        public String headerText;	
        public String documentId;	
        public String contentVersionId;	
        public String mimeType;	
        public String language;	
        public String templateName;	
        public String templateBody;
        public String templateBodyText;
        public String footer;	
        public String category;	
        public String buttonOption;	
        public String mediaType;
        public String fileName;	
        public String objectName;
        public Boolean isHeaderMedia;
        public Boolean isHeaderText;
        public Boolean isActionList;
        public Boolean isQuickReplyList;
        public ListMapping[] listMapping;
        public ListQuickReply[] listQuickReply;
        public ListActions[] listActions;
    }
    
    public class ListMapping {
        public String mappingId ;
        public String fieldName;
        public String parameterNum;
        public String placeHolder;
        public String exampleText;
    }
    
    public class ListActions {
        public String buttonId ;
        public String actionType ;
        public String buttonText;
        public String  countryCode ;
        public String  phoneNumber ;
        public String  urlType ;
        public String  websiteUrl;
        public Boolean  isIcon ;
        public String  iconName ;
        public String  type ;
        public Boolean  isActionPhoneNumber ;
        public Boolean  isActionUrl;
        
    }
    
    public class ListQuickReply {
        public String buttonId ;
        public Boolean  isIcon ;
        public String buttonText;
        public String  type ;
    }
    
    public class LwcReturnResponse{
        public String strDocPublicUrl;
        public String mediaHandler;
        public String templateId;
        public ListMapping[] listMapping;
        public ListQuickReply[] listQuickReply;
        public ListActions[] listActions;
    }
    
    public class FileUploadWrapper{
        public String strDocPublicUrl;
        public String mediaHandler;
    }
}