public with sharing class C3WhatsAppSendTemplateBulkBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Set<String> setRecordIds;
    public String phoneField;
    public String query;
    Map<String, String> mapParamNumWithFieldName;
    Template_Object__c objTemplate;
    
	public C3WhatsAppSendTemplateBulkBatch(Set<String> setRecordIds, String query, Map<String, String> mapParamNumWithFieldName, Template_Object__c objTemplate, String phoneField){
        this.setRecordIds = new Set<String>();
        this.mapParamNumWithFieldName = new Map<String, String>();
        this.objTemplate = new Template_Object__c();
        this.objTemplate = objTemplate;
        this.mapParamNumWithFieldName = mapParamNumWithFieldName;
        this.setRecordIds = setRecordIds;
        this.query = query;
        this.phoneField = phoneField;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> lstSObject){
        if(lstSObject != null && lstSObject.size() > 0){
            C3WhatsAppWebService.createWebserviceBody(lstSObject, this.mapParamNumWithFieldName, this.objTemplate, this.phoneField );
        }
    }

    public void finish(Database.BatchableContext bc) {
        
    }
}