trigger AccountTrigger on Account (before insert, before update ) {

    AccountTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
}