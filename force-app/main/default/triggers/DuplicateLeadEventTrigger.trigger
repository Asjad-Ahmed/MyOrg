trigger DuplicateLeadEventTrigger on Duplicate_Lead_Event__e (after insert) {
    for(Duplicate_Lead_Event__e objEvent : trigger.new){
        TempClass.sendDuplicateLeadEmail(objEvent.Email_Table_Body__c);
        
    }
}