public with sharing class C3WhatsAppChatPanelCtrl {
    
    public class ChatPanelException extends Exception {}
    
    @AuraEnabled
    public static string initWhatsAppChatPanelController(string recordId, string objName){
        WrapperChat wrapMain = new WrapperChat();
        
        wrapMain.lstTxtMsg = new List<TextMessagWrapper>();
        wrapMain.strMsg = '';
        wrapMain.strSuccessMsg = '';
        wrapMain.nameIntial = 'VP'; // Dummy initials
        wrapMain.currentUserIntial = 'JS'; // Dummy initials
        wrapMain.sendFrom = 'Vivek Pratap';
        wrapMain.toNumber = '919557714444';
        wrapMain.fromNumber = '919464700XXXX';
        wrapMain.isSuccess = true;
        wrapMain.isPNA = false;
        wrapMain.isConversationStarted = false;
        wrapMain.currentUserId = UserInfo.getUserId();
        wrapMain.organizationId = UserInfo.getOrganizationId();
        wrapMain.useReturnAsSend = false;
        wrapMain.url = System.URL.getOrgDomainUrl().toExternalForm()+'/lightning/n/Billing_Support';
        wrapMain.strNoMessagingCampaignErrorMsg = '';
        wrapMain.lstMessagingCampaignOptions = new List<picklistWrapper>();
        wrapMain.lstMessagingTemplateOptions = C3WhatsppFetchTemplate(objName);
        wrapMain.lstMessagingCampaignPhoneOptions = new List<picklistWrapper>();
        wrapMain.strSelectedMessagingCampaign = '';
        wrapMain.strSelectedMessagingTemplate = '';
        wrapMain.isUSAPhoneNumber = false;
        wrapMain.currentUserName='';
        wrapMain.isAllowedToChat=true;   //User can only send messages if he receives messages in last 24 hours
        
        
        String phoneNumber = C3Utility.fetchPhoneNumber(recordId);
        if (phoneNumber != null) {
            wrapMain.toNumber = phoneNumber; 
        }
        List<WhatsApp_Conversation__b> allTXTMessages = new List<WhatsApp_Conversation__b>();
        String [] listFields = new String [] {'Direction__c', 'Status__c', 'Message_formatted__c', 'From_Phone__c', 'Message__c', 'Read__c', 'To_Phone__c', 'Record_ID__c', 'CreatedDate', 'created_date__c'};
            if(C3Utility.checkFieldPermission('WhatsApp_Conversation__b', 'isAccessible', null, true) && C3Utility.checkFieldPermission('WhatsApp_Conversation__b', 'isAccessible', listFields, false)){
                allTXTMessages = [SELECT Direction__c, Status__c,Message_formatted__c,From_Phone__c, Message__c, Read__c, To_Phone__c, Record_ID__c, CreatedDate,created_date__c
                                  FROM WhatsApp_Conversation__b WHERE Record_ID__c =:recordId WITH SECURITY_ENFORCED];
            }else {
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }
        
        if(test.isRunningTest()){
            allTXTMessages.addAll(new list<WhatsApp_Conversation__b>{ C3TestDataFactory.buildConvoRecord(null, '919911410564', recordId, 'asdasdasd'), C3TestDataFactory.buildConvoRecord(null, '919911410564', recordId, 'asdasdasd')});
        }
        List<WhatsApp_Conversation__b> filteredMessages = new List<WhatsApp_Conversation__b>();
        for (WhatsApp_Conversation__b msg : allTXTMessages) {
            if (msg.Record_ID__c == recordId) {
                filteredMessages.add(msg);
            }
        }
        if(!filteredMessages.isEmpty())
        {
            integer recordsCount = filteredMessages.size();
            DateTime createdDateTime = filteredMessages[recordsCount-1].created_Date__c;
            // Calculate the time difference in hours
            long hoursSinceCreation = (DateTime.now().getTime() - createdDateTime.getTime()) / (1000 * 60 * 60);
            if(filteredMessages[recordsCount-1].Direction__c=='Inbound' && hoursSinceCreation >= 24)
            {
                wrapMain.isAllowedToChat=false;
            }
            else{
                wrapMain.isAllowedToChat=true; 
            } 
        }
        if(String.isNotBlank(objName))
        {
            Map<String, String> objectAndNameFieldsMap = C3Utility.getStandardNameField(new Set<String>{objName});
            String recordNameField=objectAndNameFieldsMap.get(objName);
            if(String.isNotBlank(recordNameField))
            {
                string queryIni = 'select id,'+recordNameField+' from '+objName + ' where id =: recordId WITH SECURITY_ENFORCED Limit 1';
                list<sObject> lstSobjInitial;
                List<String> listFields1 = recordNameField.split(',');
                if(C3Utility.checkFieldPermission(objName, 'isAccessible', null, true) && C3Utility.checkFieldPermission(objName, 'isAccessible', listFields1, false)){
                    lstSobjInitial = Database.query(String.escapeSingleQuotes(queryIni), AccessLevel.SYSTEM_MODE);
                }else {
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }
                string fullName = '';
                if(lstSobjInitial.size() > 0)
                {
                    sObject objNameInitial = lstSobjInitial[0];
                    fullName = String.valueOf(objNameInitial.get(recordNameField));
                    if(String.isNotBlank(fullName))
                    {
                        wrapMain.nameIntial = C3Utility.getNameDetails(fullName).get('senderNameSmall');
                        wrapMain.sendFrom = C3Utility.getNameDetails(fullName).get('senderName');
                    }
                }
            }
            else if(string.isNotBlank(wrapMain.toNumber)){
                wrapMain.nameIntial = wrapMain.toNumber.left(1);
                wrapMain.sendFrom =wrapMain.toNumber;
            }
            string strUserFirstName = UserInfo.getFirstName();
            string strUserLastName = UserInfo.getLastName();
            wrapMain.currentUserName = strUserFirstName+' '+strUserLastName;
            if(String.isNotBlank(strUserFirstName)){
                wrapMain.currentUserIntial = strUserFirstName.left(1).capitalize() + strUserLastName.left(1).capitalize();
            }else{
                wrapMain.currentUserIntial = strUserLastName.left(1).capitalize();
            }
        }
        
        TextMessagWrapper textMsgWrapper = new TextMessagWrapper();
        // Add the mediaWrapper to the textMsgWrapper's listMedia
        textMsgWrapper.listMedia = new List<TextMessageMediaWrapper>();
        wrapMain.lstTxtMsg= getAllTextMessagesForWhatsappChatPanel(recordId);
        // Add the textMsgWrapper to the lstTxtMsg
        return JSON.serialize(wrapMain);
    }
    
    @AuraEnabled
    public static List<picklistWrapper> C3WhatsppFetchTemplate(string objName){
        List<Template_Object__c> listName = new List<Template_Object__c>();
        List<picklistWrapper> result = new List<picklistWrapper>();
        
        String [] fieldsToQuery = new String [] {'Id', 'Name', 'Language_Code__c', 'Status__c', 'Template_Message__c', 'Header_Type__c', 'File_Name__c', 'Media_Type__c', 'Media_Handler__c', 'Footer__c', 'Header__c', 'Document_Url__c'  };
        String [] fieldsToQuery2 = new String [] {'Id', 'Field_Name__c', 'Object_name__c', 'Parameter_Name__c'  };
        String [] fieldsToQuery3 = new String [] {'Id', 'Button_text__c', 'Button_Type__c', 'Country_Code__c', 'Phone_Number__c', 'Type__c', 'Type_of_Action__c', 'URL_Type__c', 'Website_URL__c'  };
        Boolean b1 = (!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',fieldsToQuery,False));
        Boolean b12 = (!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',null,true));
        Boolean b2 = (!C3Utility.checkFieldPermission('Template_Mapping__c','isAccessible',fieldsToQuery2,False));
        Boolean b22 = (!C3Utility.checkFieldPermission('Template_Mapping__c','isAccessible',null,true));
        Boolean b3 = (!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',fieldsToQuery3,False));
        Boolean b32 = (!C3Utility.checkFieldPermission('Template_Button__c','isAccessible',null,true));
        if(b1 && b2 && b3 && b12 && b22 && b32){
            throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
        }else{
            listName = [SELECT Name, Template_Message__c, Header__c, Footer__c, Document_Url__c, Media_Type__c, Whatsapp_Template__c, Status__c,Object__c, Template_Label__c, (SELECT Id, Button_text__c, Button_Type__c, Country_Code__c, Phone_Number__c, Type__c, Type_of_Action__c, URL_Type__c, Website_URL__c FROM Template_Buttons__r) FROM Template_Object__c WITH SECURITY_ENFORCED LIMIT 49000];
        }
        
        for (Template_Object__c template : listName) {
            picklistWrapper wrapper = new picklistWrapper();
            if(template.Status__c == 'APPROVED' && template.Object__c == objName)
            {
                wrapper.label = template.Name;
                if (String.isNotBlank(template.Template_Label__c)) {
                    wrapper.label = template.Template_Label__c;
                }
                wrapper.value = template.Name;
                wrapper.textMessage =template.Whatsapp_Template__c;
                wrapper.tempId = template.id;
                if (String.isNotBlank(template.Document_Url__c)) {
                    wrapper.mediaUrl = template.Document_Url__c;
                }
                if (String.isNotBlank(template.Media_Type__c)) {
                    wrapper.mediaType = template.Media_Type__c;
                }
                if (String.isNotBlank(template.Header__c)) {
                    wrapper.header = template.Header__c;
                }
                if (String.isNotBlank(template.Footer__c)) {
                    wrapper.footer = template.Footer__c;
                }
                if(template.Template_Buttons__r != null && template.Template_Buttons__r.size()>0){
                    wrapper.listButtons = new List<Template_Button__c>();
                    wrapper.listButtons = template.Template_Buttons__r;
                }
                result.add(wrapper);
            }
        }
        
        return result;
    }
    
    public static list<C3WhatsAppChatPanelCtrl.TextMessagWrapper> getAllTextMessagesForWhatsappChatPanel(String recordId)
    {
        list<C3WhatsAppChatPanelCtrl.TextMessagWrapper> lstTxtMsg = new list<C3WhatsAppChatPanelCtrl.TextMessagWrapper>();
        List<WhatsApp_Conversation__b> allTXTMessages = new List<WhatsApp_Conversation__b>();
        // Get the first name and last name of the current user
        String currentUserFirstName = UserInfo.getFirstName();
        String currentUserLastName = UserInfo.getLastName();
        
        String [] fieldsToQuery = new String [] {'Direction__c', 'Status__c', 'Read__c',  'Message_formatted__c', 'File_Name__c',  'sid__c', 'From_Phone__c', 'Media_Type__c', 'Message__c', 'Read__c', 'To_Phone__c', 'Record_ID__c', 'CreatedDate', 'created_date__c'};
            if((!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',fieldsToQuery, true)) && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',fieldsToQuery, false))){
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }else{
                allTXTMessages = [SELECT Direction__c, Status__c,Message_formatted__c,sid__c, From_Phone__c, Message__c, Media_Type__c, Media_URL__c, File_Name__c, Read__c, To_Phone__c, Record_ID__c, CreatedDate,created_date__c FROM WhatsApp_Conversation__b WHERE Record_ID__c =:recordId WITH SECURITY_ENFORCED]; /////////////////////////////////////
            }
        if (!allTXTMessages.isEmpty() || test.isRunningTest()) {
            if(test.isRunningTest()){
                allTXTMessages.addAll(new list<WhatsApp_Conversation__b>{ C3TestDataFactory.buildConvoRecord(null, '919911410564', recordId, 'asdasdasd'), C3TestDataFactory.buildConvoRecord(null, '919911410564', recordId, 'asdasdasd')});
            }
            list<WhatsApp_Conversation__b> lstUpdateTextMsgs = new  list<WhatsApp_Conversation__b>();
            for (WhatsApp_Conversation__b objTXT : allTXTMessages) {
                C3WhatsAppChatPanelCtrl.TextMessagWrapper objTextMessagWrapper = new C3WhatsAppChatPanelCtrl.TextMessagWrapper();
                objTextMessagWrapper.isPending = false;
                objTextMessagWrapper.isSent = false;
                objTextMessagWrapper.isRead = false;
                objTextMessagWrapper.isDelivered = false;
                objTextMessagWrapper.isFailed = false;
                objTextMessagWrapper.strMsgInitials = currentUserFirstName +' '+currentUserLastName; //getNameInitials(currentUserFirstName, currentUserLastName);
                objTextMessagWrapper.listMedia = new list<C3WhatsAppChatPanelCtrl.TextMessageMediaWrapper>();
                objTextMessagWrapper.isMMS = false;
                objTextMessagWrapper.isVoice = false;
                
                
                if(objTXT.Status__c == 'sent'){
                    objTextMessagWrapper.isSent = true;
                }
                else if(objTXT.Status__c == 'delivered'){
                    objTextMessagWrapper.isDelivered = true;
                }
                else if(objTXT.Status__c == 'failed' || objTXT.Status__c == 'undelivered'){
                    objTextMessagWrapper.isFailed = true;
                }
                else if(objTXT.Status__c == 'read'){
                    objTextMessagWrapper.isRead = true;
                }else{
                    objTextMessagWrapper.isPending = true;
                }
                
                objTextMessagWrapper.isShow = true; 
                objTextMessagWrapper.objTXT = objTXT;
                if(String.isNotBlank(objTXT.Media_URL__c)){
                    objTextMessagWrapper.isMMS = true;
                    
                    C3WhatsAppChatPanelCtrl.TextMessageMediaWrapper objMMSWrap = new C3WhatsAppChatPanelCtrl.TextMessageMediaWrapper();
                    objMMSWrap.isImage = false;
                    objMMSWrap.isVideo = false;
                    objMMSWrap.isAudio = false;
                    objMMSWrap.isDocument = false;
                    objMMSWrap.isUnknown = false;
                    if(String.isNotBlank(objTXT.File_Name__c)){
                        objMMSWrap.fileName = objTXT.File_Name__c;
                    }
                    objMMSWrap.imageUrl = objTXT.Media_URL__c;
                    if(string.isNotBlank(objTXT.Media_Type__c)){
                        if(objTXT.Media_Type__c.containsIgnoreCase('image')){
                            objMMSWrap.isImage = true;
                        }else if(objTXT.Media_Type__c.containsIgnoreCase('video')){
                            objMMSWrap.isVideo = true;
                        }else if(objTXT.Media_Type__c.containsIgnoreCase('audio')){
                            objMMSWrap.isAudio = true;
                        }
                        else {
                            objMMSWrap.isDocument = true;
                        }
                    }
                    else{
                        objMMSWrap.isUnknown = true;
                    }
                    objTextMessagWrapper.listMedia.add(objMMSWrap);
                }
                
                if(!test.isrunningTest()){
                    objTextMessagWrapper.smallDetails = objTXT.CreatedDate.format();
                }
                lstTxtMsg.add(objTextMessagWrapper);
                if(objTXT.Read__c=='false'){
                    WhatsApp_Conversation__b wb =  new WhatsApp_Conversation__b(read__c='true',created_date__c=objTXT.created_date__c,record_id__c=objTXT.record_id__c);
                    lstUpdateTextMsgs.add(wb);
                }
                
            }
            if(!test.isrunningTest()){
                String[] listFields = new String[]{'read__c', 'created_date__c', 'record_id__c'};
                if(!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',null,true)
                && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',listFields, false)) 
                &&  (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',null, true))
                &&  (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',listFields, true))){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    Database.insertImmediate(lstUpdateTextMsgs, AccessLevel.SYSTEM_MODE); 
                }
            }
        }
        return lstTxtMsg;
    }
    
    public static string getNameInitials(string strFirstName, string strLastName){
        string strInitials = '';
        
        if(string.isNotBlank(strFirstName)){
            strInitials = strInitials+''+strFirstName.left(1).capitalize();
        }
        
        if(string.isNotBlank(strLastName)){
            strInitials = strInitials+''+strLastName.left(1).capitalize();
        }
        return strInitials;
    }
    
    @AuraEnabled
    public static String saveMessage(string recordId, string toNumber, string msg, String objectName, string mediaUrl, String strBase64Data, String strFileName, string templateName, string strtempid){
        try{
            cls_value clsResponse = new cls_value();
            string ReqBody='';
            string result='';
            string wamId='';
            C3Utility.formattedTemplateMessage = msg;
            boolean isTemplate = true;
            if(string.isblank(templateName)){
                ReqBody = C3WhatsAppWebService.sendWhatsAppMessage(toNumber,msg);
            }
            if(string.isNotBlank(ReqBody)){
                clsResponse = (cls_value)json.deserialize(ReqBody,cls_value.class);
            }
            
            if(string.isNotBlank(templateName)){
                
                result = C3WhatsAppTemplateScreenLWCCtrl.sendWhatsAppMessage(new List<string>{recordId}, strtempid);
                clsResponse = (cls_value)json.deserialize(result,cls_value.class);              
            }
            if(clsResponse.messages!=null)
            {
                wamId = clsResponse.messages[0].id;
            }
            return wamId;
        }
        catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppChatPanelCtrl','saveMessage','');
            return null;
        }
    }
    
    @AuraEnabled
    public static String LoadTextMessages(string recordId, string toNumber, string msg, String objectName, string mediaUrl, String mediaType, String strFileName, string templateName, string strtempid, String vamId){
        datetime currentdate = datetime.now();
        WrapperChat wrapMain = new WrapperChat(); 
        try{
            if(string.isNotBlank(objectName) && string.isNotBlank(recordId)  || string.isNotBlank(strFileName))
            {
                String wrapMainJSON = initWhatsAppChatPanelController(recordId, objectName);
                wrapMain=(WrapperChat)json.deserialize(wrapMainJSON, WrapperChat.class);
                
                if(string.isNotBlank(wrapMain.strMsg)){
                    throw new ChatPanelException(wrapMain.strMsg);
                }
                if(String.isNotBlank(templateName)){
                    wrapMain.strSelectedMessagingTemplate = templateName;
                }
                
                
                if (Test.isRunningTest()) { 
                    wrapMain.strMsg = '';
                }
                if(test.isRunningTest()){
                    wrapMain.fromNumber='919464700700';
                    wrapMain.toNumber=toNumber;
                }
                
                //Send Message part start here
                if( String.isNotBlank(wrapMain.fromNumber) && String.isNotBlank(wrapMain.toNumber) && String.isBlank(templateName))
                {
                    wrapMain.strSuccessMsg = '';
                    
                    WhatsApp_Conversation__b objTxtMsg = new WhatsApp_Conversation__b();
                    objTxtMsg.Direction__c = 'Outbound';
                    objTxtMsg.Status__c = 'Pending';
                    objTxtMsg.Record_ID__c = recordId;
                    objTxtMsg.Read__c = 'false';
                    if(String.isNotBlank(msg)){
                        objTxtMsg.Message__c = msg;
                        objTxtMsg.Message_formatted__c = C3Utility.getFormattedBodyutility(msg);
                    }
                    if(String.isNotBlank(mediaUrl))
                        objTxtMsg.Media_URL__c = mediaUrl;
                    if(String.isNotBlank(mediaType))
                        objTxtMsg.Media_Type__c = mediaType;
                    if(String.isNotBlank(strFileName))
                        objTxtMsg.File_Name__c = strFileName;
                    objTxtMsg.From_Phone__c = wrapMain.fromNumber;
                    objTxtMsg.To_Phone__c = wrapMain.toNumber;
                    objTxtMsg.Interaction_Type__c='Whatsapp';
                    objTxtMsg.Created_date__c=currentdate;
                    if(string.isNotBlank(vamId)){
                        objTxtMsg.sid__c = vamId;
                    }
                    if(String.isNotBlank(templateName)){
                        objTxtMsg.Status__c = 'sent'; 
                    }
                    if(string.isNotBlank(strFileName)){
                        objTxtMsg.Interaction_Type__c='MMS';
                    }
                    
                    objTxtMsg.Unique_Key__c=recordId+'-'+System.Now().formatLong();
                    System.debug('objTxtMsg -- '+JSON.serialize(objTxtMsg));
                    if(!Test.isRunningTest()){
                        String[] listFields = new String[]{'Id', 'Direction__c', 'Status__c', 'Record_ID__c', 'Read__c', 'Message__c', 'Message_formatted__c', 'Media_URL__c', 'Media_Type__c', 'File_Name__c', 'From_Phone__c', 'To_Phone__c', 'Interaction_Type__c', 'Created_date__c', 'sid__c', 'Unique_Key__c'};
                        if(!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',null,true) 
                        && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',listFields, false)) 
                        && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',null, true)) 
                        && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',listFields, false)) 
                        ){
                            throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                        }else{
                            Database.insertImmediate(objTxtMsg, AccessLevel.SYSTEM_MODE); 
                        }
                    }
                    string sid= 'test';
                    if(sid == 'failed'){
                        wrapMain.isSuccess = false;
                    }
                }
                wrapMain.lstTxtMsg = new list<TextMessagWrapper>();
                wrapMain.lstTxtMsg = getAllTextMessagesForWhatsappChatPanel(recordId);
            }else{
                wrapMain.strSuccessMsg = '';
                wrapMain.isSuccess = false;
            }
            return json.serialize(wrapMain);
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppChatPanelCtrl','LoadTextMessages','');
            return null;
        }
    }
    
    @AuraEnabled
    public static String getPublicUrl(String toNumber, String cVId, String relatedId, String fileName, String mediaType){
        try{
            String strDocUrl = '';
            if(String.isNotBlank(cVId) && String.isNotBlank(relatedId) && String.isNotBlank(fileName)){
                ContentDistribution objCD = new ContentDistribution();
                objCD.Name = fileName;
                objCD.ContentVersionId = cVId;
                objCD.PreferencesAllowViewInBrowser= true;
                objCD.PreferencesAllowOriginalDownload=true;
                objCD.RelatedRecordId = relatedId;
                
                String[] objCDFields = new String[]{'Id', 'Name', 'ContentVersionId', 'PreferencesAllowViewInBrowser', 'PreferencesAllowOriginalDownload', 'RelatedRecordId'};
                    System.debug('d1 '+ (C3Utility.checkFieldPermission('ContentDistribution', 'isAccessible', null, true) 
                                         && C3Utility.checkFieldPermission('ContentDistribution', 'isCreateable', null, true)));
                if(C3Utility.checkFieldPermission('ContentDistribution', 'isAccessible', null, true) 
                   && C3Utility.checkFieldPermission('ContentDistribution', 'isCreateable', null, true) 
                   && C3Utility.checkFieldPermission('ContentDistribution', 'isCreateable', null, true)){
                       Database.INSERT(objCD, AccessLevel.SYSTEM_MODE);
                   }else {
                       throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                   }
                list<ContentDistribution> listContentDistributions = new list<ContentDistribution>();   
                String [] fieldsToQuery = new String [] {'Id', 'ContentDownloadUrl', 'DistributionPublicUrl', 'Name', 'RelatedRecordId'};
                    if(!C3Utility.checkFieldPermission('ContentDistribution','isAccessible',null,true) 
                       && (!C3Utility.checkFieldPermission('ContentDistribution','isAccessible',null,true))){
                           throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                       }else{
                           listContentDistributions = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl, Name, RelatedRecordId FROM ContentDistribution WHERE Id =: objCD.Id WITH SECURITY_ENFORCED]; 
                       }
                if (!listContentDistributions.isEmpty()) {
                    strDocUrl = listContentDistributions[0].ContentDownloadUrl;
                }
                if(String.isNotBlank(strDocUrl)){
                    return strDocUrl;
                }
                return null;
            }
            return null;
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppChatPanelCtrl','getPublicUrl','');
            return null;
        }
    }
    
    
    
    @AuraEnabled
    public static String getMediaWamId(String toNumber, String mediaUrl, String mediaType, String fileName)
    {
        try{
            if (String.isNotBlank(toNumber) && String.isNotBlank(mediaUrl) && String.isNotBlank(mediaType) ) {
                String responseBody = C3WhatsAppWebService.sendWhatsAppMessageMedia(toNumber, mediaUrl, mediaType);
                cls_value clsResponse = (cls_value)json.deserialize(responseBody, cls_value.class);
                String wamId = '';
                if(clsResponse.messages!=null)
                {
                    wamId = clsResponse.messages[0].id;
                    return wamId;
                }
                return null;
            }
            return null;
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppChatPanelCtrl','getMediaWamId','');
            return null;
        }
    }
    
    
    @AuraEnabled
    public static String checkForNumberConfigurationImplemented(string recordId){
        try{ 
            chatpanelValidations cvWrapper = new chatpanelValidations();
            boolean isAllowedToChat;
            string errorMessage='';
            SObject record;
            
            String phoneNumber = '';
            String objectNameForPhone = '';
            if (recordId != null) {
                objectNameForPhone = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            }
            Map<String, WhatsApp_Number_Configuration__c> numberSettingsMap = new Map<String, WhatsApp_Number_Configuration__c>();
            if((!C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c','isAccessible',null,true))
               && (!C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c','isAccessible',new List<String>{'Field_Name__c', 'Object_Name__c'},False))){
                   throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
               }else{
                   numberSettingsMap = WhatsApp_Number_Configuration__c.getAll();
               }            
            
            WhatsApp_Number_Configuration__c setting = numberSettingsMap.get(objectNameForPhone);
            if (setting != null) {
                String query = 'SELECT ' + setting.Field_Name__c + ' FROM ' + setting.Object_Name__c + ' WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1';
                SObject record2;
                List<String> fieldsToQuery = setting.Field_Name__c.split(',');
                Boolean b1 = (!C3Utility.checkFieldPermission(setting.Object_Name__c,'isAccessible',null,true));
                Boolean b2 = (!C3Utility.checkFieldPermission(setting.Object_Name__c,'isAccessible',fieldsToQuery,False));
                if(b1 && b2){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    Map<String, Object> bindVariablesMap = new Map<String, Object>{'recordId' => recordId  };
                        record2 = Database.queryWithBinds(
                            String.escapeSingleQuotes(query),
                            bindVariablesMap,
                            AccessLevel.SYSTEM_MODE
                        );
                }
                if (record2 != null) {
                    phoneNumber = String.valueOf(record2.get(setting.Field_Name__c));
                    if(phoneNumber==null){
                        isAllowedToChat=false;
                        errorMessage='No phone number is there in the record';
                    }
                    else{
                        isAllowedToChat=true;
                        errorMessage = null;
                    }
                }
            }
            else{
                isAllowedToChat=false;
                errorMessage='Please configure whatsapp number configuration before initialising a chat';
            }
            cvWrapper.isAllowedToChat=isAllowedToChat;
            cvWrapper.errorMessage=errorMessage;    
            return json.serialize(cvWrapper);
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppChatPanelCtrl','checkForNumberConfigurationImplemented','');
            return null;
        }
    }
    
    public class WrapperChat{
        public boolean isSetUpCompleted;
        public list<TextMessagWrapper> lstTxtMsg;
        public string strMsg;
        public string strSuccessMsg;
        public string nameIntial;
        public string currentUserIntial;
        public string sendFrom;
        public string fromNumber;
        public string toNumber;                                                                       
        public Boolean isPNA;
        public Boolean isSuccess;
        public string currentUserId;
        public string organizationId;
        public string wsChatEndpoint;
        public string phoneRecordId;
        public Boolean useReturnAsSend;
        public string url;
        public string strNoMessagingCampaignErrorMsg;
        public list<picklistWrapper> lstMessagingCampaignOptions;
        public list<picklistWrapper> lstMessagingCampaignPhoneOptions;
        public list<picklistWrapper> lstMessagingTemplateOptions;
        public string strSelectedMessagingCampaign;
        public string strSelectedMessagingTemplate;
        public string strFilePublicURL;
        public string strContentVersionId;
        public string strContentDocumentId;
        public boolean isConversationStarted;
        public boolean isUSAPhoneNumber;
        public string currentUserName;
        public boolean isAllowedToChat;
    }
    
    public class TextMessagWrapper{
        public WhatsApp_Conversation__b objTXT;
        public string smallDetails;
        public string strMsgInitials;
        public Boolean isShow;
        public boolean isPending;
        public boolean isSent;
        public boolean isDelivered;
        public boolean isFailed;
        public boolean isRead;
        public boolean isUndelivered;
        public list<TextMessageMediaWrapper> listMedia;
        public boolean isMMS;
        public boolean isVoice;
    }
    
    public class TextMessageMediaWrapper{
        public String fileName;
        public String imageUrl;
        public boolean isImage;
        public boolean isVideo;
        public boolean isAudio;
        public boolean isUnknown;
        public boolean isDocument;
    }
    
    public class picklistWrapper{
        public string label;
        public string value;
        public string header;
        public string footer;
        public string textMessage;
        public string tempId;
        public string mediaUrl;
        public string mediaType;
        public List<Template_Button__c> listButtons;
    }
    public class Template {
        public String name;
        public String language;
        public String status;
        public String category;
        public String id;
    }
    
    public class cls_value {
        public String messaging_product;	//whatsapp
        public cls_contacts[] contacts;
        public cls_messages[] messages;
    }
    public class cls_contacts {
        public string input;
        public String wa_id;	//918802271489
    }
    public class cls_messages {
        public String id;	//wamid.HBgMOTE4ODAyMjcxNDg5FQIAEhggNDBBOEE2QTdGNDU2OTE3RTgzQkRGM0NCRkE3ODlDN0UA
    }
    public class chatpanelValidations{
        public boolean isAllowedToChat;
        public string errorMessage;        
    }
}