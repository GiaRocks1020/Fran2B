/**
 * @description Test class for cloneTaskRayProjectTemplate
 *
 * @author Creston Kuenzi
 * @date 2019-08-25
 */
@IsTest
public class cloneTaskRayProjectTemplateTest {

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

	public static String ASSIGNMENT_SETTING_OBJECT_PIP = 'TASKRAY__Project__c';
    
	/**
	 * @description Data setup method used for unit tests
	 *
	 * @return void
	 */
	@TestSetup
	static void dataSetup() {

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

		List<TASKRAY__Project__c> pipProjects = new List<TASKRAY__Project__c> {
			new TASKRAY__Project__c(
				Name = 'PIP TEST',
				PIP_Type__c = PIP_TYPE_APPLICATION,
				PIP_Method__c = PIP_METHOD_DESKTOP,
				PIP_Assignment_Date__c = Date.newInstance(2019, 7, 29),
				App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
				Contract__c = contracts[0].Id,
				Brand__c = brands[0].Id,
				Property__c = properties[0].Id,
				Product__c = products[0].Id,
                TASKRAY__trTemplate__c = true
			)
		};

		insert pipProjects;
        
	}
    
    
	/**
	 * @description Used to test the positive test case for cloning a new project
	 *
	 * @return void
	 */
	@IsTest
	static void testCloneProjectPositive() {
        List<TASKRAY__Project__c> pipProjects = [SELECT Id from TASKRAY__Project__c WHERE TASKRAY__trTemplate__c = true LIMIT 1];
		
        List<Id> idList = new List<Id>{pipProjects[0].Id};
		Test.startTest();
			
        List<String> newProjectIds = cloneTaskRayProjectTemplate.cloneTaskRayProjectTemplate(idList);
        	
		Test.stopTest();   
        
        List<TASKRAY__Project__c> projectsReturned = [SELECT Id, TASKRAY__trTemplate__c from TASKRAY__Project__c WHERE Id =: newProjectIds[0] AND TASKRAY__trTemplate__c = false LIMIT 1];
		System.assertEquals(1, projectsReturned.size());               
        
    }

	/**
	 * @description Used to test the negative test case for cloning a new project where
	 * 				a template could not be found
	 *
	 * @return void
	 */
	@IsTest
	static void testCloneProjectNegative() {
        List<TASKRAY__Project__c> pipProjects = [SELECT Id from TASKRAY__Project__c WHERE TASKRAY__trTemplate__c = true LIMIT 1];
		
        List<Id> idList = new List<Id>();
		Test.startTest();
			
        List<String> newProjectIds = cloneTaskRayProjectTemplate.cloneTaskRayProjectTemplate(idList);
        	
		Test.stopTest();   
        
		System.assertEquals(null, newProjectIds);               
    }
}