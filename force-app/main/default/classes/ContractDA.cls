public with sharing class ContractDA {
    public static List<Contract__c> getContractsByIds(Set<Id> contrIds){
        return [
            SELECT id,Name,Contract_ID__c,AD__c,Application_Type__c,Billable_Rooms__c,Contract_Status__c,Effective_Contract_Flag__c,
            Legal_Sec_Name__c,Next_Out_Date__c 
            FROM Contract__c
            WHERE id in:contrIds
        ];
    }
}