public with sharing class ApproverDA {
	/************************************************************************************
	Method to retrieves A list of Approvers that contain the set data
	*************************************************************************************/
    public static List<Approver__c> getRecordsThatContainBrandsStatesAndCountries(Set<String> brands, Set<String>states, Set<String>countries){
        return [SELECT Id,
                Brand__c,
                Country__c,
                State__c,
                OwnerId
                FROM Approver__c
                WHERE Brand__c IN :brands
                AND State__c IN :states
                AND Country__c IN :countries];
    }
}