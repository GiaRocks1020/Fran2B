public with sharing class OwnershipRelationDA {
	
    public static List<Ownership_Relation__c> getOwnershipRelationsByOwnershipGroupIds(set<Id> ownershipGroupIds){
        return [
            SELECT id,Account__c,Account__r.Name,Account__r.Legacy_ID__c,Account__r.Account_Structure__c,Account__r.Phone,
            Account__r.Date_Formed__c,Account__r.State_Formed__c,Account__r.Email__c,Account__r.BillingStreet,Account__r.BillingCity,
            Account__r.BillingState,Account__r.BillingCountry,
            End_Date__c, OwnershipGroupId__c, Ownership_Percentage__c,Relationship_Type__c, Start_Date__c
            FROM Ownership_Relation__c
            WHERE OwnershipGroupId__c IN:ownershipGroupIds
        ];
    }
    
    public static List<Ownership_Relation__c> getOwnershipRelationsByIds(set<Id> ownerRelIds){
        return [
            SELECT id,Account__c,Account__r.Name,Account__r.Legacy_ID__c,Account__r.Account_Structure__c,Account__r.Phone,
            Account__r.Date_Formed__c,Account__r.State_Formed__c,Account__r.Email__c,Account__r.BillingStreet,Account__r.BillingCity,
            Account__r.BillingState,Account__r.BillingCountry,
            End_Date__c, OwnershipGroupId__c, Ownership_Percentage__c,Relationship_Type__c, Start_Date__c
            FROM Ownership_Relation__c
            WHERE Id IN:ownerRelIds
        ];
    }
    
}