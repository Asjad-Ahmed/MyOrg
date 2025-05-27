public with sharing class skAccountHierarchyCmpController {
    @AuraEnabled(cacheable=true)
    public static list<Account> findAllHierarchyAccounts(string recordId){
        list<Account> allAccountList=new List<Account>();
        string ultimateAccountId;
        for(Account acc:[select id,Ultimate_Account_Id__c from Account where Id=:recordId]){
            ultimateAccountId=acc.Ultimate_Account_Id__c;
        }
        if(string.isNotBlank(ultimateAccountId)){
            for(Account acc:[select id,(select id from ChildAccounts),Name,ParentId,Type,Parent.Name,Industry 
            from Account where Ultimate_Account_Id__c=:ultimateAccountId order by parentId NULLS FIRST]){
                allAccountList.add(acc);
            }
        }
        system.debug('***allAccountList size:'+allAccountList);
        return allAccountList;
    }
}