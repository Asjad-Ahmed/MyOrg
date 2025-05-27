public with sharing class C3WhatsAppUtilityBarCtrl {
    public class WhatsAppException extends Exception {}

    public static List<String> colorList = new List<String>{'#2BA9B9', '#2ECC40', '#E08B1E', '#FF5733', '#6A0572', '#AB83A1', '#0074D9', '#FFDC00', '#2ECC40', '#FF4136', '#F012BE', '#FF851B', '#7FDBFF', '#B10DC9', '#01FF70', '#FFD700', '#00FF00', '#FF1493', '#001F3F', '#85144B', '#F1EDEC', '#7FFF00', '#B22222', '#FF8C00', '#4169E1', '#8A2BE2', '#A52A2A', '#32CD32', '#FFD700', '#9932CC', '#00FFFF', '#4B0082', '#FF6347', '#40E0D0', '#9370DB', '#808000', '#00FA9A', '#8B008B', '#800000', '#ADFF2F', '#20B2AA', '#8B4513', '#00BFFF', '#DC143C', '#6B8E23', '#FF00FF', '#00FF7F', '#8B0000', '#228B22', '#4682B4', '#D2B48C', '#556B2F', '#8B4513', '#2F4F4F', '#87CEEB', '#8B0000', '#8B4513', '#8B4513', '#008080', '#8B4513', '#8B4513', '#556B2F', '#8B4513', '#2BA9B9', '#48844B00','#E08B1E', '#FF5733', '#6A0572', '#AB83A1', '#0074D9', '#FFDC00', '#2ECC40', '#FF4136', '#F012BE', '#FF851B', '#7FDBFF', '#B10DC9', '#01FF70', '#FFD700', '#00FF00', '#FF1493', '#001F3F', '#85144B', '#F1EDEC', '#7FFF00', '#B22222', '#FF8C00', '#4169E1', '#8A2BE2', '#A52A2A', '#32CD32', '#FFD700', '#9932CC', '#00FFFF', '#4B0082', '#FF6347', '#40E0D0', '#9370DB', '#808000', '#00FA9A', '#8B008B', '#800000', '#ADFF2F', '#20B2AA', '#8B4513', '#00BFFF', '#DC143C', '#6B8E23', '#FF00FF', '#00FF7F', '#8B0000', '#228B22', '#4682B4', '#D2B48C', '#556B2F', '#8B4513', '#2F4F4F', '#87CEEB', '#8B0000', '#8B4513', '#8B4513', '#008080', '#8B4513', '#8B4513', '#556B2F', '#8B4513'};
    
    @AuraEnabled
    public static String AllConversationMessages() 
    { 
        try{
            for (Integer i = 0; i < colorList.size(); i++) {
                colorList[i] = 'background:' + colorList[i];
            }
                MainWrapper wrapM=new MainWrapper();
                Integer totalUnreadCount=0;
                wrapM.currentUserId=userInfo.getUserId();
                wrapM.organizationId=UserInfo.getOrganizationId();
                List<WrapperMessage> WrapperMessageList=new List<WrapperMessage>();
                Map<String, List<whatsApp_conversation__b>> mapRecordIdWhatsAppConvo =new Map<String, List<whatsApp_conversation__b>>();
                List<whatsApp_conversation__b> MessagesList = new List<whatsApp_conversation__b>();
                        Map<String, whatsApp_conversation__b> textMessageMap=new Map<String, whatsApp_conversation__b>();
                        String query='select id, From_Phone__c, Message__c , Read__c ,Message_formatted__c ,To_Phone__c,createdById,'+
                            'Record_ID__c,createdDate'+
                            ' FROM whatsApp_conversation__b limit 50000';
                    
                        List<String> FieldsToQuery = new List<String>{'id', 'From_Phone__c', 'Message__c', 'Read__c', 'Message_formatted__c', 'To_Phone__c', 'createdById', 'Record_ID__c', 'createdDate' };
                        if((!C3Utility.checkFieldPermission('whatsApp_conversation__b','isAccessible',null,true)) && (!C3Utility.checkFieldPermission('whatsApp_conversation__b','isAccessible',FieldsToQuery,false))){
                            throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                        }else{
                            MessagesList = Database.Query(String.escapeSingleQuotes(query), AccessLevel.SYSTEM_MODE);
                        }
                        
                        if(test.isRunningTest()){
                            
                            MessagesList.add(C3TestDataFactory.buildConvoRecord(null, '919911410564', [SELECT Id FROM Template_Object__c LIMIT 1].Id, 'asdasdasd'));
                        }
                        if(!MessagesList.isEmpty())
                        {
                            Map<String, List<String>> RecordIdsPrefix =new Map<String, List<String>>();
                            Map<String, Integer> recordTotalUnreadMsgMap=new Map<String, Integer>();

                            
                            
                            for(whatsApp_conversation__b msg:MessagesList)
                            {
                                if(String.isNotBlank(msg.Record_ID__c))
                                {
                                    //prepare map of records by object to make 1 query each
                                    if(!RecordIdsPrefix.containsKey(String.valueOf(msg.Record_ID__c).substring(0,3)))
                                    {
                                        RecordIdsPrefix.put(String.valueOf(msg.Record_ID__c).substring(0,3), new List<String>());
                                    }
                                    RecordIdsPrefix.get(String.valueOf(msg.Record_ID__c).substring(0,3)).add(msg.Record_ID__c);
                                    
                                    //Unread message count
                                    if(msg.Read__c=='false')
                                    {
                                        if(!recordTotalUnreadMsgMap.containsKey(msg.Record_ID__c))
                                        {
                                            recordTotalUnreadMsgMap.put(msg.Record_ID__c, 1);
                                        }else{
                                            recordTotalUnreadMsgMap.put(msg.Record_ID__c, (recordTotalUnreadMsgMap.get(msg.Record_ID__c))+1);
                                        }
                                    }
                                }
                                
                            }
                            Map<String, C3Utility.ValidRecordWrapper> validatedRecordIds= C3Utility.validateRecordIds(RecordIdsPrefix);
                            
                            Integer maxConversations = 100;
                            Integer countRecords=0;
                            for(whatsApp_conversation__b msg : MessagesList)
                            {
                                if (!mapRecordIdWhatsAppConvo.containsKey(msg.Record_ID__c)) {
                                    mapRecordIdWhatsAppConvo.put(msg.Record_ID__c, new List<whatsApp_conversation__b>());
                                }
                                mapRecordIdWhatsAppConvo.get(msg.Record_ID__c).add(msg);
                            }
                            for (String key : mapRecordIdWhatsAppConvo.keySet()) {
                                List<whatsApp_conversation__b> lstMegs = mapRecordIdWhatsAppConvo.get(key);
                                List<whatsApp_conversation__b> lstMegsSorted = new List<whatsApp_conversation__b>();
                                for (Integer i = mapRecordIdWhatsAppConvo.get(key).size(); i > 0; --i) {
                                    lstMegsSorted.add(lstMegs[i-1]);
                                }
                                mapRecordIdWhatsAppConvo.put(key, lstMegsSorted);
                            }
                            integer colorIndex = 0;
                            for(whatsApp_conversation__b msg : MessagesList)
                            {
                                if(countRecords< maxConversations &&String.isNotBlank(msg.Record_ID__c) && validatedRecordIds.containsKey(msg.Record_ID__c) 
                                    && !textMessageMap.containsKey(msg.Record_ID__c))
                                {
                                    textMessageMap.put(msg.Record_ID__c, msg);
                                    
                                    String objectLabel='';
                                    objectLabel=validatedRecordIds.get(msg.Record_ID__c).objectLabel;
                                    
                                    WrapperMessage wrap=new WrapperMessage();
                                    wrap.colorCode = colorList[colorIndex];
                                    wrap.recordId=msg.Record_ID__c;
                                    wrap.objectApiName=validatedRecordIds.get(msg.Record_ID__c).objectApiName;
                                    wrap.lastText = '';
                                    wrap.createdDate = mapRecordIdWhatsAppConvo.get(msg.Record_ID__c)[0].CreatedDate;
                                    if (mapRecordIdWhatsAppConvo.containsKey(msg.Record_ID__c) && mapRecordIdWhatsAppConvo.get(msg.Record_ID__c)[0].Message__c != null ) {
                                        wrap.lastText = mapRecordIdWhatsAppConvo.get(msg.Record_ID__c)[0].Message_formatted__c;
                                        system.debug('wrap.lastText'+wrap.lastText);
                                    }
                                    wrap.isRead =  mapRecordIdWhatsAppConvo.get(msg.Record_ID__c)[0].read__c;
                                    
                                    if(wrap.isRead=='true'){
                                    wrap.BooleanIsRead=true; 
                                    }
                                    else{
                                    wrap.BooleanIsRead=false;
                                    }
                                    
                                    if(msg.Read__c=='false')
                                    {
                                        wrapM.boolUnreadMsgAvailable = true;
                                    }
                                
                                    
                                    if(String.isNotBlank(validatedRecordIds.get(msg.Record_ID__c).recordName))
                                    {
                                        wrap.senderNameSmall = C3Utility.getNameDetails(validatedRecordIds.get(msg.Record_ID__c).recordName).get('senderNameSmall');
                                        wrap.senderName = C3Utility.getNameDetails(validatedRecordIds.get(msg.Record_ID__c).recordName).get('senderName')+' ('+objectLabel+')';
                                    }
                                    wrap.unreadCount=0;
                                    if(recordTotalUnreadMsgMap.containsKey(msg.Record_ID__c))
                                    {
                                        wrap.unreadCount=recordTotalUnreadMsgMap.get(msg.Record_ID__c);
                                    }
                                    totalUnreadCount+=wrap.unreadCount;
                                    
                                    WrapperMessageList.add(wrap);
                                    countRecords++;
                                    colorIndex++;
                                }
                            }

                        }
            system.debug('WrapperMessageList '+WrapperMessageList);
            if(WrapperMessageList != null && WrapperMessageList.size() > 0) {
            for(Integer i=0; i<WrapperMessageList.size(); i++) {
                for(Integer j=i+1; j<WrapperMessageList.size(); j++) {
                    if(WrapperMessageList[i].createdDate < WrapperMessageList[j].createdDate) {
                        WrapperMessage temp = WrapperMessageList[i];
                        WrapperMessageList[i] = WrapperMessageList[j];
                        WrapperMessageList[j] = temp;
                    }
                }
            }
            }
            list<WrapperMessage> unreadMessages = new list<WrapperMessage>();
            list<WrapperMessage> readMessages = new list<WrapperMessage>();
            for(WrapperMessage wrp : WrapperMessageList){
                if(wrp.unreadCount!=0){
                    unreadMessages.add(wrp);
                }
                else{
                    readMessages.add(wrp);
                }
            }
            wrapM.WrapperMessageList = unreadMessages;
            wrapM.WrapperMessageList.addall(readMessages);
                //wrapM.WrapperMessageList=WrapperMessageList;
            system.debug('WrapperMessageListsorted '+wrapM.WrapperMessageList);

                wrapM.totalUnreadCount=totalUnreadCount;

            return json.serialize(wrapM);
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','UtilityBarClass','AllConversationMessages','');
            return null;
        } 
    }
    
    public class MainWrapper{
        public string currentUserId;
        public string organizationId;
        public string strMsg;
        List<WrapperMessage> WrapperMessageList;
        public boolean boolUnreadMsgAvailable;

        public Integer totalUnreadCount=0;
    }
    public class WrapperMessage {
        public string recordId;
        public string objectApiName;
        public string senderNameSmall;
        public string senderName;
        public string lastText;
        public string isRead;
        public string colorCode;
        public Integer unreadCount=0;
        public boolean BooleanIsRead;
        public datetime createdDate;
    }
}