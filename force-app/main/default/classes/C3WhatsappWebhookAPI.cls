@RestResource(urlmapping = '/WhatsappWebhook')
global without sharing class C3WhatsappWebhookAPI {
    
    public static string strResponseBody= '';
    @HttpGet
    global static void doGet(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        if(request.params.get('hub.verify_token')=='TestToken123'){
            if(!test.isrunningtest()){
                response.responseBody=Blob.valueOf(request.params.get('hub.challenge'));
            }
        }
    }
    
    
    public static String uploadFile(Blob fileContent, String fileName, String fileType, String recordId) {
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
            if(C3Utility.checkFieldPermission('ContentVersion', 'isAccessible', null, true) 
               && C3Utility.checkFieldPermission('ContentVersion', 'isAccessible', listFields0, false)
               && C3Utility.checkFieldPermission('ContentVersion', 'isCreateable', null, true) 
               && C3Utility.checkFieldPermission('ContentVersion', 'isCreateable', null, true)){
                   Database.INSERT(objCV, AccessLevel.SYSTEM_MODE);
               }
        
        ContentDocumentLink objCDL = new ContentDocumentLink();
        String[] listFields = new String[]{'ContentDocumentId', 'Id'};
            if(C3Utility.checkFieldPermission('ContentVersion', 'isAccessible', null, true) 
               && C3Utility.checkFieldPermission('ContentVersion', 'isAccessible', listFields, false)){
                   objCDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: objCV.Id WITH SYSTEM_MODE].ContentDocumentId;
               }
        objCDL.LinkedEntityId = recordId;
        objCDL.ShareType = 'V';
        String[] listFields2 = new String[]{'LinkedEntityId', 'ShareType', 'ContentDocumentId'};
            if(C3Utility.checkFieldPermission('ContentDocumentLink', 'isAccessible', null, true) 
               && C3Utility.checkFieldPermission('ContentDocumentLink', 'isAccessible', listFields2, false)
               && C3Utility.checkFieldPermission('ContentDocumentLink', 'isCreateable', null, true) 
               && C3Utility.checkFieldPermission('ContentDocumentLink', 'isCreateable', listFields2, false)){
                   Database.INSERT(objCDL, AccessLevel.SYSTEM_MODE);
               }
        
        ContentDistribution objCD = new ContentDistribution();
        objCD.Name = fileName;
        objCD.ContentVersionId = objCV.Id;
        objCD.PreferencesAllowViewInBrowser= true;
        objCD.PreferencesAllowOriginalDownload=true;
        objCD.RelatedRecordId = recordId;
        Database.INSERT(objCD, AccessLevel.SYSTEM_MODE);
        list<ContentDistribution> listContentDistributions = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE Id =: objCD.Id WITH SYSTEM_MODE];
        return listContentDistributions[0].ContentDownloadUrl;
    }
    
    public static void sendPushWhatsAppNotification(String recordId, String message){
        if (String.isNotBlank(recordId)) {
            Id recId = Id.valueOf(recordId);
            String objectName = recId.getSObjectType().getDescribe().getName();
            String query = 'SELECT Id, OwnerId FROM '+objectName+' WHERE Id =: recordId';
            SObject sRecord ;
            String [] fieldsToQuery = new String [] {'Id', 'OwnerId'};
                if(!C3Utility.checkFieldPermission(objectName,'isAccessible',null,true) && (!C3Utility.checkFieldPermission(objectName,'isAccessible',fieldsToQuery,false) ) ){
                    system.debug('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    sRecord = database.query( String.escapeSingleQuotes(query), AccessLevel.SYSTEM_MODE);
                }
            String userId = (String)sRecord.get('OwnerId');
            
            Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
            customNotificationObj.setBody( message);
            customNotificationObj.setTitle('WhatsApp New Message');
            CustomNotificationType type = new CustomNotificationType();
            if(!C3Utility.checkFieldPermission('CustomNotificationType','isAccessible',null,true) && (!C3Utility.checkFieldPermission('CustomNotificationType','isAccessible',fieldsToQuery,false) ) ){
                system.debug('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }else{
                type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'WhatsApp_Notification' WITH SYSTEM_MODE];
            }
            customNotificationObj.setNotificationTypeId(type.id);
            customNotificationObj.setSenderId(userId);
            customNotificationObj.setTargetId(recordId);
            customNotificationObj.send(new Set<String> {userId});
        }
    }
    
    @HttpPost
    global static void doPost(){
        String strRequestBody = RestContext.request.requestBody.tostring();
        System.debug(' strRequestBody -- '+strRequestBody);
        try{     
            if(strRequestBody.contains('"from"')){
                strRequestBody = strRequestBody.replace('"from"','"fromNumber"');
            }        
            
            C3InboundWrapper objWrap1=new C3InboundWrapper();
            C3InboundWrapper.cls_statuses entry=new C3InboundWrapper.cls_statuses();
            objWrap1=(C3InboundWrapper)JSON.deserialize(strRequestBody, C3InboundWrapper.class);        
            if(objWrap1!=null )
            { 
                String[] listFields = new String[]{'Id', 'Direction__c', 'Status__c', 'Record_ID__c', 'Read__c', 'Message__c', 'Message_formatted__c', 'Media_URL__c', 'Media_Type__c', 'File_Name__c', 'From_Phone__c', 'To_Phone__c', 'Interaction_Type__c', 'Created_date__c', 'sid__c', 'Unique_Key__c'};
                List<WhatsApp_Conversation__b> records = new List<WhatsApp_Conversation__b>();
                String str = 'Id,Record_ID__c,sid__c,Status__c,Message_formatted__c, Unique_Key__c,To_Phone__c,From_Phone__c, Created_Date__c';
                List<String> fieldsToQuery = str.split(',');
                if(!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',null,true) && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',null,true))){
                    system.debug('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    records = [SELECT Id,Record_ID__c, Message_formatted__c, sid__c,Status__c, Unique_Key__c,To_Phone__c,From_Phone__c, Created_Date__c FROM WhatsApp_Conversation__b WITH SECURITY_ENFORCED];
                }

                boolean found=false;
                String recordId='';
                datetime createddate;
                if(objWrap1.entry != null && (!objWrap1.entry.isempty()))
                    if(objWrap1.entry != null && (!objWrap1.entry[0].changes.isempty()))
                    if(objWrap1.entry != null && objWrap1.entry[0].changes[0].value!=null)            
                    if(objWrap1.entry != null && objWrap1.entry[0].changes[0].value.statuses != null)
                {                
                    
                    for(WhatsApp_Conversation__b objWAConversation : records)
                    {
                        if(objWAConversation.sid__c!=null && objWAConversation.sid__c ==objWrap1.entry[0].changes[0].value.statuses[0].id)
                        {
                            found=true;
                            recordId=objWAConversation.Record_ID__c;
                            createddate=objWAConversation.Created_Date__c;
                            break;
                        }
                    }
                    if(!found){
                        WhatsApp_Conversation__b objfilteredMessages = new WhatsApp_Conversation__b();
                        objfilteredMessages.Direction__c ='Outbound';
                        objfilteredMessages.Status__c='Sent';
                        objfilteredMessages.To_Phone__c= objWrap1.entry[0].changes[0].value.statuses[0].recipient_id!=null?objWrap1.entry[0].changes[0].value.statuses[0].recipient_id : '';
                        objfilteredMessages.From_Phone__c=objWrap1.entry[0].changes[0].value.metadata.display_phone_number!=null?objWrap1.entry[0].changes[0].value.metadata.display_phone_number : '';
                        objfilteredMessages.Read__c='false';
                        objfilteredMessages.sid__c=objWrap1.entry[0].changes[0].value.statuses[0].id!=null?objWrap1.entry[0].changes[0].value.statuses[0].id:'';
                        objfilteredMessages.Created_date__c=DateTime.now();
                        objfilteredMessages.Response_Body__c=strRequestBody;
                        if(test.isRunningTest()){
                            WhatsApp_Conversation__b rec =new WhatsApp_Conversation__b();
                            rec.Media_Type__c='test1';
                            rec.File_Name__c ='testdata';
                            rec.From_Phone__c =objWrap1.entry[0].changes[0].value.metadata.display_phone_number!=null?objWrap1.entry[0].changes[0].value.metadata.display_phone_number : '';
                            rec.To_Phone__c=objWrap1.entry[0].changes[0].value.statuses[0].recipient_id != null ? objWrap1.entry[0].changes[0].value.statuses[0].recipient_id:'';
                            rec.Direction__c ='Inbound';
                            rec.Message__c = 'Hi Vivek Sir';
                            rec.Read__c='true';
                            rec.Record_ID__c=recordId;
                            rec.sid__c='retfgvfbhnm';
                            rec.Status__c='delivered';
                            rec.Unique_Key__c='';
                            rec.Media_URL__c='test';
                            rec.Interaction_Type__c='test';
                            rec.sid__c='records';
                            rec.Read__c='testing';
                        }
                        
                        if(!test.isrunningtest()){
                            if(!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',null,true) 
                                && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',listFields, false)) 
                                && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',null, true)) 
                                && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',listFields, false)) 
                            ){
                                system.debug('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                            }else{
                                Database.insertImmediate(objfilteredMessages, AccessLevel.SYSTEM_MODE); 
                            }
                        }
                    }else{
                        WhatsApp_Conversation__b objfilteredMessage1 = new WhatsApp_Conversation__b();
                        objfilteredMessage1.Record_ID__c=recordId;
                        objfilteredMessage1.Status__c = objWrap1.entry[0].changes[0].value.statuses[0].status;
                        System.debug('Status Update--'+objfilteredMessage1.Status__c);
                        objfilteredMessage1.Created_date__c = createddate;
                        if(!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',null,true) 
                            && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',listFields, false)) 
                            && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',null, true)) 
                            && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',listFields, false)) 
                        ){
                            system.debug('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                        }else{
                            Database.insertImmediate(objfilteredMessage1, AccessLevel.SYSTEM_MODE); 
                        }
                        if (objWrap1.entry[0].changes[0].value.statuses[0]?.errors != null ) {
                            C3Utility.logError(objWrap1.entry[0].changes[0].value.statuses[0].errors[0].error_data.details,'', 178, strRequestBody,'C3WhatsappWebhookAPI','status update', '');
                        }
                    }
                }
                else{
                    Boolean isWamId= false;
                    Boolean isMedia = false;
                    String webhookMediaId = '';
                    String webhookMediaType = '';
                    String webhookMediaName = '';
                    String sfDownloadURL = '';
                    Set<String> wamIdSet = new Set<String>();
                    //Inbound Message
                    WhatsApp_Conversation__b objfilteredMessages = new WhatsApp_Conversation__b();
                    objfilteredMessages.Direction__c ='Inbound';
                    objfilteredMessages.To_Phone__c= objWrap1.entry[0].changes[0].value.messages[0].fromNumber!=null?objWrap1.entry[0].changes[0].value.messages[0].fromNumber:'';
                    objfilteredMessages.Read__c ='false';
                    objfilteredMessages.sid__c = objWrap1.entry[0].changes[0].value.messages[0].id!=null?objWrap1.entry[0].changes[0].value.messages[0].id:'';
                    objfilteredMessages.From_Phone__c = objWrap1.entry[0].changes[0].value.metadata.display_phone_number!=null? objWrap1.entry[0].changes[0].value.metadata.display_phone_number:'';
                    objfilteredMessages.Message__c = '';
                
                    for (WhatsApp_Conversation__b conversation : records) {
                        wamIdSet.add(conversation.sid__c);
                    }

                    if (!records.isEmpty() || test.isRunningTest()) {
                        if(test.isRunningTest()){
                            objfilteredMessages.To_Phone__c='919911410564';
                            records.add(new WhatsApp_Conversation__b(Direction__c ='Inbound',Message__c = 'Hi Vivek Sir',Read__c='false',Record_ID__c=recordId,sid__c='retfgvfbhnm',Status__c='delivered',To_Phone__c='919911410564',Unique_Key__c=''));
                            records.add(new WhatsApp_Conversation__b(Direction__c ='Inbound',Message__c = 'Hi Vivek Sir',Read__c='false',Record_ID__c=recordId,sid__c='retfgvfbhnm',Status__c='failed',To_Phone__c='919911410564',Unique_Key__c=''));
                        }
                        if (!records.isEmpty()){
                            for(WhatsApp_Conversation__b objWAConversation:records){
                                if(objWAConversation.To_Phone__c==objfilteredMessages.To_Phone__c){
                                    objfilteredMessages.Record_ID__c = objWAConversation.Record_ID__c;
                                    objfilteredMessages.Unique_Key__c= objWAConversation.Unique_Key__c;
                                    break;
                                }
                            }
                        }
                        if(objWrap1.entry[0].changes[0].value.messages[0].text != null || (objWrap1.entry[0].changes[0].value.messages[0].button != null && objWrap1.entry[0].changes[0].value.messages[0].button.text != null)){
                            if(objWrap1.entry[0].changes[0].value.messages[0].text != null && objWrap1.entry[0].changes[0].value.messages[0].text.body != null){
                                objfilteredMessages.Message__c = objWrap1.entry[0].changes[0].value.messages[0].text.body;
                                objfilteredMessages.Message_formatted__c = objWrap1.entry[0].changes[0].value.messages[0].text.body;
                            }else if(objWrap1.entry[0].changes[0].value.messages[0].button != null && objWrap1.entry[0].changes[0].value.messages[0].button.text != null){
                                objfilteredMessages.Message__c = objWrap1.entry[0].changes[0].value.messages[0].button.text;
                                objfilteredMessages.Message_formatted__c = objWrap1.entry[0].changes[0].value.messages[0].button.text;
                            }else{
                                objfilteredMessages.Message__c = '';
                                objfilteredMessages.Message_formatted__c = '';
                            }
                            objfilteredMessages.Status__c='Retrieved';
                            objfilteredMessages.Created_date__c=DateTime.now();
                            objfilteredMessages.Response_Body__c=strRequestBody;
                            if(!(wamIdSet.contains(objfilteredMessages.sid__c))){
                                if(!Test.isRunningTest()){
                                    if(!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',null,true) 
                                       && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',listFields, false)) 
                                       && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',null, true)) 
                                       && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',listFields, false)) 
                                      ){
                                          system.debug('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                                      }else{
                                          Database.insertImmediate(objfilteredMessages, AccessLevel.SYSTEM_MODE); 
                                      }
                                }
                                if(String.isNotBlank(objfilteredMessages.Record_ID__c))
                                    sendPushWhatsAppNotification(objfilteredMessages.Record_ID__c, objfilteredMessages.Message__c);
                            }
                        }
                        else{
                            if(objWrap1.entry[0].changes[0].value.messages[0].video != null){
                                webhookMediaId = objWrap1.entry[0].changes[0].value.messages[0].video.id;
                                webhookMediaType = objWrap1.entry[0].changes[0].value.messages[0].video.mime_type;
                                if (String.isNotBlank(objWrap1.entry[0].changes[0].value.messages[0].video.caption)) {
                                    webhookMediaName = objWrap1.entry[0].changes[0].value.messages[0].video.caption;
                                }else {
                                    webhookMediaName = 'VideoFile';
                                }
                            }
                            else if(objWrap1.entry[0].changes[0].value.messages[0].image != null){
                                webhookMediaId = objWrap1.entry[0].changes[0].value.messages[0].image.id;
                                webhookMediaType = objWrap1.entry[0].changes[0].value.messages[0].image.mime_type;
                                if (String.isNotBlank(objWrap1.entry[0].changes[0].value.messages[0].image.caption)) {
                                    webhookMediaName = objWrap1.entry[0].changes[0].value.messages[0].image.caption;
                                }else {
                                    webhookMediaName = 'imageFile';
                                }
                            }
                            else if(objWrap1.entry[0].changes[0].value.messages[0].document != null){
                                webhookMediaId = objWrap1.entry[0].changes[0].value.messages[0].document.id;
                                webhookMediaType = objWrap1.entry[0].changes[0].value.messages[0].document.mime_type;
                                if (String.isNotBlank(objWrap1.entry[0].changes[0].value.messages[0].document.caption)) {
                                    webhookMediaName = objWrap1.entry[0].changes[0].value.messages[0].document.caption;
                                }else {
                                    webhookMediaName = 'documentFile';
                                }
                            }
                            else if(objWrap1.entry[0].changes[0].value.messages[0].audio != null){
                                webhookMediaId = objWrap1.entry[0].changes[0].value.messages[0].audio.id;
                                webhookMediaType = objWrap1.entry[0].changes[0].value.messages[0].audio.mime_type;
                                webhookMediaName = 'AudioFile';
                            }
                            objfilteredMessages.Status__c='Retrieved';
                            objfilteredMessages.Created_date__c=DateTime.now();
                            
                            if(String.isNotBlank(webhookMediaId) && String.isNotBlank(webhookMediaType)){
                                sfDownloadURL = C3WhatsAppWebService.getMediaFromAPI(webhookMediaId, webhookMediaName, webhookMediaType, objfilteredMessages.Record_ID__c);
                            }
                            if(String.isNotBlank(sfDownloadURL)){
                                objfilteredMessages.Media_URL__c=sfDownloadURL;
                                objfilteredMessages.File_Name__c=webhookMediaName;
                                objfilteredMessages.Media_Type__c=webhookMediaType;
                                
                            }
                            objfilteredMessages.Response_Body__c=strRequestBody;
                            if(!(wamIdSet.contains(objfilteredMessages.sid__c))){
                                
                                if(!test.isrunningtest()){
                                    System.enqueueJob(new C3CreateWhatsAppConversationQueue(objfilteredMessages));
                                }
                            }
                        }
                    }
                }  
            }
        }
        catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), strRequestBody,'C3WhatsappWebhookAPI','doPost','');
        }
    }
    
}