global with sharing class C3Utility {

    
    public static String formattedTemplateMessage;
    
    public static Boolean checkFieldPermission(String objName,String strfieldAccessbility,List<String> lstCheckFields,Boolean isObject){
        Boolean isfieldPermitted=true;
        String apiNamePrefix=getNameSpace();
        map<string,schema.sobjecttype> describeObject = schema.getglobaldescribe();
        objName=objName.toLowerCase();  
        /*if(objName.endsWith('__c') && (!objName.contains('')) ){
            objName=apiNamePrefix+objName;
        }*/
        if(objName.endsWith('__c') ){
            objName=apiNamePrefix+objName;
        }
        
        if(describeObject.containskey(objName) && isObject) {
            if ((strfieldAccessbility=='isCreateable' && !describeObject.get(objName).getdescribe().isCreateable()) 
                || (strfieldAccessbility=='isUpdateable' && !describeObject.get(objName).getdescribe().isUpdateable())
                || (strfieldAccessbility=='isAccessible' && !describeObject.get(objName).getdescribe().isAccessible())
                || (strfieldAccessbility=='isDeletable' && !describeObject.get(objName).getdescribe().isDeletable()))
            {
                isfieldPermitted= false; 
            }
        }
        else if(describeObject.containskey(objName) && !isObject && lstCheckFields!=Null && !lstCheckFields.isEmpty()){
            map<string,schema.sobjectfield> fieldmap = describeObject.get(objName).getdescribe().fields.getmap();
            
            for (String fieldToCheck : lstCheckFields ) {
                fieldToCheck=fieldToCheck.toLowerCase();    
                /*if(fieldToCheck.endsWith('__c')  && (!objName.contains(''))){
                    fieldToCheck=apiNamePrefix+fieldToCheck;
                }*/
                if(fieldToCheck.endsWith('__c')){
                    fieldToCheck=apiNamePrefix+fieldToCheck;
                }
                if (strfieldAccessbility=='isCreateable' && fieldmap.containsKey(fieldToCheck) && !fieldmap.get(fieldToCheck).getdescribe().isCreateable()) {
                    isfieldPermitted= false; 
                    break;   
                }
                else if(strfieldAccessbility=='isUpdateable' && fieldmap.containsKey(fieldToCheck) && !fieldmap.get(fieldToCheck).getdescribe().isUpdateable()){
                    isfieldPermitted= false; 
                    break; 
                }
                else if(strfieldAccessbility=='isAccessible' && fieldmap.containsKey(fieldToCheck) && !fieldmap.get(fieldToCheck).getdescribe().isAccessible()){
                    isfieldPermitted= false; 
                    break; 
                }
            }
        }
        return isfieldPermitted;
    }
    
    public static String getFieldWithoutNameSpace(String fieldName){
        String apiNamePrefix=getNameSpace();
        if(fieldName.startsWithIgnoreCase(apiNamePrefix)){
            fieldName=fieldName.substring(apiNamePrefix.length(),fieldName.length());
        }
        return fieldName;
    }
    
    public static String getNameSpace(){ 
        String apiNamePrefix='';
        String[] classNameParts = String.valueOf(C3Utility.class).split('\\.', 2);
        if(classNameParts.size() > 1) {
            Type classType = Type.forName(classNameParts[0], classNameParts[1]);
            if(classType == C3Utility.class) {
                apiNamePrefix = classNameParts[0]+'__';
            }
        }
        return apiNamePrefix;
    }

    public static string fetchPhoneNumber(String recordId) {
        String phoneNumber = '';
        String objectNameForPhone = '';
        if (recordId != null) {
            objectNameForPhone = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        }
        Map<String, WhatsApp_Number_Configuration__c> numberSettingsMap = new Map<String, WhatsApp_Number_Configuration__c>();
        if(!checkFieldPermission('WhatsApp_Number_Configuration__c','isAccessible',new List<String>{'Field_Name__c', 'Object_Name__c'},False)){
            throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
        }else{
            numberSettingsMap = WhatsApp_Number_Configuration__c.getAll();
        }
        WhatsApp_Number_Configuration__c setting = numberSettingsMap.get(objectNameForPhone);
        
        if (setting != null) {
            String query = 'SELECT ' + setting.Field_Name__c + ' FROM ' + setting.Object_Name__c + ' WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1';
            SObject record;
            List<String> fieldsToQuery = setting.Field_Name__c.split(',');
            Boolean b1 = (!checkFieldPermission(setting.Object_Name__c,'isAccessible',null,true));
            Boolean b2 = (!checkFieldPermission(setting.Object_Name__c,'isAccessible',fieldsToQuery,false));
            if(b1 && b2){
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }else{
                record = Database.query(String.escapeSingleQuotes(query), AccessLevel.SYSTEM_MODE); 
            }
            if (record != null) {
                phoneNumber = String.valueOf(record.get(setting.Field_Name__c));
            }
            return phoneNumber;
        }
        throw new AuraHandledException('This record have blank number field which is configured in WhatsApp Configuration Setting!');
    }

    public static String getFormattedBodyutility(String strText){
        String input = '';
        
        if(!String.isBlank(strText)){
            input = strText.replaceAll('<b>', '*');
            input = input.replaceAll('</b>', '*');
            input = input.replaceAll('</p>', '\n');
            input = input.replaceAll('<p>', '');
            input = input.replaceAll('<em>', '_');
            input = input.replaceAll('</em>', '_');
            input = input.replaceAll('<br>', '\n');
            input = input.replaceAll('</strong>', '*');
            input = input.replaceAll('<strong>', '*');
            input = input.replaceAll('<strike>', '~');
            input = input.replaceAll('</strike>', '~');
            input = input.replaceAll('<div style="text-align:center">', '');
            input = input.replaceAll('</div>', '');
            input = input.replaceAll('<br/>', '\n');
        }
        return input;
    }
    

    @AuraEnabled
    public static string valdiateTemplatePrameters(String recordId, String templateId){
        if (String.isNotBlank(recordId) && String.isNotBlank(templateId)) {
            Id recId = Id.valueOf(recordId);
            String objectName = recId.getSObjectType().getDescribe().getName();
            Template_Object__c objTemplate = C3WhatsAppTemplateScreenLWCCtrl.getRecordData(templateId, objectName);
            if((objTemplate != null) && (objTemplate.Template_Mappings__r != null) && objTemplate.Template_Mappings__r.size()>0 ){
                Map<String, String> mapParamNumWithFieldName = new Map<String, String>();
                for(Template_Parameter__c objTempMapping : objTemplate.Template_Mappings__r ){
                    mapParamNumWithFieldName.put(objTempMapping.Parameter_Name__c, objTempMapping.Field_Name__c );
                }
                System.debug('mapParamNumWithFieldName == '+mapParamNumWithFieldName);
                System.debug('objTemplate == '+JSON.serialize(objTemplate));
                Set<String> fieldSet = new Set<String>(mapParamNumWithFieldName.values());
                String query = 'SELECT Id, '+ String.join(fieldSet, ',') + ' FROM '+objectName+' WHERE Id =: recId WITH SECURITY_ENFORCED LIMIT 1';
                SObject objSObject ;         
                List<String> fieldsToQuery = new List<String>(fieldSet);
                Boolean b1 = (!C3Utility.checkFieldPermission(objectName,'isAccessible',null, true));
                Boolean b2 = (!C3Utility.checkFieldPermission(objectName,'isAccessible',fieldsToQuery,false));
                if(b1 && b2){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    objSObject = database.query(String.escapeSingleQuotes(query));
                }
                System.debug('objSObject == '+objSObject);
                if(mapParamNumWithFieldName != null && (!mapParamNumWithFieldName.isEmpty())){
                    integer numOfParam = mapParamNumWithFieldName.size();
                    List<String> listField = new List<String>();
                    for(integer loopVar = 0; loopVar <= numOfParam ; loopVar++){
                        String key = String.valueOf(loopVar);
                        if(mapParamNumWithFieldName.containsKey(key)){
                            if(objSobject.get(mapParamNumWithFieldName.get(key)) == null){
                                listField.add(mapParamNumWithFieldName.get(key));
                                // throw new AuraHandledException('One of the template parameter is blank!, field Name : '+mapParamNumWithFieldName.get(key) +', please do not send this template without parameter.');
                            }
                        }
                    }
                    if(!listField.isEmpty()){
                        throw new AuraHandledException('One of the template parameters are blank!, field Names : '+ String.join(listField, ', ') +', please do not send this template without parameter.');
                    }
                }
            }
        }
        return 'success';
    }
    
    //getting all the Fields of the SObject
    @AuraEnabled
    public static string getObjectFields(String sObjectName) 
    {
        try {
            UtilityMainWrapper objMain = new UtilityMainWrapper();
            objMain.lstObjectPicklist = new List<ObjectPicklist>();
            SObjectType SObjectType = Schema.getGlobalDescribe().get(sObjectName);
            Map<String, Schema.SObjectField> objectFieldsMap = SObjectType.getDescribe().fields.getMap();
            
            for (Schema.SObjectField field : objectFieldsMap.values()) {
                
                Schema.DescribeFieldResult desribeResult = field.getDescribe();
                String fieldName = field.getDescribe().getLabel() + ' ('+ field.getDescribe().getName() + ' )';
                String fieldAPIName = field.getDescribe().getName();
                String strType = String.valueOf(field.getDescribe().getType());
                
                if(field.getDescribe().isAccessible() && !(field.getDescribe().getName() == 'Id'))
                {
                    system.debug(strType);
                    switch on strType 
                    {
                        when 'EMAIL' {
                            ObjectPicklist objPickList = new ObjectPicklist();
                            objPickList.label = fieldName;
                            objPickList.value = fieldAPIName;
                            objMain.lstObjectPicklist.add(objPickList);
                        }
                        when 'BOOLEAN' {
                            
                        }
                        when 'DATE' {
                            
                        }
                        when 'DATETIME' {
                            
                        }
                        when 'PICKLIST' {
                            ObjectPicklist objPickList = new ObjectPicklist();
                            objPickList.label = fieldName;
                            objPickList.value = fieldAPIName;
                            objMain.lstObjectPicklist.add(objPickList);
                        }
                        when 'REFERENCE' {
                            
                        }
                        when 'DOUBLE' {
                            
                        }
                        when 'INTEGER' {
                            
                        }
                        when 'PERCENT' {
                            
                            
                        }
                        when 'CURRENCY' {
                            
                            
                        }
                        when else {
                            ObjectPicklist objPickList = new ObjectPicklist();
                            objPickList.label = fieldName;
                            objPickList.value = fieldAPIName;
                            objMain.lstObjectPicklist.add(objPickList);
                        }
                    }
                }
            }
            return JSON.serialize(objMain);
        }catch (Exception ex) {
            logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','Utility','getObjectFields','');
            return null;
        }
    }
    
    // upload file under record
    public static String uploadFile(Blob fileContent, String fileName, String fileType, String recordId) {
        try{
            ContentVersion objCV = new ContentVersion();
            objCV.VersionData = fileContent;
            objCV.Title = fileName;
            objCV.PathOnClient = fileName;
            if(String.isNotBlank(fileType) && fileType.contains('/')){
                String ext = fileType.split('/')[1];
                objCV.PathOnClient = objCV.PathOnClient + ext ;
                objCV.Title = objCV.Title + ext ;
            }
            String[] listFields0 = new String[]{'VersionData', 'Title', 'PathOnClient', 'fileType'};
                if(checkFieldPermission('ContentVersion', 'isAccessible', null, true) 
                   && checkFieldPermission('ContentVersion', 'isAccessible', listFields0, false)
                   && checkFieldPermission('ContentVersion', 'isCreateable', null, true) 
                   && checkFieldPermission('ContentVersion', 'isCreateable', listFields0, false)){
                       Database.INSERT(objCV, AccessLevel.SYSTEM_MODE);
                   }else {
                       throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                   }
            
            ContentDocumentLink objCDL = new ContentDocumentLink();
            String[] listFields = new String[]{'ContentDocumentId', 'Id'};
                if(checkFieldPermission('ContentVersion', 'isAccessible', null, true) 
                   && checkFieldPermission('ContentVersion', 'isAccessible', listFields, false)){
                       objCDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: objCV.Id].ContentDocumentId;
                   }else {
                       throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                   }
            objCDL.LinkedEntityId = recordId;
            objCDL.ShareType = 'V';
            String[] listFields2 = new String[]{'LinkedEntityId', 'ShareType', 'ContentDocumentId'};
                if(checkFieldPermission('ContentDocumentLink', 'isAccessible', null, true) 
                   && checkFieldPermission('ContentDocumentLink', 'isAccessible', listFields2, false)
                   && checkFieldPermission('ContentDocumentLink', 'isCreateable', null, true) 
                   && checkFieldPermission('ContentDocumentLink', 'isCreateable', listFields2, false)){
                       Database.INSERT(objCDL, AccessLevel.SYSTEM_MODE);
                   }else {
                       throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                   }
            
            ContentDistribution objCD = new ContentDistribution();
            objCD.Name = fileName;
            objCD.ContentVersionId = objCV.Id;
            objCD.PreferencesAllowViewInBrowser= true;
            objCD.PreferencesAllowOriginalDownload=true;
            objCD.RelatedRecordId = recordId;
            String[] listFields3 = new String[]{'Name', 'ContentVersionId', 'PreferencesAllowViewInBrowser', 'PreferencesAllowOriginalDownload', 'RelatedRecordId'};
            if(checkFieldPermission('ContentDistribution', 'isAccessible', null, true) 
                && checkFieldPermission('ContentDistribution', 'isAccessible', listFields3, false)
                && checkFieldPermission('ContentDistribution', 'isCreateable', null, true) 
                && checkFieldPermission('ContentDistribution', 'isCreateable', listFields3, false)){
                    Database.INSERT(objCD, AccessLevel.SYSTEM_MODE);
                }else {
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }
            
            
            String[] listFields4 = new String[]{'ContentDownloadUrl', 'Id'};
            if(checkFieldPermission('ContentDistribution', 'isAccessible', null, true) 
                && checkFieldPermission('ContentDistribution', 'isAccessible', listFields4, false)){
                    list<ContentDistribution> listContentDistributions = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE Id =: objCD.Id WITH SECURITY_ENFORCED];
                    return listContentDistributions[0].ContentDownloadUrl;
                }else {
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }
            
        }catch(exception ex){
            logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','Utility','uploadFile','');
            return null;
        }
    }
    
    // Used in Chat Panel
    public static Map<String, String> getStandardNameField(Set<String> listOfSObjectApiNames){
        Map<String, String> result=new Map<String, String>();
        
        String [] listFields = new String [] {'QualifiedApiName', 'EntityDefinitionId','IsNameField'};
        if(checkFieldPermission('ContentDistribution', 'isAccessible', null, true) 
            && checkFieldPermission('ContentDistribution', 'isAccessible', listFields, false)){
                List<FieldDefinition> listFieldDefinition = new List<FieldDefinition>([SELECT QualifiedApiName,EntityDefinition.QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName IN :listOfSObjectApiNames AND IsNameField = TRUE]);
                for(FieldDefinition fieldDef : listFieldDefinition){
                    result.put(fieldDef.EntityDefinition.QualifiedApiName, fieldDef.QualifiedApiName);
                }
            }else {
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }
        return result;
    }
    
    // Used in Chat Panel
    public static Map<String, String> getNameDetails(String fullName){
        Map<String, String> result=new Map<String, String>();
        if(fullName.contains('null')){
            fullName = fullName.replaceAll('null', '');
        }
        string fName = '';
        string lName = '';
        if(fullName.contains(' ')){
            fName = string.isBlank(fullName.split(' ')[0]) ? '' : fullName.split(' ')[0];
            lName = fullName.split(' ')[fullName.split(' ').size() - 1];
        }else{
            lName = fullName;
        }
        if(String.isNotBlank(fName)){
            result.put('senderNameSmall', fName.left(1).capitalize() + lName.left(1).capitalize());
        }else{
            result.put('senderNameSmall', lName.left(1).capitalize());
        }
        result.put('senderName', fullName);
        return result;
    }
    
    public static Map<String,ValidRecordWrapper> validateRecordIds(Map<String, List<String>> prefixAndRecordIds)
    {
        Map<String,ValidRecordWrapper> validRecordIds=new Map<String,ValidRecordWrapper>();
        Map<String,String> objectPrefixAndNameMap = new Map<String,String>();
        Set<String> listOfSObjectApiNames=new Set<String>();
        
        Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
        for(String myIdPrefix : prefixAndRecordIds.keySet())
        {
            for(Schema.SObjectType stype : gd.values())
            {
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                if(prefix!=null)
                {
                    if(prefix.equals(myIdPrefix)){
                        objectPrefixAndNameMap.put(myIdPrefix,  r.getName()+'-'+r.getLabel());
                        listOfSObjectApiNames.add(r.getName());
                        break;
                    }
                }
            }
        }
        Map<String, String> objectAndNameFieldsMap = getStandardNameField(listOfSObjectApiNames);
        for(String myIdPrefix : prefixAndRecordIds.keySet())
        {
            if(objectPrefixAndNameMap.containsKey(myIdPrefix))
            {
                List<String> recordIdsCheck=new List<String>();
                recordIdsCheck=prefixAndRecordIds.get(myIdPrefix);
                
                String objectNameAndLabel=objectPrefixAndNameMap.get(myIdPrefix);
                String objectName=objectNameAndLabel.split('-')[0];
                String objectLabel=objectNameAndLabel.split('-')[1];
                
                String soql = 'SELECT Id ';
                if(objectAndNameFieldsMap.containsKey(objectName) && String.isNotBlank(objectAndNameFieldsMap.get(objectName)))
                {
                    soql+=','+objectAndNameFieldsMap.get(objectName)+' ';
                }
                if(objectName=='Lead')
                {
                    soql+=',IsConverted ';
                }
                soql+= ' From '+objectName +' WHERE Id IN :recordIdsCheck' ;
                String strTempFields = 'Id,' + objectAndNameFieldsMap.get(objectName);
                if(!checkFieldPermission(objectName,'isAccessible', strTempFields.split(',')  ,true)){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    for(SObject sObj : Database.query(soql))
                    {
                        if(objectName!='Lead' || (objectName=='Lead' && (boolean)sObj.get('isconverted')==false))
                        {
                            string recordName;
                            if(objectAndNameFieldsMap.containsKey(objectName) && String.isNotBlank(objectAndNameFieldsMap.get(objectName)))
                            {
                                recordName=(string)sObj.get(objectAndNameFieldsMap.get(objectName));
                            }
                            validRecordIds.put(sObj.Id, new ValidRecordWrapper(objectLabel, objectName, recordName));
                        }
                    }
                }
            }
        }
        return validRecordIds;
    }
    
    public static void getWhatsAppDetails(){
        
        List<WhatsApp_Admin__c> listWAA = new List<WhatsApp_Admin__c>();
        
        /*if(!checkFieldPermission('WhatsApp_Admin__c','isAccessible',new List<String>{'NumberID__c', 'WabaId__c'},False)){
            throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
        }else{*/
            listWAA = WhatsApp_Admin__c.getall().values();
        // }
        if(listWAA != null && listWAA.size()>0){
            C3WhatsAppWebService.PHONE_NUMBER_ID = listWAA[0].NumberID__c;
            C3WhatsAppWebService.WABA_ID = listWAA[0].WabaId__c;
            C3WhatsAppWebService.endPointURL = 'https://graph.facebook.com/v17.0/'+listWAA[0].NumberID__c+'/messages';
        }
    }
    
    // Used in webservice
    public static String getFieldName(String objectName) {
        Map<String, WhatsApp_Number_Configuration__c> settingsMap = new Map<String, WhatsApp_Number_Configuration__c>();
        if(!checkFieldPermission('WhatsApp_Number_Configuration__c','isAccessible',new List<String>{'Field_Name__c', 'Object_Name__c'},False)){
            throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
        }else{
            settingsMap = WhatsApp_Number_Configuration__c.getAll();
        }
        WhatsApp_Number_Configuration__c setting = settingsMap.get(objectName);
        if (setting != null) {
            return setting.Field_Name__c;
        }
        throw new AuraHandledException('This object is not configured for bulk messaging!');
    }
    
    global static void callSendTemplate(List<String> recordIds, String templateRecordId){
        //String ids = '(' + String.join(recordIds, ',') + ')';
        C3WhatsAppTemplateScreenLWCCtrl.sendWhatsAppMessageBulk(new List<String>(recordIds), templateRecordId);
    }
 
    public static void logError( String ErrorMessage, String StackTrace, Integer LineNumber, String response, String className, String methodName, String request){
        String[] listFields = new String[]{ 'Line_Number__c', 'Error_Message__c', 'Stack_Trace__c', 'Response__c', 'Class_Name__c', 'Method_Name__c', 'Request__c'};
            if(checkFieldPermission('ContentVersion', 'isAccessible', null, true) 
               && checkFieldPermission('ContentVersion', 'isAccessible', listFields, false)
               && checkFieldPermission('ContentVersion', 'isCreateable', null, true) 
               && checkFieldPermission('ContentVersion', 'isCreateable', listFields, false)){
                   Error_Log__c objError = new Error_Log__c( 
                       Line_Number__c = String.valueOf(LineNumber),
                       Method_Name__c = methodName,
                       Error_Message__c = ErrorMessage,
                       Stack_Trace__c = StackTrace,
                       Response__c = response,
                       Class_Name__c = className, 
                       Request__c = request
                   );
                   Database.INSERT(objError, AccessLevel.SYSTEM_MODE);
               }else {
                   throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
               }
    }

    public static WhatsApp_Conversation__b buildConvoRecord(Template_Object__c objTemplate, String toNumber, String recordId, String wamId){
        
        WhatsApp_Conversation__b objTxtMsg = new WhatsApp_Conversation__b();
        objTxtMsg.Direction__c = 'Outbound';
        objTxtMsg.Status__c = 'Pending';
        objTxtMsg.Record_ID__c = recordId;
        objTxtMsg.Read__c = 'false';
        // System.debug('formattedTemplateMessage   '+formattedTemplateMessage);
        // if(String.isNotBlank(formattedTemplateMessage)){
        //     objTxtMsg.Message__c = formattedTemplateMessage;
        // }else{
            objTxtMsg.Message__c = buildMessage(objTemplate);
        // }
        
        
        if(String.isNotBlank(objTemplate.Template_Message__c)){
            objTxtMsg.Message_formatted__c = objTemplate.Template_Message__c;
            objTxtMsg.Template_Name__c = objTemplate.Name;
        }
        
        objTxtMsg.From_Phone__c = '919557718888';
        objTxtMsg.Read__c = 'true';
        objTxtMsg.To_Phone__c = toNumber;
        objTxtMsg.Interaction_Type__c='Whatsapp';
        objTxtMsg.Created_date__c = DateTime.now();
        if(string.isNotBlank(wamId)){
            objTxtMsg.sid__c = wamId;
        }
        objTxtMsg.Status__c = 'sent'; 
        
        if(string.isNotBlank(objTemplate.File_Name__c)){
            objTxtMsg.Interaction_Type__c='MMS';
        }
        objTxtMsg.Unique_Key__c = recordId+'-'+System.Now().formatLong();
        return objTxtMsg;
    }

    public static string buildMessage(Template_Object__c objTemplate){
        String txtMsg = '';
        if (String.isNotBlank(objTemplate.header__c)) {
            txtMsg = '<div style="text-align:center"><b>'+ objTemplate.header__c + '</b></div>';
        }
        if (objTemplate.Header_Type__c == 'MEDIA' && String.isNotBlank(objTemplate.Document_Url__c) && objTemplate.Media_Type__c == 'IMAGE') {
            txtMsg = '<div><img width="200" height="250" src="'+objTemplate.Document_Url__c+'"></div>';
            txtMsg = txtMsg + '<div>'+objTemplate.Whatsapp_Template__c+'</div>';
        }else if(objTemplate.Header_Type__c == 'MEDIA' && String.isNotBlank(objTemplate.Document_Url__c) && objTemplate.Media_Type__c == 'VIDEO'){
            txtMsg = txtMsg + objTemplate.Whatsapp_Template__c;
        }else{
            txtMsg = txtMsg + objTemplate.Whatsapp_Template__c;
        }
        if (String.isNotBlank(objTemplate.Footer__c)) {
            txtMsg =  txtMsg  + '</br><p style="font-size : 12px" class="slds-text-color_inverse-weak">'+ objTemplate.Footer__c +'<p>';
        }
        System.debug('objTemplate.Template_Buttons__r -- '+ JSON.serialize(objTemplate.Template_Buttons__r));
        if(objTemplate.Template_Buttons__r != null && objTemplate.Template_Buttons__r.size() > 0){
            for(Template_Button__c button : objTemplate.Template_Buttons__r){
                if( button.Button_Type__c == 'QUICK_REPLY'){
                    txtMsg = txtMsg + '<div class="slds-theme_shade" style="margin-top : 5px; padding: 5;  font-size : 18px; border-radius: 5px; text-align:center; color: #4191e1;  text-decoration: underline">'+button.Button_text__c+'</div>';
                }
                if( button.Button_Type__c == 'PHONE_NUMBER'){
                    txtMsg = txtMsg + '<div class="slds-theme_shade" style="margin-top : 5px; padding: 5;  font-size : 18px; border-radius: 5px; text-align:center; color: #4191e1;  text-decoration: underline">'+button.Button_text__c+'</div>';
                }
                if(button.Button_Type__c == 'call to action'){
                    if (button.Type_of_Action__c == 'PHONE_NUMBER') {
                        txtMsg = txtMsg + '<div class="slds-theme_shade" style="margin-top : 5px; padding: 5;  font-size : 18px; border-radius: 5px; text-align:center; color: #4191e1; "><lightning-icon icon-name="utility:call" size="small"> </lightning-icon>'+button.Button_text__c+'</div>';
                    }
                    if (button.Type_of_Action__c == 'URL') {
                        txtMsg = txtMsg + '<div class="slds-theme_shade" style="margin-top : 5px; padding: 5;  font-size : 18px; border-radius: 5px; text-align:center; color: #4191e1; "><lightning-icon icon-name="utility:new_window" size="small"> </lightning-icon>'+button.Button_text__c+'</div>';
                    }
                }
            }
        }
        return txtMsg;
    }
    
    // Used in Chat Panel
    public class ValidRecordWrapper
    {
        public string objectLabel;
        public string objectApiName;
        public string recordName;
        public ValidRecordWrapper(string objectLabel, string objectApiName, string recordName)
        {
            this.objectLabel=objectLabel;
            this.objectApiName=objectApiName;
            this.recordName=recordName;
        }
    }
    
    public class UtilityMainWrapper{
        List<ObjectPicklist> lstObjectPicklist;
    }
    public class ObjectPicklist{
        public String label;
        public String value;
    }
}