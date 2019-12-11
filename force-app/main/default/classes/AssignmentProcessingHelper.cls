/**
 * @description Helper class used to store utility methods
 *
 * @author Zach French
 * @date 2019-08-23
 */
public class AssignmentProcessingHelper {

	public static Set<String> sObjectBrands;
	public static Set<String> sObjectProducts;
	public static Set<String> sObjectPIPType;
	public static Set<String> sObjectPIPMethod;
	public static Set<String> sObjectAppType;
	private static Integer fakeIdStartingInteger = 1;

	/**
	 * @description Used to retrieve the record type for an sObject record without a query.
	 *
	 * @param sObjectType - SObjectType of an SObject
	 * @param developerName - Record Type Developer Name
	 * @return Id
	 */
	public static Id getRecordTypeId(SObjectType sObjectType, String developerName){

		Map<String,Schema.RecordTypeInfo> recordTypeInfoByDeveloperName = new Map<String,Schema.RecordTypeInfo>();
		SObject objectRecord;
		Id recordTypeId = null;

		if(sObjectType != null) {
			objectRecord = sObjectType.newSObject();
			Schema.DescribeSObjectResult describeSObjectResult = objectRecord.getSObjectType().getDescribe();

			if(describeSObjectResult != null) {
				recordTypeInfoByDeveloperName = describeSObjectResult.getRecordTypeInfosByDeveloperName();
			}

			if(recordTypeInfoByDeveloperName.containsKey(developerName)) {
				recordTypeId = recordTypeInfoByDeveloperName.get(developerName).getRecordTypeId();
			}
		}

		return recordTypeId;
	}

	/**
	 * @description Used to retrieve a fake id used for mock records
	 *
	 * @param sObjectTypeValue- SObjectType of an SObject
	 * @return String
	 */
	public static String getFakeRecordIdString(Schema.SObjectType sObjectTypeValue) {
		String result = String.valueOf(fakeIdStartingInteger++);
		return sObjectTypeValue.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
	}

