/**
 * @description Test class for AssignmentProcessing
 *
 * @author Pradnya Desai
 * @date 2019-11-26
 */
@IsTest
private class OpeningResourceAssignmentTest {

    private static Profile sysAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    private static final String BRAND_NAME_ASCEND = 'Ascend';
    private static final String BRAND_NAME_CAMBRIA = 'Cambria';
    private static final String STATE_VERMONT = 'US-VT';
    private static final String STATE_ARIZONA = 'US-AZ';
    private static final String COUNTRY_US = 'US';
    private static final String ASSIGNMENT_SETTING_ROLE_TYPE_OPD = 'OPD';
    private static final String ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECT= 'Architect';
    private static final String ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES = 'Opening_Resources';
    private static final String TEST_USER_1_EMAIL = 'TestUser1US1@example.com';
    private static final String TEST_USER_2_EMAIL = 'TestUser2US2@example.com';
    private static String ASSIGNMENT_SETTING_OBJECT_PROJECT = 'TASKRAY__Project__c';
    private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id  openingRecordTypeId = recordTypeMap.get('Opening').getRecordTypeId();
    private static final String CONTRACT_NAME_SAMPLE_CONTRACT = 'Sample Contract';
    private static final String PRODUCT_CODE_RE = 'RE';
    private static final String PROPERTY_CODE_VT019= 'VT019';
    private static final String APP_TYPE_NEW_CONSTRUCTION = 'New Construction';

    /**
	 * @description Data setup method used for unit tests
	 *
	 * @return void
	 */
    @TestSetup
    static void dataSetup() {

        List<User> users = new List<User>();
        User user1 = TestDataFactory.getUserDetails('Test', 'User1US1', sysAdmin.Id);
        User user2 = TestDataFactory.getUserDetails('Test', 'User2US2', sysAdmin.Id);
        User user3 = TestDataFactory.getUserDetails('Test', 'User3US3', sysAdmin.Id);

        users.add(user1);
        users.add(user2);
        users.add(user3);
        insert users;

        Property__c property = TestDataFactory.createVTProperty(true);

        Brand__c brand = TestDataFactory.createBrand(true,'Ascend');
        Brand__c brandCambria = TestDataFactory.createBrand(true,'Cambria');


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

        TestDataFactory.createProductRE(true,'Resort Collection',brand.Id,'AC-RE');
        TestDataFactory.createProductRE(true,'Resort Collection',brandCambria.Id,'CM-RE');


    }


