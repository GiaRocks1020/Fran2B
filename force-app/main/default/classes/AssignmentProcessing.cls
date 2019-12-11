/**
 * @description Used to assign resources to lookup field based upon assignment criteria.
 *
 * @author Zach French
 * @date 2019-08-16
 */
public inherited sharing class AssignmentProcessing {

	@TestVisible
	private static Map<Id, Assignment_Setting__mdt> assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>();
	private Map<Id, Assignment__c> assignmentsById;
	private Map<Id, Resource__c> resourcesById;
	private Map<Id, Assignment_Setting__mdt> assignmentSettingsById;
	private Map<Id, Product__c> productsById;
	private Map<Id, Property__c> propertiesById;
	private Map<Id, Brand__c> brandsById;
	private Map<String, Assignment_Setting__mdt> assignmentSettingByUniqueId;
	private Map<String, String> missingResourceRoleByFieldAPIName;

	// PIP Method Collections
	private Map<Id, Assignment__c> PIPMethod_assignmentsById;
	private Map<Id, Brand__c> PIPMethod_brandsById;
	private Map<Id, Assignment_Setting__mdt> PIPMethod_assignmentSettingsById;
	public static Map<String, Set<Id>> PIPMethod_assignmentByAppType;
	public static Map<String, Set<Id>> PIPMethod_assignmentByBrand;
	public static Map<String, Set<Id>> PIPMethod_assignmentByPIPMethod;

	public static String ASSIGNMENT_RECORD_TYPE_PIP_PICKLISTS = StaticValue.getStaticValueText
		('ASSIGNMENT_RECORD_TYPE_PIP_PICKLISTS');
	private static String ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES = StaticValue.getStaticValueText
		('ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES');
	public static String ASSIGNMENT_ALL_COUNTRIES = StaticValue.getStaticValueText('ASSIGNMENT_ALL_COUNTRIES');
	public static String ASSIGNMENT_ALL_STATES = StaticValue.getStaticValueText('ASSIGNMENT_ALL_STATES');
	public static String ASSIGNMENT_APP_TYPE = StaticValue.getStaticValueText('ASSIGNMENT_APP_TYPE');
	public static String ASSIGNMENT_BRAND = StaticValue.getStaticValueText('ASSIGNMENT_BRAND');
	public static String ASSIGNMENT_COUNTRY = StaticValue.getStaticValueText('ASSIGNMENT_COUNTRY');
	public static String ASSIGNMENT_PIP_METHOD = StaticValue.getStaticValueText('ASSIGNMENT_PIP_METHOD');
	public static String ASSIGNMENT_PIP_TYPE = StaticValue.getStaticValueText('ASSIGNMENT_PIP_TYPE');
	public static String ASSIGNMENT_PRODUCT = StaticValue.getStaticValueText('ASSIGNMENT_PRODUCT');
	public static String ASSIGNMENT_STATE = StaticValue.getStaticValueText('ASSIGNMENT_STATE');
	public static String ASSIGNMENT_PROPERTY = StaticValue.getStaticValueText('ASSIGNMENT_PROPERTY');
	public static String ASSIGNMENT_RECORDTYPEID = StaticValue.getStaticValueText('ASSIGNMENT_RECORDTYPEID');
	public static String RESOURCE_OBJECT_API_NAME = StaticValue.getStaticValueText('RESOURCE_OBJECT_API_NAME');
	public static String ASSIGNMENT_ROLE_FIELD_MAP_JSON = StaticValue.getStaticValueTextAreaLong
		('ASSIGNMENT_ROLE_FIELD_MAP_JSON');
	public static String ASSIGNMENT_RESOURCE_ASSIGNMENT_MISSING = StaticValue.getStaticValueText
		('ASSIGNMENT_RESOURCE_ASSIGNMENT_MISSING');
	public static String ASSIGNMENT_RESOURCE_ASSIGNMENT_DUPLICATE = StaticValue.getStaticValueText
		('ASSIGNMENT_RESOURCE_ASSIGNMENT_DUPLICATE');
	public static String ASSIGNMENT_RECORD_TYPE_PIP_METHOD = StaticValue.getStaticValueText
		('ASSIGNMENT_RECORD_TYPE_PIP_METHOD');

	public static Map<String, Set<Id>> assignmentByBrand;
	public static Map<String, Set<Id>> assignmentByProduct;
	public static Map<String, Set<Id>> assignmentByPIPType;
	public static Map<String, Set<Id>> assignmentByPIPMethod;
	public static Map<String, Set<Id>> assignmentByAppType;
	public static Map<String, Set<Id>> assignmentByState;
	public static Map<String, Set<Id>> assignmentByCountry;

	/**
	 * @description Used to initiate the PIP Method rules for processing.
	 *
	 * @param records - List<SObject>
	 * @return void
	 */
	public void processPIPMethodRules(List<SObject> records) {
		// Run required queries
		initiatePIPMethodQueries(records);

		// Populate the maps needed for processing
		populatePIPMethodMaps();

		// Get the SObjectType of the first record passed in the SObject list. Assumes that all SObjects are related
		// to the same object.
		SObjectType sobjectTypeValue = records != null ? records[0].getSObjectType() : null;
		if(sobjectTypeValue == null) { return; }

		for(SObject record : records) {
			// Assign PIP Method value, if available
			assignPIPMethodValue(record, getMatchingAssignmentPIPMethod(record, sobjectTypeValue));
		}
	}

	/**
	 * @description Execute queries to populate maps needed for processing a PIP Method rule
	 *
	 * @param records - List of SObjects
	 * @return void
	 */
	private void initiatePIPMethodQueries(List<SObject> records) {
		// Retrieve Assignment Records
		PIPMethod_assignmentsById = new Map<Id, Assignment__c>(
			AssignmentProcessingHelper.getAssignmentsByIdPIPMethod());

		// Retrieve Related Brand Records
		PIPMethod_brandsById = new Map<Id, Brand__c>(AssignmentProcessingHelper.getBrandsById(records));

		// Retrieve Assignment Settings Custom Metadata records
		PIPMethod_assignmentSettingsById = new Map<Id, Assignment_Setting__mdt>(
			AssignmentProcessingHelper.getAssignmentSettingsById(assignmentSettingsByIdMock));
	}

	private void populatePIPMethodMaps() {
		PIPMethod_assignmentByAppType = new Map<String, Set<Id>>();
		PIPMethod_assignmentByBrand = new Map<String, Set<Id>>();
		PIPMethod_assignmentByPIPMethod = new Map<String, Set<Id>>();

		for(Assignment__c assignment : PIPMethod_assignmentsById.values()) {

			for(String value : assignment.Brand__c.split(';')) {
				String lowerCaseValue = value.toLowerCase();

				// Add Brands as value as key and Record Ids in a Set
				if(PIPMethod_assignmentByBrand.containsKey(lowerCaseValue)) {
					PIPMethod_assignmentByBrand.get(lowerCaseValue).add(assignment.Id);
				} else {
					PIPMethod_assignmentByBrand.put(lowerCaseValue, new Set<Id>{assignment.Id});
				}
			}

			for(String value : assignment.App_Type__c.split(';')) {
				String lowerCaseValue = value.toLowerCase();

				// Add App Types value as key and Record Ids in a Set
				if(PIPMethod_assignmentByAppType.containsKey(lowerCaseValue)) {
					PIPMethod_assignmentByAppType.get(lowerCaseValue).add(assignment.Id);
				} else {
					PIPMethod_assignmentByAppType.put(lowerCaseValue, new Set<Id>{assignment.Id});
				}
			}

			for(String value : assignment.PIP_Method__c.split(';')) {
				String lowerCaseValue = value.toLowerCase();

				// Add Brands as value as key and Record Ids in a Set
				if(PIPMethod_assignmentByPIPMethod.containsKey(lowerCaseValue)) {
					PIPMethod_assignmentByPIPMethod.get(lowerCaseValue).add(assignment.Id);
				} else {
					PIPMethod_assignmentByPIPMethod.put(lowerCaseValue, new Set<Id>{assignment.Id});
				}
			}
		}
	}

	/**
	 * @description Used to return a map of Assignment Setting Records by Object Name for PIP Method Assignment
	 *
	 * @param sObjectTypeValue - Curent SObjectType
	 * @return Map<String, Assignment_Setting__mdt>
	 */
	private Map<String, Assignment_Setting__mdt> getPIPMethodAssignmentSettingsByObject(SObjectType sObjectTypeValue) {
		Map<String, Assignment_Setting__mdt> PIPMethodAssignmentSettingsByObject = new Map<String,
			Assignment_Setting__mdt>();

		for(Assignment_Setting__mdt assignmentSetting : PIPMethod_assignmentSettingsById.values()) {

			if(assignmentSetting.Assignment_Rule_Type__c == ASSIGNMENT_RECORD_TYPE_PIP_METHOD
				&& assignmentSetting.Object__c == String.valueOf(sobjectTypeValue)) {
				PIPMethodAssignmentSettingsByObject.put(assignmentSetting.Object__c, assignmentSetting);
			}
		}

		return PIPMethodAssignmentSettingsByObject;
	}

	/**
	 * @description Used to return a set of Id of the Assignment records that matched the criteria for a PIP Method rule
	 *
	 * @param record - current record
	 * @param sObjectTypeValue - SObjectType
	 * @return Set<Id>
	 */
	private Set<Id> getMatchingAssignmentPIPMethod(SObject record, SObjectType sObjectTypeValue) {

		Map<String, Assignment_Setting__mdt> PIPMethodAssignmentSettingsByObject =
			getPIPMethodAssignmentSettingsByObject(sObjectTypeValue);

		Set<Id> matchingAssignmentIds = new Set<Id>();

		Assignment_Setting__mdt currentAssignmentSetting;
		if(PIPMethodAssignmentSettingsByObject.containsKey(String.valueOf(sobjectTypeValue))) {
			currentAssignmentSetting = PIPMethodAssignmentSettingsByObject.get(String.valueOf(sobjectTypeValue));
		}

		Integer matchingCriteriaSize = 0;
		Integer count = 0;

		if(currentAssignmentSetting != null) {
			Set<String> sObjectFieldSet = new Set<String>();
			sObjectFieldSet.addAll(currentAssignmentSetting.Matching_Criteria__c.split(';'));
			// Assign size of matching criteria
			matchingCriteriaSize = sObjectFieldSet.size();

			// Brand Match Determination
			if(sObjectFieldSet.contains(ASSIGNMENT_BRAND)
				&& PIPMethod_brandsById.containsKey((String) record.get(ASSIGNMENT_BRAND))) {

				String brandValue = PIPMethod_brandsById.get((String) record.get(ASSIGNMENT_BRAND)).Name == null ?
				'' : PIPMethod_brandsById.get((String) record.get(ASSIGNMENT_BRAND)).Name.toLowerCase();

				Boolean brandMatch = PIPMethod_assignmentByBrand.containsKey(brandValue);

				// Brand Match Met
				if(brandMatch) {
					matchingAssignmentIds.addAll(PIPMethod_assignmentByBrand.get(brandValue));

					// Increment count
					count++;
				}
			}

			// App Type Determination
			if(sObjectFieldSet.contains(ASSIGNMENT_APP_TYPE)) {

				String appTypeValue = record.get(ASSIGNMENT_APP_TYPE) == null ? '' : String.valueOf(record.get
					(ASSIGNMENT_APP_TYPE)).toLowerCase();
				Boolean appTypeMatch = PIPMethod_assignmentByAppType.containsKey(appTypeValue);

				// App Type Match Met
				if(appTypeMatch) {

					if(matchingAssignmentIds.isEmpty()) {
						matchingAssignmentIds.addAll(PIPMethod_assignmentByAppType.get(appTypeValue));
					}

					// Identify and retain duplicate matching values
					Boolean result = matchingAssignmentIds.retainAll(PIPMethod_assignmentByAppType.get(appTypeValue));

					// Increment count
					count++;
				}
			}
		}

		// Evaluate if count of criteria met against the criteria size
		Boolean allCriteriaMet = (count == matchingCriteriaSize && count != 0) ? true : false;

		if(!allCriteriaMet) {
			matchingAssignmentIds = new Set<Id>();
		}

		return matchingAssignmentIds;
	}

	/**
	 * @description Assign a value to the PIP_Method__c field on the related object.
	 *
	 * @param record - current record
	 * @param matchingAssignmentIds - Set of matching Assignment Ids
	 * @return void
	 */
	private void assignPIPMethodValue(SObject record, Set<Id> matchingAssignmentIds) {
		if(matchingAssignmentIds != null && !matchingAssignmentIds.isEmpty()) {
			Id assignmentId = new List<Id> (matchingAssignmentIds).get(0);
			String pipMethod = PIPMethod_assignmentsById.get(assignmentId).PIP_Method__c;
			if(pipMethod != '') {
				record.put(ASSIGNMENT_PIP_METHOD, pipMethod);
			}
		}
	}

	/**
	 * @description Used to initiate the processing of resource assignments
	 *
	 * @param records - List of SObject records to handle different types of SObjects
	 * @return void
	 */
	public void initializeData(List<SObject> records) {
		// Initialize missing resource by field map
		initializeMissingResourceRoleByFieldAPIName();

		// Initiate queries to set maps used for Resource Assignment
		initiateAssignmentResourceQueries(records);

		// Add Assignment Settings by Unique Id to Map variable
		assignmentSettingByUniqueId = new Map<String, Assignment_Setting__mdt>(getAssignmentSettingsByUniqueId());
	}

	/**
	 * @description Used to deserialize a JSON Map of the Field API Name and Field Values to be used for processing
	 * missing Assigned Recource fields
	 *
	 * @return void
	 */
	public void initializeMissingResourceRoleByFieldAPIName() {
		missingResourceRoleByFieldAPIName = new Map<String, String>();

		try {
			missingResourceRoleByFieldAPIName = (Map<String,String>) JSON.deserialize(ASSIGNMENT_ROLE_FIELD_MAP_JSON,
				Map<String,String>.class);
		} catch(Exception e) { system.debug('JSON deserialization error occurred.'); }
	}

	/**
	 * @description Used to execute the queries needed for retrieving data for Assignment Processing
	 *
	 * @param records - List of current SObject records
	 * @return void
	 */
	private void initiateAssignmentResourceQueries(List<SObject> records) {
		// Process SObject records to add values to sets to restrict query parameters.
		// Must occur before invoking queries.
		AssignmentProcessingHelper.populateSetsForAssignmentQuery(records);

		// Retrieve Assignment Records
		assignmentsById = new Map<Id, Assignment__c>(AssignmentProcessingHelper.getAssignmentsById());


		// Retrieve Resource Records
		resourcesById = new Map<Id, Resource__c>(AssignmentProcessingHelper.getResourcesById());

		// Retrieve Assignment Settings Custom Metadata records
		assignmentSettingsById = new Map<Id, Assignment_Setting__mdt>(
			AssignmentProcessingHelper.getAssignmentSettingsById(assignmentSettingsByIdMock));

		// Retrieve Related Product Records
		//productsById = new Map<Id, Product__c>(AssignmentProcessingHelper.getProductsById(records));
		productsById = new Map<Id, Product__c>(AssignmentProcessingHelper.getProductsById(records));

		// Retrieve Related Property Records
		propertiesById = new Map<Id, Property__c>(AssignmentProcessingHelper.getPropertiesById(records));

		// Retrieve Related Brand Records
		brandsById = new Map<Id, Brand__c>(AssignmentProcessingHelper.getBrandsById(records));
	}

	/**
	 * @description Used to initiate the processing of retrieve the assigned resources
	 *
	 * @param record - Current SObject
	 * @return Map<String, AssignmentRulesMatching>
	 */
	public Map<String, AssignmentRulesMatching> getProcessedResources(SObject record) {

		Map<String, AssignmentRulesMatching> assignmentRuleMatchByString = getMatchingResourceAssignments(record);

		return assignmentRuleMatchByString;
	}

	/**
	 * @description Used to assignment matching resource records to corresponding lookup fields on before insert.
	 *
	 * @param record - SObject record that was processed
	 * @param assignmentRuleMatchByString - Map of matched rules with the resource assignment
	 * @return void
	 */
	public SObject assignResources(SObject record, Map<String, AssignmentRulesMatching> assignmentRuleMatchByString) {

		Set<String> assignedRoles = new Set<String>();

		String missingRoles = '';
		List<String> duplicateRoles = new List<String>();
		SObject clonedRecord = record.clone(true);
		SObject newSObjectRecord = record.getSObjectType().newSObject();
		newSObjectRecord.Id = record.Id;

		for(AssignmentRulesMatching arm : assignmentRuleMatchByString.values()) {

			if(AssignmentProcessingHelper.hasSObjectField(assignmentSettingsById.get(arm.assignmentSettingId)
				.Field_To_Update__c.toLowerCase(), clonedRecord)
				&& AssignmentProcessingHelper.isValidId(assignmentsById.get(arm.assignmentId).Assignee__c)
				&& String.valueOf(assignmentsById.get(arm.assignmentId).Assignee__c.getSobjectType()) ==
				RESOURCE_OBJECT_API_NAME) {

				// Check for duplicate role and add role to list
				if(assignedRoles.contains(assignmentsById.get(arm.assignmentId).Role__c)) {
					duplicateRoles.add(JSON.serialize(assignmentsById.get(arm.assignmentId)));
					continue;
				}

				assignedRoles.add(assignmentsById.get(arm.assignmentId).Role__c);

				clonedRecord.put(assignmentSettingsById.get(arm.assignmentSettingId).Field_To_Update__c,
					assignmentsById.get(arm.assignmentId).Assignee__c);
				newSObjectRecord.put(assignmentSettingsById.get(arm.assignmentSettingId).Field_To_Update__c,
					assignmentsById.get(arm.assignmentId).Assignee__c);
			}
		}

		for(String fieldAPIName : missingResourceRoleByFieldAPIName.keySet()) {
			if(AssignmentProcessingHelper.hasSObjectField(fieldAPIName, clonedRecord) && clonedRecord.get
				(fieldAPIName) == null) {

				missingRoles += missingResourceRoleByFieldAPIName.get(fieldAPIName) + ';';
			}
		}

		// Add missing roles to field
		if(missingRoles != '' && AssignmentProcessingHelper.hasSObjectField
			(ASSIGNMENT_RESOURCE_ASSIGNMENT_MISSING, clonedRecord)) {
			clonedRecord.put(ASSIGNMENT_RESOURCE_ASSIGNMENT_MISSING, missingRoles);
			newSObjectRecord.put(ASSIGNMENT_RESOURCE_ASSIGNMENT_MISSING, missingRoles);
		}

		// Add duplicate roles to field
		if(!duplicateRoles.isEmpty() && duplicateRoles.size() > 0 && AssignmentProcessingHelper.hasSObjectField
			(ASSIGNMENT_RESOURCE_ASSIGNMENT_DUPLICATE, clonedRecord)) {
			clonedRecord.put(ASSIGNMENT_RESOURCE_ASSIGNMENT_DUPLICATE, string.join(duplicateRoles,','));
			newSObjectRecord.put(ASSIGNMENT_RESOURCE_ASSIGNMENT_DUPLICATE, string.join(duplicateRoles,','));
		}

		//return clonedRecord;

		return newSObjectRecord;
	}

	/**
	 * @description Assignment Setting Rules to be processed based on Record's SObjectType and will be returned in a
	 * map to be used for evaluation.
	 *
	 * @return Map<String, Assignment_Setting__mdt>
	 */
	private Map<String, Assignment_Setting__mdt> getAssignmentSettingsByUniqueId() {

		Map<String, Assignment_Setting__mdt> assignmentSettingsByString = new Map<String,
			Assignment_Setting__mdt>();
		for(Assignment_Setting__mdt assignmentSetting : assignmentSettingsById.values()) {

			// Add values to map with a key in the following format (AssignmentRuleType--Role)
			assignmentSettingsByString.put(assignmentSetting.Assignment_Rule_Type__c + '--' +
				assignmentSetting.Role__c, assignmentSetting);
		}

		return assignmentSettingsByString;
	}

	/**
	 * @description Process the assignment matching criteria to determine if all conditions have been met and return
	 * matched records.
	 *
	 * @param record - Current SObject
	 * @return Map<String, AssignmentRulesMatching>
	 */
	private Map<String, AssignmentRulesMatching> getMatchingResourceAssignments(SObject record){

		Map<String, AssignmentRulesMatching> assignmentRulesMatchingByString = new Map<String,
			AssignmentRulesMatching>();

		// Iterate over Assignment records
		for(Assignment__c assignment : assignmentsById.values()) {

			Integer matchingCount = 0;

			Boolean pipTypeMatch = false;
			Boolean pipMethodMatch = false;
			Boolean appTypeMatch = false;
			Boolean brandMatch = false;
			Boolean productMatch = false;
			Boolean stateMatch = false;
			Boolean countryMatch = false;

			String key = assignment.RecordType.DeveloperName + '--' + assignment.Role__c;

			if(assignmentEntryCriteriaMet(record, assignment, key)){

				// Matching Criteria from Assignment Setting
				Set<String> matchingCriteria = getAssignmentSettingMatchingCriteria(key);

				// Count is used add matching resources to map for assignment.
				Integer assignmentMatchingCriteriaFieldTotal = getAssignmentMatchingCriteriaFieldTotal
					(matchingCriteria);

				// PIP match validation
				pipTypeMatch = getPIPTypeMatch(matchingCriteria, assignment, record);
				if(pipTypeMatch) {
					matchingCount++;
				}

				// PIP match validation
				pipMethodMatch = getPIPMethodMatch(matchingCriteria, assignment, record);
				if(pipMethodMatch) {
					matchingCount++;
				}

				// App Type match validation
				appTypeMatch = getAppTypeMatch(matchingCriteria, assignment, record);
				if(appTypeMatch) {
					matchingCount++;
				}

				// Brand match validation
				brandMatch = getBrandMatch(matchingCriteria, assignment, record);
				if(brandMatch) {
					matchingCount++;
				}

				// Product match validation
				productMatch = getProductMatch(matchingCriteria, assignment, record);
				if(productMatch) {
					matchingCount++;
				}

				// State match validation
				stateMatch = getStateMatch(matchingCriteria, assignment, record);
				if(stateMatch) {
					matchingCount++;
				}

				// State match validation
				countryMatch = getCountryMatch(matchingCriteria, assignment, record);
				if(countryMatch) {
					matchingCount++;
				}


				system.debug('matchingCount: ' + matchingCount + ', assignmentMatchingCriteriaFieldTotal: ' +
					assignmentMatchingCriteriaFieldTotal);
				system.debug(
					'pipTypeMatch: ' + pipTypeMatch +
						', pipMethodMatch: ' + pipMethodMatch +
						', appTypeMatch: ' + appTypeMatch +
						', brandMatch: ' + brandMatch +
						', productMatch: ' + productMatch +
						', stateMatch: ' + stateMatch +
						', countryMatch: ' + countryMatch
				);

				// Add assignment rule match to assign resource values on related record
				if(matchingCount == assignmentMatchingCriteriaFieldTotal) {

					String matchingCriteriaKey = assignmentSettingByUniqueId.get(key).Id + '--' + assignment.Id;

					assignmentRulesMatchingByString.put(
						matchingCriteriaKey,
						new AssignmentRulesMatching()
							.assignmentSettingId(assignmentSettingByUniqueId.get(key).Id)
							.assignmentId(assignment.Id)
							.role(assignment.Role__c)
					);
				}

			}
		}

		return assignmentRulesMatchingByString;
	}

	/**
	 * @description Used to determine if the initial entry criteria is met for resource assignment
	 *
	 * @param record - SObject that was modified
	 * @param assignment - Associated assignment record being processed
	 * @param key - Current custom assignment key being processed
	 * @return Boolean
	 */
	private Boolean assignmentEntryCriteriaMet(SObject record, Assignment__c assignment, String key) {
		Boolean criteriaMet = false;

		System.debug('assignment : ' + assignment.Assignee__r.Name);
		if(assignmentSettingByUniqueId.containsKey(key)
			&& assignmentSettingByUniqueId.containsKey(key) != null
			&& assignment.Role__c == assignmentSettingByUniqueId.get(key).Role__c
			&& assignment.RecordType.DeveloperName != null
			&& assignment.RecordType.DeveloperName.contains(ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES)
			&& ((AssignmentProcessingHelper.hasSObjectField(ASSIGNMENT_RECORDTYPEID.toLowerCase(), record)
			&& assignmentSettingByUniqueId.get(key).Record_Type_Developer_Name__c ==
				RecordTypeUtils.getRecordTypeNameForId((Id) record.get(ASSIGNMENT_RECORDTYPEID), assignmentSettingByUniqueId.get(key).Object__c)))) {
				criteriaMet = true;
			}
		System.debug('criteriaMet : ' + criteriaMet);
		return criteriaMet;
	}

	/**
	 * @description Get Current Assignment Setting matching criteria in a set to be used for conditional matching
	 *
	 * @param key - Current Assignment key
	 * @return Set<String>
	 */
	private Set<String> getAssignmentSettingMatchingCriteria(String key) {
		Set<String> matchingCriteria = new Set<String>{};
		matchingCriteria.addAll(assignmentSettingByUniqueId.get(key).Matching_Criteria__c.toLowerCase().split
			(';'));
		system.debug(matchingCriteria);

		return matchingCriteria;
	}

	/**
	 * @description Get Number of Fields used for matching to compare against the number of match conditional checks.
	 *
	 * @param matchingCriteria - Current matching criteria from Assignment Setting
	 * @return Integer
	 */
	private Integer getAssignmentMatchingCriteriaFieldTotal(Set<String> matchingCriteria) {
		// Count is used add matching resources to map for assignment.
		Integer assignmentMatchingCriteriaFieldTotal = matchingCriteria.size();

		// Used to reduce the count if All_Countries__c & Country__c are used for matching criteria in the
		// Assignment Settings as there is only boolean field for matching country logic.
		if(matchingCriteria.contains(ASSIGNMENT_ALL_COUNTRIES.toLowerCase()) && matchingCriteria.contains
			(ASSIGNMENT_COUNTRY.toLowerCase())) {
			assignmentMatchingCriteriaFieldTotal--;
		}

		// Used to reduce the count if All_States__c & State__c are used for matching criteria in the
		// Assignment Settings as there is only boolean field for matching country logic.
		if(matchingCriteria.contains(ASSIGNMENT_ALL_STATES.toLowerCase()) && matchingCriteria.contains
			(ASSIGNMENT_STATE.toLowerCase())) {
			assignmentMatchingCriteriaFieldTotal--;
		}

		return assignmentMatchingCriteriaFieldTotal;
	}

	/**
	 * @description Returns true/false if PIP Type Matched
	 *
	 * @param matchingCriteria - Current set of matching criteria from Assignment Setting
	 * @param assignment - Associated assignment record being processed
	 * @param record - Current SObject Record
	 * @return Boolean
	 */
	private Boolean getPIPTypeMatch(Set<String> matchingCriteria, Assignment__c assignment, SObject record) {
		Boolean match = false;
        Set<String> typeSet = AssignmentProcessingHelper.convertMultiPicklistToSet(assignment.PIP_Type__c);

		if(matchingCriteria.contains(ASSIGNMENT_PIP_TYPE.toLowerCase())
			&& AssignmentProcessingHelper.hasSObjectField(ASSIGNMENT_PIP_TYPE.toLowerCase(), record)
			&& (typeSet.contains((String)record.get(ASSIGNMENT_PIP_TYPE.toLowerCase()))
				|| String.isBlank(assignment.PIP_Type__c) )) {

			match = true;
		}

		return match;
	}

	/**
	 * @description Returns true/false if PIP Method Matched
	 *
	 * @param matchingCriteria - Current set of matching criteria from Assignment Setting
	 * @param assignment - Associated assignment record being processed
	 * @param record - Current SObject Record
	 * @return Boolean
	 */
	private Boolean getPIPMethodMatch(Set<String> matchingCriteria, Assignment__c assignment, SObject record) {
		Boolean match = false;
        Set<String> methodSet = AssignmentProcessingHelper.convertMultiPicklistToSet(assignment.PIP_Method__c);

		if(matchingCriteria.contains(ASSIGNMENT_PIP_METHOD.toLowerCase())
			&& AssignmentProcessingHelper.hasSObjectField(ASSIGNMENT_PIP_METHOD.toLowerCase(), record)
			&& (methodSet.contains((String)record.get(ASSIGNMENT_PIP_METHOD))
				|| String.isBlank(assignment.PIP_Method__c) )) {

			match = true;
		}

		return match;
	}

	/**
	 * @description Returns true/false if App Type Matched
	 *
	 * @param matchingCriteria - Current set of matching criteria from Assignment Setting
	 * @param assignment - Associated assignment record being processed
	 * @param record - Current SObject Record
	 * @return Boolean
	 */
	private Boolean getAppTypeMatch(Set<String> matchingCriteria, Assignment__c assignment, SObject record) {
		Boolean match = false;
        Set<String> appSet = AssignmentProcessingHelper.convertMultiPicklistToSet(assignment.App_Type__c);

		if(matchingCriteria.contains(ASSIGNMENT_APP_TYPE.toLowerCase())
			&& AssignmentProcessingHelper.hasSObjectField(ASSIGNMENT_APP_TYPE.toLowerCase(), record)
			&& (appSet.contains((String)record.get(ASSIGNMENT_APP_TYPE))
				|| (String.isBlank(assignment.App_Type__c)) )) {

			match = true;
		}

		return match;
	}

	/**
	 * @description Returns true/false if Brand Matched
	 *
	 * @param matchingCriteria - Current set of matching criteria from Assignment Setting
	 * @param assignment - Associated assignment record being processed
	 * @param record - Current SObject Record
	 * @return Boolean
	 */
	private Boolean getBrandMatch(Set<String> matchingCriteria, Assignment__c assignment, SObject record) {
		Boolean match = false;
        Set<String> brandSet = AssignmentProcessingHelper.convertMultiPicklistToSet(assignment.Brand__c);
		if(matchingCriteria.contains(ASSIGNMENT_BRAND.toLowerCase())
			&& AssignmentProcessingHelper.hasSObjectField(ASSIGNMENT_BRAND.toLowerCase(), record)
			&& (record.get(ASSIGNMENT_BRAND) != null
				&& brandsById.containsKey((Id) record.get(ASSIGNMENT_BRAND))
				&& (brandSet.contains(brandsById.get((Id) record.get(ASSIGNMENT_BRAND)).Name)
					|| String.isBlank(assignment.Brand__c)))
			|| String.isBlank(assignment.Brand__c) ) {

			match = true;
		}

		return match;
	}

	/**
	 * @description Returns true/false if Product Matched
	 *
	 * @param matchingCriteria - Current set of matching criteria from Assignment Setting
	 * @param assignment - Associated assignment record being processed
	 * @param record - Current SObject Record
	 * @return Boolean
	 */
	private Boolean getProductMatch(Set<String> matchingCriteria, Assignment__c assignment, SObject record) {
		Boolean match = false;
        Set<String> productSet = AssignmentProcessingHelper.convertMultiPicklistToSet(assignment.Product__c);

		if(matchingCriteria.contains(ASSIGNMENT_PRODUCT.toLowerCase())
			&& AssignmentProcessingHelper.hasSObjectField(ASSIGNMENT_PRODUCT.toLowerCase(), record)
			&& (record.get(ASSIGNMENT_PRODUCT) != null
				&& productsById.containsKey((Id) record.get(ASSIGNMENT_PRODUCT))
				&& (productSet.contains(productsById.get((Id) record.get(ASSIGNMENT_PRODUCT)).Name)
					|| String.isBlank(assignment.Product__c)) )) {

			match = true;
		}

		return match;
	}

	/**
	 * @description Returns true/false if State Matched
	 *
	 * @param matchingCriteria - Current set of matching criteria from Assignment Setting
	 * @param assignment - Associated assignment record being processed
	 * @param record - Current SObject Record
	 * @return Boolean
	 */
	private Boolean getStateMatch(Set<String> matchingCriteria, Assignment__c assignment, SObject record)  {
		Boolean match = false;

		Set<String> states = new Set<String>();

		if(assignment.State__c != '' && assignment.State__c != null){
			states.addAll(assignment.State__c.split(';'));
		}

		if((!assignment.All_States__c && String.isBlank(assignment.State__c))
			|| (matchingCriteria.contains(ASSIGNMENT_ALL_STATES.toLowerCase())
				&& assignment.All_States__c)
			|| (matchingCriteria.contains(ASSIGNMENT_STATE.toLowerCase())
				&& AssignmentProcessingHelper.hasSObjectField(ASSIGNMENT_PROPERTY.toLowerCase(), record)
				&& record.get(ASSIGNMENT_PROPERTY) != null
				&& propertiesById.containsKey((Id) record.get(ASSIGNMENT_PROPERTY))
				&& states.contains(propertiesById.get((Id) record.get(ASSIGNMENT_PROPERTY)).State_Province__c))) {

			match = true;
		}

		return match;
	}

	/**
	 * @description Returns true/false if Country Matched
	 *
	 * @param matchingCriteria - Current set of matching criteria from Assignment Setting
	 * @param assignment - Associated assignment record being processed
	 * @param record - Current SObject Record
	 * @return Boolean
	 */
	private Boolean getCountryMatch(Set<String> matchingCriteria, Assignment__c assignment, SObject record) {
		Boolean match = false;

		Set<String> countries = new Set<String>();
		if(assignment.Country__c != '' && assignment.Country__c != null) {
			countries.addAll(assignment.Country__c.split(';'));
		}

		if((!assignment.All_Countries__c && String.isBlank(assignment.Country__c))
			|| (matchingCriteria.contains(ASSIGNMENT_ALL_COUNTRIES.toLowerCase())
				&& assignment.All_Countries__c)
			|| (matchingCriteria.contains(ASSIGNMENT_COUNTRY.toLowerCase())
				&& AssignmentProcessingHelper.hasSObjectField(ASSIGNMENT_PROPERTY.toLowerCase(), record)
				&& record.get(ASSIGNMENT_PROPERTY) != null
				&& propertiesById.containsKey((Id) record.get(ASSIGNMENT_PROPERTY))
				&& countries.contains(propertiesById.get((Id) record.get(ASSIGNMENT_PROPERTY)).Country__c) ) ) {

			match = true;
		}

		return match;
	}

	// Wrapper class used for processing an Assignment Rule Match
	public class AssignmentRulesMatching {
		Id assignmentSettingId;
		Id assignmentId;
		String role;

		public AssignmentRulesMatching() { }

		public AssignmentRulesMatching assignmentSettingId(Id value) {
			assignmentSettingId = value;
			return this;
		}

		public AssignmentRulesMatching assignmentId(Id value) {
			assignmentId = value;
			return this;
		}

		public AssignmentRulesMatching role(String value) {
			role = value;
			return this;
		}
	}
}