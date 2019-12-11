/**
 * @description Test Class for TASKRAY_ProjectTriggerHelper
 *
 * @author Zach French
 * @date 2019-08-13
 */
@IsTest
public class TASKRAY_ProjectTriggerHelperTest {
	
	private static final String PIP_TYPE_APPLICATION = TASKRAY_ProjectTriggerHelper.PIP_TYPE_APPLICATION;
	private static final String PIP_METHOD_DESKTOP = TASKRAY_ProjectTriggerHelper.PIP_METHOD_DESKTOP;
	private static final String PIP_METHOD_TRAVEL = TASKRAY_ProjectTriggerHelper.PIP_METHOD_TRAVEL;
	private static final String TRAVEL_STATUS_NO_TRAVEL_NEEDED =
		TASKRAY_ProjectTriggerHelper.TRAVEL_STATUS_NO_TRAVEL_NEEDED;
	private static final String TRAVEL_STATUS_TRAVEL_PENDING =
		TASKRAY_ProjectTriggerHelper.TRAVEL_STATUS_TRAVEL_PENDING;
	private static final String PIP_SUB_STATUS_REVISIONS = TASKRAY_ProjectTriggerHelper.PIP_SUB_STATUS_REVISIONS;
	private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName();
	private static Id  pipRecordTypeId = recordTypeMap.get('PIP').getRecordTypeId();

	/**
	 * @description Used to setup test data used for unit tests
	 *
	 * @return void
	 */
	@TestSetup
	static void dataSetup() {
		List<PIP_SLA_Rule__c> pipSLARules = new List<PIP_SLA_Rule__c>{
			new PIP_SLA_Rule__c(
				Rule_Target_Field__c = 'Target_Completion_Date__c',
				Rule_Type__c = 'SLA',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				Days__c = 4
			),
			new PIP_SLA_Rule__c(
				Rule_Target_Field__c = 'Target_Completion_Date__c',
				Rule_Type__c = 'SLA',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_TRAVEL,
				Days__c = 10
			)
		};

		insert pipSLARules;

		Contract__c contract = new Contract__c(
			Name = 'Sample Contract',
			AD__c = 'Harper,Stephen',
			Application_Type__c = 'NEWC',
			Billable_Rooms__c = 109.0,
			Contract_Status__c = 'PROP',
			Effective_Contract_Flag__c = true,
			LR1__c = 'Branch,Susan',
			RVP__c = 'Manger,Tanner'
		);

		insert Contract;

	}

	/**
	 * @description Used to validate that the target assignment date field is being set on before insert for Method
	 * of PIP Method: Desktop
	 *
	 * @return void
	 */
	static testMethod void validateTargetAssignmentDateDesktopBeforeInsert() {

		Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];

