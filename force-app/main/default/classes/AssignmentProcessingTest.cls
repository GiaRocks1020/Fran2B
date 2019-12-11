/**
 * @description Test class for AssignmentProcessing
 *
 * @author Zach French
 * @date 2019-08-23
 */
@IsTest
public class AssignmentProcessingTest {

	private static final String TEST_USER_1_EMAIL = 'testUserUS1@choicehotels.com';
	private static final String TEST_USER_2_EMAIL = 'testUserUS2@choicehotels.com';
	private static final String TEST_USER_3_EMAIL = 'testUserUS3@choicehotels.com';
	private static Profile sysAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
	private static final String PIP_TYPE_APPLICATION = StaticValue.getStaticValueText('PIP_TYPE_APPLICATION');
	private static final String PIP_METHOD_DESKTOP = StaticValue.getStaticValueText('PIP_METHOD_DESKTOP');
	private static final String PIP_METHOD_TRAVEL = StaticValue.getStaticValueText('PIP_METHOD_TRAVEL');
	private static final String CONTRACT_NAME_SAMPLE_CONTRACT = 'Sample Contract';
	private static final String BRAND_ASCEND_EXTERNAL_ID = 'AC';
	private static final String PROPERTY_CODE_VT019= 'VT019';
	private static final String BRAND_NAME_ASCEND = 'Ascend';
	private static final String BRAND_NAME_CAMBRIA = 'Cambria';
	private static final String STATE_VERMONT = 'US-VT';
	private static final String STATE_ARIZONA = 'US-AZ';
	private static final String COUNTRY_US = 'US';
	private static final String PRODUCT_NAME_RESORT_COLLECTION = 'Resort Collection';
	private static final String PRODUCT_CODE_RE = 'RE';
	private static final String APP_TYPE_NEW_CONSTRUCTION = 'New Construction';
	private static final String ASSIGNMENT_SETTING_NAME_PIP_WRITER = 'ASSIGNMENT_PIP_WRITER';
	private static final String ASSIGNMENT_SETTING_NAME_ARCHITECTURE_COORDINATOR =
		'ASSIGNMENT_ARCHITECTURE_COORDINATOR';
	private static final String ASSIGNMENT_SETTING_NAME_BRAND_PROJECT_MANAGER = 'ASSIGNMENT_BRAND_PROJECT_MANAGER';
	private static final String ASSIGNMENT_SETTING_NAME_DESIGN_COORDINATOR = 'ASSIGNMENT_DESIGN_COORDINATOR';
	private static final String ASSIGNMENT_SETTING_NAME_DFS_USER = 'ASSIGNMENT_DFS_USER';
	private static final String ASSIGNMENT_SETTING_NAME_LICENSEE_REP = 'ASSIGNMENT_LICENSEE_REP';
	private static final String ASSIGNMENT_SETTING_NAME_PORTFOLIO_MANAGER = 'ASSIGNMENT_PORTFOLIO_MANAGER';
	private static final String ASSIGNMENT_SETTING_NAME_PROCUREMENT_COORDINATOR = 'ASSIGNMENT_PROCUREMENT_COORDINATOR';
	private static final String ASSIGNMENT_SETTING_NAME_PROCUREMENT_MANAGER = 'ASSIGNMENT_PROCUREMENT_MANAGER';
	private static final String ASSIGNMENT_SETTING_NAME_VERIFYING_MANAGER = 'ASSIGNMENT_VERIFYING_MANAGER';
	private static final String ASSIGNMENT_RULE_TYPE_PIP_RESOURCES = 'PIP_Resources';
	private static final String ASSIGNMENT_RULE_TYPE_PIP_METHOD = 'PIP_Method';
	private static final String ASSIGNMENT_SETTING_ROLE_TYPE_PIP_WRITER = 'PIP Writer';
	private static final String ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECTURE_COORDINATOR = 'Architecture Coordinator';
	private static final String ASSIGNMENT_SETTING_ROLE_TYPE_BRAND_PROJECT_MANAGER = 'Brand Project Manager';
	private static final String ASSIGNMENT_SETTING_ROLE_TYPE_DESIGN_COORDINATOR = 'Design Coordinator';
	private static final String ASSIGNMENT_SETTING_ROLE_TYPE_DFS_USER = 'DFS User';
	private static final String ASSIGNMENT_SETTING_ROLE_TYPE_LICENSEE_REP = 'Licensee Rep';
	private static final String ASSIGNMENT_SETTING_ROLE_TYPE_PORTFOLIO_MANAGER = 'Portfolio Manager';
	private static final String ASSIGNMENT_SETTING_ROLE_TYPE_PROCUREMENT_COORDINATOR = 'Procurement Coordinator';
	private static final String ASSIGNMENT_SETTING_ROLE_TYPE_PROCUREMENT_MANAGER = 'Procurement Manager';
	private static final String ASSIGNMENT_SETTING_ROLE_TYPE_VERIFYING_MANAGER = 'Verifying Manager';
	private static final String ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES = 'PIP_Resources';
	private static final String ASSIGNMENT_PIP_METHOD = 'ASSIGNMENT_PIP_METHOD';
	public static String ASSIGNMENT_SETTING_OBJECT_PIP = 'TASKRAY__Project__c';
	private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName();
	private static Id  pipRecordTypeId = recordTypeMap.get('PIP').getRecordTypeId();


