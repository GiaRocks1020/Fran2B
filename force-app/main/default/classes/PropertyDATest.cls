@isTest
private class PropertyDATest {
	
	@testSetup
	static void setupData(){

		Property__c property1 = TestUtil.createProperty('Test 1', 'City Test', '', 'AR', '12345');
		Property__c property2 = TestUtil.createProperty('Test 2', 'City Test', '', 'AF', '12345');
		insert property1;
		property2.Property_Code__c = 'AF002';
		insert property2;

	}


	@isTest 
	static void getPropertiesBasedOnIdsTest() {
		List<Property__c> properties = [SELECT Id FROM Property__c];
		Set<Id> propertyIds = new Set<Id>();
		for(Property__c property: properties){
			propertyIds.add(property.Id);
		}
		List<Property__c> updatedProperties = new List<Property__c>();

		Test.startTest();
			updatedProperties = PropertyDA.getPropertiesBasedOnIds(propertyIds);
		Test.stopTest();

		System.assertEquals(updatedProperties.size(), properties.size(), 'The function should have found all properties');

	}

	@isTest 
	static void getPropertyByIdTest() {
		Property__c property = [SELECT Id,Country__c FROM Property__c WHERE Country__c ='AF' LIMIT 1];

		Property__c updatedProperty = new Property__c();
		Test.startTest();
			updatedProperty = PropertyDA.getPropertyById(property.Id);
		Test.stopTest();

		System.assertEquals(updatedProperty.Country__c, property.Country__c, 'The records should be the same');
		System.assertEquals(updatedProperty.Id, property.Id, 'The records should be the same');

	}


	@isTest 
	static void getPropertiesByCountryTest() {
		Property__c property = [SELECT Id,Country__c FROM Property__c WHERE Country__c ='AF' LIMIT 1];

		List<Property__c> updatedProperties = new List<Property__c>();
		Test.startTest();
			updatedProperties = PropertyDA.getPropertiesByCountry('AF');
		Test.stopTest();

		System.assertEquals(updatedProperties[0].Id, property.Id, 'The records should be the same');

	}

	@isTest 
	static void updatePropertyTest() {
		List<Property__c> properties2 = [SELECT Id,Country__c FROM Property__c];
		System.debug(properties2);
		Property__c property = [SELECT Id,Country__c FROM Property__c WHERE Country__c ='AF' LIMIT 1];
		property.Country__c = 'CC';
		Test.startTest();
			PropertyDA.updateProperty(property);
		Test.stopTest();

		List<Property__c>  oldProperties = [SELECT Id,Country__c FROM Property__c WHERE Country__c ='AF'];
		Property__c updatedProperty = [SELECT Id,Country__c FROM Property__c WHERE Country__c ='CC' LIMIT 1];
		System.assertEquals(oldProperties.size(), 0, 'There should be no more records with the AF country code.');
		System.assertEquals(updatedProperty.Country__c, property.Country__c, 'The record should have an updated country');

	}


}