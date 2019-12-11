public class ContractTrigger_Handler {
    
    Public Static void updateProperty(List<Contract__c> lstContract){
        Set<Id> setPropertyIds = new Set<Id>(); //this set will store all the property id related to current Contract
        for (Contract__c itemNew : lstContract ) {
            if(itemNew.Effective_Contract_Flag__c)
                setPropertyIds.add(itemNew.Property__c); // we will store property id if the Contract Effective Contract flag is true
        }
        if(setPropertyIds.size() > 0){
            // Below query will fetch all old contract related to current Property and set all record effective contract flag to false
            List<Contract__c> lstTObeUpdated = [SELECT id, Effective_Contract_Flag__c FROM Contract__c WHERE 
                                                id Not IN: trigger.newMap.keySet() AND Property__c IN:setPropertyIds];
            for(Contract__c contract : lstTObeUpdated){                
                contract.Effective_Contract_Flag__c = false;
            }
            
            if(!lstTObeUpdated.isEmpty()){
                try{
                    update lstTObeUpdated;
                }catch(DMLException e) {
                    System.debug(e);   
                }
                
            }
        }
    }
    
}