/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

//
trigger ContactTrigger on Contact (before insert, before update) {
    //System.TriggerOperation triggerEvent
    //Trigger.operationType
    ContactTriggerHandler.handleDuplicate(trigger.new);
    if(trigger.isBefore){
        
    }
    
    //ContactTriggerHandler.handleAfterTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.operationType);
}