public without sharing class C3CreateWhatsAppConversationQueue implements Queueable, Database.AllowsCallouts{
    public WhatsApp_Conversation__b objfilteredMessages;
    public C3CreateWhatsAppConversationQueue(WhatsApp_Conversation__b objfilteredMessages) {
        this.objfilteredMessages = new WhatsApp_Conversation__b();
        this.objfilteredMessages = objfilteredMessages;
    }

    public void execute(QueueableContext context) {
        if(!test.isRunningTest()){
            Database.insertImmediate(this.objfilteredMessages);  
        }
        
    }
}