public with sharing class C3TemplateTriggerHandler {
    public static void afterDelete(List<Template_Object__c> listTemplate){
        deleteTempateFromMeta(listTemplate);
    }

    public static void deleteTempateFromMeta(List<Template_Object__c> listTemplate){
        Set<string> setTemplateNames = new Set<string>();
        for (Template_Object__c objTemplate : listTemplate) {
            setTemplateNames.add(objTemplate.Name);
        }
        if (!setTemplateNames.isEmpty()) {
            system.enqueueJob(new C3DeleteTemplateQueue(setTemplateNames));
        }
    }
}