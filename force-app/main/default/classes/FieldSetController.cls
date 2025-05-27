public class FieldSetController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getFieldSet(String Account, String Account_Field_Set) {
        Schema.FieldSet fieldSetObj = Schema.getGlobalDescribe().get(Account).getDescribe().fieldSets.getMap().get(Account_Field_Set);
        List<Map<String, String>> fieldSetList = new List<Map<String, String>>();

        for(Schema.FieldSetMember fsm : fieldSetObj.getFields()) {
            Map<String, String> fieldDetails = new Map<String, String>();
            fieldDetails.put('label', fsm.getLabel());
            fieldDetails.put('fieldPath', fsm.getFieldPath());
            fieldSetList.add(fieldDetails);
        }

        return fieldSetList;
    }
}