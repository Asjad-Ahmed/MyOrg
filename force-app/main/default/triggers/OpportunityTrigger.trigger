trigger OpportunityTrigger on Opportunity (before insert) {
    try{
        for(Opportunity obj : trigger.new){
        
    	}
    }catch(exception e){
        system.debug(e.getMessage());
    }
    
}