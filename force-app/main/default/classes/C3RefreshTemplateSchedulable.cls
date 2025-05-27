global with sharing class C3RefreshTemplateSchedulable implements Schedulable, Database.AllowsCallouts {
    
    global void execute(SchedulableContext SC){
        scheduleRefreshTemplate();
    }

    global void scheduleRefreshTemplate(){
        try{
            Map<String, Template_Object__c> mapWhatsAppTemplateId = new Map<String, Template_Object__c>();
            List<Template_Object__c> listTemplate = new List<Template_Object__c>();
            String responseBody = C3WhatsAppWebService.fetchTemplate();
            system.debug('responseBody::::'+responseBody);

            if (String.isNotBlank(responseBody)) { 
                if((!C3Utility.CheckFieldPermission('Template_Object__c','isAccessible', null, false)) &&
                (!C3Utility.CheckFieldPermission('Template_Object__c', 'isAccessible', new List<String>{'Id', 'TemplateID__c', 'Status__c' }, false)  )){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else {
                    List<Template_Object__c> listOfTemplate = new List<Template_Object__c>([SELECT Id, TemplateID__c FROM Template_Object__c LIMIT 49000]);
                    for (Template_Object__c obj : listOfTemplate) {
                        if (String.isNotBlank(obj.TemplateID__c))
                            mapWhatsAppTemplateId.put(obj.TemplateID__c, obj);
                    }
                }
                
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                List<Object> templateJsonList = (List<Object>) responseMap.get('data');

                for (Object templateJson : templateJsonList) {
                    Map<String, Object> templateMap = (Map<String, Object>) templateJson;
                    String whatsAppId = (String) templateMap.get('id');
                    if (mapWhatsAppTemplateId.containsKey(whatsAppId)) {
                        Template_Object__c objTemplate = mapWhatsAppTemplateId.get(whatsAppId);
                        objTemplate.Status__c = (String) templateMap.get('status');
                        objTemplate.Name = (String) templateMap.get('name');
                        objTemplate.TemplateID__c = whatsAppId;
                        listTemplate.add(objTemplate);
                    }
                }
                System.debug('listTemplate--'+listTemplate);
                if (!listTemplate.isEmpty()) {
                    if((!C3Utility.CheckFieldPermission('Template_Object__c', 'isAccessible', null, false) && !C3Utility.CheckFieldPermission('Template_Object__c', 'isAccessible', new List<String>{'Id', 'Name', 'TemplateID__c', 'Status__c' }, false)) && (!C3Utility.CheckFieldPermission('Template_Object__c', 'isCreateable', null, false)  && !C3Utility.CheckFieldPermission('Template_Object__c', 'isCreateable', new List<String>{'Id', 'Name', 'TemplateID__c', 'Status__c' }, false)) && (!C3Utility.CheckFieldPermission('Template_Object__c', 'isUpdateable', null, false)  && !C3Utility.CheckFieldPermission('Template_Object__c', 'isUpdateable', new List<String>{'Id', 'Name', 'TemplateID__c', 'Status__c' }, false))){
                        throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                    }else{
                        Database.UPDATE(listTemplate,AccessLevel.User_mode);
                    }
                }
            }
        }catch(exception ex){
            C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','RefreshTemplateSchedulable','execute','');
           
        }
    }
}