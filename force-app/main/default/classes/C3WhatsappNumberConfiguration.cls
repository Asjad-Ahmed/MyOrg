public with sharing class C3WhatsappNumberConfiguration {
    public class WhatsappNumberConfigurationException extends Exception {}

    @AuraEnabled
    public static string initWhatsAppNumberConfiguration() {
        try{
            MainWrapper objMain = new MainWrapper();
            objMain.hasRecords = false;
            objMain.lstToNumberConfiguration = new List<WhatsApp_Number_Configuration__c>();
            objMain.objectPickList = new List<PickList>();
            Map<String, String> mapObjectNamewithLable = new Map<String, String>();
            Set<String> setOfObjectSaved = new Set<String>();
            if(!C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c','isAccessible',new List<String>{'Field_Name__c', 'Object_Name__c'},False)){
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }else{
                objMain.lstToNumberConfiguration = WhatsApp_Number_Configuration__c.getAll().values();
                
            }
            
            for(WhatsApp_Number_Configuration__c objCustToNumber : objMain.lstToNumberConfiguration){
                setOfObjectSaved.add(objCustToNumber.Object_Name__c);
                objMain.hasRecords = true;
                
            }

            List<String> listAllObjectNames = new List<String>();
            for(Schema.SObjectType strObjType : Schema.getGlobalDescribe().Values()){
                String name = strObjType.getDescribe().getName();
                String label = strObjType.getDescribe().getlabel();
                if(!setOfObjectSaved.contains(strObjType.getDescribe().getName()) && strObjType.getDescribe().isAccessible() && strObjType.getDescribe().isCreateable() && !strObjType.getDescribe().isCustomSetting() 
                && strObjType.getDescribe().isQueryable() && strObjType.getDescribe().isUpdateable() && !strObjType.getDescribe().getName().containsignorecase('history') && !strObjType.getDescribe().getName().containsignorecase('tag') && !strObjType.getDescribe().getName().containsignorecase('event') &&
                !strObjType.getDescribe().getName().containsignorecase('share') && !strObjType.getDescribe().getName().containsignorecase('feed')){      
                    mapObjectNamewithLable.put(name, label);
                   
                }
            }

            for(String objectName : mapObjectNamewithLable.keySet()){
                if(hasPhoneField(objectName)){
                    PickList objPickList = new PickList();
                    objPickList.label = mapObjectNamewithLable.get(objectName);
                    objPickList.value = objectName;
                    objMain.objectPickList.add(objPickList);
                }
            }
            return json.serialize(objMain);
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','WhatsappNumberConfiguration','initWhatsAppNumberConfiguration','');
            return null;
        }
    }
    
    @AuraEnabled
    public static string getObjectLabel(String objectName){
    try{
        if(String.isNotBlank(objectName)){
            SObjectType SObjectType = Schema.getGlobalDescribe().get(objectName);
            return SObjectType.getDescribe().getlabel();
        }
        return null;
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','WhatsappNumberConfiguration','getObjectLabel','');
            return null;
        }
    } 

    public static Boolean hasPhoneField(String sObjectName){
        SObjectType SObjectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String, Schema.SObjectField> objectFieldsMap = SObjectType.getDescribe().fields.getMap();
        for (Schema.SObjectField field : objectFieldsMap.values()) {
            Schema.DescribeFieldResult desribeResult = field.getDescribe();
            String fieldName = field.getDescribe().getLabel();
            String fieldAPIName = field.getDescribe().getName();
            String strType = String.valueOf(field.getDescribe().getType());
            
            if(field.getDescribe().isAccessible() && !(field.getDescribe().getName() == 'Id'))
            {
                switch on strType 
                {
                    when 'PHONE' {
                        return true;
                    }
                    when else {
                        
                    }
                }
            }
        }
        return false;
    }

    @AuraEnabled
    public static String getAllPhoneField(String sObjectName){
        try{
            List<PickList> listPickList = new List<PickList>();
            SObjectType SObjectType = Schema.getGlobalDescribe().get(sObjectName);
            Map<String, Schema.SObjectField> objectFieldsMap = SObjectType.getDescribe().fields.getMap();
            for (Schema.SObjectField field : objectFieldsMap.values()) {
                Schema.DescribeFieldResult desribeResult = field.getDescribe();
                String fieldName = field.getDescribe().getLabel();
                String fieldAPIName = field.getDescribe().getName();
                String strType = String.valueOf(field.getDescribe().getType());
                
                if(field.getDescribe().isAccessible() && !(field.getDescribe().getName() == 'Id'))
                {
                    switch on strType 
                    {
                        when 'PHONE' {
                            PickList objPickList = new PickList();
                            objPickList.label = fieldName;
                            objPickList.value = fieldAPIName;
                            listPickList.add(objPickList);
                        }
                        when else {
                            
                        }
                    }
                }
            }
            if (!listPickList.isEmpty()) {
                return json.serialize(listPickList);
            }
            return null;
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','WhatsappNumberConfiguration','getAllPhoneField','');
            return null;
        }
    }

    @AuraEnabled
    public static string saveWhatsAppNumberConfig(String jsonNumberConfig){
        System.debug(jsonNumberConfig);
        try{
            if(String.isnotblank(jsonNumberConfig)){
                WhatsApp_Number_Configuration__c objWhatsAppNumConfig = (WhatsApp_Number_Configuration__c)JSON.deserialize(jsonNumberConfig, WhatsApp_Number_Configuration__c.class);
                Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                Schema.DescribeSObjectResult objectDescribe = globalDescribe.get(objWhatsAppNumConfig.Object_Name__c).getDescribe();
                objWhatsAppNumConfig.Object_Label__c = objectDescribe.getLabel();
                System.debug(objWhatsAppNumConfig);
                List<String> listFields = new List<String>{'Field_Name__c', 'Object_Name__c'};
                if(C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c', 'isAccessible', null, true) 
                && C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c', 'isAccessible', listFields, false)
                && C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c', 'isCreateable', null, true) 
                && C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c', 'isCreateable', listFields, false)
                && C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c', 'isUpdateable', null, true) 
                && C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c', 'isUpdateable', listFields, false)){
                    Database.UPSERT(objWhatsAppNumConfig, AccessLevel.SYSTEM_MODE);
                }else {
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }
                return json.serialize(WhatsApp_Number_Configuration__c.getAll().values());
            }
            return null;
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','WhatsappNumberConfiguration','saveWhatsAppNumberConfig','');
            return null;
        }
    }

    @AuraEnabled
    public static string deleteWhatsAppNumberConfig(String jsonNumberConfig){
        if(String.isnotblank(jsonNumberConfig)){
            WhatsApp_Number_Configuration__c objWhatsAppNumConfig = (WhatsApp_Number_Configuration__c)JSON.deserialize(jsonNumberConfig, WhatsApp_Number_Configuration__c.class);
            if(C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c', 'isDeletable', null, true) 
            && C3Utility.checkFieldPermission('WhatsApp_Number_Configuration__c', 'isAccessible', null, true)){
                Database.Delete(objWhatsAppNumConfig, AccessLevel.SYSTEM_MODE);
            }else{
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }
            return json.serialize(WhatsApp_Number_Configuration__c.getAll().values());
        }
        return null;
    }

    public class MainWrapper{
        public boolean hasRecords;        
        public list<WhatsApp_Number_Configuration__c> lstToNumberConfiguration;
        public list<PickList> objectPickList;
    }

    public class PickList{
        public String label;
        public String value;
    }




    public class LWCWrapper{
        public string strMessage;
        public Boolean isSetUpCompleted;
        public boolean isSuccess;        
        public list<WhatsApp_Number_Configuration__c> lstToNumberConfiguration;
        public list<objectDetailWrapper> lstObjectDetailWrapper;
        public list<objectDetailWrapper> lstObjectCreatedMapping;
    }
    public class objectDetailWrapper{
        public string strObjectName;
        public string strObjectAPIName;
        public string strObject3DigitCode;
        public list<fieldDetailWrapper> lstFieldDetailWrapper;
    }
    
    public class fieldDetailWrapper{
        public string strLabel;
        public string strAPIName;
    }
}