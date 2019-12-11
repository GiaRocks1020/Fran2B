/**
 * @description Test class for BusinessDaysUtility
 *
 * @author Zach French
 * @date 2019-08-14
 */
@IsTest
private class BusinessDaysUtilityTest {
	private static final String usUsername = 'testUserUS@choicehotels.com';
	private static final String gbUsername = 'testUserGB@choicehotels.com';
	private static Profile sysAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
	private static final String PIP_TYPE_APPLICATION = StaticValue.getStaticValueText('PIP_TYPE_APPLICATION');
	private static final String PIP_METHOD_DESKTOP = StaticValue.getStaticValueText('PIP_METHOD_DESKTOP');
	private static final String PIP_METHOD_TRAVEL = StaticValue.getStaticValueText('PIP_METHOD_TRAVEL');

	/** 
	 * @description Used to setup test data used for unit tests
	 * 
	 * @return void
	 */
	@TestSetup
	static void dataSetup() {

		List<User> users = new List<User>{
			new User(
				Alias = 'tuserUS',
				Email='testuserUS@choicehotels.com',
				EmailEncodingKey='UTF-8',
				FirstName = 'Test',
				LastName='UserUS',
				LanguageLocaleKey='en_US',
				LocaleSidKey='en_US',
				ProfileId = sysAdmin.Id,
				TimeZoneSidKey = 'America/Los_Angeles',
				UserName = usUsername
			),
			new User(
				Alias = 'tuserGB',
				Email='testuserGB@choicehotels.com',
				EmailEncodingKey='UTF-8',
				FirstName = 'Test',
				LastName='UserGB',
				LanguageLocaleKey='en_US',
				LocaleSidKey='en_GB',
				ProfileId = sysAdmin.Id,
				TimeZoneSidKey = 'Europe/London',
				UserName = gbUsername
			)
		};

		insert users;

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
	 * @description Used to validate business days are added based on input
	 *  
	 * @return void
	 */
	@IsTest
	static void testAddBusinessDays() {

		Date startDate = Date.newInstance(2019, 7, 29);
		Integer businessDaysToAdd = 4;

		Date calculatedDate = BusinessDaysUtility.addBusinessDays(startDate, businessDaysToAdd);
		system.debug(calculatedDate);

		System.assertEquals(Date.newInstance(2019, 8, 2), calculatedDate);
	}

	/**
	 * @description Used to validate business day calculation with a holiday for a US User
	 *
	 * @return void
	 */
	@IsTest
	static void testSetPIPTargetAssignmentDateWithHolidayUSUser() {

		Holiday holidayDay = new Holiday(
			Name = 'Test Holiday',
			ActivityDate = Date.newInstance(2019, 8, 2)
		);

		insert holidayDay;

		Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c> {
			new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
				Contract__c = contract.Id)
		};

		List<TASKRAY__Project__c> targetAssignmentDates = new List<TASKRAY__Project__c>();
		Test.starttest();
		User user = [SELECT ID FROM User WHERE username = :usUsername];
		System.runAs(user){
			targetAssignmentDates = BusinessDaysUtility.setPIPTargetAssignmentDate(pipProjects);
		}
		Test.stoptest();

		system.debug(targetAssignmentDates);
		System.assertEquals(
			Date.newInstance(2019, 8, 5),
			targetAssignmentDates[0].Target_Completion_Date__c
		);
	}

	/**
	 * @description Used to validate business day calculation with a holiday for a GB User
	 *
	 * @return void
	 */
	@IsTest
	static void testSetPIPTargetAssignmentDateWithHolidayGBUser() {

		Holiday holidayDay = new Holiday(
			Name = 'Test Holiday',
			ActivityDate = Date.newInstance(2019, 8, 2)
		);

		insert holidayDay;

		Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c> {
			new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
				Contract__c = contract.Id)
		};

		List<TASKRAY__Project__c> targetAssignmentDates = new List<TASKRAY__Project__c>();
		Test.starttest();
		User user = [SELECT ID FROM User WHERE username = :gbUsername];
		System.runAs(user){
			targetAssignmentDates = BusinessDaysUtility.setPIPTargetAssignmentDate(pipProjects);
		}
		Test.stoptest();

		system.debug(targetAssignmentDates);
		System.assertEquals(
			Date.newInstance(2019, 8, 5),
			targetAssignmentDates[0].Target_Completion_Date__c
		);
	}
}