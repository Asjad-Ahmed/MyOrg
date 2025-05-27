/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ContactTriggerHandler {
    
    public static void handleAfterTrigger(List<Contact> triggerNew, List<Contact> triggerOld, Map <Id,Contact> triggerNewMap, Map <Id,Contact> triggerOldMap, System.TriggerOperation triggerEvent)
    {
        Map<Id, List<Contact>> AccId_ConMap = new Map<Id, List<Contact>>();
        List<Contact> conList = new List<Contact>();
        set<Id> accIds = new set<Id>();
        set<Id> activeConIds = new set<Id>();
        set<Id> activeConAccIds = new set<Id>();
        set<Id> inActiveConAccIds = new set<Id>();
        set<Id> inActiveConIds = new set<Id>();

        List<Contact> lstInActiveContact = new List<Contact>();
        for (Contact con : triggerNew) 
        {
            accIds.add(con.AccountId);
            if(con.Active_Contact__c == true)
            {
                activeConIds.add(con.Id);
                activeConAccIds.add(con.AccountId);
            }
            else{
                inActiveConIds.add(con.Id);
                inActiveConAccIds.add(con.AccountId);
            }
        }
        system.debug(inActiveConAccIds  +  ' ------'+inActiveConIds);
        conList = [SELECT Id, Active_Contact__c, AccountId FROM Contact WHERE AccountId IN: accIds];
        for (Contact con : conList) 
        {
            if(!AccId_ConMap.containsKey(con.AccountId))
            {
                AccId_ConMap.put(con.AccountId, new List<Contact>());
            }
            AccId_ConMap.get(con.AccountId).add(con);
        }

        System.debug('AccId_ConMap---'+AccId_ConMap);
        switch on triggerEvent 
        {
            when AFTER_INSERT
            {
                for(Contact con : [SELECT Id, Active_Contact__c, AccountId FROM Contact WHERE AccountId IN: activeConAccIds])
                {   
                    if(con.Active_Contact__c == true)
                    {
                        con.Active_Contact__c = false;
                        lstInActiveContact.add(con);
                    }
                }
                if(inActiveConAccIds != null && inActiveConAccIds.size()>0)
                {
                    for(Account acc : [SELECT Id ,(SELECT Id, Active_Contact__c FROM Contacts) FROM Account WHERE Id IN: inActiveConAccIds])
                    {
                        contact inact = new contact();
                        Boolean hasActiveContact = false;
                        for(Contact con : acc.Contacts)
                        {system.debug('Active_Contact__c-------'+con.Active_Contact__c);
                            if(con.Active_Contact__c == true)
                            {
                                hasActiveContact = true;
                            }else{
                                if(triggerNewMap.get(con.Id) !=null)
                                {
                                    inact = triggerNewMap.get(con.Id); 
                                }
                            }
                        }
                        system.debug('hasActiveContact-------'+hasActiveContact);
                        if(hasActiveContact == false)
                        {
                            system.debug('hasActiveContact-------'+hasActiveContact);
                            inact.addError('No Active Contact!!!!');
                        }
                    }
                }
            }
            when AFTER_UPDATE
            {
                
            }
        }
    }
    
    public static void handleCountry(List<SObject> triggerNew){
       // List<SObject> listSObject = new List<SObject>();
        
        for(SObject objSobject : triggerNew){
            if(String.isNotBlank(  (String)objSobject.get('MobilePhone')  )){
                String strPhone = (String)objSobject.get('MobilePhone');
                system.debug('strPhone --- '+strPhone);
                if(strPhone.startsWith('91')){
                    objSobject.put('Country__c', 'India');
                }
            }
        }
    }
    
    public static void handleDuplicate(List<Contact> triggerNew){
       // List<SObject> listSObject = new List<SObject>();
		Set<String> setDuplicateChecks = new Set<String>();
        for(Contact objContact : [SELECT Id , Email, MobilePhone FROM Contact LIMIT 50000]){
            if(String.isNotBlank(objContact.Email))
            	setDuplicateChecks.add(objContact.Email);
            if(String.isNotBlank(objContact.MobilePhone))
            	setDuplicateChecks.add(objContact.MobilePhone);
        }
        
        system.debug('setDuplicateChecks -- '+setDuplicateChecks);
        
        
        for(Contact objContact : triggerNew){
            system.debug(objContact.MobilePhone);
            if(String.isNotBlank(objContact.Email) || String.isNotBlank(objContact.MobilePhone)){
                if(setDuplicateChecks.contains(objContact.Email) || setDuplicateChecks.contains(objContact.MobilePhone))
                    objContact.addError('Duplicate Contact!');
            }   	
        }
    }
}