	/**
	 * @description Data setup method used for unit tests
	 *
	 * @return void
	 */
	@TestSetup
	static void dataSetup() {

		List<User> users = new List<User>{
			new User(
				Alias = 'tuser1',
				Email = TEST_USER_1_EMAIL,
				EmailEncodingKey = 'UTF-8',
				FirstName = 'Test',
				LastName = 'User1',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				ProfileId = sysAdmin.Id,
				TimeZoneSidKey = 'America/Los_Angeles',
				UserName = TEST_USER_1_EMAIL
			),
			new User(
				Alias = 'tuser2',
				Email = TEST_USER_2_EMAIL,
				EmailEncodingKey = 'UTF-8',
				FirstName = 'Test',
				LastName = 'User2',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				ProfileId = sysAdmin.Id,
				TimeZoneSidKey = 'America/Los_Angeles',
				UserName = TEST_USER_2_EMAIL
			),
			new User(
				Alias = 'tuser3',
				Email = TEST_USER_3_EMAIL,
				EmailEncodingKey = 'UTF-8',
				FirstName = 'Test',
				LastName = 'User3',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				ProfileId = sysAdmin.Id,
				TimeZoneSidKey = 'America/Los_Angeles',
				UserName = TEST_USER_3_EMAIL
			)
		};

		insert users;

		// Properties
		List<Property__c> properties = new List<Property__c>{
			new Property__c(
				Name = 'VT019 Montpelier',
				Property_Code__c = PROPERTY_CODE_VT019,
				State_Province__c = STATE_VERMONT,
				Country__c = COUNTRY_US
			)
		};

		insert properties;

		// Brand
		List<Brand__c> brands = new List<Brand__c>{
			new Brand__c(
				Name = BRAND_NAME_ASCEND,
				Brand_Code__c = BRAND_ASCEND_EXTERNAL_ID,
				External_ID__c = BRAND_ASCEND_EXTERNAL_ID,
				Start_Date__c = Date.newInstance(2008, 5, 7),
				End_Date__c = Date.newInstance(2199, 1, 1),
				Status__c = 'Active'
			)
		};

		insert brands;

		// Contracts
		List<Contract__c> contracts = new List<Contract__c>{
			new Contract__c(
				Name = 'Sample Contract',
				AD__c = 'Harper,Stephen',
				Application_Type__c = 'NEWC',
				Billable_Rooms__c = 109.0,
				Contract_Status__c = 'PROP',
				Effective_Contract_Flag__c = true,
				LR1__c = 'Branch,Susan',
				RVP__c = 'Manger,Tanner'
			)
		};

		insert contracts;

		// Products
		List<Product__c> products = new List<Product__c>{
			new Product__c(
				Name = PRODUCT_NAME_RESORT_COLLECTION,
				Brand__c = brands[0].Id,
				Product_Code__c = PRODUCT_CODE_RE,
				External_ID__c = 'AC-RE',
				Choice_Class_ID__c = 'R'
			)
		};

		insert products;

	}

