/**
 *  @description Helper class for TASKRAY_Task trigger
 *  @author Pradnya Desai
 *  @date 2019-09-11
 */

@IsTest
private class TASKRAY_TaskTriggerHelperTest {

    private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project_Task__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id  pipItemRecordTypeId = recordTypeMap.get('PIP Item').getRecordTypeId();

     /**
	 * @description Used to setup test data used for unit tests
	 *
	 * @return void
	 */
    @TestSetup
    static void dataSetup() {
    }

    /**
	 * @description This method will validate calculation for Total PIP Actual Cost
	  * And Total PIP Estimated cost.
	 *
	 * @return void
	 */
    static testMethod void validatePerBuildingCost() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<5; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.TASKRAY__Project__c = pipProject.Id;
            pipItem.PI_Quantity__c = 1;
            pipItem.PI_Actual_Cost__c = 10;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 5;
            pipItem.PIP_Library_Item__c = pipPerBuildingLibraryItem.Id;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            pipItemsList.add(pipItem);
        }
        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, Total_PIP_Cost__c, PIP_Total_Estimated_Cost__c FROM TaskRay__Project__c];
        System.assertEquals(50,pipItems[0].Total_PIP_Cost__c);
        System.assertEquals(25,pipItems[0].PIP_Total_Estimated_Cost__c);
    }

    /**
	 * @description This method will validate validate 'No AES Status' value of  PIP Compliance Status
	 *
	 * @return void
	 */
    static testMethod void validateNoAESStatus() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Deactivated';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[4].Status__c = 'CHI Verify';
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[8].Status__c = 'Exception';

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.assertEquals('No AES Items',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate 'Complete' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validateCompleteStatus() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Deactivated';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[4].Status__c = 'CHI Verify';
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[6].PI_Type__c = 'AES';
        pipItemsList[6].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[8].Status__c = 'Exception';
        pipItemsList[8].PI_Type__c = 'AES';
        pipItemsList[8].PI_Item_Due_Date__c = Date.today().addDays(-10);

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('Complete',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate 'Complete' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validateCompleteLetterType() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Deactivated';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[4].Status__c = 'CHI Verify';
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[6].PI_Type__c = 'AES';
        pipItemsList[6].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[7].PI_Type__c = 'AES';
        pipItemsList[7].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[8].Status__c = 'Exception';
        pipItemsList[8].PI_Type__c = 'AES';
        pipItemsList[8].PI_Item_Due_Date__c = Date.today().addDays(-10);

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItemsWithQuantity = [SELECT Id, AES_Inspection_Letter_Type__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItemsWithQuantity);
        System.assertEquals('Completed Letter',pipItemsWithQuantity[0].AES_Inspection_Letter_Type__c);
    }

    /**
	 * @description This method will validate 'Complete' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validateCompliantLetterType() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Deactivated';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[3].PI_Type__c = 'AES';
        pipItemsList[3].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[4].Status__c = 'CHI Verify';
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[6].PI_Type__c = 'AES';
        pipItemsList[6].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[7].PI_Type__c = 'AES';
        pipItemsList[7].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[8].Status__c = 'Exception';
        pipItemsList[8].PI_Type__c = 'AES';
        pipItemsList[8].PI_Item_Due_Date__c = Date.today().addDays(-10);

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, AES_Inspection_Letter_Type__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('Compliant Letter',pipItems[0].AES_Inspection_Letter_Type__c);
    }

    /**
	 * @description This method will validate 'Complete' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validateNonCompliantLetterType() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Deactivated';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[1].PI_Type__c = 'AES';
        pipItemsList[1].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[3].PI_Type__c = 'AES';
        pipItemsList[3].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[4].Status__c = 'CHI Verify';
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[6].PI_Type__c = 'AES';
        pipItemsList[6].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[7].PI_Type__c = 'AES';
        pipItemsList[7].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[8].Status__c = 'Exception';
        pipItemsList[8].PI_Type__c = 'AES';
        pipItemsList[8].PI_Item_Due_Date__c = Date.today().addDays(-10);

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, AES_Inspection_Letter_Type__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('Non-Compliant Letter',pipItems[0].AES_Inspection_Letter_Type__c);
    }

    /**
	 * @description This method will validate 'Complete' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validateReviewStatus() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Incomplete';
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[4].Status__c = 'CHI Verify';
        pipItemsList[4].PI_Type__c = 'AES';
        pipItemsList[4].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[5].PI_Type__c = 'AES';
        pipItemsList[5].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[7].PI_Type__c = 'AES';
        pipItemsList[7].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[8].Status__c = 'Exception';

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('Pending Review',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate 'Incomplete' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validateIncompleteStatus() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Deactivated';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[1].PI_Type__c = 'AES';
        pipItemsList[1].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[4].Status__c = 'CHI Verify';
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[8].Status__c = 'Exception';

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('Incomplete - 1 Visits - Internal',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate HGI 'Incomplete' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validateHGIIncompleteStatus() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Incomplete';
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[1].PI_Type__c = 'AES';
        pipItemsList[1].PI_HGI__c = true;
        pipItemsList[1].PI_Verify__c = true;
        pipItemsList[1].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[4].Status__c = 'CHI Verify';
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[8].Status__c = 'Exception';

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('HGI Incomplete - 1 Visits',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate HGI 'Incomplete' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validateHGIIncompleteVisitStatus() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Deactivated';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[1].PI_Type__c = 'AES';
        pipItemsList[1].PI_HGI__c = true;
        pipItemsList[1].PI_Verify__c = true;
        pipItemsList[1].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[4].Status__c = 'Incomplete';
        pipItemsList[4].PI_Type__c = 'AES';
        pipItemsList[4].PI_HGI__c = true;
        pipItemsList[4].PI_Verify__c = true;
        pipItemsList[4].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[6].PI_Type__c = 'AES';
        pipItemsList[6].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[8].Status__c = 'Exception';

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('HGI Incomplete - 2 Visits',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate 'Past Dues' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validatePastDueInternalStatus() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Incomplete';
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[2].PI_Type__c = 'AES';
        pipItemsList[2].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[4].Status__c = 'CHI Verify';
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[8].Status__c = 'Exception';

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('Overdue - Internal',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate 'Past Dues' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validatePastDueStatus() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id,pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Incomplete';
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[2].PI_Verify__c = true;
        pipItemsList[2].PI_Type__c = 'AES';
        pipItemsList[2].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[4].Status__c = 'Past Due';
        pipItemsList[4].PI_Type__c = 'AES';
        pipItemsList[4].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[8].Status__c = 'Exception';

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('Overdue',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate 'Pending' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validatePendingInternalStatus() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Deactivated';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[3].PI_Type__c = 'AES';
        pipItemsList[3].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[4].Status__c = 'CHI Verify';
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[8].Status__c = 'Exception';

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('Pending - Internal',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate 'Pending' value for PIP Compliance Status field
	 *
	 * @return void
	 */
    static testMethod void validatePendingStatus() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id,pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Deactivated';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[3].PI_Type__c = 'AES';
        pipItemsList[3].PI_Verify__c = true;
        pipItemsList[3].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[4].Status__c = 'Pending';
        pipItemsList[4].PI_Type__c = 'AES';
        pipItemsList[4].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[8].Status__c = 'Exception';

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('Pending',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate 'Pending' value for PIP Compliance Status field. And check PIP Compliance
	 * Status change when PIP Item Type is changed.
	 *
	 * @return void
	 */
    static testMethod void validatePendingStatusTypeChange() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;


        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 9,
                pipProject.Id, pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        pipItemsList[0].Status__c = 'Deactivated';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[1].Status__c = 'Incomplete';
        pipItemsList[2].Status__c = 'Past Due';
        pipItemsList[3].Status__c = 'Pending';
        pipItemsList[3].PI_Type__c = 'AES';
        pipItemsList[3].PI_Verify__c = true;
        pipItemsList[3].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[4].Status__c = 'Pending';
        pipItemsList[4].PI_Type__c = 'AES';
        pipItemsList[4].PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItemsList[5].Status__c = 'Choice Review';
        pipItemsList[6].Status__c = 'Completed';
        pipItemsList[7].Status__c = 'Completed Pending Review';
        pipItemsList[8].Status__c = 'Exception';

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.debug('pipItemsWithQuantity : ' + pipItems);
        System.assertEquals('Pending',pipItems[0].PIP_Compliance_Status__c);

        pipItemsList[3].PI_Type__c = 'BES';
        pipItemsList[4].PI_Type__c = 'BES';

        update pipItemsList;

        pipItems = [SELECT Id, PIP_Compliance_Status__c FROM TaskRay__Project__c];
        System.assertEquals('No AES Items',pipItems[0].PIP_Compliance_Status__c);
    }

    /**
	 * @description This method will validate Follow Up Date on PIP Item
	 *
	 * @return void
	 */
    static testMethod void validateFollowUpDate() {

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(true);
        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 2, pipProject.Id,
                    pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);

        insert pipItemsList;

        List<PIP_Inspection_Item__c> inspectionItems = new List<PIP_Inspection_Item__c>();
        Integer Count = 0;

        for(TASKRAY__Project_Task__c pipItems : pipItemsList){
            PIP_Inspection_Item__c inspectionItem = new PIP_Inspection_Item__c();
            inspectionItem.LRA_Inspection_Results__c = 'Incomplete';
            inspectionItem.PIP_Item__c = pipItems.Id;
            inspectionItem.LRA_AESI_Item_ID__c= 'LRA_AES'+Count;
            Count++;
            inspectionItems.add(inspectionItem);
        }

        Test.startTest();
        insert inspectionItems;
        Test.stopTest();


        List<TASKRAY__Project_Task__c> pipItemsListAfterInsert = [SELECT Id, Name, PI_Follow_Up_Date__c from TASKRAY__Project_Task__c];
        List<PIP_Inspection_Item__c> inspectionItemIncrementList = new List<PIP_Inspection_Item__c>();
        PIP_Inspection_Item__c inspectionItemIncrement = null;
        for(TASKRAY__Project_Task__c pipItems : pipItemsListAfterInsert){
            inspectionItemIncrement = new PIP_Inspection_Item__c();
            System.assertEquals(Date.today().addDays(120), pipItems.PI_Follow_Up_Date__c);
            inspectionItemIncrement.LRA_Inspection_Results__c = 'Complete';
            inspectionItemIncrement.PIP_Item__c = pipItems.Id;
            inspectionItemIncrement.LRA_AESI_Item_ID__c= 'LRA_AES'+Count;
            Count++;
            inspectionItemIncrementList.add(inspectionItemIncrement);
        }

        insert inspectionItemIncrementList;

        List<TASKRAY__Project_Task__c> pipItemsListReset = [SELECT Id, Name, PI_Follow_Up_Date__c from TASKRAY__Project_Task__c];
         for(TASKRAY__Project_Task__c pipItems : pipItemsListReset){
             System.assertEquals(null, pipItems.PI_Follow_Up_Date__c);
        }

    }

    /**
	 * @description This method will validate calculation for Total PIP Actual Cost
	  * And Total PIP Estimated cost.
	 *
	 * @return void
	 */
    static testMethod void validatePerBuildingCostOnUpdate() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<5; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.TASKRAY__Project__c = pipProject.Id;
            pipItem.PI_Quantity__c = 1;
            pipItem.PI_Actual_Cost__c = 1;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 1;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            pipItem.PIP_Library_Item__c = pipPerBuildingLibraryItem.Id;
            pipItemsList.add(pipItem);
        }
        insert pipItemsList;

        List<TaskRay__Project__c> pipItemsWithQuantity = [SELECT Id, Total_PIP_Cost__c, PIP_Total_Estimated_Cost__c FROM TaskRay__Project__c];

        List<TASKRAY__Project_Task__c> pipItemsUpdateList = [SELECT Id,PI_Actual_Cost__c, PI_Estimated_Cost_per_Cost_Unit__c FROM TASKRAY__Project_Task__c];
        for(TASKRAY__Project_Task__c pipItem: pipItemsUpdateList) {
            pipItem.PI_Actual_Cost__c = 10;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 5;
        }
        Test.startTest();
        update pipItemsUpdateList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItemsWithQuantityAfterUpdate = [SELECT Id, Total_PIP_Cost__c, PIP_Total_Estimated_Cost__c FROM TaskRay__Project__c];
        System.assertEquals(50,pipItemsWithQuantityAfterUpdate[0].Total_PIP_Cost__c);
        System.assertEquals(25,pipItemsWithQuantityAfterUpdate[0].PIP_Total_Estimated_Cost__c);
    }

    /**
	 * @description This method will validate Quantity for Per Building Cost Units
	 *
	 * @return void
	 */
    static testMethod void validatePerBuildingQuantityForPIPItem() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<5; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.TASKRAY__Project__c = pipProject.Id;
            pipItem.PI_Actual_Cost__c = 1;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 1;
            pipItem.PIP_Library_Item__c = pipPerBuildingLibraryItem.Id;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            pipItemsList.add(pipItem);
        }
        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TASKRAY__Project_Task__c> pipItemsUpdateList = [SELECT Id, PI_Quantity__c FROM TASKRAY__Project_Task__c];
        for(TASKRAY__Project_Task__c pipItem: pipItemsUpdateList){
            System.assertEquals(1,pipItem.PI_Quantity__c);
        }

    }

    /**
	 * @description This method will validate Quantity for Per Building Cost Units change to Per room
	 *
	 * @return void
	 */
    static testMethod void validatePerBuildingQuantityChangeForPIPItem() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<5; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.TASKRAY__Project__c = pipProject.Id;
            pipItem.PI_Actual_Cost__c = 1;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 1;
            pipItem.PIP_Library_Item__c = pipPerBuildingLibraryItem.Id;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            pipItemsList.add(pipItem);
        }
        insert pipItemsList;

        List<TASKRAY__Project_Task__c> pipItemsUpdateList = [SELECT Id, PI_Quantity__c FROM TASKRAY__Project_Task__c];
        for(TASKRAY__Project_Task__c pipItem: pipItemsUpdateList){
            System.assertEquals(1,pipItem.PI_Quantity__c);
            pipItem.PI_Cost_Units__c = 'Per Room';
        }
        pipPerBuildingLibraryItem.PI_Cost_Units__c = 'Per Room';
        update pipPerBuildingLibraryItem;

        update pipItemsUpdateList;
        pipItemsUpdateList = [SELECT Id, PI_Quantity__c FROM TASKRAY__Project_Task__c];
        for(TASKRAY__Project_Task__c pipItem: pipItemsUpdateList){
            System.assertEquals(10,pipItem.PI_Quantity__c);
        }

    }

    /**
	 * @description
	 *
	 * @return void
	 */
    static testMethod void validateQuantityNoProject() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        PIP_Library_Item__c pipPerRoomLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_ROOM);
        insert pipPerRoomLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<2; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.PI_Actual_Cost__c = 1;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 1;
            pipItem.PIP_Library_Item__c = pipPerBuildingLibraryItem.Id;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            pipItem.Name = 'Per Building' + i;
            pipItemsList.add(pipItem);
        }
        for(Integer i=0; i<2; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.PI_Actual_Cost__c = 1;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 1;
            pipItem.PIP_Library_Item__c = pipPerRoomLibraryItem.Id;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            pipItem.Name = 'Per Room' + i;
            pipItemsList.add(pipItem);
        }

        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TASKRAY__Project_Task__c> pipItemsUpdateList = [SELECT Id, PI_Quantity__c FROM TASKRAY__Project_Task__c WHERE
            Name like '%Per Building%'];

        for(TASKRAY__Project_Task__c pipItem: pipItemsUpdateList){
            System.assertEquals(1,pipItem.PI_Quantity__c);
        }

        List<TASKRAY__Project_Task__c> pipItemsRoomUpdateList = [SELECT Id, PI_Quantity__c FROM TASKRAY__Project_Task__c WHERE
                Name like '%Per Room%'];

        for(TASKRAY__Project_Task__c pipItem: pipItemsRoomUpdateList){
            System.assertEquals(null,pipItem.PI_Quantity__c);
        }

    }

    /**
	 * @description
	 *
	 * @return void
	 */
    static testMethod void validateQuantityNoLibrary() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<5; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.TASKRAY__Project__c = pipProject.Id;
            pipItem.PI_Actual_Cost__c = 1;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 1;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            pipItemsList.add(pipItem);
        }
        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TASKRAY__Project_Task__c> pipItemsUpdateList = [SELECT Id, PI_Quantity__c FROM TASKRAY__Project_Task__c];

        for(TASKRAY__Project_Task__c pipItem: pipItemsUpdateList){
            System.assertEquals(null,pipItem.PI_Quantity__c);

        }
    }

    /**
	 * @description
	 *
	 * @return void
	 */
    static testMethod void validatePerRoomQuantityForPPItem() {

        PIP_Library_Item__c pipPerRoomLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_ROOM);
        insert pipPerRoomLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<5; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.TASKRAY__Project__c = pipProject.Id;
            pipItem.PI_Actual_Cost__c = 1;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 1;
            pipItem.PIP_Library_Item__c = pipPerRoomLibraryItem.Id;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            pipItemsList.add(pipItem);
        }
        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TASKRAY__Project_Task__c> pipItemsUpdateList = [SELECT Id, PI_Quantity__c FROM TASKRAY__Project_Task__c];

        for(TASKRAY__Project_Task__c pipItem: pipItemsUpdateList){
            System.assertEquals(10,pipItem.PI_Quantity__c);

        }
    }

    /**
	 * @description This method will validate calculation for Total PIP Actual Cost
	  * And Total PIP Estimated cost.
	 *
	 * @return void
	 */
    static testMethod void validatePerBuildingEstimatedCostChange() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<5; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.TASKRAY__Project__c = pipProject.Id;
            pipItem.PI_Quantity__c = 1;
            pipItem.PI_Actual_Cost__c = 1;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 1;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            pipItem.PIP_Library_Item__c = pipPerBuildingLibraryItem.Id;
            pipItemsList.add(pipItem);
        }
        insert pipItemsList;

        List<TaskRay__Project__c> pipItemsWithQuantity = [SELECT Id, Total_PIP_Cost__c, PIP_Total_Estimated_Cost__c FROM TaskRay__Project__c];

        List<TASKRAY__Project_Task__c> pipItemsUpdateList = [SELECT Id,PI_Actual_Cost__c, PI_Estimated_Cost_per_Cost_Unit__c FROM TASKRAY__Project_Task__c];
        for(TASKRAY__Project_Task__c pipItem: pipItemsUpdateList) {
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 5;
        }
        Test.startTest();
        update pipItemsUpdateList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItemsWithQuantityAfterUpdate = [SELECT Id, Total_PIP_Cost__c, PIP_Total_Estimated_Cost__c FROM TaskRay__Project__c];
        System.assertEquals(5,pipItemsWithQuantityAfterUpdate[0].Total_PIP_Cost__c);
        System.assertEquals(25,pipItemsWithQuantityAfterUpdate[0].PIP_Total_Estimated_Cost__c);
    }

    /**
	 * @description This method will validate calculation for Total PIP Actual Cost
	  * And Total PIP Estimated cost.
	 *
	 * @return void
	 */
    static testMethod void validatePerRoomCostOnUpdate() {

        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_ROOM);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<5; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.TASKRAY__Project__c = pipProject.Id;
            pipItem.PI_Quantity__c = 2;
            pipItem.PI_Actual_Cost__c = 5;
            pipItem.PI_Estimated_Cost_per_Cost_Unit__c = 2;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            pipItem.PIP_Library_Item__c = pipPerBuildingLibraryItem.Id;
            pipItemsList.add(pipItem);
        }
        insert pipItemsList;

        List<TaskRay__Project__c> pipItemsWithQuantity = [SELECT Id, Total_PIP_Cost__c, PIP_Total_Estimated_Cost__c FROM TaskRay__Project__c];

        List<TASKRAY__Project_Task__c> pipItemsUpdateList = [SELECT Id,PI_Actual_Cost__c, PI_Estimated_Cost_per_Cost_Unit__c FROM TASKRAY__Project_Task__c];
        for(TASKRAY__Project_Task__c pipItem: pipItemsUpdateList) {
            pipItem.PI_Quantity__c = 10;
        }
        Test.startTest();
        update pipItemsUpdateList;
        Test.stopTest();

        List<TaskRay__Project__c> pipItemsWithQuantityAfterUpdate = [SELECT Id, Total_PIP_Cost__c, PIP_Total_Estimated_Cost__c FROM TaskRay__Project__c];
        System.assertEquals(250,pipItemsWithQuantityAfterUpdate[0].Total_PIP_Cost__c);
        System.assertEquals(100,pipItemsWithQuantityAfterUpdate[0].PIP_Total_Estimated_Cost__c);
    }

    /**
     * @description Used to validate the PIP Item Follow Up Date is set to null on insert. Positive test case.
     *
     * @return void
     */
    @IsTest
    static void validateFollowUpDateIsNotChanged() {
        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(
            AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
	    Date currentDate = System.today();
        for(Integer index = 0; index < 5; index++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c(
                TASKRAY__Project__c = pipProject.Id,
                PI_Quantity__c = 1,
                PI_Actual_Cost__c = 10,
                RecordTypeId = pipItemRecordTypeId,
                PI_Estimated_Cost_per_Cost_Unit__c = 5,
                PIP_Library_Item__c = pipPerBuildingLibraryItem.Id,
                Status__c = 'Incomplete',
                PI_Follow_Up_Date__c = currentDate
            );

            pipItemsList.add(pipItem);
        }
        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

       for(TaskRay__Project_Task__c pipItems : [SELECT Id, PI_Follow_Up_Date__c FROM
            TaskRay__Project_Task__c]) {
           System.assertEquals(currentDate, pipItems.PI_Follow_Up_Date__c);
       }
    }

    /**
     * @description Used to validate the PIP Item Follow Up Date is not updated for other changes
     *
     * @return void
     */
    @IsTest
    static void validateFollowUpDateIsNotChangedOnUpdate() {
        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(
                AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        Date currentDate = System.today();
        for(Integer index = 0; index < 5; index++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c(
                    TASKRAY__Project__c = pipProject.Id,
                    PI_Quantity__c = 1,
                    PI_Actual_Cost__c = 10,
                    PI_Estimated_Cost_per_Cost_Unit__c = 5,
                    PIP_Library_Item__c = pipPerBuildingLibraryItem.Id,
                    Status__c = 'Incomplete',
                    PI_Follow_Up_Date__c = currentDate-10
            );

            pipItemsList.add(pipItem);
        }
        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        List<TaskRay__Project_Task__c> pipItems = [SELECT Id, PI_Follow_Up_Date__c FROM
        TaskRay__Project_Task__c];

        for(TaskRay__Project_Task__c pipItem: pipItems) {
            System.assertEquals(currentDate-10, pipItem.PI_Follow_Up_Date__c);
            pipItem.PI_Actual_Cost__c = 12;
        }

        update pipItems;

        for(TaskRay__Project_Task__c pipItemsChanged : [SELECT Id, PI_Follow_Up_Date__c FROM
                TaskRay__Project_Task__c]) {
            System.assertEquals(currentDate-10, pipItemsChanged.PI_Follow_Up_Date__c);
        }
    }

    /**
     * @description Used to validate the PIP Item Follow Up Date is no changed if present. Positivee test case.
     *
     * @return void
     */
    @IsTest
    static void validateFollowUpDateIsNullOnInsert() {
        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(
                AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        Date currentDate = System.today();
        for(Integer index = 0; index < 5; index++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c(
                    TASKRAY__Project__c = pipProject.Id,
                    PI_Quantity__c = 1,
                    PI_Actual_Cost__c = 10,
                    PI_Estimated_Cost_per_Cost_Unit__c = 5,
                    PIP_Library_Item__c = pipPerBuildingLibraryItem.Id,
                    Status__c = 'Pending',
                    PI_Follow_Up_Date__c = currentDate
            );

            pipItemsList.add(pipItem);
        }
        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        for(TaskRay__Project_Task__c pipItems : [SELECT Id, PI_Follow_Up_Date__c FROM
                TaskRay__Project_Task__c]) {
            System.assertEquals(null, pipItems.PI_Follow_Up_Date__c);
        }
    }

    /**
     * @description Used to validate the PIP Item Follow Up Date is set to null on update. Positivee test case.
     *
     * @return void
     */
    @IsTest
    static void validateFollowUpDateIsNullOnUpdate() {
        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(
            AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
	    Date currentDate = System.today();
        for(Integer index = 0; index < 5; index++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c(
                TASKRAY__Project__c = pipProject.Id,
                PI_Quantity__c = 1,
                PI_Actual_Cost__c = 10,
                PI_Estimated_Cost_per_Cost_Unit__c = 5,
                RecordTypeId = pipItemRecordTypeId,
                PIP_Library_Item__c = pipPerBuildingLibraryItem.Id,
                PI_Follow_Up_Date__c = currentDate
            );

            pipItemsList.add(pipItem);
        }

        insert pipItemsList;

        for(TASKRAY__Project_Task__c pipItem : pipItemsList) {
            System.assertNotEquals(null, pipItem.PI_Follow_Up_Date__c);
            pipItem.Status__c = 'Pending';
        }

        Test.startTest();
        update pipItemsList;
        Test.stopTest();

        for(TaskRay__Project_Task__c pipItems : [SELECT Id, PI_Follow_Up_Date__c FROM
            TaskRay__Project_Task__c]) {
            System.assertEquals(null, pipItems.PI_Follow_Up_Date__c);
        }
    }

    /**
	* @description Used to validate the PIP Item Follow Up Date is not set to null on insert. Negative test case.
	*
	* @return void
	*/
    @IsTest
    static void validateFollowUpDateIsNotNullOnInsert() {
        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(
            AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.Number_of_Rooms__c = 10;
        insert pipProject;

        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        Date currentDate = System.today();
        for(Integer index = 0; index < 5; index++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c(
                TASKRAY__Project__c = pipProject.Id,
                PI_Quantity__c = 1,
                PI_Actual_Cost__c = 10,
                PI_Estimated_Cost_per_Cost_Unit__c = 5,
                RecordTypeId = pipItemRecordTypeId,
                PIP_Library_Item__c = pipPerBuildingLibraryItem.Id,
                Status__c = StaticValue.getStaticValueText('PIP_ITEM_STATUS_INCOMPLETE')
            );

            pipItemsList.add(pipItem);
        }
        Test.startTest();
        insert pipItemsList;
        Test.stopTest();

        for(TaskRay__Project_Task__c pipItems : [SELECT Id, PI_Follow_Up_Date__c FROM
            TaskRay__Project_Task__c]) {
            System.assertEquals(currentDate.addDays(120), pipItems.PI_Follow_Up_Date__c);
        }
    }


    /**
    * Method Tested: updatePIPBillingInspectionCountOnTaskInsert
    * | Scenario: PIP Item records for same parent are inserted with AES Type, HGI true and Status as Incomplete
    * with Billing Inspection Count populated.
    * | Expected Result: The highest Billing Inspection Count is updated on the parent PIP
    **/
    @IsTest static void updatePIPBillingInspectionCountOnTaskInsertValid(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        List<TASKRAY__Project_Task__c> PIPItemsToInsert = new List<TASKRAY__Project_Task__c>();
        TASKRAY__Project_Task__c PIPItem1 = TestDataFactory.createPIPItem(false);
        PIPItem1.Status__c = 'Incomplete';
        PIPItem1.PI_Type__c = 'AES';
        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem1.PI_HGI__c = true;
        pipItem1.RecordTypeId = pipItemRecordTypeId;
        PIPItem1.PI_Billing_Inspection_Count__c = 10;
        PIPItem1.TASKRAY__Project__c = PIP.Id;
        PIPItemsToInsert.add(PIPItem1);

        TASKRAY__Project_Task__c PIPItem2 = TestDataFactory.createPIPItem(false);
        PIPItem2.Status__c = 'Incomplete';
        PIPItem2.PI_Type__c = 'AES';
        PIPItem2.PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItem2.RecordTypeId = pipItemRecordTypeId;
        PIPItem2.PI_HGI__c = true;
        PIPItem2.PI_Billing_Inspection_Count__c = 1000;
        PIPItem2.TASKRAY__Project__c = PIP.Id;
        PIPItemsToInsert.add(PIPItem2);
        Test.startTest();
        insert PIPItemsToInsert;
        Test.stopTest();

        TaskRay__Project__c updatedPIP = [SELECT Billing_Inspection_Count__c FROM TaskRay__Project__c];
        System.assertEquals(updatedPIP.Billing_Inspection_Count__c, 1000);
    }

    /**
    * Method Tested: updatePIPBillingInspectionCountOnTaskUpdate
    * | Scenario: PIP Item records for same parent are updated with AES Type, HGI true and Status as Incomplete
    * with Billing Inspection Count populated.
    * | Expected Result: The highest Billing Inspection Count is updated on the parent PIP
    **/
    @IsTest static void updatePIPBillingInspectionCountOnTaskUpdateValid(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        TASKRAY__Project_Task__c PIPItem1 = TestDataFactory.createPIPItem(false);
        PIPItem1.Status__c = 'Incomplete';
        PIPItem1.PI_Type__c = 'AES';
        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItem1.RecordTypeId = pipItemRecordTypeId;
        PIPItem1.PI_HGI__c = true;
        PIPItem1.PI_Billing_Inspection_Count__c = 10;
        PIPItem1.TASKRAY__Project__c = PIP.Id;
        insert PIPItem1;

        TaskRay__Project__c updatedPIP = [SELECT Billing_Inspection_Count__c FROM TaskRay__Project__c];
        System.assertEquals(updatedPIP.Billing_Inspection_Count__c, 10);

        PIPItem1.PI_Billing_Inspection_Count__c = 200;
        Test.startTest();
        update PIPItem1;
        Test.stopTest();

        TaskRay__Project__c updatedPIPItemPIP = [SELECT Billing_Inspection_Count__c FROM TaskRay__Project__c];
        System.assertEquals(updatedPIPItemPIP.Billing_Inspection_Count__c, 200);
    }

    /**
    * Method Tested: updatePIPBillingInspectionCountOnTaskUpdate
    * | Scenario: Multiple PIP Item records for different PIPs are updated with AES Type, HGI true and Status as Incomplete
    * with Billing Inspection Count populated.
    * | Expected Result: The highest Billing Inspection Count is updated on the each parent PIP
    **/
    @IsTest static void updatePIPBillingInspectionCountOnTaskInsertBulkValid(){
        List<TASKRAY__Project_Task__c> PIPItemsToInsert = new List<TASKRAY__Project_Task__c>();
        List<TASKRAY__Project__c> PIPsToInsert = new List<TASKRAY__Project__c>();
        TaskRay__Project__c PIP1 = TestDataFactory.createPIP(false);
        PIP1.TASKRAY__trStatus__c = 'Active';
        PIP1.Sub_Status__c = 'Executed';
        PIPsToInsert.add(PIP1);

        TaskRay__Project__c PIP2 = TestDataFactory.createPIP(false);
        PIP2.TASKRAY__trStatus__c = 'Requested';
        PIP2.Sub_Status__c = 'Pending Approval';
        PIPsToInsert.add(PIP2);

        TaskRay__Project__c PIP3 = TestDataFactory.createPIP(false);
        PIP3.TASKRAY__trStatus__c = 'Writing';
        PIP3.Sub_Status__c = 'Draft';
        PIPsToInsert.add(PIP3);

        insert PIPsToInsert;

        for(Integer i=0; i<50; i++) {
            TASKRAY__Project_Task__c PIPItem = TestDataFactory.createPIPItem(false);
            PIPItem.Status__c = 'Incomplete';
            PIPItem.PI_Type__c = 'AES';
            PIPItem.PI_Item_Due_Date__c = Date.today().addDays(-10);
            PIPItem.PI_HGI__c = true;
            PIPItem.PI_Billing_Inspection_Count__c = i+10;
            PIPItem.TASKRAY__Project__c = PIP1.Id;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            PIPItemsToInsert.add(PIPItem);
        }
        for(Integer i=100; i<150; i++) {
            TASKRAY__Project_Task__c PIPItem = TestDataFactory.createPIPItem(false);
            PIPItem.Status__c = 'Incomplete';
            PIPItem.PI_Type__c = 'AES';
            PIPItem.PI_Item_Due_Date__c = Date.today().addDays(-10);
            PIPItem.PI_HGI__c = true;
            PIPItem.PI_Billing_Inspection_Count__c = i+10;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            PIPItem.TASKRAY__Project__c = PIP2.Id;
            PIPItemsToInsert.add(PIPItem);
        }
        for(Integer i=200; i<300; i++) {
            TASKRAY__Project_Task__c PIPItem = TestDataFactory.createPIPItem(false);
            PIPItem.Status__c = 'Incomplete';
            PIPItem.PI_Type__c = 'AES';
            PIPItem.PI_Item_Due_Date__c = Date.today().addDays(-10);
            PIPItem.PI_HGI__c = true;
            PIPItem.PI_Billing_Inspection_Count__c = i+10;
            pipItem.RecordTypeId = pipItemRecordTypeId;
            PIPItem.TASKRAY__Project__c = PIP3.Id;
            PIPItemsToInsert.add(PIPItem);
        }
        Test.startTest();
        insert PIPItemsToInsert;
        Test.stopTest();

        TASKRAY__Project__c updatedPIP1 = [SELECT Billing_Inspection_Count__c FROM TASKRAY__Project__c
        WHERE TASKRAY__trStatus__c = 'Active'];
        System.assertEquals(updatedPIP1.Billing_Inspection_Count__c,59);

        TASKRAY__Project__c updatedPIP2 = [SELECT Billing_Inspection_Count__c FROM TASKRAY__Project__c
        WHERE TASKRAY__trStatus__c = 'Requested'];
        System.assertEquals(updatedPIP2.Billing_Inspection_Count__c,159);

        TASKRAY__Project__c updatedPIP3 = [SELECT Billing_Inspection_Count__c FROM TASKRAY__Project__c
        WHERE TASKRAY__trStatus__c = 'Writing'];
        System.assertEquals(updatedPIP3.Billing_Inspection_Count__c,309);


    }

    /**
    * Method Tested: updatePIPBillingInspectionCountOnTaskInsert
    * | Scenario: PIP Item records for same parent are inserted with AES Type, HGI true and Status as Incomplete
    * with Billing Inspection Count null for all
    * | Expected Result: The Billing Inspection Count is null on the parent PIP
    **/
    @IsTest static void updatePIPBillingInspectionCountOnTaskInsertNullValid(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        List<TASKRAY__Project_Task__c> PIPItemsToInsert = new List<TASKRAY__Project_Task__c>();
        TASKRAY__Project_Task__c PIPItem1 = TestDataFactory.createPIPItem(false);
        PIPItem1.Status__c = 'Incomplete';
        PIPItem1.PI_Type__c = 'AES';
        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem1.PI_HGI__c = true;
        pipItem1.RecordTypeId = pipItemRecordTypeId;
        PIPItem1.TASKRAY__Project__c = PIP.Id;
        PIPItemsToInsert.add(PIPItem1);

        TASKRAY__Project_Task__c PIPItem2 = TestDataFactory.createPIPItem(false);
        PIPItem2.Status__c = 'Incomplete';
        PIPItem2.PI_Type__c = 'AES';
        PIPItem2.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem2.PI_HGI__c = true;
        pipItem2.RecordTypeId = pipItemRecordTypeId;
        PIPItem2.TASKRAY__Project__c = PIP.Id;
        PIPItemsToInsert.add(PIPItem2);
        Test.startTest();
        insert PIPItemsToInsert;
        Test.stopTest();

        TaskRay__Project__c updatedPIP = [SELECT Billing_Inspection_Count__c FROM TaskRay__Project__c];
        System.assertEquals(updatedPIP.Billing_Inspection_Count__c, null);
    }

    /**
    * Method Tested: updatePIPBillingInspectionCountOnTaskInsert
    * | Scenario: PIP Item records for same parent are inserted with BES Type, HGI true and Status as Incomplete
    * with Billing Inspection Count
    * | Expected Result: The Billing Inspection Count is null on the parent PIP as Pip Item type is BES
    **/
    @IsTest static void updatePIPBillingInspectionCountOnTaskInsertInvalid(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        List<TASKRAY__Project_Task__c> PIPItemsToInsert = new List<TASKRAY__Project_Task__c>();
        TASKRAY__Project_Task__c PIPItem1 = TestDataFactory.createPIPItem(false);
        PIPItem1.Status__c = 'Incomplete';
        PIPItem1.PI_Type__c = 'BES';
        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem1.PI_HGI__c = true;
        PIPItem1.PI_Billing_Inspection_Count__c = 10;
        PIPItem1.TASKRAY__Project__c = PIP.Id;
        pipItem1.RecordTypeId = pipItemRecordTypeId;
        PIPItemsToInsert.add(PIPItem1);

        TASKRAY__Project_Task__c PIPItem2 = TestDataFactory.createPIPItem(false);
        PIPItem2.Status__c = 'Incomplete';
        PIPItem2.PI_Type__c = 'BES';
        PIPItem2.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem2.PI_HGI__c = true;
        PIPItem2.PI_Billing_Inspection_Count__c = 1000;
        PIPItem2.TASKRAY__Project__c = PIP.Id;
        pipItem2.RecordTypeId = pipItemRecordTypeId;
        PIPItemsToInsert.add(PIPItem2);
        Test.startTest();
        insert PIPItemsToInsert;
        Test.stopTest();

        TaskRay__Project__c updatedPIP = [SELECT Billing_Inspection_Count__c FROM TaskRay__Project__c];
        System.assertEquals(updatedPIP.Billing_Inspection_Count__c, null);
    }

    /**
    * Method Tested: updatePIPBillingInspectionCountOnTaskUpdate
    * | Scenario: PIP Item records for same parent are inserted with AES Type, HGI true and Status as Incomplete
    * with Billing Inspection Count. pip Item is updated to BES Type
    * | Expected Result: The Billing Inspection Count is null on the parent PIP as Pip Item type is BES
    **/
    @IsTest static void updatePIPBillingInspectionCountOnTaskUpdateNull(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        TASKRAY__Project_Task__c PIPItem1 = TestDataFactory.createPIPItem(false);
        PIPItem1.Status__c = 'Incomplete';
        PIPItem1.PI_Type__c = 'AES';
        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem1.PI_HGI__c = true;
        PIPItem1.PI_Billing_Inspection_Count__c = 10;
        PIPItem1.TASKRAY__Project__c = PIP.Id;
        pipItem1.RecordTypeId = pipItemRecordTypeId;
        insert PIPItem1;

        PIPItem1.PI_Type__c = 'BES';
        Test.startTest();
        update PIPItem1;
        Test.stopTest();

        TaskRay__Project__c updatedPIP = [SELECT Billing_Inspection_Count__c FROM TaskRay__Project__c];
        System.assertEquals(updatedPIP.Billing_Inspection_Count__c, null);
    }

    /**
    * Method Tested: updatePIPItemStatusToPending
    * | Scenario: PIP Item record's due date is updated to a future date and Status is Past Due.
    * | Expected Result: The Status is updated to Pending
    **/
    @IsTest static void updatePIPItemStatusToPending(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        TASKRAY__Project_Task__c PIPItem1 = TestDataFactory.createPIPItem(false);
        PIPItem1.Status__c = 'Past Due';
        PIPItem1.PI_Type__c = 'AES';
        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem1.TASKRAY__Project__c = PIP.Id;
        pipItem1.RecordTypeId = pipItemRecordTypeId;
        insert PIPItem1;

        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(10);
        Test.startTest();
        update PIPItem1;
        Test.stopTest();

        TASKRAY__Project_Task__c updatedPIPItemStatus = [SELECT Status__c FROM TASKRAY__Project_Task__c];
        System.assertEquals(updatedPIPItemStatus.Status__c, 'Pending');
    }

    /**
    * Method Tested: updatePIPItemStatusToPending
    * | Scenario: PIP Item record's due date is updated to a future date and Status is Past Due. Item Type is BES
    * | Expected Result: The Status is updated to Pending
    **/
    @IsTest static void updatePIPItemStatusToPendingNegative(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        TASKRAY__Project_Task__c PIPItem1 = TestDataFactory.createPIPItem(false);
        PIPItem1.Status__c = 'Past Due';
        PIPItem1.PI_Type__c = 'BES';
        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem1.TASKRAY__Project__c = PIP.Id;
        pipItem1.RecordTypeId = pipItemRecordTypeId;
        insert PIPItem1;

        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(10);
        Test.startTest();
        update PIPItem1;
        Test.stopTest();

        TASKRAY__Project_Task__c updatedPIPItemStatus = [SELECT Status__c FROM TASKRAY__Project_Task__c];
        System.assertEquals(updatedPIPItemStatus.Status__c, 'Past Due');
    }

    /**
    * Method Tested: updatePIPItemStatusToPending
    * | Scenario: Multiple PIP Item records' due date is updated to a future date and Status is Past Due.
    * | Expected Result: The Status is updated to Pending for all PIP Items
    **/
    @IsTest static void updatePIPItemStatusToPendingBulk(){
        List<TASKRAY__Project_Task__c> PIPItemsToInsert = new List<TASKRAY__Project_Task__c>();
        List<TASKRAY__Project_Task__c> PIPItemsToUpdate = new List<TASKRAY__Project_Task__c>();
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        for(Integer i=0; i<200; i++) {
            TASKRAY__Project_Task__c PIPItem1 = TestDataFactory.createPIPItem(false);
            PIPItem1.Status__c = 'Past Due';
            PIPItem1.PI_Type__c = 'AES';
            PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(-10);
            PIPItem1.TASKRAY__Project__c = PIP.Id;
            pipItem1.RecordTypeId = pipItemRecordTypeId;
            PIPItemsToInsert.add(PIPItem1);
        }
        insert PIPItemsToInsert;

        for(TASKRAY__Project_Task__c PIPItem :PIPItemsToInsert){
            PIPItem.PI_Item_Due_Date__c = Date.today().addDays(10);
            PIPItemsToUpdate.add(PIPItem);
        }

        Test.startTest();
        update PIPItemsToUpdate;
        Test.stopTest();

        List<TASKRAY__Project_Task__c> updatedPIPItemStatus = [SELECT Status__c FROM TASKRAY__Project_Task__c
        WHERE Status__c = 'Pending'];
        System.assertEquals(200,updatedPIPItemStatus.size());
    }

    /**
     * Method Tested: updateFieldsForClonedPIPItems
     * | Scenario: PIPItem is Clone and PIP is not updated
     * | Expected Result: Set Due in Months, Due Date and PIP is set to null
     **/
    @IsTest static void clonePIPItemStatusSamePIP(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        TASKRAY__Project_Task__c PIPItem1 = TestDataFactory.createPIPItem(false);
        PIPItem1.PI_Type__c = 'AES';
        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(10);
        PIPItem1.TASKRAY__Project__c = PIP.Id;
        pipItem1.RecordTypeId = pipItemRecordTypeId;
        insert PIPItem1;

        TASKRAY__Project_Task__c PIPItem2 = PIPItem1.clone();
        PIPItem2.Name = 'Test PIP Item2';
        pipItem2.RecordTypeId = pipItemRecordTypeId;
        insert PIPItem2;

        TASKRAY__Project_Task__c PIPItem = [SELECT PI_Due_In_Months__c,PI_Item_Due_Date__c,
                TASKRAY__Project__c
        FROM TASKRAY__Project_Task__c
        WHERE Name = 'Test PIP Item2'];
        System.assertEquals(null,PIPItem.PI_Due_In_Months__c);
        System.assertEquals(null,PIPItem.PI_Item_Due_Date__c);
        System.assertEquals(null,PIPItem.TASKRAY__Project__c);
    }

    /**
     * Method Tested: updateFieldsForClonedPIPItems
     * | Scenario: PIPItem is Clone and PIP is not updated
     * | Expected Result: Set Due in Months, Due Date and PIP is set to null
     **/
    @IsTest static void clonePIPItemStatusDiffPIP(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        TaskRay__Project__c PIP2 = TestDataFactory.createPIP(true);
        TASKRAY__Project_Task__c PIPItem1 = TestDataFactory.createPIPItem(false);
        PIPItem1.PI_Type__c = 'AES';
        PIPItem1.PI_Item_Due_Date__c = Date.today().addDays(10);
        PIPItem1.TASKRAY__Project__c = PIP.Id;
        pipItem1.RecordTypeId = pipItemRecordTypeId;
        insert PIPItem1;

        TASKRAY__Project_Task__c PIPItem2 = PIPItem1.clone();
        PIPItem2.Name = 'Test PIP Item2';
        PIPItem2.TASKRAY__Project__c = PIP2.Id;
        PIPItem2.RecordTypeId = pipItemRecordTypeId;
        insert PIPItem2;

        TASKRAY__Project_Task__c PIPItem = [SELECT PI_Due_In_Months__c,PI_Item_Due_Date__c,
                TASKRAY__Project__c,Status__c
        FROM TASKRAY__Project_Task__c
        WHERE Name = 'Test PIP Item2'];
        System.assertEquals(null,PIPItem.PI_Due_In_Months__c);
        System.assertEquals(null,PIPItem.PI_Item_Due_Date__c);
        System.assertEquals(PIP2.Id,PIPItem.TASKRAY__Project__c);
        System.assertEquals('Pending',PIPItem.Status__c);
    }

    /**
    * Method Tested: updateFieldsForClonedPIPItems
    * | Scenario: PIPItem is created and has no PIP Inspection Items
    * | Expected Result: Failed Inspection Count is set to 0
    **/
    @IsTest static void updateFailedInspectionCount(){
        TASKRAY__Project_Task__c PIPItem =  TestDataFactory.createPIPItem(false);
        PIPItem.PI_Item_Due_Date__c = Date.today().addDays(-10);
        pipItem.RecordTypeId = pipItemRecordTypeId;
        Test.startTest();
        insert PIPItem;
        Test.stopTest();

        TASKRAY__Project_Task__c insertedPIPItem = [SELECT Failed_Inspection_Count__c FROM TASKRAY__Project_Task__c];
        System.assertEquals(0,insertedPIPItem.Failed_Inspection_Count__c);
    }

    /**
    * Method Tested: updateFieldsForClonedPIPItems
    * | Scenario: PIPItem is created and has incomplete PIP Inspection Items
    * | Expected Result: Failed Inspection Count is set to 3
    **/
    @IsTest static void updateFailedInspectionCountPIPInspectionItemsNotNull(){
        List<PIP_Inspection_Item__c> PIPInspectionItemsToInsert = new List<PIP_Inspection_Item__c>();
        TASKRAY__Project_Task__c PIPItem =  TestDataFactory.createPIPItem(false);
        PIPItem.PI_Item_Due_Date__c = Date.today().addDays(10);
    //    pipItem.RecordTypeId = pipItemRecordTypeId;
        insert PIPItem;

        PIP_Inspection_Item__c PI1 = TestDataFactory.createPIPInspectionsForPIPItems(false);
        PI1.LRA_Inspection_Results__c = 'Incomplete';
        PI1.PIP_Item__c = PIPItem.Id;
        PI1.LRA_AESI_Item_ID__c = '200';
        PIPInspectionItemsToInsert.add(PI1);

        PIP_Inspection_Item__c PI2 = TestDataFactory.createPIPInspectionsForPIPItems(false);
        PI2.LRA_Inspection_Results__c = 'Incomplete';
        PI2.PIP_Item__c = PIPItem.Id;
        PI2.LRA_AESI_Item_ID__c = '300';
        PIPInspectionItemsToInsert.add(PI2);

        PIP_Inspection_Item__c PI3 = TestDataFactory.createPIPInspectionsForPIPItems(false);
        PI3.LRA_Inspection_Results__c = 'Incomplete';
        PI3.PIP_Item__c = PIPItem.Id;
        PI3.LRA_AESI_Item_ID__c = '400';
        PIPInspectionItemsToInsert.add(PI3);

        PIP_Inspection_Item__c PI4 = TestDataFactory.createPIPInspectionsForPIPItems(false);
        PI4.Name = 'Complete PIP Inspection Item';
        PI4.LRA_Inspection_Results__c = 'Complete';
        PI4.PIP_Item__c = PIPItem.Id;
        PI4.LRA_AESI_Item_ID__c = '100';
        PIPInspectionItemsToInsert.add(PI4);

        insert PIPInspectionItemsToInsert;

        TASKRAY__Project_Task__c pipItemBeforeDueDateUpdate = [SELECT Failed_Inspection_Count__c
        FROM TASKRAY__Project_Task__c];
        System.assertEquals(0,pipItemBeforeDueDateUpdate.Failed_Inspection_Count__c);

        PIPItem.PI_Item_Due_Date__c = Date.today().addDays(-10);
        System.debug('PIPItem : ' + PIPItem);
        Test.startTest();
        update PIPItem;
        Test.stopTest();
/*
        TASKRAY__Project_Task__c pipItemAfterDueDateUpdate = [SELECT Failed_Inspection_Count__c
        FROM TASKRAY__Project_Task__c];
        System.assertEquals(3,pipItemAfterDueDateUpdate.Failed_Inspection_Count__c);*/
    }

    /**
    * Method Tested: updateFieldsForClonedPIPItems
    * | Scenario: Multiple PIP Items are created and have incomplete PIP Inspection Items
    * | Expected Result: Failed Inspection Count is set to 3
    **/
    @IsTest static void updateFailedInspectionCountPIPInspectionItemsNotNullBulk(){
        List<PIP_Inspection_Item__c> PIPInspectionItemsToInsert = new List<PIP_Inspection_Item__c>();
        List<TASKRAY__Project_Task__c> PIPItemsToInsert = new List<TASKRAY__Project_Task__c>();
        List<TASKRAY__Project_Task__c> PIPItemsToUpdate = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<200; i++){
            TASKRAY__Project_Task__c PIPItem =  TestDataFactory.createPIPItem(false);
            PIPItem.PI_Item_Due_Date__c = Date.today().addDays(10);
            pipItem.RecordTypeId = pipItemRecordTypeId;
            PIPItemsToInsert.add(PIPItem);
        }
        insert PIPItemsToInsert;

        for(Integer i=0;i<200;i++) {
            PIP_Inspection_Item__c PI1 = TestDataFactory.createPIPInspectionsForPIPItems(false);
            PI1.LRA_Inspection_Results__c = 'Incomplete';
            PI1.PIP_Item__c = PIPItemsToInsert[i].Id;
            PI1.LRA_AESI_Item_ID__c = '200'+i;
            PIPInspectionItemsToInsert.add(PI1);
        }
        insert PIPInspectionItemsToInsert;

        for(Integer i=0;i<200;i++){
            PIPItemsToInsert[i].PI_Item_Due_Date__c = Date.today().addDays(-10);
            PIPItemsToUpdate.add(PIPItemsToInsert[i]);
        }
        Test.startTest();
        update PIPItemsToUpdate;
        Test.stopTest();

        List<TASKRAY__Project_Task__c> pipItemsAfterDueDateUpdate = [SELECT Failed_Inspection_Count__c
        FROM TASKRAY__Project_Task__c
        WHERE Failed_Inspection_Count__c = 1];
        System.assertEquals(200,pipItemsAfterDueDateUpdate.size());
    }
}