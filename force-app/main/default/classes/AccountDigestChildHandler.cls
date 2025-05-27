/**
* @Description     : Handler for Account Digest Component
* *Test Class      : AccountDigestChildHandlerTest
* * Story          : GLAS-2823(Account_Digest)
* * Created Date   : 16-08-2023
* * Created By     : Kapil Kawrani
**/
public class AccountDigestChildHandler {
    
    
    @AuraEnabled
    public static WrapperList getImperativeTaskList(String objcName) {
        return genricList(objcName);
    }
    
    //Genric method to call from above methods for related object data-table(Params: Object Name, Days(Filter in combobox On UI), String if user clicked on view all button)
    public static WrapperList genricList(String objectName ){
        WrapperList wl = new WrapperList();
        List<DataTableColumns> lstDataColumns            = new List<DataTableColumns>();
        List<SObject> lstDataTableData                   = new List<SObject>();
        List<string> columnList                          = new List<string>();
        List<string> fieldAPINameList                    = new List<string>();
        Account_digest__mdt vm = [SELECT Label,Table_Heading__c,New_URL_Label__c,Fields_Name__c,Field_Name__c,Header_Value__c,URL_Fields__c
                                  FROM Account_digest__mdt WHERE Label =: objectName];
        if(vm.Header_Value__c != null)
        {
            columnList = vm.Header_Value__c.split(',');
        }
        
        if(vm.Field_Name__c != null)
        {
            fieldAPINameList = vm.Field_Name__c.split(',');
        }
        integer j =0;
        for(integer i = 0; i < columnList.size(); i++)
        {
            
            DataTableColumns datacolumns = new DataTableColumns();
            if(fieldAPINameList[i].contains(':url')){
                LabelWrapper lw = new LabelWrapper();
                lw.fieldName = 'newUrl' +j ;
                
                TypeAttributesWrapper vte = new TypeAttributesWrapper();
                vte.label = lw;
                vte.target = '_blank';
                
                datacolumns.label= columnList[i].trim();
                datacolumns.fieldName = fieldAPINameList[i].substringBefore(':url').trim();
                datacolumns.type = 'url';
                datacolumns.typeAttributes =vte;                                 
                
                lstDataColumns.add(datacolumns);
                j++;
            }
            else{
                datacolumns.label= columnList[i].trim();
                datacolumns.fieldName = fieldAPINameList[i].substringBefore(':').trim();
                datacolumns.type = fieldAPINameList[i].substringAfter(':').trim();
                lstDataColumns.add(datacolumns);
                
            }
        }
        wl.accDigest =vm;
        wl.lstDataTableColumns = lstDataColumns;
        Set<Id> accountIds = new Set<Id>();
        
        
            string countQuery = 'Select Count() from '+vm.Label;
            string query = 'Select  '+vm.Fields_Name__c+',isChild from '+vm.Label+ ' where isChild=false ';
            system.debug(query);
           	wl.recordCount = Database.countQuery(countQuery);
                
          
           
           
                wl.objList = Database.query(query);
             system.debug(wl.objList);
                //======================================================================================================
                // we need to do modification here by checking if the sobject is "Event" then we will need to add SOQL query on eventRelation.
                // we need to add a map<Id,List< EventRelation>> in the returning wrapper which will be null on other sobject cases but on Event case it will be populated with EventId as a key and List<String> which will be attendies names as a value.
                // We also need to create a map of attendee Id and Attende record like for contact Map<Id,Contact> , Map<Id, Lead> or Map<Id,User> , lead or user id and associated record.
                if(vm.Label == 'Event'){
                    set<String> eventIds = new Set<String>();
                    for(Sobject objSobj : wl.objList)
                        eventIds.add((String)objSobj.get('Id'));
                    //populate your map here as EventId as key and List<String> attendies name as value by executing selective SOQL on EventRelation with EventId and iterating over that list and getting the names of the attendies.

                    // Get the list of attenddess from map of map<Id,List< EventRelation>> and once, the list of event relation received.
                    //then use the Contact Map or Lead Map or User Map to get the name of the Contact, Or lead or user to put into List of List<String> as an attendee list.
                    Map<Id, List<String>> mapEventIdListAttendies = new  Map<Id, List<String>>();
                    for(EventRelation obj : [SELECT Id, EventId, Relation.Name FROM EventRelation WHERE EventId IN: eventIds]){
                        if(!mapEventIdListAttendies.containsKey(obj.EventId)){
                            mapEventIdListAttendies.put(obj.EventId, new List<String>());
                        }
                        mapEventIdListAttendies.get(obj.EventId).add(obj.Relation.Name);
                    }
                    if(mapEventIdListAttendies != null && (!mapEventIdListAttendies.isEmpty()) ){
                        wl.mapEventIdListAttendies = json.serialize(mapEventIdListAttendies);
                    }
                    system.debug(wl.mapEventIdListAttendies);


                }
            
        
        return wl;
    }
    
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public TypeAttributesWrapper typeAttributes {get;set;}
        
        public DataTableColumns()
        {
            label     = '';
            fieldName = '';
            type      = '';  
            typeAttributes =  new TypeAttributesWrapper();
        }
    } 
    
    public class TypeAttributesWrapper{
        
        @AuraEnabled public LabelWrapper label;
        @AuraEnabled public String target;
        public TypeAttributesWrapper(){
            label = new LabelWrapper();
            target = '';
        } 
    }
    public class LabelWrapper{
        @AuraEnabled
        public String fieldName {get;set;}
        public LabelWrapper(){
            fieldName =''; 
        }  
    }

    //add map variable in the wrapper
    public class WrapperList {
        @AuraEnabled public List<DataTableColumns> lstDataTableColumns {get;set;}  
        @AuraEnabled  public List<sObject> objList;
        @AuraEnabled  public Account_Digest__mdt accDigest;
        @AuraEnabled  public Integer recordCount;
        
        @AuraEnabled  public String mapEventIdListAttendies;
        public WrapperList(){
            objList = new  List<sObject>();
            accDigest = new Account_Digest__mdt();
            recordCount = 0;
            mapEventIdListAttendies = null;
        }
    }
    public class WrapperTreeGridList {
        @AuraEnabled  public List<Opportunity> objList;
        @AuraEnabled  public Integer recordCount;
        public WrapperTreeGridList(){
            objList = new  List<Opportunity>();
            recordCount = 0;
        }
    }
    
}