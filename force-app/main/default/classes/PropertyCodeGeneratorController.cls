public with sharing class PropertyCodeGeneratorController {
	


	@AuraEnabled
	public static String getDataEnvelope(Id propId){
		Property__c property = PropertyDA.getPropertyById(propId);
		List<Property_Code_Metadata__c> propMtd = getLatestCode(property);
		List<PropertyCodeCountryMapping__mdt> propertyCodeList = 
		CustomMetadataDA.getPropertyCodeCountryMapping(property.Country__c);

		Property_Code_Metadata__c updatedMtd = new Property_Code_Metadata__c(); 
		if(propMtd.size() >0){
			updatedMtd = isCountryInMetadata(propMtd[0],propertyCodeList, property.Country__c);
		}

		List<Property__c> propertiesByAccount = PropertyDA.getPropertiesByCountry(property.Country__c);
		Map<String,String> propertyCodeMap = generatePropertyCodeMap(propertiesByAccount);
		PropertyCodeEnvelope envelope = new PropertyCodeEnvelope(property,updatedMtd,propertiesByAccount,propertyCodeMap);
		return JSON.serialize(envelope);

	}


	public static Property_Code_Metadata__c isCountryInMetadata (Property_Code_Metadata__c propMtd, 
	List<PropertyCodeCountryMapping__mdt > propertyCodeList, String countryCode){
		if(countryCode  == 'US'){
			return propMtd;
		}else{
			if(propertyCodeList.size() >0){// This means there is a match for the ISO code.
				if(propertyCodeList[0].Choice_Country_Code__c != null && propertyCodeList[0].Choice_Country_Code__c != ''){
					propMtd.State_Country_Code__c = propertyCodeList[0].Choice_Country_Code__c;
					}else{
						propMtd.State_Country_Code__c = '';
					}
			}
			else{
				propMtd.State_Country_Code__c = countryCode;
			}
		}
		return propMtd;

	}

	public static Map<String,String> generatePropertyCodeMap(List<Property__c> properties){
		Map<String,String> propertyCodeMap = new Map<String,String>();

		for(Property__c property: properties){
			propertyCodeMap.put(property.Property_Code__c,property.Id);

		}

		return propertyCodeMap;

	}


	@AuraEnabled
	public static String incramentCode(String currentCode, Map<String,String> propertyCodeMap , String prefixLetters){
		Boolean isFound = true;
		do{
			//currentCode = PropertyCodeCreation.getLast3Characters(currentCode);
			currentCode = PropertyCodeGenUtil.getNextCode(currentCode);
			String tempCode = prefixLetters+currentCode;
			System.debug('tempCode = '+ tempCode);
			System.debug('propertyCodeMap = '+ propertyCodeMap);


			if(!propertyCodeMap.containsKey(tempCode)){
				isFound = false;
			}

		}while(isFound == true);
		return currentCode;
		
	}


	@AuraEnabled
	public static List<Property_Code_Metadata__c> getLatestCode(Property__c prop){
		List<Property__c> props = new List<Property__c>();
		props.add(prop);
		List<Property_Code_Metadata__c> propMtd = PropertyCodeCreation.getLatestRecords(props);

		return propMtd;
		

	}


	@AuraEnabled
	public static void saveAutoGenCode(String propertyJson,String propMtdJson){
		Property__c property = (Property__c)JSON.deserialize(propertyJson, Property__c.class);
		Property_Code_Metadata__c propMtd =(Property_Code_Metadata__c) JSON.deserialize(propMtdJson, Property_Code_Metadata__c.class);

			PropertyDA.updateProperty(property);
			upsertPropertyCodeMtd(propMtd);
	}

	@AuraEnabled
	public static void saveManualCode(String propertyJson){
		Property__c property = (Property__c)JSON.deserialize(propertyJson, Property__c.class);
		PropertyDA.updateProperty(property);
	}

	public static void upsertPropertyCodeMtd(Property_Code_Metadata__c propMtd){
		upsert propMtd;
	}

	 public class PropertyCodeEnvelope{
		public Property__c property {get; set;}
		public Property_Code_Metadata__c propMtd {get;set;}
		public List<Property__c> propertiesByAccount {get;set;}
		public Map<String,String> propertyCodeMap {get;set;}
		public PropertyCodeEnvelope(Property__c property, Property_Code_Metadata__c propMtd,
			List<Property__c> propertiesByAccount,Map<String,String> propertyCodeMap) {
			this.property = property;
			this.propMtd = propMtd;
			this.propertiesByAccount = propertiesByAccount;
			this.propertyCodeMap = propertyCodeMap;
		}
	}
}