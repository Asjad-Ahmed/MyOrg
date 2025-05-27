public class OpportunityHandler {
    
	/* It will take collection of OpprtunityIds as a parameter and then it will clone the respected Opportunity and its Lineitems, then it will create a new renewal Opportunity with same lineItems as original Opportunity
         * @params Set of OpportunityIds
         * @returns void
	 */
    public static void createRenewalOppty(Set<Id> lstOppId)
    {
        String fieldsNames = '';
        List<String> listFieldName = new List<String>(Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().keySet());
        fieldsNames = String.join(listFieldName, ',');
        System.debug(fieldsNames);
        List<Opportunity> lstOpp = Database.query('SELECT ' + fieldsNames + ' FROM Opportunity Where id IN: lstOppId');
        System.debug(lstOpp);

        if(lstOpp.size()>0)
        {
            map<Id, List<OpportunityLineItem>> OppLImap = new map<Id, List<OpportunityLineItem>>();
            for (OpportunityLineItem OppLI : [SELECT Id, OpportunityId, Product2Id, Quantity, ListPrice, UnitPrice, Description FROM OpportunityLineItem WHERE OpportunityId IN: lstOppId]) 
            {
                if(!OppLImap.containskey(OppLI.OpportunityId)) 
                {
                    OppLImap.put(OppLI.OpportunityId, new list<OpportunityLineItem>());
                }
                OppLImap.get(OppLI.OpportunityId).add(OppLI);
            }
            System.debug('OppLImap==='+OppLImap);
            
            
            List<MainWrapper> lstWrapperObj = new List<MainWrapper>();
            
            for (Opportunity oppty : lstOpp) 
            {
                Opportunity tempOpp = oppty.Clone();
                tempOpp.Name = 'Renewal '+tempOpp.Name;
    
                MainWrapper wrapperObj = new MainWrapper();
                wrapperObj.Oppty = new Opportunity();
                wrapperObj.Oppty = tempOpp;
                if(OppLImap.containskey(oppty.Id))
                {
                    wrapperObj.oppLineItems = new List<OpportunityLineItem>(OppLImap.get(oppty.Id));
                }
                lstWrapperObj.add(wrapperObj);
            }
            System.debug('lstWrapperobj====='+lstWrapperObj.size()+'   -   '+lstWrapperObj);
            System.debug('lstWrapperObj[0].oppLineItems====='+lstWrapperObj[0].oppLineItems);
            System.debug('lstWrapperObj[1].oppLineItems====='+lstWrapperObj[1].oppLineItems);
            System.debug('lstWrapperObj[2].oppLineItems====='+lstWrapperObj[2].oppLineItems);
            
            if(lstWrapperObj.size()>0)
            {
                
                List<Opportunity> lstOfOpp = new List<Opportunity>();
                List<OpportunityLineItem> lstOfOppLI = new List<OpportunityLineItem>();

                for (MainWrapper obj : lstWrapperObj) 
                {
                    lstOfOpp.add(obj.Oppty);
                }
                system.debug('lstOfOpp====='+ lstOfOpp.size()+'---'+lstOfOpp);
                if(lstOfOpp.size()>0)
                {
                    insert lstOfOpp;
                    System.debug('After Insert---'+lstOfOpp.size() + '    '+lstOfOpp);
                    for (Integer i = 0; i < lstOfOpp.size(); i++) 
                    {
                        System.debug('EACHoppLineItems---'+ lstWrapperObj[i].oppLineItems);
                        System.debug((lstWrapperObj[i].oppLineItems != null && lstWrapperObj[i].oppLineItems.size()>0));
                        if (lstWrapperObj[i].oppLineItems != null && lstWrapperObj[i].oppLineItems.size()>0) 
                        {
                            for (OpportunityLineItem OpptyLI : lstWrapperObj[i].oppLineItems) 
                            {
                                OpportunityLineItem tempOppLI = OpptyLI.Clone();
                                tempOppLI.OpportunityId = lstOfOpp[i].Id;
                                lstOfOppLI.add(tempOppLI);
                            }
                        }
                    }
                    System.debug('lstOfOppLI======'+lstOfOppLI.size()+ '  -  '+lstOfOppLI);
                    if(lstOfOppLI.size()>0)
                    {
                        insert lstOfOppLI;
                    }
                }
            }
        }
    }

    public class MainWrapper
    {
        public Opportunity Oppty ;
        public List<OpportunityLineItem> oppLineItems;
    }
}