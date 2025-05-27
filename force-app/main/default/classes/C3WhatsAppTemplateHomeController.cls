public with sharing class C3WhatsAppTemplateHomeController {
    @AuraEnabled
    public static string WhatsAppTemplates(){
        try{
            TemplateWrapper Objwrap = new TemplateWrapper();
            list<Template_Object__c> ListOfTemplates = new list<Template_Object__c>();
            if(!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',new List<String>{'Id', 'name', 'Language_Code__c', 'Template_Message__c', 'Object__c', 'Category__c'  },true)){
                throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
            }else{
                ListOfTemplates = [SELECT id,name,status__c,Language_Code__c,Template_Message__c,Object__c,Category__c FROM Template_Object__c WITH SECURITY_ENFORCED LIMIT 49000];
            }
            
            if(ListOfTemplates.size()>0){
                Objwrap.success=true;
                Objwrap.ListOfTemplates=ListOfTemplates;
            }
            return json.serialize(Objwrap);
        }catch(exception ex){ C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','WhatsAppTemplateHomeController','WhatsAppTemplates',''); return null;
        }
    }


    @AuraEnabled
    public static string DeleteWhatsAppTemplates(string RecordId){
        try{
            TemplateWrapper Objwrap=new TemplateWrapper();
            if(string.isnotblank(RecordId) && RecordId!=null){
                list<Template_Object__c> DeleteTemp = new list<Template_Object__c>();
                if(!C3Utility.checkFieldPermission('Template_Object__c','isAccessible',new List<String>{'Id'},true)){
                    throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');
                }else{
                    DeleteTemp=[SELECT id FROM Template_Object__c WHERE id =:RecordId WITH SECURITY_ENFORCED];
                }
                
                if(!DeleteTemp.isempty()){
                    if(Template_Object__c.SObjectType.getDescribe().isAccessible() && Template_Object__c.SObjectType.getDescribe().isDeletable() ){
                        Database.Delete(DeleteTemp, AccessLevel.SYSTEM_MODE);
                    }else{ throw new AuraHandledException('User : Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.');  }
                } 
            }
            Objwrap=(TemplateWrapper)json.deserialize(WhatsAppTemplates(), TemplateWrapper.class);
            return json.serialize(Objwrap);
        }catch(exception ex){ C3Utility.logError(ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), '','WhatsAppTemplateHomeController','DeleteWhatsAppTemplates',''); return null; } 
    }
    public class TemplateWrapper{
        public boolean Success;        
        list<Template_Object__c> ListOfTemplates;
    }
    public class TemplateObject{
        public string Name;
        public string status;        
    }
}