	/**
	 * @description Used to determine if an SObject has the field passed in the argument.
	 *
	 * @param fieldName - API field name
	 * @param sObjectRecord - SOject record to be processed
	 * @return Boolean
	 */
	public static Boolean hasSObjectField(String fieldName, SObject sObjectRecord){
		return sObjectRecord.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName.toLowerCase());
	}

	/**
	 * @description Used to determine if an Id is valid or not.
	 *
	 * @param value - Id string
	 * @return Boolean
	 */
	public static Boolean isValidId(String value) {
		Boolean isValid = (value InstanceOf Id) ? true : false;
		return isValid;
	}

	/**
	 * @description Used to return a map of Product__c records by Id
	 *
	 * @param sObjects - List of SObjects
	 * @return Map<Id, Product__c>
	 */
	public static Map<Id, Product__c> getProductsById(List<SObject> sObjects) {
		Set<Id> productIds = new Set<Id>();

		for(SObject sobjectRecord : sObjects) {
			if(AssignmentProcessingHelper.hasSObjectField(AssignmentProcessing.ASSIGNMENT_PRODUCT.toLowerCase(),
				sobjectRecord)) {
				productIds.add((Id) sobjectRecord.get(AssignmentProcessing.ASSIGNMENT_PRODUCT));
			}
		}

		return new Map<Id, Product__c>([
			SELECT Id, Name
			FROM Product__c
			WHERE Id IN :productIds
		]);
	}

	/**
	 * @description Used to return a map of Property__c records by Id
	 *
	 * @param sObjects - List of SObjects
	 * @return Map<Id, Property__c>
	 */
	public static Map<Id, Property__c> getPropertiesById(List<SObject> sObjects) {
		Set<Id> propertyIds = new Set<Id>();

		for(SObject sobjectRecord : sObjects) {
			if(AssignmentProcessingHelper.hasSObjectField(AssignmentProcessing.ASSIGNMENT_PROPERTY.toLowerCase(),
				sobjectRecord)) {
				propertyIds.add((Id) sobjectRecord.get(AssignmentProcessing.ASSIGNMENT_PROPERTY));
			}
		}

		return new Map<Id, Property__c>([
			SELECT Id, State_Province__c, Country__c
			FROM Property__c
			WHERE Id IN :propertyIds
		]);
	}

	/**
	 * @description Used to return a map of Brand__c records by Id
	 *
	 * @param sObjects - List of SObjects
	 * @return Map<Id, Brand__c>
	 */
	public static Map<Id, Brand__c> getBrandsById(List<SObject> sObjects) {
		Set<Id> brandIds = new Set<Id>();

		for(SObject sobjectRecord : sObjects) {
			if(AssignmentProcessingHelper.hasSObjectField(AssignmentProcessing.ASSIGNMENT_BRAND.toLowerCase(),
				sobjectRecord)) {
				brandIds.add((Id) sobjectRecord.get(AssignmentProcessing.ASSIGNMENT_BRAND));
			}
		}

		return new Map<Id, Brand__c>([
			SELECT Id, Name
			FROM Brand__c
			WHERE Id IN :brandIds
		]);
	}

	/**
	 * @description Used to return a map of Assignment__c records by Id
	 *
	 * @return Map<Id, Assignment__c>
	 */
	public static Map<Id, Assignment__c> getAssignmentsById(){
		return new Map<Id, Assignment__c>([
			SELECT Id, All_Countries__c, All_States__c, App_Type__c, Assignee__c, Product__c, Brand__c, Country__c,
				Name, PIP_Type__c, PIP_Method__c, Role__c, State__c, RecordType.DeveloperName, Assignee__r.Name
			FROM Assignment__c
			WHERE Active__c = TRUE
				AND RecordType.DeveloperName != :AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD]);
	}

	/**
	 * @description Used to return a map of Assignment__c records specific to PIP Methods for Assignment Rules
	 *
	 * @return Map<Id, Assignment__c>
	 */
	public static Map<Id, Assignment__c> getAssignmentsByIdPIPMethod(){
		return new Map<Id, Assignment__c>([
			SELECT Id, App_Type__c, Brand__c, PIP_Method__c, PIP_Type__c
			FROM Assignment__c
			WHERE Active__c = TRUE
				AND RecordType.DeveloperName = :AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD]);
	}

	/**
	 * @description Used to return a map of Resource__c records
	 *
	 * @return Map<Id, Resource__c>
	 */
	public static Map<Id, Resource__c> getResourcesById(){
		return new Map<Id, Resource__c>([
			SELECT Id, Name, User__c, External_User_Name__c, Email__c
			FROM Resource__c]);
	}

	/**
	 * @description Converts a multipicklist to a Set of strings 
	 *
	 * @param multipicklist - Semi-colon delimited text string
	 * @return Set<String>
	 */	
	public static Set<String> convertMultiPicklistToSet(String multipicklist){
        if (String.isBlank(multipicklist)) return new Set<String>{''};
        Set<String> setOfStrings = new Set<String>();
    	setOfStrings.addAll(multipicklist.split(';'));
        return setOfStrings;        
	}
	
	/**
	 * @description Used to return a map of Assignment_Setting__mdt records
	 *
	 * @param assignmentSettingsByIdMock - Map of Mock Assignment Settings
	 * @return Map<Id, Resource__c>
	 */
	public static Map<Id, Assignment_Setting__mdt> getAssignmentSettingsById(Map<Id, Assignment_Setting__mdt>
		assignmentSettingsByIdMock){

		return (!assignmentSettingsByIdMock.isEmpty()) ? assignmentSettingsByIdMock : new Map<Id,
			Assignment_Setting__mdt>([
				SELECT Id, DeveloperName, Label, Language, MasterLabel, Active__c, Field_To_Update__c,
					Matching_Criteria__c, Object__c, Record_Type_Developer_Name__c, Role__c, Assignment_Rule_Type__c
				FROM Assignment_Setting__mdt
				WHERE Active__c = true]);
	}

	/**
	 * @description Used to populate object specific sets for Resource Assignment Rules
	 *
	 * @param records - List of SObjects
	 * @return void
	 */
	public static void populateSetsForAssignmentQuery(List<SObject> records) {
		// Initialize sets to be used for restricting fields
		sObjectBrands = new Set<String>();
		sObjectProducts = new Set<String>();
		sObjectPIPType = new Set<String>();
		sObjectPIPMethod = new Set<String>();
		sObjectAppType = new Set<String>();

		for(SObject record : records) {
			if(hasSObjectField(AssignmentProcessing.ASSIGNMENT_BRAND.toLowerCase(), record)) {
				sObjectBrands.add((String) record.get(AssignmentProcessing.ASSIGNMENT_BRAND));
			}
			if(hasSObjectField(AssignmentProcessing.ASSIGNMENT_PRODUCT.toLowerCase(), record)) {
				sObjectProducts.add((String) record.get(AssignmentProcessing.ASSIGNMENT_PRODUCT));
			}
			if(hasSObjectField(AssignmentProcessing.ASSIGNMENT_PIP_TYPE.toLowerCase(), record)) {
				sObjectPIPType.add((String) record.get(AssignmentProcessing.ASSIGNMENT_PIP_TYPE));
			}
			if(hasSObjectField(AssignmentProcessing.ASSIGNMENT_PIP_METHOD.toLowerCase(), record)) {
				sObjectPIPMethod.add((String) record.get(AssignmentProcessing.ASSIGNMENT_PIP_METHOD));
			}
			if(hasSObjectField(AssignmentProcessing.ASSIGNMENT_APP_TYPE.toLowerCase(), record)) {
				sObjectAppType.add((String) record.get(AssignmentProcessing.ASSIGNMENT_APP_TYPE));
			}
		}
	}
}