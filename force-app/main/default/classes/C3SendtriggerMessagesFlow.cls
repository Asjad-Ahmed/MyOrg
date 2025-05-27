global with sharing class C3SendtriggerMessagesFlow {


    @InvocableMethod(label='Send WhatsApp Template' category='WhatsApp')
    global static void sendTemplate(List<FlowInput> objFlowInput) {
        List<String> setRecordIds = new List<String>();
        for (FlowInput flowInput : objFlowInput) {
            setRecordIds.add(flowInput.recordId);
        }
        C3Utility.callSendTemplate(setRecordIds, objFlowInput[0].templateRecordId);
    }


    global class FlowInput {
        @InvocableVariable(label='List Record IDs')
        public String recordId;

        @InvocableVariable(label='Active Template Id') 
        public String templateRecordId;
    }
}