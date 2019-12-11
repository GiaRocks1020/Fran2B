public with sharing class CustomMetadataDA {
	public static List<Brand_Ranking__mdt> getBrandRankings(){
		return [SELECT Label,
				Brand__c, 
				Brand_Code__c , 
				Weightage__c
				FROM Brand_Ranking__mdt 
				ORDER BY Weightage__c ASC];
	}

	public static List<Lead_Assignment_Mapping__mdt> getLeadAssignments(){
		return [SELECT Label,
		Brand_Code__c, 
		Employee_Number__c, 
		DFS_Name__c, 
		Is_a_Queue__c,
		State__c,
		Country__c
		FROM Lead_Assignment_Mapping__mdt];
	}

	public static List<Lead_Source_for_Routing__mdt> getLeadSourcesForRouting(){
		return [SELECT Label
		FROM Lead_Source_for_Routing__mdt];
	}

	public static List<Lead_Convert_Contact_Fields_Metadata__mdt> getLeadConvertContactFieldsMetadata(){
		return [SELECT Label,
		Field_API_Name__c,
		Column_Order__c
		FROM Lead_Convert_Contact_Fields_Metadata__mdt
		ORDER BY Column_Order__c ASC];
	}

	public static List<Lead_Convert_Account_Fields_Metadata__mdt> getLeadConvertAccountFieldsMetadata(){
		return [SELECT Label,
		Field_API_Name__c,
		Column_Order__c
		FROM Lead_Convert_Account_Fields_Metadata__mdt
		ORDER BY Column_Order__c ASC];
	}

	public static List<Lead_Convert_Property_Fields_Metadata__mdt> getLeadConvertPropertyFieldsMetadata(){
		return [SELECT Label,
		Field_API_Name__c,
		Column_Order__c
		FROM Lead_Convert_Property_Fields_Metadata__mdt
		ORDER BY Column_Order__c ASC];
	}
	/************************************************************************************
	Method to retrieve MatchWeightage information
	*************************************************************************************/
	public static list<LeadConvertMatchWeightage__mdt> getMatchWeightageInfo(String sObjectName) {
		list<LeadConvertMatchWeightage__mdt> metadataInfo = new list<LeadConvertMatchWeightage__mdt>();
		if(!String.isEmpty(sObjectName)) {
			metadataInfo.addALL([SELECT Matched_Lead_Field_API_Name__c,Match_Field_API_Name__c,Match_Score__c,SObject_Name__c,Is_Exact_Match__c FROM LeadConvertMatchWeightage__mdt WHERE SObject_Name__c = :sObjectName]);
		}
		return metadataInfo;
		
	}

	/************************************************************************************
	Method to retrieve Conversion Mapping information by SObject
	*************************************************************************************/
	public static List<Lead_Convert_Conversion_Mapping__mdt> getLeadConvertConversionMappingBySObject(String sObjectName){
		return [SELECT SObject_Name__c,
		Lead_Field_API_Name__c,
		SObject_Field_API_Name__c,
		Use_Picklist_Label__c
		FROM Lead_Convert_Conversion_Mapping__mdt
		WHERE SObject_Name__c = :sObjectName];
	}

	/************************************************************************************
	Method to retrieve RecordType Mapping information by SObject
	*************************************************************************************/
	public static List<Lead_Convert_RecordType_Mapping__mdt> getLeadConvertRecordTypeMappingBySObject(String sObjectName){
		return [SELECT SObject_API_Name__c,
		Lead_Value__c,
		Record_Type_Label__c	
		FROM Lead_Convert_RecordType_Mapping__mdt
		WHERE SObject_API_Name__c = :sObjectName];
	}
	/************************************************************************************
	Method to retrieve ISO Code to Choice Code Metadata
	*************************************************************************************/
	public static List<PropertyCodeCountryMapping__mdt> getPropertyCodeCountryMapping(){
		return [SELECT
		Choice_Country_Code__c,
		Country_ISO_Code__c
		FROM PropertyCodeCountryMapping__mdt];
	}
	/************************************************************************************
	Method to retrieve ISO Code to Choice Code Metadata by specific ISO code
	*************************************************************************************/
	public static List<PropertyCodeCountryMapping__mdt> getPropertyCodeCountryMapping(String isoCode){
		return [SELECT
		Choice_Country_Code__c,
		Country_ISO_Code__c
		FROM PropertyCodeCountryMapping__mdt
		WHERE Country_ISO_Code__c =:isoCode];
	}
}