    /**
      * @description Used to test the positive test case for retrieving a OPD assignment for opening based upon assignment rules.
      *
      * @return void
      */
    @IsTest
    static void testOPDAssignmentNegative() {
        Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
        SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();


        // Assignment Setting Custom Metadata Type, mock
        List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
                new Assignment_Setting__mdt(
                        Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
                        DeveloperName = ASSIGNMENT_SETTING_ROLE_TYPE_OPD,
                        MasterLabel = ASSIGNMENT_SETTING_ROLE_TYPE_OPD,
                        Active__c = TRUE,
                        Object__c = ASSIGNMENT_SETTING_OBJECT_PROJECT,
                        Assignment_Rule_Type__c = ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES,
                        Field_To_Update__c = 'OPD__c',
                        Matching_Criteria__c = 'Brand__c;State__c;Country__c;',
                        Record_Type_Developer_Name__c = 'Opening',
                        Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_OPD
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
        System.debug('Record Type Id : ' + AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
                ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES));
        // Assignments
        Assignment__c stateDifferentAssignment =
                new Assignment__c(
                        RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
                                ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES),
                        Active__c = true,
                        Assignee__c = resources[0].Id,
                        Role__c = 'OPD',
                        Brand__c = BRAND_NAME_ASCEND,
                        All_States__c = false,
                        State__c = STATE_ARIZONA,
                        All_Countries__c = false,
                        Country__c = COUNTRY_US
                );
        Assignment__c brandDifferentAssignment =
                new Assignment__c(
                        RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
                                ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES),
                        Active__c = true,
                        Assignee__c = resources[0].Id,
                        Role__c = 'OPD',
                        Brand__c = BRAND_NAME_CAMBRIA,
                        All_States__c = false,
                        State__c = STATE_VERMONT,
                        All_Countries__c = false,
                        Country__c = COUNTRY_US
                );

        List<Assignment__c> assignments =  new List<Assignment__c>();
        assignments.add(stateDifferentAssignment);
        assignments.add(brandDifferentAssignment);

        insert assignments;

        Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
        Brand__c brand = [SELECT Id FROM Brand__c WHERE Name = :BRAND_NAME_ASCEND];
        Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
        Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
                :brand.Id];

        Test.startTest();

        List<TASKRAY__Project__c> openingProjects = new List<TASKRAY__Project__c> {
                new TASKRAY__Project__c(
                        Name = 'Opening TEST',
                        App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
                        Contract__c = contract.Id,
                        Brand__c = brand.Id,
                        Property__c = property.Id,
                        Product__c = product.Id,
                        RecordTypeId = openingRecordTypeId
                )
        };

        insert openingProjects;

        Test.stopTest();

        openingProjects = [SELECT Id, OPD__c FROM TASKRAY__Project__c];
        System.assertEquals(null, openingProjects[0].OPD__c);
    }

    /**
     * @description Used to test the negative test case for retrieving a OPD assignment for Opening based upon assignment rules.
     *
     * @return void
     */
    @IsTest
    static void testOPDAssignmentPositive() {
        Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
        SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();


        // Assignment Setting Custom Metadata Type, mock
        List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
                new Assignment_Setting__mdt(
                        Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
                        DeveloperName = ASSIGNMENT_SETTING_ROLE_TYPE_OPD,
                        MasterLabel = ASSIGNMENT_SETTING_ROLE_TYPE_OPD,
                        Active__c = TRUE,
                        Object__c = ASSIGNMENT_SETTING_OBJECT_PROJECT,
                        Assignment_Rule_Type__c = ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES,
                        Field_To_Update__c = 'OPD__c',
                        Matching_Criteria__c = 'Brand__c;State__c;Country__c;',
                        Record_Type_Developer_Name__c = 'Opening',
                        Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_OPD
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
        System.debug('Record Type Id : ' + AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
                ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES));
        // Assignments
        List<Assignment__c> assignments = new List<Assignment__c>{
                new Assignment__c(
                        RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
                                ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES),
                        Active__c = true,
                        Assignee__c = resources[0].Id,
                        Role__c = 'OPD',
                        Brand__c = BRAND_NAME_ASCEND,
                        All_States__c = false,
                        State__c = STATE_VERMONT,
                        All_Countries__c = false,
                        Country__c = COUNTRY_US
                )
        };

        insert assignments;

        Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
        Brand__c brand = [SELECT Id FROM Brand__c WHERE Name = :BRAND_NAME_ASCEND];
        Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
        Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
                :brand.Id];

        Test.startTest();

        List<TASKRAY__Project__c> openingProjects = new List<TASKRAY__Project__c> {
                new TASKRAY__Project__c(
                        Name = 'Opening TEST',
                        App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
                        Contract__c = contract.Id,
                        Brand__c = brand.Id,
                        Property__c = property.Id,
                        Product__c = product.Id,
                        RecordTypeId = openingRecordTypeId
                )
        };

        insert openingProjects;

        Test.stopTest();

        openingProjects = [SELECT Id, OPD__c, OPD__r.Name FROM TASKRAY__Project__c];
        System.assertEquals('Test User1US1', openingProjects[0].OPD__r.Name);
    }

    /**
     * @description Used to test the Positive test case for retrieving a Architect assignment for Opening based upon assignment rules.
     *
     * @return void
     */
    @IsTest
    static void testArchitectAssignmentPositive() {
        Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
        SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();


        // Assignment Setting Custom Metadata Type, mock
        List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
                new Assignment_Setting__mdt(
                        Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
                        DeveloperName = ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECT,
                        MasterLabel = ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECT,
                        Active__c = TRUE,
                        Object__c = ASSIGNMENT_SETTING_OBJECT_PROJECT,
                        Assignment_Rule_Type__c = ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES,
                        Field_To_Update__c = 'Architect__c',
                        Matching_Criteria__c = 'Brand__c;State__c;Country__c;',
                        Record_Type_Developer_Name__c = 'Opening',
                        Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECT
                )
        };

        AssignmentProcessing.assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>(assignmentSettings);

        // Resource
        List<Resource__c> resources = new List<Resource__c>{
                new Resource__c(
                        User__c = [SELECT Id FROM User WHERE username = : TEST_USER_2_EMAIL].Id
                )
        };

        insert resources;

        // Get sObjectType from Record to get Record Type Id
        Assignment__c assignmentInstance = new Assignment__c();
        SObjectType sObjectTypeValue = assignmentInstance.getSObjectType();
        System.debug('Record Type Id : ' + AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
                ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES));
        // Assignments
        List<Assignment__c> assignments = new List<Assignment__c>{
                new Assignment__c(
                        RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
                                ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES),
                        Active__c = true,
                        Assignee__c = resources[0].Id,
                        Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECT,
                        Brand__c = BRAND_NAME_CAMBRIA,
                        All_States__c = false,
                        State__c = STATE_VERMONT,
                        All_Countries__c = false,
                        Country__c = COUNTRY_US
                )
        };

        insert assignments;

        Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
        Brand__c brand = [SELECT Id FROM Brand__c WHERE Name = :BRAND_NAME_CAMBRIA];
        Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
        Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
                :brand.Id];

        Test.startTest();

        List<TASKRAY__Project__c> openingProjects = new List<TASKRAY__Project__c> {
                new TASKRAY__Project__c(
                        Name = 'Opening TEST',
                        App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
                        Contract__c = contract.Id,
                        Brand__c = brand.Id,
                        Property__c = property.Id,
                        Product__c = product.Id,
                        RecordTypeId = openingRecordTypeId
                )
        };

        insert openingProjects;

        Test.stopTest();

        openingProjects = [SELECT Id, OPD__c, Architect__r.Name FROM TASKRAY__Project__c];
        System.assertEquals('Test User2US2', openingProjects[0].Architect__r.Name);
    }

    /**
     * @description Used to test the Negative test case for retrieving a Architect assignment for Opening based upon assignment rules.
     *
     * @return void
     */
    @IsTest
    static void testArchitectAssignmentNegative() {
        Assignment_Setting__mdt assignmentSetting = new Assignment_Setting__mdt();
        SObjectType sObjectTypeAssignmentSetting = assignmentSetting.getSObjectType();


        // Assignment Setting Custom Metadata Type, mock
        List<Assignment_Setting__mdt> assignmentSettings = new List<Assignment_Setting__mdt>{
                new Assignment_Setting__mdt(
                        Id = (Id) AssignmentProcessingHelper.getFakeRecordIdString(sObjectTypeAssignmentSetting),
                        DeveloperName = ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECT,
                        MasterLabel = ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECT,
                        Active__c = TRUE,
                        Object__c = ASSIGNMENT_SETTING_OBJECT_PROJECT,
                        Assignment_Rule_Type__c = ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES,
                        Field_To_Update__c = 'Architect__c',
                        Matching_Criteria__c = 'Brand__c;State__c;Country__c;',
                        Record_Type_Developer_Name__c = 'Opening',
                        Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECT
                )
        };

        AssignmentProcessing.assignmentSettingsByIdMock = new Map<Id, Assignment_Setting__mdt>(assignmentSettings);

        // Resource
        List<Resource__c> resources = new List<Resource__c>{
                new Resource__c(
                        User__c = [SELECT Id FROM User WHERE username = : TEST_USER_2_EMAIL].Id
                )
        };

        insert resources;

        // Get sObjectType from Record to get Record Type Id
        Assignment__c assignmentInstance = new Assignment__c();
        SObjectType sObjectTypeValue = assignmentInstance.getSObjectType();
        System.debug('Record Type Id : ' + AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
                ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES));
        // Assignments
        List<Assignment__c> assignments = new List<Assignment__c> ();
        Assignment__c wrongBrand = new Assignment__c(
                        RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
                                ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES),
                        Active__c = true,
                        Assignee__c = resources[0].Id,
                        Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECT,
                        Brand__c = BRAND_NAME_CAMBRIA,
                        All_States__c = false,
                        State__c = STATE_VERMONT,
                        All_Countries__c = false,
                        Country__c = COUNTRY_US
                );
        Assignment__c wrongState = new Assignment__c(
                RecordTypeId = AssignmentProcessingHelper.getRecordTypeId(sObjectTypeValue,
                        ASSIGNMENT_RECORD_TYPE_OPENING_RESOURCES),
                Active__c = true,
                Assignee__c = resources[0].Id,
                Role__c = ASSIGNMENT_SETTING_ROLE_TYPE_ARCHITECT,
                Brand__c = BRAND_NAME_ASCEND,
                All_States__c = false,
                State__c = STATE_ARIZONA,
                All_Countries__c = false,
                Country__c = COUNTRY_US
        );
        assignments.add(wrongBrand);
        assignments.add(wrongState);
        insert assignments;

        Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = :CONTRACT_NAME_SAMPLE_CONTRACT];
        Brand__c brand = [SELECT Id FROM Brand__c WHERE Name = :BRAND_NAME_ASCEND];
        Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = :PROPERTY_CODE_VT019];
        Product__c product = [SELECT Id FROM Product__c WHERE Product_Code__c = :PRODUCT_CODE_RE AND Brand__c =
                :brand.Id];

        Test.startTest();

        List<TASKRAY__Project__c> openingProjects = new List<TASKRAY__Project__c> {
                new TASKRAY__Project__c(
                        Name = 'Opening TEST',
                        App_Type__c = APP_TYPE_NEW_CONSTRUCTION,
                        Contract__c = contract.Id,
                        Brand__c = brand.Id,
                        Property__c = property.Id,
                        Product__c = product.Id,
                        RecordTypeId = openingRecordTypeId
                )
        };

        insert openingProjects;

        Test.stopTest();

        openingProjects = [SELECT Id, OPD__c, Architect__r.Name FROM TASKRAY__Project__c];
        System.assertEquals(null, openingProjects[0].Architect__r.Name);
    }
}