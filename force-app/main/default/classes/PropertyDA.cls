public with sharing class PropertyDA {
    /************************************************************************************
	Method to retrieve Properties by Ids
	*************************************************************************************/
	public static List<Property__c> getPropertiesBasedOnIds(Set<Id> Ids){
		return new List<Property__c>([SELECT Id,
            Name,
            Country__c,
            State_Province__c
            FROM Property__c
            WHERE Id IN :Ids]);
	}

    public static void updateProperty(Property__c property){
        update property;
    }

    public static Property__c getPropertyById(Id propId){
        return [
        SELECT Id,Property_Code__c,State_Province__c,Country__c
        FROM Property__c
        WHERE Id =:propId];
    }

    public static List<Property__c> getPropertiesByCountry(String country){
        return [
        SELECT Id,State_Province__c,Property_Code__c
        FROM Property__c
        WHERE Country__c =:country
        AND Property_Code__c != null];
    }
}