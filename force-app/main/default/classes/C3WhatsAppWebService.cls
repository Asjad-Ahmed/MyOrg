global with sharing class C3WhatsAppWebService {
    
    
    public static  String PHONE_NUMBER_ID ; 
    public static  String WABA_ID ; 
    public static String endPointURL;
    
    public static string createWebserviceBody(List<SObject> listSObject, Map<String, String> mapParamNumWithFieldName, Template_Object__c objTemplate, String phoneFieldName){
        try {
            C3Utility.getWhatsAppDetails();
            List<String> listOfJsonBody = new List<String>();
            List<C3WhatsAppWebServiceWrapper> listWrapper = new List<C3WhatsAppWebServiceWrapper>();
            for(SObject objSobject : listSObject){
                C3WhatsAppWebServiceWrapper objMain = new C3WhatsAppWebServiceWrapper();
                objMain.messaging_product = 'whatsapp';
                objMain.to = '';
                if(objSobject!=null && String.isNotBlank(phoneFieldName) && String.isNotBlank(String.valueof(objSobject.get(phoneFieldName)))){
                    objMain.to = String.valueof(objSobject.get(phoneFieldName));
                }
                objMain.type = 'template';
                objMain.template = new template();
                objMain.template.name = objTemplate.Name;
                objMain.template.language = new language();
                objMain.template.language.code = objTemplate.Language_Code__c;
                objMain.template.components = new List<components>();
                
                if (objTemplate.Header_Type__c != 'TEXT' && String.isNotBlank(objTemplate.Header_Type__c)) {
                    components objHeaderComp = new components();
                    objHeaderComp.type = 'header';
                    objHeaderComp.parameters = new List<parameters>();
                    parameters objParam = new parameters();
                    objParam.type = objTemplate.Media_Type__c.toLowerCase();
                    if (objTemplate.Media_Type__c == 'IMAGE') {
                        objParam.image = new MediaClass();
                        objParam.image.link = objTemplate.Document_Url__c;
                    }else if(objTemplate.Media_Type__c == 'DOCUMENT'){
                        objParam.document = new MediaClass();
                        objParam.document.link = objTemplate.Document_Url__c;
                    }else if(objTemplate.Media_Type__c == 'VIDEO'){
                        objParam.video = new MediaClass();
                        objParam.video.link = objTemplate.Document_Url__c;
                    }
                    objHeaderComp.parameters.add(objParam);
                    objMain.template.components.add(objHeaderComp);
                }
                components objBodyComp = new components();
                objBodyComp.type = 'body';
                objBodyComp.parameters = new List<parameters>();
                if(mapParamNumWithFieldName != null && (!mapParamNumWithFieldName.isEmpty())){
                    integer numOfParam = mapParamNumWithFieldName.size();
                    for(integer loopVar = 0; loopVar <= numOfParam ; loopVar++){
                        String key = String.valueOf(loopVar);
                        if(mapParamNumWithFieldName.containsKey(key)){
                            if(objSobject.get(mapParamNumWithFieldName.get(key)) != null){
                                parameters objParam = new parameters();
                                objParam.type = 'text';
                                objParam.text = (String)objSobject.get(mapParamNumWithFieldName.get(key));
                                objBodyComp.parameters.add(objParam);
                            }
                        }
                    }
                }
                objMain.template.components.add(objBodyComp);
                if (String.isNotBlank(objMain.to)) {
                    listWrapper.add(objMain);
                }
                System.debug('template listWrapper  -- '+ JSON.Serialize(listWrapper));
            }
            if(!listWrapper.isEmpty()){
                string resbody=  webServiceCallOut(listWrapper, listSObject, objTemplate, phoneFieldName);
                return resbody;
            }
            return null;
        } catch (Exception ex) {
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','C3WhatsAppWebService','createWebserviceBody','');
            return null;
        }
    }    
    
    public static string webServiceCallOut(List<C3WhatsAppWebServiceWrapper> listOfC3WhatsAppWebServiceWrapper, List<SObject> listSObject, Template_Object__c objTemplate, String phoneField){
        C3Utility.getWhatsAppDetails();
        list<WhatsApp_Conversation__b> listConvoRecords=new list<WhatsApp_Conversation__b>();
        integer i = 0;
        string resbody='';
        for(C3WhatsAppWebServiceWrapper objWrapper : listOfC3WhatsAppWebServiceWrapper){
            string phonefieldName ='';
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String apiUrl = 'callout:FacebookAPI/' + PHONE_NUMBER_ID + '/messages';
            req.setEndpoint(apiUrl);
            req.setHeader('Content-Type', 'application/json');        
            req.setMethod('POST'); 
            req.setBody(Json.serialize(objWrapper, true));
            req.setTimeout(120000);
            HttpResponse res  = new HttpResponse();
            res  = new Http().send(req);
            resbody = res.getBody();
            System.debug('template send Response -- '+res.getBody());
            if(res.getStatusCode()==200 ||  res.getStatusCode()==201){
                if(listSObject != null && listSObject[i] != null && listSObject[i].get('Id') != null){
                    id recordid = (id)listSObject[i].get('Id');
                    string objectNameForPhone = recordid.getSObjectType().getDescribe().getName();
                    phonefieldName = C3Utility.getFieldName(objectNameForPhone);
                }
                C3WhatsAppChatPanelCtrl.cls_value clsResponse = (C3WhatsAppChatPanelCtrl.cls_value)json.deserialize(resbody, C3WhatsAppChatPanelCtrl.cls_value.class);
                if(String.isNotBlank(clsResponse.messages[0].id)  && String.isNotBlank((String)listSObject[i].get('Id'))){
                    listConvoRecords.add(C3Utility.buildConvoRecord(objTemplate, (String)listSObject[i].get(phoneField), (String)listSObject[i].get('Id'), clsResponse.messages[0].id));
                }
            }else{
                C3Utility.logError('API Error','', 131, resbody,'C3WhatsAppWebService','webServiceCallOut',Json.serialize(objWrapper, true));
            }
            i++;
        } 
        if((!listConvoRecords.isEmpty()) && (!Test.isRunningTest()))  
        { 
            String[] listFields = new String[]{'Id', 'Direction__c', 'Status__c', 'Record_ID__c', 'Read__c', 'Message__c', 'Message_formatted__c', 'Media_URL__c', 'Media_Type__c', 'File_Name__c', 'From_Phone__c', 'To_Phone__c', 'Interaction_Type__c', 'Created_date__c', 'sid__c', 'Unique_Key__c'};
            if(!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',null,true) 
            && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isAccessible',listFields, false)) 
            && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',null, true)) 
            && (!C3Utility.checkFieldPermission('WhatsApp_Conversation__b','isCreateable',listFields, false)) 
            ){
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }else{
                Database.insertImmediate(listConvoRecords, AccessLevel.SYSTEM_MODE); 
            }
        }
        return resbody;
    }
    
    
    
    public static string getUploadSessionIdFromWebService(String fileType, Integer fileSize, String fileName){
        C3Utility.getWhatsAppDetails();
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String endPoint = 'callout:FacebookAPI/' +'app/uploads/?file_length=' + String.valueOf(fileSize)+ '&file_type=' + fileType + '&file_name=' + fileName;
        req.setEndpoint(endPoint);
        req.setHeader('Content-Type', 'application/json');        
        req.setMethod('POST'); 
        req.setTimeout(120000);
        HttpResponse res  = new HttpResponse();
        res  = new Http().send(req);
        if(res.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>)Json.deserializeUntyped(res.getBody());
            if(responseMap.containsKey('id')){
                return String.valueOf(responseMap.get('id'));
            }
        }else{
            C3Utility.logError('API Error','', 237, res.getBody(),'C3WhatsAppWebService','getUploadSessionIdFromWebService', 'Url Body : '+endPoint);
        }
        return '';
    }
    
    
    public static string getFileHandlerFromWebService(blob fileData, String sessionId, String contentType){
        C3Utility.getWhatsAppDetails();
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String endPoint = 'callout:FacebookFileAuth' + '/' + sessionId;
        req.setEndpoint(endPoint);
        req.setHeader('Content-Type',contentType);
        req.setHeader('file_offset','0');
        req.setMethod('POST'); 
        req.setBodyAsBlob(fileData);
        req.setTimeout(120000);
        HttpResponse res  = new HttpResponse();
        res  = new Http().send(req);
        if(res.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>)Json.deserializeUntyped(res.getBody());
            if(responseMap.containsKey('h')){
                return String.valueOf(responseMap.get('h'));
            }
        }else{
            C3Utility.logError('API Error','', 276, res.getBody(),'C3WhatsAppWebService','getFileHandlerFromWebService', fileData.tostring());
        }
        return null;        
    }
    
    
    
    @AuraEnabled
    public static String sendWhatsAppTemplateToMeta(String jsonObject){
        C3Utility.getWhatsAppDetails();
        if(String.isNotBlank(jsonObject)){
            ResponseWrapper objResponseWrapper = new ResponseWrapper();
            C3WhatsAppTemplateScreenLWCCtrl.TemplateWrapper objTemplateWrapper = (C3WhatsAppTemplateScreenLWCCtrl.TemplateWrapper)JSON.deserialize(jsonObject, C3WhatsAppTemplateScreenLWCCtrl.TemplateWrapper.class);
            CreateTemplateWrapper objCreateTemplateWrapper = new CreateTemplateWrapper();
            if (String.isNotBlank(objTemplateWrapper.contentVersionId) && String.isNotBlank(objTemplateWrapper.mimeType)) {
                objTemplateWrapper.mediaHandler = C3WhatsAppTemplateScreenLWCCtrl.runMediaAPIs(objTemplateWrapper.contentVersionId, objTemplateWrapper.mimeType);
            }
            objCreateTemplateWrapper.name = objTemplateWrapper.templateName.toLowerCase().replaceAll(' ', '_'); 
            objCreateTemplateWrapper.language = objTemplateWrapper.language; 
            objCreateTemplateWrapper.category = objTemplateWrapper.category;
            objCreateTemplateWrapper.components = new List<components>();
            if(objTemplateWrapper.isHeaderMedia || objTemplateWrapper.isHeaderText){
                components objComp = new components();
                objComp.type = 'HEADER';
                if(objTemplateWrapper.isHeaderText){
                    objComp.format = objTemplateWrapper.headerType;
                    objComp.text = objTemplateWrapper.headerText;
                }
                if(objTemplateWrapper.isHeaderMedia && String.isNotBlank(objTemplateWrapper.mediaHandler)){
                    objComp.format = objTemplateWrapper.mediaType;
                    objComp.example = new example();
                    objComp.example.header_handle = new List<String>{objTemplateWrapper.mediaHandler};
                        }
                objCreateTemplateWrapper.components.add(objComp);
            }
            if(String.isNotBlank(objTemplateWrapper.templateBody) ){
                components objComp = new components();
                objComp.type = 'BODY';
                objComp.text =C3WhatsAppTemplateScreenLWCCtrl.getFormattedBody(objTemplateWrapper.templateBodyText);                
                if(objTemplateWrapper.listMapping != null && (!objTemplateWrapper.listMapping.isEmpty())){
                    objComp.example = new example();
                    objComp.example.body_text = new List<List<String>>();
                    List<String> lstExampleText = new List<String>();
                    for(C3WhatsAppTemplateScreenLWCCtrl.ListMapping objLstMap : objTemplateWrapper.listMapping){
                        lstExampleText.add(objLstMap.exampleText);
                    }
                    objComp.example.body_text.add(new List<String>(lstExampleText));
                    
                }
                objCreateTemplateWrapper.components.add(objComp);
            }
            if(String.isNotBlank(objTemplateWrapper.footer) ){
                components objComp = new components();
                objComp.type = 'FOOTER';
                objComp.text = objTemplateWrapper.footer;
                objCreateTemplateWrapper.components.add(objComp);
            }
            
            if(objTemplateWrapper.isActionList || objTemplateWrapper.isQuickReplyList){
                components objComp = new components();
                objComp.buttons = new List<buttons>();
                objComp.type = 'BUTTONS';
                List<buttons> lstButtons = new List<buttons>();
                if(objTemplateWrapper.listActions != null){
                    for(C3WhatsAppTemplateScreenLWCCtrl.ListActions objLstAct : objTemplateWrapper.listActions){
                        buttons objButton = new buttons();
                        if(objLstAct.isActionPhoneNumber){
                            objButton.type = 'PHONE_NUMBER';
                            objButton.phone_number = objLstAct.countryCode + objLstAct.phoneNumber;
                        }else if(objLstAct.isActionUrl){
                            objButton.type = 'URL';
                            objButton.url = objLstAct.websiteUrl;
                        }
                        objButton.text = objLstAct.buttonText;
                        objComp.buttons.add(objButton);
                    }
                }
                
                if(objTemplateWrapper.listQuickReply != null){
                    for(C3WhatsAppTemplateScreenLWCCtrl.ListQuickReply objLstAct : objTemplateWrapper.listQuickReply){
                        buttons objButton = new buttons();
                        objButton.type = 'QUICK_REPLY'; 
                        objButton.text = objLstAct.buttonText;
                        objComp.buttons.add(objButton);
                    }
                }
                objCreateTemplateWrapper.components.add(objComp);
            }
            String requestBody = json.serialize(objCreateTemplateWrapper, true);
            String endpointUrl = '';
            if(String.isNotBlank(objTemplateWrapper.whatsAppTemplateId)){
                endpointUrl = objTemplateWrapper.whatsAppTemplateId;
            }
            else{
                endpointUrl = WABA_ID+'/message_templates';
            }
            HttpResponse response = makeCallOut(requestBody, endpointUrl );
            if(String.isNotBlank(objTemplateWrapper.templateId)){
                objResponseWrapper.isSuccess = false;
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                objResponseWrapper = (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
                Template_Object__c objSFTemplate = new Template_Object__c();
                if (String.isNotBlank(objTemplateWrapper.mediaHandler)) {
                    objSFTemplate.Media_Handler__c = objTemplateWrapper.mediaHandler;
                }
                objSFTemplate.Id = objTemplateWrapper.templateId;
                if(responseMap.containsKey('id')){
                    objSFTemplate.TemplateID__c =objResponseWrapper.id;
                    objResponseWrapper.isSuccess = true;
                    objResponseWrapper.message = 'Template has been submitted succesfully! ';
                }
                if(responseMap.containsKey('status')){
                    objSFTemplate.Status__c =(String)responseMap.get('status');
                    objResponseWrapper.status = (String)responseMap.get('status');
                }
                if(responseMap.containsKey('success')){
                    objSFTemplate.Status__c = 'PENDING';
                    objResponseWrapper.status = 'PENDING';
                    objResponseWrapper.message = 'Template has been submitted succesfully for update!';
                    objResponseWrapper.isSuccess = true;
                }
                if(responseMap.containsKey('error')){
                    objResponseWrapper.isSuccess = false;
                    if(String.isNotBlank(objResponseWrapper.error.error_user_msg)){
                        objResponseWrapper.message = objResponseWrapper.error.error_user_msg;
                    }else if(String.isNotBlank(objResponseWrapper.error.message)){
                        objResponseWrapper.message = objResponseWrapper.error.message;
                    }else{
                        objResponseWrapper.message = 'Something went wrong, check error logs!';
                    }
                }
                List<String> listFields = new List<String>{'Status__c', 'TemplateID__c', 'Media_Handler__c'};
                    if(!C3Utility.checkFieldPermission('Template_Object__c', 'isAccessible', null, true) 
                       && !C3Utility.checkFieldPermission('Template_Object__c', 'isAccessible', listFields, false)
                       && !C3Utility.checkFieldPermission('Template_Object__c', 'isUpdateable', null, true) 
                       && !C3Utility.checkFieldPermission('Template_Object__c', 'isUpdateable', listFields, false)){
                           throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                       }else {
                           Database.UPDATE(objSFTemplate, AccessLevel.SYSTEM_MODE);
                       }
            }
            return json.serialize(objResponseWrapper);
        }
        return null;        
    }
    
    public static HttpResponse makeCallOut(String requestBody, String endpointUrl ){
        C3Utility.getWhatsAppDetails();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:FacebookAPI/'+endpointUrl);
        req.setMethod('POST');   
        req.setHeader('Accept' , 'application/json');
        req.setHeader('content-type', 'application/json');
        req.setTimeout(120000);
        req.setBody(requestBody);
        HttpResponse response=new  HttpResponse();
        response = http.send(req);
        if(response.getStatusCode() != 200 && response.getStatusCode() != 201){
            C3Utility.logError('API Error','', 438, response.getBody(),'C3WhatsAppWebService','makeCallOut', req.getBody());
        }
        return response;
    }
    
    
    
    public static string sendWhatsAppMessage(string ToNumber, string strText) {
        C3Utility.getWhatsAppDetails();
        String apiUrl = 'callout:FacebookAPI/' + PHONE_NUMBER_ID + '/messages';
        string input = '';
        input = C3WhatsAppTemplateScreenLWCCtrl.getFormattedBody(strText);
        Map<String, Object> requestBody = new Map<String, Object> {
            'messaging_product' => 'whatsapp',
                'recipient_type' => 'individual',
                'to' => ToNumber,
                'type' => 'text',
                'text' => new Map<String, Object> {
                    'preview_url' => false,
                        'body' => input
                        }
        };
        String requestBodyJson = JSON.serialize(requestBody);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setHeader('Accept' , 'application/json');
        request.setHeader('content-type', 'application/json');
        request.setMethod('POST');
        request.setBody(requestBodyJson);
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        System.debug('send message res -- '+response.getBody());
        System.debug('send message getStatusCode -- '+response.getStatusCode());
        // Parse the JSON response)
        if(response.getStatusCode() != 200) {
            C3Utility.logError('API Error','', 482, response.getBody(),'C3WhatsAppWebService','sendWhatsAppMessage', request.getBody()); 
        }
        return response.getBody();
    }
    
    
    public static string sendWhatsAppMessageMedia(String ToNumber, String url, String mediaType) {
        C3Utility.getWhatsAppDetails();
        String apiUrl = 'callout:FacebookAPI/' + PHONE_NUMBER_ID + '/messages'; 
        Map<String, Object> requestBody = new Map<String, Object> {
            'messaging_product' => 'whatsapp',
                'recipient_type' => 'individual',
                'to' => ToNumber,
                'type' => mediaType,
                mediaType => new Map<String, Object> {
                    'link' => url
                        }
        };        
        String requestBodyJson = JSON.serialize(requestBody);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setHeader('Accept' , 'application/json');
        request.setHeader('content-type', 'application/json');
        request.setMethod('POST'); 
        request.setBody(requestBodyJson);
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        return response.getBody();
    }
    
    // We will see it later
    public static String getMediaFromAPI(String mediaId, String fileName, String fileType, String recordId){
        C3Utility.getWhatsAppDetails();
        HttpRequest request = new HttpRequest();
        String strUrl = 'callout:FacebookAPI/' +mediaId+'?phone_number_id='+PHONE_NUMBER_ID;
        HttpResponse response = makeMediaMessageAPICalls(strUrl, 'GET', '');
        if (response.getStatusCode() == 200) {
            GetMediaURLWrapper mediaURLWrapper = (GetMediaURLWrapper)JSON.deserialize(response.getBody(), GetMediaURLWrapper.class);
            if(String.isNotBlank(mediaURLWrapper.url)){                
                Integer attachmentIndex = mediaURLWrapper.url.indexOf('attachments');
                String docId = mediaURLWrapper.url.substring(attachmentIndex + 'attachments'.length());
                String downloadMediaUrl = 'callout:WhatsAppGetMedia' +docId;
                HttpResponse downloadUrlResponse = makeMediaMessageAPICalls(downloadMediaUrl, 'GET', '');
                if (downloadUrlResponse.getStatusCode() == 200 && String.isNotBlank(recordId)) {
                    blob mediaContent = downloadUrlResponse.getBodyAsBlob();
                    return C3WhatsappWebhookAPI.uploadFile(mediaContent, fileName, fileType,  recordId);
                }
            }
        }else{
            C3Utility.logError('API Error','', 546, response.getBody(),'C3WhatsAppWebService','getMediaFromAPI', request.getBody());
        }
        return '';
    }
    
    public static HttpResponse makeMediaMessageAPICalls(String url, String method, String body){
        C3Utility.getWhatsAppDetails();
        System.debug('url-- '+url);
        System.debug('method-- '+method);
        System.debug('body-- '+body);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setHeader('Accept' , 'application/json');
        request.setHeader('content-type', 'application/json');
        request.setMethod(method);
        if (String.isNotBlank(body)) {
            request.setBody(body);
        }
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        if (response.getStatusCode() != 200 && response.getStatusCode() != 201 ) {
            C3Utility.logError('API Error','', 568, response.getBody(),'C3WhatsAppWebService','makeMediaMessageAPICalls', request.getBody());
        }
        return response;
    }
    
    // Refresh Template
    public static String fetchTemplate() {
        C3Utility.getWhatsAppDetails();
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setEndpoint('callout:FacebookAPI/'+WABA_ID+'/message_templates?fields=name,status');
        request.setMethod('GET');        
        HttpResponse res = http.send(request);
        if (res.getStatusCode() == 200  || res.getStatusCode() == 201) {
            return res.getBody();
        }else{
            C3Utility.logError('API Error','', 590, res.getBody(),'C3WhatsAppWebService','fetchTemplate', request.getBody());
            return null;
        }
    } 
    
    public static boolean deleteTemplate(String name){
        C3Utility.getWhatsAppDetails();
        Http delhttp = new Http();
        HttpRequest delreq = new HttpRequest();
        HttpResponse delres = new HttpResponse();
        String apiUrl = 'callout:FacebookAPI/' +WABA_ID+'/message_templates'; 
        delreq.setEndpoint(apiUrl);
        delreq.setMethod('DELETE');
        delreq.setHeader('Content-Type', 'application/json');
        String jsonBody = '{"name":"' + name + '"}';
        delreq.setBody(jsonBody);
        
        delres = delhttp.send(delreq);
        if(delres.getStatusCode()==200 || delres.getStatusCode() == 201){
            return true;
        }
        else{
            C3Utility.logError('API Error','', 615, delres.getBody(),'C3WhatsAppWebService','deleteTemplate', delreq.getBody());
            return false;
        }
    }
    
    public class C3WhatsAppWebServiceWrapper {
        public String messaging_product;	    //whatsapp
        public String recipient_type;	    //individual
        public String to;	    //917905256379
        public String type;	    //template
        public template template;
    }
    
    public class CreateTemplateWrapper{
        public String category;
        public String language;
        public String name;
        public list<components> components;
    }
    
    public class template {
        public String name;	    //send_marketing
        public language language;
        public List<components> components;
    }
    
    public class language {
        public String code;	    //en
    }
    
    public class components {
        public String type;	    //body
        public List<parameters> parameters;
        public String text;
        public String format;
        public example example;
        public list<buttons> buttons;
    }
    
    public class MediaClass{
        public String link;
    }
    
    public class example{
        public List<List<String>> body_text;
        public List<String> header_handle;
    }
    
    public class buttons{
        public String text;
        public String type;
        public String phone_number;
        public String url;
    }
    
    public class parameters {
        public String type;	    //text
        public String text;	    //Amit
        public MediaClass image;
        public MediaClass document;
        public MediaClass video;
    }
    
    public class ResponseWrapper{
        public Error error;
        public String id;
        public String status;
        public String message;
        public String success;
        public Boolean isSuccess;
    }
    public class Error {
        public String message;	//Unsupported post request. Object with ID '108193625692105' does not exist, cannot be loaded due to missing permissions, or does not support this operation. Please read the Graph API documentation at https://developers.facebook.com/docs/graph-api
        public String type;	//GraphMethodException
        public Integer code;	//100
        public Integer error_subcode;	//33
        public String fbtrace_id;	//ALw3bzFT9VF9V_VoZxNN12D
        public String error_user_msg;	//ALw3bzFT9VF9V_VoZxNN12D
    }
    
    public class GetMediaURLWrapper{
        public String url;
        public String mime_type;
        public String sha256;
        public Integer file_size;
        public String id;
        public String messaging_product;
    }
}