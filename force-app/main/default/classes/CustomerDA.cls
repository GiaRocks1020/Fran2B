public with sharing class CustomerDA {
	
    public static List<Customer__c> getCustomersByOwnershipGroupIds(Set<Id> OwnrGrpIds){
        return [
            SELECT id,Name, Ownership_Group__c,Contract__c,Contract__r.Effective_Contract_Flag__c, 
            Contract__r.Contract_ID__c,Start_Date__c,End_Date__c
            FROM Customer__c
            WHERE Ownership_Group__c in:OwnrGrpIds
        ];
    }
}