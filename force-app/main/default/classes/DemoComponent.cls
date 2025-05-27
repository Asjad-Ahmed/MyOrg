public class DemoComponent {
    
    @AuraEnabled
    public static String createOpp_Con_Acc(String jsStringObj){
        JSWrapper obj = (JSWrapper)JSON.deserialize(jsStringObj, JSWrapper.class);
        Account acc = new Account();

        Opportunity opp = new Opportunity();
        opp.Name = obj.opptyName;
        opp.StageName = obj.stage;
        opp.CloseDate = Date.valueOf(obj.closeDate);

        Contact con = new Contact();

        System.debug('obj'+obj);
        try {
            if (obj.isBusinessLead == false) {
                String personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
                acc.FirstName = obj.fName;
                acc.LastName = obj.lName;
                acc.recordtypeId = personRecordTypeId;

                insert acc;

                opp.AccountId = acc.Id;
                
            }else{

                acc.Name = obj.accountName;
                insert acc; 

                opp.AccountId = acc.Id;

                con.FirstName = obj.contactFname;
                con.LastName = obj.contactLname;
                con.AccountId = acc.Id;

                insert con;
            }
            insert opp;

        } catch (Exception e) {
            System.debug('Message++'+e.getMessage());
            System.debug('line++'+e.getLineNumber());
            System.debug('cause++'+e.getCause());
            throw new AuraHandledException(e.getMessage());
        }
        return 'Successfully created the records';
    }

    class JSWrapper{
        public String accountName;
        public Boolean isBusinessLead;
        public String contactFname;
        public String contactLname;
        public String fName;
        public String lName;
        public String opptyName;
        public String stage;
        public String closeDate;
    }
}