		System.debug('RecordTypeId : ' + pipRecordTypeId);

		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Method__c = PIP_METHOD_DESKTOP,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			RecordTypeId = pipRecordTypeId,
			Contract__c = contract.Id
		);

		Test.startTest();
		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> projects = [SELECT Id, Target_Completion_Date__c FROM TASKRAY__Project__c];
		system.debug(projects);

		System.assertEquals(Date.newInstance(2019, 8, 19), projects[0].Target_Completion_Date__c);
	}

	/**
	 * @description Used to validate that the target assignment date field is being set on before insert for Method
	 * of PIP Method: Travel
	 *
	 * @return void
	 */
	static testMethod void validateTargetAssignmentDateTravelBeforeInsert() {

		Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];

		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Method__c = PIP_METHOD_TRAVEL,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			RecordTypeId = pipRecordTypeId,
			Contract__c = contract.Id
		);

		Test.startTest();
		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> projects = [SELECT Id, Target_Completion_Date__c FROM TASKRAY__Project__c];

		System.assertEquals(Date.newInstance(2019, 8, 27), projects[0].Target_Completion_Date__c);
	}

	/**
	 * @description Used to validate that the target assignment date field is being set on before update for Method
	 * of PIP Method: Desktop
	 *
	 * @return void
	 */
	static testMethod void validateTargetAssignmentDateDesktopBeforeUpdate() {

		Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];

		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Method__c = PIP_METHOD_DESKTOP,
			Contract__c = contract.Id,
			RecordTypeId = pipRecordTypeId,
			PIP_Assignment_Date__c = null
		);
		insert pipProject;

		Test.startTest();
		pipProject.PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13);
		update pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> projects = [SELECT Id, Target_Completion_Date__c FROM TASKRAY__Project__c];
		system.debug(projects);

		System.assertEquals(Date.newInstance(2019, 8, 19), projects[0].Target_Completion_Date__c);
	}

	/**
	 * @description Used to validate that the target assignment date field is being set on before update for Method
	 * of PIP Method: Travel
	 *
	 * @return void
	 */
	static testMethod void validateTargetAssignmentDateTravelBeforeUpdate() {

		Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];

		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST Assignment Date Null',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Method__c = PIP_METHOD_TRAVEL,
			RecordTypeId = pipRecordTypeId,
			Contract__c = contract.Id,
			PIP_Assignment_Date__c = null
		);
		insert pipProject;

		Test.startTest();
		pipProject.PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13);
		update pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> projects = [SELECT Id, Target_Completion_Date__c FROM TASKRAY__Project__c];
		system.debug(projects);

		System.assertEquals(Date.newInstance(2019, 8, 27), projects[0].Target_Completion_Date__c);
	}

	/**
	 * @description Used to validate that the Method changed on before update
	 *
	 * @return void
	 */
	static testMethod void validateTargetAssignmentDateMethodChangeBeforeUpdate() {

		Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];

		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Method__c = PIP_METHOD_TRAVEL,
			Contract__c = contract.Id,
			RecordTypeId = pipRecordTypeId,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13)
		);
		insert pipProject;

		Test.startTest();
		pipProject.PIP_Method__c = PIP_METHOD_DESKTOP;
		pipProject.Travel_Status__c = '';
		update pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> projects = [SELECT Id, Target_Completion_Date__c FROM TASKRAY__Project__c];
		system.debug(projects);

		System.assertEquals(Date.newInstance(2019, 8, 19), projects[0].Target_Completion_Date__c);
	}

	/**
	 * @description Used to validate that the PIP Type changed on before update
	 *
	 * @return void
	 */
	static testMethod void validateTargetAssignmentDatePIPTypeChangeBeforeUpdate() {

		Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];

		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = 'Other',
			PIP_Method__c = PIP_METHOD_TRAVEL,
			Contract__c = contract.Id,
			RecordTypeId = pipRecordTypeId,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13)
		);
		insert pipProject;

		Test.startTest();
		pipProject.PIP_Type__c = PIP_TYPE_APPLICATION;
		update pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> projects = [SELECT Id, Target_Completion_Date__c FROM TASKRAY__Project__c];
		system.debug(projects);

		System.assertEquals(Date.newInstance(2019, 8, 27), projects[0].Target_Completion_Date__c);
	}

	/**
	 * @description Used to validate that the target assignment date is null when the PIP Assignment Date is null on
	 * before insert
	 *
	 * @return void
	 */
	static testMethod void validateTargetAssignmentDateNullBeforeInsert() {

		Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];

		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = 'Other',
			PIP_Method__c = PIP_METHOD_DESKTOP,
			PIP_Assignment_Date__c = null,
			RecordTypeId = pipRecordTypeId,
			Contract__c = contract.Id
		);

		Test.startTest();
		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> projects = [SELECT Id, Target_Completion_Date__c FROM TASKRAY__Project__c];

		System.assertEquals(null, projects[0].Target_Completion_Date__c);
	}

	/**
	 * @description Used to validate that a bulk insert was succsessful on before insert
	 *
	 * @return void
	 */
	static testMethod void validateTargetAssignmentDateDesktopBeforeInsertBulk(){
		List<TASKRAY__Project__c> pips = new List<TASKRAY__Project__c>();
		Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];

		for(Integer i = 0; i < 200; i++) {
			TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				RecordTypeId = pipRecordTypeId,
				PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
				Contract__c = contract.Id
			);

			pips.add(pipProject);
		}

		Test.startTest();
		insert pips;
		Test.stopTest();

		List<TASKRAY__Project__c> insertedProjects = [SELECT Id,Target_Completion_Date__c FROM TASKRAY__Project__c];

		System.assertEquals(200, insertedProjects.size());

		for(TASKRAY__Project__c project : insertedProjects) {
			System.assertEquals(Date.newInstance(2019, 8, 19), project.Target_Completion_Date__c);
		}
	}

	/**
	 * @description Validate property code field is populated on TASKRAY__Project__c record. Value is being set by
	 * method in trigger.
	 *
	 * @return void
	 */
	@isTest
	private static void validatePropertyCodePopulatedPostive() {
		Contract__c contract = TestDataFactory.createContract(true);
		Property__c property = TestDataFactory.createProperty(true);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Method__c = PIP_METHOD_DESKTOP,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			RecordTypeId = pipRecordTypeId,
			Contract__c = contract.Id,
			Property__c = property.Id
		);
		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pips = [
			SELECT Id, Property_Code__c, Standard_GM_Email__c, Franchise_Owner__c, Property_Phone__c,
				Property_Fax__c, Additional_GM_Email__c
			FROM TASKRAY__Project__c];

		for(TASKRAY__Project__c pip : pips) {
			system.debug(pip);
			System.assertNotEquals(null, pip.Property_Code__c);
			System.assertNotEquals(null, pip.Standard_GM_Email__c);
			System.assertNotEquals(null, pip.Franchise_Owner__c);
			System.assertNotEquals(null, pip.Property_Phone__c);
			System.assertNotEquals(null, pip.Property_Fax__c);
			System.assertNotEquals(null, pip.Additional_GM_Email__c);
		}
	}

	/**
	 * @description Validate property code field is *not* populated on TASKRAY__Project__c record. Value is being set by
	 * method in trigger.
	 *
	 * @return void
	 */
	@isTest
	private static void validatePropertyCodePopulatedNegative() {
		Contract__c contract = TestDataFactory.createContract(true);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Method__c = PIP_METHOD_DESKTOP,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			RecordTypeId = pipRecordTypeId,
			Contract__c = contract.Id
		);
		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pips = [
			SELECT Id, Property_Code__c, Standard_GM_Email__c, Franchise_Owner__c, Property_Phone__c,
				Property_Fax__c, Additional_GM_Email__c
			FROM TASKRAY__Project__c];

		for(TASKRAY__Project__c pip : pips) {
			system.debug(pip);
			System.assertEquals(null, pip.Property_Code__c);
			System.assertEquals(null, pip.Standard_GM_Email__c);
			System.assertEquals(null, pip.Franchise_Owner__c);
			System.assertEquals(null, pip.Property_Phone__c);
			System.assertEquals(null, pip.Property_Fax__c);
			System.assertEquals(null, pip.Additional_GM_Email__c);
		}
	}

	/**
	 * @description Validate the Travel Status was updated to 'No Travel Needed' when the PIP Method is 'Desktop'
	 *
	 * @return void
	 */
	@isTest
	private static void validateTravelStatusNoTravelNeeded() {
		Contract__c contract = TestDataFactory.createContract(true);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Method__c = PIP_METHOD_DESKTOP,
			RecordTypeId = pipRecordTypeId,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			Contract__c = contract.Id
		);
		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pips = [
			SELECT Id, Travel_Status__c
			FROM TASKRAY__Project__c];

		for(TASKRAY__Project__c pip : pips) {
			System.assertEquals(TRAVEL_STATUS_NO_TRAVEL_NEEDED, pip.Travel_Status__c);
		}
	}

	/**
	 * @description Validate the Travel Status was updated to 'Travel Pending' when the PIP Method is 'Travel'
	 *
	 * @return void
	 */
	@isTest
	private static void validateTravelStatusTravelPending() {
		Contract__c contract = TestDataFactory.createContract(true);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Method__c = PIP_METHOD_TRAVEL,
			RecordTypeId = pipRecordTypeId,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			Contract__c = contract.Id
		);
		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pips = [
			SELECT Id, Travel_Status__c
			FROM TASKRAY__Project__c];

		for(TASKRAY__Project__c pip : pips) {
			System.assertEquals(TRAVEL_STATUS_TRAVEL_PENDING, pip.Travel_Status__c);
		}
	}

	/**
	 * @description Validate the Travel Status was updated to null when the PIP Method is null
	 *
	 * @return void
	 */
	@isTest
	private static void validateTravelStatusNull() {
		Contract__c contract = TestDataFactory.createContract(true);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			RecordTypeId = pipRecordTypeId,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			Contract__c = contract.Id
		);
		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pips = [
			SELECT Id, Travel_Status__c
			FROM TASKRAY__Project__c];

		for(TASKRAY__Project__c pip : pips) {
			System.assertEquals(null, pip.Travel_Status__c);
		}
	}

	/**
	 * @description Validate the DFS User is populated that the DFS User Email was updated.
	 *
	 * @return void
	 */
	@isTest
	private static void validateDFSUserEmailNotNull() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			Contract__c = contract.Id,
			DFS_User__c = resource.Id,
			PIP_Writer__c = resource.Id,
			Licensee_Rep__c = resource.Id,
			Portfolio_Manager__c = resource.Id,
			Brand_Project_Manager__c = resource.Id,
			Procurement_Manager__c = resource.Id,
			Design_Coordinator__c = resource.Id,
			RecordTypeId = pipRecordTypeId,
			Procurement_Coordinator__c = resource.Id,
			Verifying_Manager__c = resource.Id
		);
		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pips = [
			SELECT Id, DFS_User_Email__c
			FROM TASKRAY__Project__c];

		for(TASKRAY__Project__c pip : pips) {
			System.assertNotEquals(null, pip.DFS_User_Email__c);
		}
	}

	/**
	 * @description Validate a PIP Written Alert email template was sent for when the Sub Status is 'Draft'.
	 *
	 * @return void
	 */
	@isTest
	private static void validatePIPWrittenAlertEmailSentSubStatusDraft() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c>();
		for(Integer index = 0; index < 200; index++) {
			TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
				Contract__c = contract.Id,
				DFS_User__c = resource.Id,
				RecordTypeId = pipRecordTypeId,
				TASKRAY__trStatus__c = 'Writing',
				Sub_Status__c = 'Draft'
			);
			pipProjects.add(pipProject);
		}

		Test.startTest();
		insert pipProjects;

		// Assert must be done inside start/stop test as a new apex context is created outside the start/stop and
		// email invocations will reflect as 0.
		System.assertEquals(1, Limits.getEmailInvocations());
		Test.stopTest();
	}

	/**
	 * @description Validate a PIP Written Alert email template was sent for when the Sub Status is 'Send to Legal'.
	 *
	 * @return void
	 */
	@isTest
	private static void validatePIPWrittenAlertEmailSentSubStatusSentToLegal() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		Test.startTest();
		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c>();
		for(Integer index = 0; index < 200; index++) {
			TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
				Contract__c = contract.Id,
				DFS_User__c = resource.Id,
				RecordTypeId = pipRecordTypeId,
				TASKRAY__trStatus__c = 'Writing',
				Sub_Status__c = 'Sent to Legal'
			);
			pipProjects.add(pipProject);
		}

		insert pipProjects;

		// Assert must be done inside start/stop test as a new apex context is created outside the start/stop and
		// email invocations will reflect as 0.
		System.assertEquals(1, Limits.getEmailInvocations());
		Test.stopTest();
	}


	/**
	 * @description Validate a PIP Status Effective Date set on insert.
	 *
	 * @return void
	 */
	@isTest
	private static void validatePIPStatusEffectiveDateOnInsert() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			Contract__c = contract.Id,
			DFS_User__c = resource.Id,
			RecordTypeId = pipRecordTypeId,
			TASKRAY__trStatus__c = 'Writing',
			Sub_Status__c = 'Sent to Legal'
		);

		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pips = [SELECT Id, PIP_Status_Effective_Date__c FROM TASKRAY__Project__c];

		for(TASKRAY__Project__c pip : pips) {
			System.assertNotEquals(null, pip.PIP_Status_Effective_Date__c);
		}
	}

	/**
	 * @description Validate the name field was set on a PIP record was changed.
	 *
	 * @return void
	 */
	@isTest
	private static void validatePIPName() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			Contract__c = contract.Id,
			DFS_User__c = resource.Id,
			RecordTypeId = pipRecordTypeId,
			TASKRAY__trStatus__c = 'Writing',
			Sub_Status__c = 'Sent to Legal'
		);

		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pips = [SELECT Id, Name FROM TASKRAY__Project__c];

		for(TASKRAY__Project__c pip : pips) {
			System.debug('pip.Name : ' + pip);
			System.assertNotEquals(null, pip.Name);
		}
	}

	/**
	 * @description Validate the name field was set on a PIP record was changed.
	 *
	 * @return void
	 */
	@isTest
	private static void validatePIPNameForDataMigration() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
				Name = 'PIP TEST 10/14/2019',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
				Contract__c = contract.Id,
				DFS_User__c = resource.Id,
				RecordTypeId = pipRecordTypeId,
				TASKRAY__trStatus__c = 'Writing',
				Sub_Status__c = 'Sent to Legal'
		);

		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pips = [SELECT Id, Name FROM TASKRAY__Project__c];

		for(TASKRAY__Project__c pip : pips) {
			System.assertEquals('PIP TEST 10/14/2019', pip.Name);
		}
	}

	/**
	 * @description Validate the OwnerId is the same value as the PIP Writer. Needs to be a user field.
	 *
	 * @return void
	 */
	@isTest
	private static void validatePIPOwnerIdSet() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			Contract__c = contract.Id,
			RecordTypeId = pipRecordTypeId,
			PIP_Writer__c = resource.Id
		);
		insert pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pips = [
			SELECT Id, OwnerId, PIP_Writer__r.User__c
			FROM TASKRAY__Project__c];

		for(TASKRAY__Project__c pip : pips) {
			System.assertEquals(pip.PIP_Writer__r.User__c, pip.OwnerId);
		}
	}

	/**
	 * @description Validate the Number of Revisions (Revision__c) increased when the Sub Status is 'Revisions' on
	 * insert
	 *
	 * @return void
	 */
	@isTest
	private static void validateNumberOfRevisionIncreasedOnInsert() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			Contract__c = contract.Id,
			PIP_Writer__c = resource.Id,
			RecordTypeId = pipRecordTypeId,
			TASKRAY__trStatus__c = 'Negotiations',
			Sub_Status__c = PIP_SUB_STATUS_REVISIONS
		);
		insert pipProject;


		List<TASKRAY__Project__c> pips = [
			SELECT Id, Revision__c
			FROM TASKRAY__Project__c];

		// Validate Revisions on Insert
		for(TASKRAY__Project__c pip : pips) {
			System.assertEquals(1, pip.Revision__c);
		}

		pipProject.Sub_Status__c = 'In Negotiation';
		update pipProject;
		Test.stopTest();

		pips = [
			SELECT Id, Revision__c, Sub_Status__c
			FROM TASKRAY__Project__c];
		system.debug(pips);

		// Validate Revision did not increment
		for(TASKRAY__Project__c pip : pips) {
			System.assertEquals(1, pip.Revision__c);
		}
	}

	/**
	 * @description Validate the Number of Revisions (Revision__c) increased when the Sub Status is 'Revisions' on
	 * update
	 *
	 * @return void
	 */
	@isTest
	private static void validateNumberOfRevisionIncreasedOnUpdate() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		Test.startTest();
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			Contract__c = contract.Id,
			PIP_Writer__c = resource.Id,
			RecordTypeId = pipRecordTypeId,
			TASKRAY__trStatus__c = 'Negotiations',
			Sub_Status__c = 'In Negotiation'
		);
		insert pipProject;

		List<TASKRAY__Project__c> pips = [
			SELECT Id, Revision__c
			FROM TASKRAY__Project__c];

		// Validate Revisions on Insert
		for(TASKRAY__Project__c pip : pips) {
			System.assertEquals(0, pip.Revision__c);
		}

		pipProject.Sub_Status__c = PIP_SUB_STATUS_REVISIONS;
		update pipProject;
		Test.stopTest();

		pips = [
			SELECT Id, Revision__c, Sub_Status__c
			FROM TASKRAY__Project__c];

		// Validate Revisions on Sub Status update to 'Revision'
		for(TASKRAY__Project__c pip : pips) {
			System.assertEquals(1, pip.Revision__c);
		}
	}

	/**
	 * @description Validate the Update Due Date field was set to true on related PIP Items
	 *
	 * @return void
	 */
	@isTest
	private static void validateUpdateDueDatePIPItems() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
			Name = 'PIP TEST',
			PIP_Type__c = PIP_TYPE_APPLICATION,
			PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
			Contract__c = contract.Id,
			PIP_Writer__c = resource.Id,
			RecordTypeId = pipRecordTypeId,
			TASKRAY__trStatus__c = 'Negotiations',
			Sub_Status__c = 'In Negotiation'
		);
		insert pipProject;

		List<TASKRAY__Project_Task__c> pipItems = new List<TASKRAY__Project_Task__c> {
			new TASKRAY__Project_Task__c(
				Name = 'Test PIP Item 1',
				PI_Due_In_Months__c = 1,
				TASKRAY__Project__c = pipProject.Id
			),
			new TASKRAY__Project_Task__c(
				Name = 'Test PIP Item 2',
				PI_Due_In_Months__c = 1,
				TASKRAY__Project__c = pipProject.Id
			)
		};
		insert pipItems;

		Test.startTest();
		pipProject.COMM_Date__c = Date.today().addMonths(1);
		update pipProject;
		Test.stopTest();

		List<TASKRAY__Project__c> pip = [SELECT Id, COMM_Date__c FROM TASKRAY__Project__c];
		for(TASKRAY__Project_Task__c updatedPIPItem : [SELECT Id, Update_Due_Date__c, PI_Item_Due_Date__c FROM
			TASKRAY__Project_Task__c]) {
			// There is a function which sets the Update Due Date flag back to false on the PIP Item so we cannot
			// test for flag equal to true. Assertion is validation the PI Item Due Date is not null.
			System.assertNotEquals(null, updatedPIPItem.PI_Item_Due_Date__c);
		}
	}

	/**
	 * @description Validate the Quantity field is updated on related PIP Items when number of rooms is changed on PIP
	 *
	 * @return void
	 */
	@isTest
	private static void validateQuantityPIPItems() {
		Contract__c contract = TestDataFactory.createContract(true);
		User user = TestDataFactory.createPIPManagerUser();
		Resource__c resource = TestDataFactory.createResource(user.Id);

		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
				Contract__c = contract.Id,
				PIP_Writer__c = resource.Id,
				RecordTypeId = pipRecordTypeId,
				TASKRAY__trStatus__c = 'Negotiations',
				Sub_Status__c = 'In Negotiation'
		);
		insert pipProject;

		PIP_Library_Item__c pipPerRoomLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_ROOM);
		insert pipPerRoomLibraryItem;
		PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
		insert pipPerBuildingLibraryItem;

		List<TASKRAY__Project_Task__c> pipItems = new List<TASKRAY__Project_Task__c> {
				new TASKRAY__Project_Task__c(
						Name = 'Test PIP Item 1',
						PI_Due_In_Months__c = 1,
						PIP_Library_Item__c=pipPerRoomLibraryItem.Id,
						TASKRAY__Project__c = pipProject.Id
				),
				new TASKRAY__Project_Task__c(
						Name = 'Test PIP Item 2',
						PI_Due_In_Months__c = 1,
						TASKRAY__Project__c = pipProject.Id
				),
				new TASKRAY__Project_Task__c(
						Name = 'Test PIP Item 3',
						PI_Due_In_Months__c = 1,
						PIP_Library_Item__c=pipPerBuildingLibraryItem.Id,
						TASKRAY__Project__c = pipProject.Id
				)
		};
		insert pipItems;

		Test.startTest();
		pipProject.Number_of_Rooms__c = 10;
		update pipProject;
		Test.stopTest();

		for(TASKRAY__Project_Task__c updatedPIPItem : [SELECT Id, Name, PI_Quantity__c, PI_Item_Due_Date__c FROM
				TASKRAY__Project_Task__c]) {
			// There is a function which sets the Update Due Date flag back to false on the PIP Item so we cannot
			// test for flag equal to true. Assertion is validation the PI Item Due Date is not null.
			if(updatedPIPItem.Name == 'Test PIP Item 1') {
				System.assertEquals(10, updatedPIPItem.PI_Quantity__c);
			}
			if(updatedPIPItem.Name == 'Test PIP Item 2') {
				System.assertEquals(null, updatedPIPItem.PI_Quantity__c);
			}
			if(updatedPIPItem.Name == 'Test PIP Item 3') {
				System.assertEquals(1, updatedPIPItem.PI_Quantity__c);
			}

		}
	}

	/**
    * Method Tested: assignRecordForApproval
    * | Scenario: PIP record is created and submitted for approval if App Type is Conversion, New Construction,
    * Relicensing, Renewal, Repositioning
    * | Expected Result: Record is submitted for Approval
    **/
	@IsTest static void PIPAssignedForApprovalPositive(){
		//Deal
		Opportunity deal = TestDataFactory.createDeal(false);
		deal.Approval_Status__c = 'Submitted for Sales Approval';
		insert deal;

		//Contract
		Contract__c contract = TestDataFactory.createContract(false);
		contract.Deal__c = deal.Id;
		insert contract;

		//PIP
		TaskRay__Project__c PIP = TestDataFactory.createPIP(false);
		PIP.App_Type__c = 'Conversion';
		PIP.TASKRAY__trStatus__c = 'Requested';
		PIP.Sub_Status__c = 'Pending Approval';
		PIP.Contract__c = contract.Id;
		PIP.RecordTypeId = pipRecordTypeId;

		Test.startTest();
		insert PIP;
		Test.stopTest();

		List<ProcessInstance> pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :PIP.Id];
		System.assertEquals(1,pi.size());

		Boolean isRecordLocked = Approval.isLocked(PIP.Id);
		System.assertEquals(false,isRecordLocked);
	}

	/**
	* Method Tested: assignRecordForApproval
	* | Scenario: PIP record is created from Deal with App Type Relicensing/Repositioning
	* | Expected Result: Record is not submitted for Approval
	**/
	@IsTest static void PIPAssignedForApprovalAfterUpdate(){
		//Deal
		Opportunity deal = TestDataFactory.createDeal(false);
		deal.Approval_Status__c = 'Submitted for Sales Approval';
		insert deal;

		//Contract
		Contract__c contract = TestDataFactory.createContract(false);
		contract.Deal__c = deal.Id;
		insert contract;

		//PIP
		TaskRay__Project__c PIP = TestDataFactory.createPIP(false);
		PIP.App_Type__c = 'Relicensing/Repositioning';
		PIP.TASKRAY__trStatus__c = 'Requested';
		PIP.Sub_Status__c = 'Pending Approval';
		PIP.Contract__c = contract.Id;
		PIP.RecordTypeId = pipRecordTypeId;

		insert PIP;

		List<ProcessInstance> pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :PIP.Id];
		System.assertEquals(0,pi.size());

		PIP.App_Type__c = 'Conversion';
		Test.startTest();
		update PIP;
		Test.stopTest();

		List<ProcessInstance> pi2 = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :PIP.Id];
		System.assertEquals(1,pi2.size());

		Boolean isRecordLocked = Approval.isLocked(PIP.Id);
		System.assertEquals(false,isRecordLocked);
	}

	/**
    * Method Tested: sendPIPVerifiedEmails
    * | Scenario: PIP record is created and App Type is not Conversion,New Construction,Repositioning and
    *  PIP Type is application and record is Verified
    * | Expected Result: Email is sent to AD
    **/
	@IsTest
	private static void validatePIPVerifiedEmailWasSent() {
		Resource__c resource = TestDataFactory.createResourceNoUser(true);
		Property__c property = TestDataFactory.createProperty(false);
		property.AD_User__c = resource.Id;
		insert property;
		TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
				Property__c = property.Id,
				TASKRAY__trStatus__c = 'Active',
				RecordTypeId = pipRecordTypeId,
				Sub_Status__c = 'Verified',
				App_Type__c = 'Renewal'
		);

		Test.startTest();
		insert pipProject;
		// Assert must be done inside start/stop test as a new apex context is created outside the start/stop and
		// email invocations will reflect as 0.
		System.assertEquals(1, Limits.getEmailInvocations());
		Test.stopTest();
	}

	/**
	* Method Tested: setSubmittedDate
	* | Scenario: PIP record is created or updated and Sub Status is updated to Sent to legal, Rejected by Management or
	* Draft and the Submitted date is null
	* | Submitted date is set to today
	**/
	@IsTest static void updatedPIPSubmittedDateInsert(){
		TaskRay__Project__c PIP = TestDataFactory.createPIP(false);
		PIP.App_Type__c = 'Conversion';
		PIP.TASKRAY__trStatus__c = 'Writing';
		PIP.Sub_Status__c = 'Draft';
		PIP.RecordTypeId = pipRecordTypeId;

		Test.startTest();
		insert PIP;
		Test.stopTest();

		TASKRAY__Project__c insertedPIP = [SELECT Submitted_Date__c FROM TASKRAY__Project__c];
		System.assertEquals(Date.today(),insertedPIP.Submitted_Date__c);
	}

	/**
	* Method Tested: setSubmittedDate
	* | Scenario: PIP record is created or updated and Sub Status is updated to Sent to legal, Rejected by Management or
	* Draft and the Submitted date is null
	* | Submitted date is set to today
	**/
	@IsTest static void updatedPIPSubmittedDateUpdate(){
		TaskRay__Project__c PIP = TestDataFactory.createPIP(false);
		PIP.App_Type__c = 'Conversion';
		PIP.TASKRAY__trStatus__c = 'Requested';
		PIP.Sub_Status__c = 'Pending Approval';
		PIP.RecordTypeId = pipRecordTypeId;
		insert PIP;

		PIP.TASKRAY__trStatus__c = 'Writing';
		PIP.Sub_Status__c = 'Rejected by Management';
		Test.startTest();
		update PIP;
		Test.stopTest();

		TASKRAY__Project__c updatedPIP = [SELECT Submitted_Date__c FROM TASKRAY__Project__c];
		System.assertEquals(Date.today(),updatedPIP.Submitted_Date__c);
	}
}