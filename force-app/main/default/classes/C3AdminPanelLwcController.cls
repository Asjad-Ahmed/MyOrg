public with sharing class C3AdminPanelLwcController {
    
  
    @AuraEnabled
    public static WhatsApp_Admin__c initialize(){
        List<WhatsApp_Admin__c> listWAA = new List<WhatsApp_Admin__c>();
        if(!C3Utility.checkFieldPermission('WhatsApp_Admin__c','isAccessible',null,True) && !C3Utility.checkFieldPermission('WhatsApp_Admin__c','isAccessible',new List<String>{'NumberID__c', 'WabaId__c'},False)){
            throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
        }else{
            listWAA = WhatsApp_Admin__c.getall().values();
            system.debug('listWAA::::'+listWAA);
        }
        
        if(listWAA != null && listWAA.size()>0){
            return listWAA[0];
        }
        return null;
    }

    @AuraEnabled
    public static string saveAdminConfig(String jsonAdminConfig){
        if(String.isnotblank(jsonAdminConfig)){
            WhatsApp_Admin__c objAdminConfig = (WhatsApp_Admin__c)JSON.deserialize(jsonAdminConfig, WhatsApp_Admin__c.class);
            List<String> listFields = new List<String>{'NumberID__c', 'WabaId__c'};

            if(C3Utility.checkFieldPermission('WhatsApp_Admin__c', 'isAccessible', null, true) 
            && C3Utility.checkFieldPermission('WhatsApp_Admin__c', 'isAccessible', listFields, false)
            && C3Utility.checkFieldPermission('WhatsApp_Admin__c', 'isCreateable', null, true) 
            && C3Utility.checkFieldPermission('WhatsApp_Admin__c', 'isCreateable', listFields, false)
            && C3Utility.checkFieldPermission('WhatsApp_Admin__c', 'isUpdateable', null, true) 
            && C3Utility.checkFieldPermission('WhatsApp_Admin__c', 'isUpdateable', listFields, false)){
                Database.UPSERT(objAdminConfig, AccessLevel.SYSTEM_MODE);
            }else {
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }
            return objAdminConfig.Id;
        }
        return null;
    }



}