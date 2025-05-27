public with sharing class C3DeleteTemplateQueue implements Queueable, Database.AllowsCallouts {
    public Set<String> listTemplateNames;
    public C3DeleteTemplateQueue(Set<String> listTemplateNames) {
        this.listTemplateNames = listTemplateNames;
    }

    public void execute(QueueableContext context){
        if (this.listTemplateNames != null && this.listTemplateNames.size()>0) {
            for (String templateName : this.listTemplateNames) {
                C3WhatsAppWebService.deleteTemplate(templateName);
            }
        }
    }
}