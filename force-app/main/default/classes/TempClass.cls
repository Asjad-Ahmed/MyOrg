public class TempClass {
	public static void sendDuplicateLeadEmail(String strTableBody){
        system.debug('asd');
        List<OrgWideEmailAddress> listOWDAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'asjadahmed51@gmail.com'];
        List<String> setContactsEmail=new List<String>{'asjadahmed51@gmail.com'};
        Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
        objEmail.setOrgWideEmailAddressId(listOWDAddress.get(0).Id);
        objEmail.setToAddresses(setContactsEmail);
        objEmail.setSubject('Dupliacate Lead');
        String strEmailBody = 'StrBody Template';
        objEmail.setHtmlBody(strEmailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objEmail });
    }
}