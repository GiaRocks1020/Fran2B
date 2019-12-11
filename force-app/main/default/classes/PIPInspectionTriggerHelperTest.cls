/**
 * Created by pradnya.desai on 10/1/19.
 */

@IsTest
private class PIPInspectionTriggerHelperTest {

    private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project_Task__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id  pipItemRecordTypeId = recordTypeMap.get('PIP Item').getRecordTypeId();

    /**
	 * @description Used to setup test data used for unit tests
	 *
	 * @return void
	 */
    @TestSetup
    static void dataSetup() {
        TaskRay__Project__c pipProject = TestDataFactory.createPIP(false);
        pipProject.PIP_Compliance_Status__c = 'Pending Review';
        insert pipProject;

        List<PIP_Inspection__c> pipInspectionList = TestDataFactory.createPIPInspections(6,pipProject.Id,
                'LRA AES Base','In Review');
        insert pipInspectionList;
        System.debug(' pipInspectionList: ' +pipInspectionList);
    }

    /**
	 * @description This method will validate Letter Sent Date and HGI Inspection result if Status Reason is changed to
	 * 'Letter Sent'. Also it will verify these values are not set otherwise.
	 *
	 * @return void
	 */
    @IsTest
    static void validateLetterSentDateAndHGIStatus() {
        List<PIP_Inspection__c> pipInspectionList = [Select Id, Status_Reason__c, HGI_Inspection_Results__c,
                Letter_Sent_Date__c from PIP_Inspection__c];
        pipInspectionList[0].Status_Reason__c = 'Letter Sent';
        pipInspectionList[1].Status_Reason__c = 'Ready for Review';
        pipInspectionList[2].Status_Reason__c = 'Inactive';
        pipInspectionList[3].Status_Reason__c = 'Letter Sent';
        pipInspectionList[4].Status_Reason__c = 'Review Complete';
        pipInspectionList[5].Status_Reason__c = 'Additional Review';

        Test.startTest();
        update pipInspectionList;
        Test.stopTest();

        List<PIP_Inspection__c> updatedPipInspectionList = [Select Id, Status_Reason__c, Letter_Sent_Date__c,
                HGI_Inspection_Results__c from PIP_Inspection__c];

        System.assertEquals(Date.today(),updatedPipInspectionList[0].Letter_Sent_Date__c);
        System.assertEquals('Pending Review',updatedPipInspectionList[0].HGI_Inspection_Results__c);

        System.assertEquals(null,updatedPipInspectionList[1].Letter_Sent_Date__c);
        System.assertEquals(null,updatedPipInspectionList[1].HGI_Inspection_Results__c);

        System.assertEquals(null,updatedPipInspectionList[2].Letter_Sent_Date__c);
        System.assertEquals(null,updatedPipInspectionList[2].HGI_Inspection_Results__c);

        System.assertEquals(Date.today(),updatedPipInspectionList[3].Letter_Sent_Date__c);
        System.assertEquals('Pending Review',updatedPipInspectionList[3].HGI_Inspection_Results__c);

        System.assertEquals(null,updatedPipInspectionList[4].Letter_Sent_Date__c);
        System.assertEquals(null,updatedPipInspectionList[4].HGI_Inspection_Results__c);

        System.assertEquals(null,updatedPipInspectionList[5].Letter_Sent_Date__c);
        System.assertEquals(null,updatedPipInspectionList[5].HGI_Inspection_Results__c);

    }

    /**
	 * @description This method will validate Letter Sent Date is changed but HGI Inspection result is blank if
	 * Status Reason is changed to 'Letter Sent' and there is no PIP associated with the Inspection
	 *
	 * @return void
	 */
    @IsTest
    static void validateNoProject() {

        List<PIP_Inspection__c> pipInspectionList = TestDataFactory.createPIPInspections(1,null,
                'LRA_AES','Letter Sent');

        Test.startTest();
        insert pipInspectionList;
        Test.stopTest();

        List<PIP_Inspection__c> updatedPipInspectionList = [Select Id, Status_Reason__c, Letter_Sent_Date__c,
                HGI_Inspection_Results__c from PIP_Inspection__c where LRA_AESI_ID__c =: 'LRA_AES0'];

        System.assertEquals(Date.today(),updatedPipInspectionList[0].Letter_Sent_Date__c);
        System.assertEquals(null,updatedPipInspectionList[0].HGI_Inspection_Results__c);
    }