	/**
	 * @description Used to test the positive test case for retrieving a PIP Writer based upon assignment rules.
	 *
	 * @return void
	 */
	@IsTest
	static void testPIPWriterAssignmentPositive() {
		Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
		SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();


		// Assignment Setting Custom Metadata Type, mock
		List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_PIP_WRITER,
				MasterLabel = ASSIGNMENT_SETTING_NAME_PIP_WRITER,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'PIP_Writer__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;Country__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_PIP_WRITER
			)
		};

		AssignmentProcessing.assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>(assignmentSettings);

		// Resource
		List<Resource__c> resources = new List<Resource__c>{
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_1_EMAIL].Id
			)
		};

		insert resources;

		// Get sObjectType from Record to get Record Type Id
		Assignment__c assignmentInstance = new Assignment__c();
		SObjectType sObjectTypeValue = assignmentInstance.getSObjectType();


		// Assignments
		List<Assignment__c> assignments = new List<Assignment__c>{
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[0].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = false,
				State__c = STATE_VERMONT,
				All_Countries__c = false,
				Country__c = COUNTRY_US
			)
		};

		insert assignments;

		Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
		Brand__c brand = [SELECT Id FROM Brand__c WHERE External_ID__c = :BRAND_ASCEND_EXTERNAL_ID];
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
		Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
			:brand.Id];

		Test.startTest();

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c> {
			new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				Contract__c = contract.Id,
				Brand__c = brand.Id,
				Property__c = property.Id,
				RecordTypeId = pipRecordTypeId,
				Product__c = product.Id
			)
		};

		insert pipProjects;

		Test.stopTest();

		pipProjects = [SELECT Id, PIP_Writer__c FROM TASKRAY__Project__c];
		System.assertNotEquals(null, pipProjects[0].PIP_Writer__c);
	}

	/**
	 * @description Used to test the negative test case for retrieving a PIP Writer based upon assignment rules. PIP
	 * Writer should be null.
	 *
	 * @return void
	 */
	@IsTest
	static void testPIPWriterAssignmentNegative() {
		Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
		SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();

		// Assignment Setting Custom Metadata Type, mock
		List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_PIP_WRITER,
				MasterLabel = ASSIGNMENT_SETTING_NAME_PIP_WRITER,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'PIP_Writer__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;Country__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_PIP_WRITER
			)
		};

		AssignmentProcessing.assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>(assignmentSettings);

		// Resource
		List<Resource__c> resources = new List<Resource__c>{
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_1_EMAIL].Id
			)
		};

		insert resources;

		// Get sObjectType from Record to get Record Type Id
		Assignment__c assignmentInstance = new Assignment__c();
		SObjectType sObjectTypeValue = assignmentInstance.getSObjectType();

		// Assignments
		List<Assignment__c> assignments = new List<Assignment__c>{
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[0].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = false,
				State__c = STATE_ARIZONA,
				All_Countries__c = false,
				Country__c = COUNTRY_US
			)
		};

		insert assignments;

		Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
		Brand__c brand = [SELECT Id FROM Brand__c WHERE External_ID__c = :BRAND_ASCEND_EXTERNAL_ID];
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
		Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
			:brand.Id];

		Test.startTest();

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c> {
			new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				Contract__c = contract.Id,
				Brand__c = brand.Id,
				Property__c = property.Id,
				RecordTypeId = pipRecordTypeId,
				Product__c = product.Id
			)
		};

		insert pipProjects;

		Test.stopTest();

		pipProjects = [SELECT Id, PIP_Writer__c FROM TASKRAY__Project__c];

		System.assertEquals(null, pipProjects[0].PIP_Writer__c);
	}

	/**
	 * @description Used to test for a duplicate role in the Assignment object.
	 *
	 * @return void
	 */
	@IsTest
	static void testPIPWriterAssignmentDuplicate() {
		Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
		SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();


		// Assignment Setting Custom Metadata Type, mock
		List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_PIP_WRITER,
				MasterLabel = ASSIGNMENT_SETTING_NAME_PIP_WRITER,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'PIP_Writer__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
					'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_PIP_WRITER
			)
		};

		AssignmentProcessing.assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>(assignmentSettings);

		// Resource
		List<Resource__c> resources = new List<Resource__c>{
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_1_EMAIL].Id
			),
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_2_EMAIL].Id
			)
		};

		insert resources;

		// Get sObjectType from Record to get Record Type Id
		Assignment__c assignmentInstance = new Assignment__c();
		SObjectType sObjectTypeValue = assignmentInstance.getSObjectType();


		// Assignments
		List<Assignment__c> assignments = new List<Assignment__c>{
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[0].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = false,
				State__c = STATE_VERMONT,
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			)
		};

		insert assignments;

		Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
		Brand__c brand = [SELECT Id FROM Brand__c WHERE External_ID__c = :BRAND_ASCEND_EXTERNAL_ID];
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
		Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
			:brand.Id];

		Test.startTest();

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c> {
			new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				Contract__c = contract.Id,
				Brand__c = brand.Id,
				Property__c = property.Id,
				Product__c = product.Id,
				RecordTypeId = pipRecordTypeId
			)
		};

		insert pipProjects;

		Test.stopTest();

		pipProjects = [SELECT Id, PIP_Writer__c, Assignment_Resource_Duplicates__c, Resource_Assignments_Missing__c FROM TASKRAY__Project__c];

		System.assertNotEquals(null, pipProjects[0].PIP_Writer__c);
		System.assertEquals(resources[0].Id, pipProjects[0].PIP_Writer__c);
	}

	/**
	 * @description Used to validate All Roles are being assigned to the appropriate resource.
	 *
	 * @return void
	 */
	@IsTest
	static void testPIPWriterAssignmentAllRoles() {
		Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
		SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();

		// Assignment Setting Custom Metadata Type, mock
		List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_PIP_WRITER,
				MasterLabel = ASSIGNMENT_SETTING_NAME_PIP_WRITER,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'PIP_Writer__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
					'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_PIP_WRITER
			),
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_ARCHITECTURE_COORDINATOR,
				MasterLabel = ASSIGNMENT_SETTING_NAME_ARCHITECTURE_COORDINATOR,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'Architecture_Coordinator__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
					'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECTURE_COORDINATOR
			),
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_BRAND_PROJECT_MANAGER,
				MasterLabel = ASSIGNMENT_SETTING_NAME_BRAND_PROJECT_MANAGER,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'Brand_Project_Manager__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
				'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_BRAND_PROJECT_MANAGER
			),
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_DESIGN_COORDINATOR,
				MasterLabel = ASSIGNMENT_SETTING_NAME_DESIGN_COORDINATOR,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'Design_Coordinator__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
				'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_DESIGN_COORDINATOR
			),
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_DFS_USER,
				MasterLabel = ASSIGNMENT_SETTING_NAME_DFS_USER,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'DFS_User__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
				'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_DFS_USER
			),
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_LICENSEE_REP,
				MasterLabel = ASSIGNMENT_SETTING_NAME_LICENSEE_REP,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'Licensee_Rep__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
				'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_LICENSEE_REP
			),
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_PORTFOLIO_MANAGER,
				MasterLabel = ASSIGNMENT_SETTING_NAME_PORTFOLIO_MANAGER,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'Portfolio_Manager__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
				'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_PORTFOLIO_MANAGER
			),
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_PROCUREMENT_COORDINATOR,
				MasterLabel = ASSIGNMENT_SETTING_NAME_PROCUREMENT_COORDINATOR,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'Procurement_Coordinator__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
				'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_PROCUREMENT_COORDINATOR
			),
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_PROCUREMENT_MANAGER,
				MasterLabel = ASSIGNMENT_SETTING_NAME_PROCUREMENT_MANAGER,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'Procurement_Manager__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
				'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_PROCUREMENT_MANAGER
			),
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_VERIFYING_MANAGER,
				MasterLabel = ASSIGNMENT_SETTING_NAME_VERIFYING_MANAGER,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'Verifying_Manager__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
				'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_VERIFYING_MANAGER
			)
		};

		AssignmentProcessing.assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>(assignmentSettings);

		// Resource
		List<Resource__c> resources = new List<Resource__c>{
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_1_EMAIL].Id
			),
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_2_EMAIL].Id
			)
		};

		insert resources;

		// Get sObjectType from Record to get Record Type Id
		Assignment__c assignmentInstance = new Assignment__c();
		SObjectType sObjectTypeValue = assignmentInstance.getSObjectType();


		// Assignments
		List<Assignment__c> assignments = new List<Assignment__c>{
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[0].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = false,
				State__c = STATE_VERMONT,
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			//Test Record - Missing Product
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = null,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			// Test Record 2 - Missing PIP TYpe
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = '',
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			// Test Record 3 - Missing PIP Method
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = '',
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			// Test Record 4 - Missing App Type
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = '',
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			// Test Record - individual state
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = false,
				State__c = 'US-MI',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
				ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'Architecture Coordinator',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
				ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'Brand Project Manager',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
				ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'Design Coordinator',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
				ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'DFS User',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
				ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'Portfolio Manager',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
				ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'Procurement Coordinator',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
				ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'Procurement Manager',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
				ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'Verifying Manager',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			)
		};

		insert assignments;

		Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
		Brand__c brand = [SELECT Id FROM Brand__c WHERE External_ID__c = :BRAND_ASCEND_EXTERNAL_ID];
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
		Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
			:brand.Id];

		Test.startTest();

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c> {
			new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				Contract__c = contract.Id,
				Brand__c = brand.Id,
				Property__c = property.Id,
				RecordTypeId = pipRecordTypeId,
				Product__c = product.Id
			)
		};

		insert pipProjects;

		Test.stopTest();

		pipProjects = [
			SELECT Id, PIP_Writer__c, Architecture_Coordinator__c, Brand_Project_Manager__c, Design_Coordinator__c,
				DFS_User__c, Portfolio_Manager__c, Procurement_Coordinator__c, Procurement_Manager__c,
				Verifying_Manager__c
			FROM TASKRAY__Project__c];

		System.assertEquals(resources[1].Id, pipProjects[0].Architecture_Coordinator__c);
		System.assertEquals(resources[1].Id, pipProjects[0].Brand_Project_Manager__c);
		System.assertEquals(resources[1].Id, pipProjects[0].Design_Coordinator__c);
		System.assertEquals(resources[1].Id, pipProjects[0].DFS_User__c);
		System.assertEquals(resources[1].Id, pipProjects[0].Portfolio_Manager__c);
		System.assertEquals(resources[1].Id, pipProjects[0].Procurement_Coordinator__c);
		System.assertEquals(resources[1].Id, pipProjects[0].Procurement_Manager__c);
		System.assertEquals(resources[1].Id, pipProjects[0].Verifying_Manager__c);
	}

	/**
	 * @description Used to validate a bulk load of TASKRAY__Project__c records occur without failure.
	 *
	 * @return void
	 */
	@IsTest
	static void testPIPWriterAssignmentBULK() {
		Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
		SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();

		Test.startTest();
		// Assignment Setting Custom Metadata Type, mock
		List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_SETTING_NAME_PIP_WRITER,
				MasterLabel = ASSIGNMENT_SETTING_NAME_PIP_WRITER,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_RESOURCES,
				Field_To_Update__c = 'PIP_Writer__c',
				Matching_Criteria__c = 'PIP_Type__c;Brand__c;Product__c;App_Type__c;PIP_Method__c;State__c;' +
					'Country__c;All_States__c;All_Countries__c;',
				Record_Type_Developer_Name__c = 'PIP',
				Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_PIP_WRITER
			)
		};

		AssignmentProcessing.assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>(assignmentSettings);

		// Resource
		List<Resource__c> resources = new List<Resource__c>{
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_1_EMAIL].Id
			),
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_2_EMAIL].Id
			)
		};

		insert resources;

		// Get sObjectType from Record to get Record Type Id
		Assignment__c assignmentInstance = new Assignment__c();
		SObjectType sObjectTypeValue = assignmentInstance.getSObjectType();

		// Assignments
		List<Assignment__c> assignments = new List<Assignment__c>{
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[0].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = false,
				State__c = STATE_VERMONT,
				All_Countries__c = false,
				Country__c = COUNTRY_US
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					ASSIGNMENT_RECORD_TYPE_PIP_RESOURCES),
				Active__c = true,
				Assignee__c = resources[1].Id,
				Role__c = 'PIP Writer',
				Brand__c = BRAND_NAME_ASCEND,
				Product__c = PRODUCT_NAME_RESORT_COLLECTION,
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				All_States__c = true,
				State__c = '',
				All_Countries__c = false,
				Country__c = COUNTRY_US
			)
		};

		insert assignments;

		Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
		Brand__c brand = [SELECT Id FROM Brand__c WHERE External_ID__c = :BRAND_ASCEND_EXTERNAL_ID];
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
		Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
			:brand.Id];

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c>();

		for(Integer index = 0; index < 20; index++) {
			pipProjects.add(new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				Contract__c = contract.Id,
				Brand__c = brand.Id,
				Property__c = property.Id,
				RecordTypeId = pipRecordTypeId,
				Product__c = product.Id
			));
		}

		insert pipProjects;

		Test.stopTest();

		pipProjects = [SELECT Id, PIP_Writer__c FROM TASKRAY__Project__c];

		System.assertEquals(20, pipProjects.size());
		Integer count = 0;
		for(TASKRAY__Project__c pipProject : pipProjects) {
			if(pipProject.PIP_Writer__c != null) {
				count++;
			}
		}

		// Batch size set to 50 records are processed in Queueable in the unit test.
		system.assertEquals(20, count);
	}


	/**
	 * @description Used to test the positive test case for assigning a value to the PIP_Method__c field based on the
	 * data defined in the assignment rule. PIP Method should contain a value and it should match the assignment.
	 *
	 * @return void
	 */
	@IsTest
	static void testPIPMethodAssignmentPositive() {
		Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
		SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();


		// Assignment Setting Custom Metadata Type, mock
		List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_PIP_METHOD,
				MasterLabel = ASSIGNMENT_PIP_METHOD,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_METHOD,
				Field_To_Update__c = 'PIP_Method__c',
				Matching_Criteria__c = 'App_Type__c;Brand__c;',
				Record_Type_Developer_Name__c = 'PIP'
			)
		};

		AssignmentProcessing.assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>(assignmentSettings);

		// Resource
		List<Resource__c> resources = new List<Resource__c>{
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_1_EMAIL].Id
			)
		};

		insert resources;

		// Get sObjectType from Record to get Record Type Id
		Assignment__c assignmentInstance = new Assignment__c();
		SObjectType sObjectTypeValue = assignmentInstance.getSObjectType();


		// Assignments
		List<Assignment__c> assignments = new List<Assignment__c>{
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD),
				Active__c = true,
				Brand__c = 'Comfort;Comfort Suites;MainStay;Sleep',
				App_Type__c = 'Conversion;Choice Repositioning;Licensee Repositioning;Repositioning',
				PIP_Method__c = PIP_METHOD_TRAVEL
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD),
				Active__c = true,
				Brand__c = BRAND_NAME_CAMBRIA,
				App_Type__c = 'New Construction;Relicensing;Renewal',
				PIP_Method__c = PIP_METHOD_TRAVEL
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD),
				Active__c = true,
				Brand__c = 'Comfort;Comfort Suites;MainStay;Sleep',
				App_Type__c = 'Conversion;Choice Repositioning;Licensee Repositioning;New Construction;Relicensing;' +
					'Repositioning;Renewal',
				PIP_Method__c = PIP_METHOD_DESKTOP
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD),
				Active__c = true,
				Brand__c = 'Ascend;Clarion;Econo;Quality;Rodeway;Suburban;WoodSpring',
				App_Type__c = 'Conversion;Choice Repositioning;Licensee Repositioning;New Construction;Relicensing;' +
					'Repositioning;Renewal',
				PIP_Method__c = PIP_METHOD_DESKTOP
			)
		};

		insert assignments;

		Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
		Brand__c brand = [SELECT Id FROM Brand__c WHERE External_ID__c = :BRAND_ASCEND_EXTERNAL_ID];
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
		Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
			:brand.Id];

		Test.startTest();

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c>();

		for(Integer index = 0; index < 20; index++) {
			pipProjects.add(new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				Contract__c = contract.Id,
				Brand__c = brand.Id,
				Property__c = property.Id,
				RecordTypeId = pipRecordTypeId,
				Product__c = product.Id
			));
		}


		insert pipProjects;

		Test.stopTest();

		pipProjects = [SELECT Id, PIP_Writer__c, PIP_Method__c FROM TASKRAY__Project__c];

		System.assertNotEquals(null, pipProjects[0].PIP_Method__c);
		System.assertEquals(PIP_METHOD_DESKTOP, pipProjects[0].PIP_Method__c);
	}

	/**
	 * @description Used to test the negative test case for assigning a value to the PIP_Method__c field based on the
	 * data defined in the assignment rule. PIP Method should be null if a match is not found.
	 *
	 * @return void
	 */
	@IsTest
	static void testPIPMethodAssignmentNegative() {
		Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
		SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();


		// Assignment Setting Custom Metadata Type, mock
		List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_PIP_METHOD,
				MasterLabel = ASSIGNMENT_PIP_METHOD,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_METHOD,
				Field_To_Update__c = 'PIP_Method__c',
				Matching_Criteria__c = 'App_Type__c;Brand__c;PIP_Method__c;',
				Record_Type_Developer_Name__c = 'PIP'
			)
		};

		AssignmentProcessing.assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>(assignmentSettings);

		// Resource
		List<Resource__c> resources = new List<Resource__c>{
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_1_EMAIL].Id
			)
		};

		insert resources;

		// Get sObjectType from Record to get Record Type Id
		Assignment__c assignmentInstance = new Assignment__c();
		SObjectType sObjectTypeValue = assignmentInstance.getSObjectType();


		// Assignments
		List<Assignment__c> assignments = new List<Assignment__c>{
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD),
				Active__c = true,
				Brand__c = BRAND_NAME_CAMBRIA,
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				PIP_Method__c = PIP_METHOD_DESKTOP
			)
		};

		insert assignments;

		Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
		Brand__c brand = [SELECT Id FROM Brand__c WHERE External_ID__c = :BRAND_ASCEND_EXTERNAL_ID];
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
		Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
			:brand.Id];

		Test.startTest();

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c>();

		pipProjects.add(new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
			App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
			Contract__c = contract.Id,
			Brand__c = brand.Id,
			Property__c = property.Id,
			RecordTypeId = pipRecordTypeId,
			Product__c = product.Id
		));


		insert pipProjects;

		Test.stopTest();

		pipProjects = [SELECT Id, PIP_Writer__c, PIP_Method__c FROM TASKRAY__Project__c];
		System.assertEquals(null, pipProjects[0].PIP_Method__c);
	}


	/**
 * @description Used to test the positive test case for assigning a value to the PIP_Method__c field based on the
 * data defined in the assignment rule. PIP Method should contain a value and it should match the assignment.
 *
 * @return void
 */
	@IsTest
	static void testPIPMethodAssignmentPositiveCambria() {
		Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
		SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();


		// Assignment Setting Custom Metadata Type, mock
		List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
			new Assignment_Setting__mdt(
				Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
				DeveloperName = ASSIGNMENT_PIP_METHOD,
				MasterLabel = ASSIGNMENT_PIP_METHOD,
				Active__c = TRUE,
				Object__c = ASSIGNMENT_SETTING_OBJECT_PIP,
				Assignment_Rule_Type__c = ASSIGNMENT_RULE_TYPE_PIP_METHOD,
				Field_To_Update__c = 'PIP_Method__c',
				Matching_Criteria__c = 'App_Type__c;Brand__c;',
				Record_Type_Developer_Name__c = 'PIP'
			)
		};

		AssignmentProcessing.assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>(assignmentSettings);

		// Resource
		List<Resource__c> resources = new List<Resource__c>{
			new Resource__c(
				User__c = [SELECT Id FROM User WHERE username = : TEST_USER_1_EMAIL].Id
			)
		};

		insert resources;

		// Get sObjectType from Record to get Record Type Id
		Assignment__c assignmentInstance = new Assignment__c();
		SObjectType sObjectTypeValue = assignmentInstance.getSObjectType();


		// Assignments
		List<Assignment__c> assignments = new List<Assignment__c>{
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD),
				Active__c = true,
				Brand__c = 'Comfort;Comfort Suites;MainStay;Sleep',
				App_Type__c = 'Conversion;Choice Repositioning;Licensee Repositioning;Repositioning',
				PIP_Method__c = PIP_METHOD_TRAVEL
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD),
				Active__c = true,
				Brand__c = BRAND_NAME_CAMBRIA,
				App_Type__c = 'New Construction;Relicensing;Renewal',
				PIP_Method__c = PIP_METHOD_TRAVEL
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD),
				Active__c = true,
				Brand__c = 'Comfort;Comfort Suites;MainStay;Sleep',
				App_Type__c = 'Conversion;Choice Repositioning;Licensee Repositioning;New Construction;Relicensing;' +
					'Repositioning;Renewal',
				PIP_Method__c = PIP_METHOD_DESKTOP
			),
			new Assignment__c(
				RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
					AssignmentProcessing.ASSIGNMENT_RECORD_TYPE_PIP_METHOD),
				Active__c = true,
				Brand__c = 'Ascend;Clarion;Econo;Quality;Rodeway;Suburban;WoodSpring',
				App_Type__c = 'Conversion;Choice Repositioning;Licensee Repositioning;New Construction;Relicensing;' +
					'Repositioning;Renewal',
				PIP_Method__c = PIP_METHOD_DESKTOP
			)
		};

		insert assignments;

		Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
		Brand__c brand = [SELECT Id FROM Brand__c WHERE External_ID__c = :BRAND_ASCEND_EXTERNAL_ID];
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
		Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
			:brand.Id];

		Test.startTest();

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c>();

		//for(Integer index = 0; index < 200; index++) {
			pipProjects.add(new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				Contract__c = contract.Id,
				Brand__c = brand.Id,
				Property__c = property.Id,
				RecordTypeId = pipRecordTypeId,
				Product__c = product.Id
			));
		//}


		insert pipProjects;

		Test.stopTest();

		pipProjects = [SELECT Id, PIP_Writer__c, PIP_Method__c FROM TASKRAY__Project__c];

		System.assertNotEquals(null, pipProjects[0].PIP_Method__c);
		System.assertEquals(PIP_METHOD_DESKTOP, pipProjects[0].PIP_Method__c);
	}

}