public class AccountTriggerHandler {
    public static void beforeInsert(List<Account> triggerNew){
        validateAccounts(triggerNew);
    }
    
    public static void beforeUpdate(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
        validateAccounts(triggerNew);
    }
    
    
    public static void validateAccounts(List<Account> triggerNew){
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        for(Account objAcc: triggerNew){
            if(objAcc.Id != null && objAcc.Type == 'Technology Partner'){
                
                mapAccount.put(objAcc.Id, objAcc);
            }
        }
        
        for(Account objAccount : [SELECT Id, Type, (SELECT Id FROM Contacts) FROM Account WHERE Id IN: mapAccount.keySet()]){
            if(objAccount.contacts != null && objAccount.contacts.size()>0 ){
                
            }else{
                mapAccount.get(objAccount.Id).addError('Account has no Contact');
                //objAccount.addError('Account has no Contact');
            }
        }
    }

    
}