    /**
	 * @description This method will validate Letter Sent Date and HGI Inspection result if Status Reason is
	 * 'Letter Sent' at the time of Insert. Also it will verify these values are not set otherwise.
	 *
	 * @return void
	 */
    @IsTest
    static void validateBeforeInsert() {

        TaskRay__Project__c pipProject = [Select Id from TaskRay__Project__c];

        List<PIP_Inspection__c> pipInspectionList = TestDataFactory.createPIPInspections(1, pipProject.Id,
                'LRA_AES_Insert','Letter Sent');

        List<PIP_Inspection__c> pipInspectionListTwo = TestDataFactory.createPIPInspections(1, pipProject.Id,
                'LRA_AES_Insert2','In Review');

        List<PIP_Inspection__c> finalPipInspections = new List<PIP_Inspection__c>();
        finalPipInspections.addAll(pipInspectionList);
        finalPipInspections.addAll(pipInspectionListTwo);

        Test.startTest();
        insert finalPipInspections;
        Test.stopTest();

        List<PIP_Inspection__c> updatedPipInspectionList = [Select Id, Status_Reason__c, Letter_Sent_Date__c,
                HGI_Inspection_Results__c from PIP_Inspection__c where LRA_AESI_ID__c like: '%LRA_AES_Insert%'];

        System.assertEquals(Date.today(),updatedPipInspectionList[0].Letter_Sent_Date__c);
        System.assertEquals('Pending Review',updatedPipInspectionList[0].HGI_Inspection_Results__c);

        System.assertEquals(null,updatedPipInspectionList[1].Letter_Sent_Date__c);
        System.assertEquals(null,updatedPipInspectionList[1].HGI_Inspection_Results__c);


    }

    /**
	 * @description This method will validate Letter Sent Date is changed but HGI Inspection result is blank if
	 * Status Reason is changed to 'Letter Sent' and HGI Status is not set on PIP associated with the Inspection
	 *
	 * @return void
	 */
    @IsTest
    static void validateNullHGIStatus() {

        TaskRay__Project__c pipProject = TestDataFactory.createPIP(true);

        List<PIP_Inspection__c> pipInspectionList = TestDataFactory.createPIPInspections(1, pipProject.Id,
                'LRA_AES_Insert','Letter Sent');

        Test.startTest();
        insert pipInspectionList;
        Test.stopTest();

        List<PIP_Inspection__c> updatedPipInspectionList = [Select Id, Status_Reason__c, Letter_Sent_Date__c,
                HGI_Inspection_Results__c from PIP_Inspection__c where LRA_AESI_ID__c like: '%LRA_AES_Insert%'];

        System.assertEquals(Date.today(),updatedPipInspectionList[0].Letter_Sent_Date__c);
        System.assertEquals(null,updatedPipInspectionList[0].HGI_Inspection_Results__c);

    }

    /**
	 * @description This method will set value 'Pending' for PIP Compliance Status field and then change Status reason
	 * to 'Letter Sent', to validate HGI_Inspection_Results__c as Pending
	 *
	 * @return void
	 */
    static testMethod void validatePendingStatusOnInspection() {

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
        insert pipItemsList;

        List<PIP_Inspection__c> pipInspectionList = TestDataFactory.createPIPInspections(1, pipProject.Id,
                'LRA_AES_Compliance_Insert','Letter Sent');

        Test.startTest();
        insert pipInspectionList;
        Test.stopTest();

        List<PIP_Inspection__c> updatedPipInspectionList = [Select Id, Status_Reason__c, Letter_Sent_Date__c,
                HGI_Inspection_Results__c from PIP_Inspection__c where LRA_AESI_ID__c like: '%LRA_AES_Compliance_Insert%'];

        System.assertEquals(Date.today(),updatedPipInspectionList[0].Letter_Sent_Date__c);
        System.assertEquals('Pending - Internal',updatedPipInspectionList[0].HGI_Inspection_Results__c);
    }
}