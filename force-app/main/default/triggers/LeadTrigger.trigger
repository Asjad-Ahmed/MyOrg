trigger LeadTrigger on Lead (before insert, before update ) {
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        ContactTriggerHandler.handleCountry(trigger.new);
    }
	/*List<Datacloud.FindDuplicatesResult> results = Datacloud.FindDuplicates.findDuplicates(trigger.new);
        if(results != null && (!results.isEmpty())){
            Integer index = 0;
            String strBody = '';
            for (Datacloud.FindDuplicatesResult findDupeResult : results) {
                for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            system.debug('matchRecord---'+matchRecord);
                            strBody = trigger.new[0].LastName;
                            index++;
                        }
                    }
                }
            }
            Duplicate_Lead_Event__e duplicateLeadEvent = new Duplicate_Lead_Event__e(Email_Table_Body__c=strBody);
            Database.SaveResult sr = EventBus.publish(duplicateLeadEvent);
            // Inspect publishing result
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
                //System.enqueueJob(new SendDuplicateLeadEmailQueue(strBody));
                //EventBus.publish(sendDuplicateLeadEmail(strBody));
            }
        }*/
}