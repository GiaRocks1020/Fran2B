/**
 *  @description Test class for PIP_Inspection_Item trigger
 *  @author Pradnya Desai
 *  @date 2019-09-17
 */

@IsTest
private class PIP_Inspection_ItemTriggerHelperTest {

    private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project_Task__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id  pipItemRecordTypeId = recordTypeMap.get('PIP Item').getRecordTypeId();
    /**
	 * @description Used to setup test data used for unit tests
	 *
	 * @return void
	 */
    @TestSetup
    static void dataSetup() {
        TaskRay__Project__c pipProject = TestDataFactory.createPIP(true);
        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 7, pipProject.Id,
                pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);
        pipItemsList[0].Name = 'Complete';
        pipItemsList[0].PI_Type__c = 'AES';
        pipItemsList[0].PI_Due_In_Months__c = 2;
        pipItemsList[0].PI_HGI__c = true;

        pipItemsList[1].Name = 'Incomplete';
        pipItemsList[1].PI_Type__c = 'BES';
        pipItemsList[1].PI_HGI__c = true;

        pipItemsList[2].Name = 'Questionable';
        pipItemsList[2].PI_Type__c = 'AES';
        pipItemsList[2].PI_Due_In_Months__c = 2;
        pipItemsList[2].PI_HGI__c = false;

        pipItemsList[3].Name = 'Future';
        pipItemsList[4].Name = 'OldPending';
        pipItemsList[4].Status__c = 'Pending';
        pipItemsList[4].PI_Item_Due_Date__c = Date.today().addDays(10);
        pipItemsList[5].Name = 'Else';
        pipItemsList[6].Name = 'NoParentPIP';

        insert pipItemsList;

    }

    /**
	 * @description This method will validate Billing Inspection count as per Inspection results of Inspection Items
	 * inserted for the PIP Item.
	 * Note: Increment the billing inspection count field when LRA has an pip inspection item that is Incomplete
	 * is added to a PIP Item where HGI = true and ItemType is AES.Set the billing inspection count to null
	 * if a new inspection result is received that is not incomplete
	 *
	 * @return void
	 */
    static testMethod void validateBillingInspectionCount() {
        List<TASKRAY__Project_Task__c> pipItemsList = [SELECT Id, Name from TASKRAY__Project_Task__c];

        List<PIP_Inspection_Item__c> inspectionItems = new List<PIP_Inspection_Item__c>();
        Integer Count = 0;

        for(TASKRAY__Project_Task__c pipItems : pipItemsList){
            PIP_Inspection_Item__c inspectionItem = new PIP_Inspection_Item__c();
            if(pipItems.Name == 'Complete') {
                inspectionItem.LRA_Inspection_Results__c = 'Incomplete';
                inspectionItem.PIP_Item__c = pipItems.Id;
            }else if (pipItems.Name == 'NoParentPIP') {
                inspectionItem.LRA_Inspection_Results__c = 'NoParentPIP';
            } else {
                inspectionItem.PIP_Item__c = pipItems.Id;
            }
            inspectionItem.LRA_AESI_Item_ID__c = 'LRA_AES_ITEM' + Count;
            Count++;
            inspectionItems.add(inspectionItem);
        }

        Test.startTest();
        insert inspectionItems;
        Test.stopTest();

        List<TASKRAY__Project_Task__c> pipItemsListAfterInsert = [SELECT Id, Name, PI_Billing_Inspection_Count__c from TASKRAY__Project_Task__c];
        List<PIP_Inspection_Item__c> inspectionItemIncrementList = new List<PIP_Inspection_Item__c>();
        PIP_Inspection_Item__c inspectionItemIncrement = null;
        for(TASKRAY__Project_Task__c pipItems : pipItemsListAfterInsert){
            inspectionItemIncrement = new PIP_Inspection_Item__c();
            if(pipItems.Name == 'Complete'){
                System.assertEquals(1, pipItems.PI_Billing_Inspection_Count__c);
            }else if(pipItems.Name == 'Incomplete'){
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }else if(pipItems.Name == 'Questionable'){
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }else{
                System.debug('pipItems : ' + pipItems.Name);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }

            inspectionItemIncrement.LRA_Inspection_Results__c = 'Incomplete';
            inspectionItemIncrement.PIP_Item__c = pipItems.Id;
            inspectionItemIncrement.LRA_AESI_Item_ID__c = 'LRA_AES'+Count;
            Count++;
            inspectionItemIncrementList.add(inspectionItemIncrement);
        }

        insert inspectionItemIncrementList;

        List<PIP_Inspection_Item__c> inspectionItemResetList = new List<PIP_Inspection_Item__c>();
        PIP_Inspection_Item__c inspectionItemReset = null;
        List<TASKRAY__Project_Task__c> pipItemsListToUpdate = [SELECT Id, Name, PI_Billing_Inspection_Count__c
            from TASKRAY__Project_Task__c];
        for(TASKRAY__Project_Task__c pipItems : pipItemsListToUpdate){
            if(pipItems.Name == 'Complete'){
                inspectionItemReset = new PIP_Inspection_Item__c();
                inspectionItemReset.LRA_Inspection_Results__c = 'Complete';
                inspectionItemReset.PIP_Item__c = pipItems.Id;
                inspectionItemReset.LRA_AESI_Item_ID__c= 'LRA_AES' + Count;
                inspectionItemResetList.add(inspectionItemReset);
                System.assertEquals(2, pipItems.PI_Billing_Inspection_Count__c);
            }else{
                inspectionItemReset = new PIP_Inspection_Item__c();
                inspectionItemReset.LRA_Inspection_Results__c = 'Complete';
                inspectionItemReset.PIP_Item__c = pipItems.Id;
                inspectionItemReset.LRA_AESI_Item_ID__c= 'LRA_AES' + Count;
                inspectionItemResetList.add(inspectionItemReset);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }
            Count++;
        }

        insert inspectionItemResetList;

        List<TASKRAY__Project_Task__c> pipItemsListToReset = [SELECT Id, Name, PI_Billing_Inspection_Count__c
        from TASKRAY__Project_Task__c];

        for(TASKRAY__Project_Task__c pipItems : pipItemsListToReset){
            System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
        }

    }

    /**
	 * @description This method will validate Billing Inspection count as per Inspection results of Inspection Items
	 * inserted for the PIP Item.
	 * Note: Increment the billing inspection count field when LRA has an pip inspection item that is Incomplete
	 * is added to a PIP Item where HGI = true and ItemType is AES.Set the billing inspection count to null
	 * if a new inspection result is received that is not incomplete
	 *
	 * @return void
	 */
    static testMethod void validateNumberOfVisits() {
        List<TASKRAY__Project_Task__c> pipItemsList = [SELECT Id, Name from TASKRAY__Project_Task__c];

        List<PIP_Inspection_Item__c> inspectionItems = new List<PIP_Inspection_Item__c>();
        Integer Count = 0;
        for(TASKRAY__Project_Task__c pipItems : pipItemsList){
            PIP_Inspection_Item__c inspectionItem = new PIP_Inspection_Item__c();
            if(pipItems.Name == 'Complete'){
                inspectionItem.LRA_Inspection_Results__c = 'Complete';
            }else if(pipItems.Name == 'Incomplete'){
                inspectionItem.LRA_Inspection_Results__c = 'Incomplete';
            }else if(pipItems.Name == 'Questionable'){
                inspectionItem.LRA_Inspection_Results__c = 'Questionable';
            }else if(pipItems.Name == 'Future'){
                inspectionItem.LRA_Inspection_Results__c = 'Future';
            }else if(pipItems.Name == 'OldPending'){
                inspectionItem.LRA_Inspection_Results__c = 'Incomplete';
            }else if(pipItems.Name == 'Else'){
                inspectionItem.LRA_Inspection_Results__c = 'Else';
            }

            if(pipItems.Name == 'NoParentPIP'){
                inspectionItem.LRA_Inspection_Results__c = 'NoParentPIP';
            }else {
                inspectionItem.PIP_Item__c = pipItems.Id;
            }
            inspectionItem.LRA_AESI_Item_ID__c= 'LRA_AES'+Count;
            Count++;
            inspectionItems.add(inspectionItem);
        }

        Test.startTest();
        insert inspectionItems;
        Test.stopTest();

        List<TASKRAY__Project_Task__c> pipItemsListAfterInsert = [SELECT Id, Name, PI_Number_Of_Visits__c from TASKRAY__Project_Task__c];
        List<PIP_Inspection_Item__c> inspectionItemIncrementList = new List<PIP_Inspection_Item__c>();
        PIP_Inspection_Item__c inspectionItemIncrement = null;
        for(TASKRAY__Project_Task__c pipItems : pipItemsListAfterInsert){
            inspectionItemIncrement = new PIP_Inspection_Item__c();
            if(pipItems.Name == 'Incomplete'){
                pipItems.Status__c = 'Past Due';
                inspectionItemIncrement.LRA_Inspection_Results__c = 'Incomplete';
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
                update pipItems;
            }else if(pipItems.Name != 'NoParentPIP'){
                inspectionItemIncrement.LRA_Inspection_Results__c = 'Complete';
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
            }
            if(pipItems.Name == 'NoParentPIP'){
                inspectionItemIncrement.LRA_Inspection_Results__c = 'Future';
                System.assertEquals(null, pipItems.PI_Number_Of_Visits__c);
            }else {
                inspectionItemIncrement.PIP_Item__c = pipItems.Id;
            }

            inspectionItemIncrement.LRA_AESI_Item_ID__c= 'LRA_AES'+Count;
            Count++;
            inspectionItemIncrementList.add(inspectionItemIncrement);
        }

        insert inspectionItemIncrementList;

        List<PIP_Inspection_Item__c> inspectionItemResetList = new List<PIP_Inspection_Item__c>();
        PIP_Inspection_Item__c inspectionItemReset = null;
        List<TASKRAY__Project_Task__c> pipItemsListToUpdate = [SELECT Id, Name, PI_Number_Of_Visits__c
        from TASKRAY__Project_Task__c];
        for(TASKRAY__Project_Task__c pipItems : pipItemsListToUpdate){
            if(pipItems.Name == 'Incomplete'){
                 System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
            }else if(pipItems.Name == 'NoParentPIP') {
                System.assertEquals(null, pipItems.PI_Number_Of_Visits__c);
            }else{
                System.assertEquals(2, pipItems.PI_Number_Of_Visits__c);
            }
        }
    }

    /**
	 * @description This method will validate Updates to PIP Inspection Item
	 *
	 * @return void
	 */
    static testMethod void validateUpdateFlow() {
        List<TASKRAY__Project_Task__c> pipItemsList = [SELECT Id, Name from TASKRAY__Project_Task__c];

        List<PIP_Inspection_Item__c> inspectionItems = new List<PIP_Inspection_Item__c>();
        Integer Count = 0;
        for(TASKRAY__Project_Task__c pipItems : pipItemsList){
            PIP_Inspection_Item__c inspectionItem = new PIP_Inspection_Item__c();
            if(pipItems.Name == 'Complete'){
                inspectionItem.LRA_Inspection_Results__c = 'Complete';
            }else if(pipItems.Name == 'Incomplete'){
                inspectionItem.LRA_Inspection_Results__c = 'Incomplete';
            }else if(pipItems.Name == 'Questionable'){
                inspectionItem.LRA_Inspection_Results__c = 'Questionable';
            }else if(pipItems.Name == 'Future'){
                inspectionItem.LRA_Inspection_Results__c = 'Future';
            }else if(pipItems.Name == 'OldPending'){
                inspectionItem.LRA_Inspection_Results__c = 'Incomplete';
            }else if(pipItems.Name == 'Else'){
                inspectionItem.LRA_Inspection_Results__c = 'Else';
            }

            if(pipItems.Name == 'NoParentPIP'){
                inspectionItem.LRA_Inspection_Results__c = 'NoParentPIP';
            }else {
                inspectionItem.PIP_Item__c = pipItems.Id;
            }
            inspectionItem.LRA_AESI_Item_ID__c= 'LRA_AES'+Count;
            Count++;
            inspectionItems.add(inspectionItem);
        }

        Test.startTest();
        insert inspectionItems;
        Test.stopTest();

        List<TASKRAY__Project_Task__c> pipItemsListAfterInsert = [SELECT Id, Name, PI_Number_Of_Visits__c,
                Status__c, PI_Billing_Inspection_Count__c from TASKRAY__Project_Task__c];
        List<PIP_Inspection_Item__c> inspectionItemIncrementList = [Select Id, LRA_Inspection_Results__c,
                PIP_Item__r.Name  from PIP_Inspection_Item__c];
        for(TASKRAY__Project_Task__c pipItems : pipItemsListAfterInsert){
            if(pipItems.Name == 'Complete'){
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals('Completed Pending Review', pipItems.Status__c);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }else if(pipItems.Name == 'Incomplete'){
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals('Incomplete', pipItems.Status__c);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }else if(pipItems.Name == 'Questionable'){
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals('Choice Review', pipItems.Status__c);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }else if(pipItems.Name == 'Future'){
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals('Pending', pipItems.Status__c);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }else if(pipItems.Name == 'OldPending'){
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals('Pending', pipItems.Status__c);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }else if(pipItems.Name == 'Else'){
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals('Choice Review', pipItems.Status__c);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }

            if(pipItems.Name == 'NoParentPIP'){
                System.assertEquals(null, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals(null, pipItems.Status__c);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }
        }
        for(PIP_Inspection_Item__c pipInspectionItem: inspectionItemIncrementList){
                pipInspectionItem.LRA_Inspection_Results__c = 'Incomplete';
        }

        update inspectionItemIncrementList;


        List<TASKRAY__Project_Task__c> pipItemsListAfterUpdate = [SELECT Id, Name, PI_Number_Of_Visits__c, Status__c,
                PI_Billing_Inspection_Count__c from TASKRAY__Project_Task__c];
        for(TASKRAY__Project_Task__c pipItems : pipItemsListAfterUpdate){
            if(pipItems.Name == 'Complete'){
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals('Incomplete', pipItems.Status__c);
                System.assertEquals(1, pipItems.PI_Billing_Inspection_Count__c);
            }else if(pipItems.Name == 'NoParentPIP'){
                System.assertEquals(null, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals(null, pipItems.Status__c);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }else if(pipItems.Name == 'OldPending'){
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals('Pending', pipItems.Status__c);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }else{
                System.debug('pipItems.Name :' + pipItems.Name);
                System.assertEquals(1, pipItems.PI_Number_Of_Visits__c);
                System.assertEquals('Incomplete', pipItems.Status__c);
                System.assertEquals(null, pipItems.PI_Billing_Inspection_Count__c);
            }
        }
    }

    /**
	 * @description Validate Error Event are triggered on DML Error.
	 *
	 * @return void
	 */
    static testMethod void validateErrorEvent() {

        List<TASKRAY__Project_Task__c> pipItemsList = [SELECT Id, Name from TASKRAY__Project_Task__c];

        List<PIP_Inspection_Item__c> inspectionItems = new List<PIP_Inspection_Item__c>();
        Integer Count = 0;
        for(TASKRAY__Project_Task__c pipItems : pipItemsList){
            PIP_Inspection_Item__c inspectionItem = new PIP_Inspection_Item__c();
            inspectionItem.LRA_Inspection_Results__c = 'Incomplete';
            inspectionItem.LRA_AESI_Item_ID__c= 'LRA_AES'+Count;
            inspectionItem.PIP_Item__c = pipItems.Id;
            Count++;
            inspectionItems.add(inspectionItem);
        }

        User pipWriter = TestDataFactory.createPIPWriterUser();

        Boolean hasPermission;
        System.runAs(pipWriter) {
            Test.startTest();
            insert inspectionItems;
            Test.stopTest();
        }

        List<Error_Log__c> errorLogList = [SELECT Id, Failed_Record_Name__c, Error_Code__c from Error_Log__c];
        System.assertEquals(7,errorLogList.size());
        List<String> nameOfParentRecords = new List<String>{ 'Complete' , 'Incomplete' , 'Questionable',
                'Future', 'OldPending', 'Else', 'NoParentPIP'};
        for(Error_Log__c errorLog : errorLogList){
            System.assert(nameOfParentRecords.contains(errorLog.Failed_Record_Name__c), 'Incorrect Parent Record');
        }
    }

    /**
	 * @description This method will validate all PIP Item Status depending on Inspection results of Inspection Items
	 * inserted for the PIP Item
	 *
	 * @return void
	 */
    static testMethod void validatePIPItemStatus() {
        List<TASKRAY__Project_Task__c> pipItemsList = [SELECT Id, Name from TASKRAY__Project_Task__c];

        List<PIP_Inspection_Item__c> inspectionItems = new List<PIP_Inspection_Item__c>();
        Integer Count = 0;
        for(TASKRAY__Project_Task__c pipItems : pipItemsList){
            PIP_Inspection_Item__c inspectionItem = new PIP_Inspection_Item__c();
            if(pipItems.Name == 'Complete'){
                inspectionItem.LRA_Inspection_Results__c = 'Complete';
            }else if(pipItems.Name == 'Incomplete'){
                inspectionItem.LRA_Inspection_Results__c = 'Incomplete';
            }else if(pipItems.Name == 'Questionable'){
                inspectionItem.LRA_Inspection_Results__c = 'Questionable';
            }else if(pipItems.Name == 'Future'){
                inspectionItem.LRA_Inspection_Results__c = 'Future';
            }else if(pipItems.Name == 'OldPending'){
                inspectionItem.LRA_Inspection_Results__c = 'Incomplete';
            }else if(pipItems.Name == 'Else'){
                inspectionItem.LRA_Inspection_Results__c = 'Else';
            }

            if(pipItems.Name == 'NoParentPIP'){
                inspectionItem.LRA_Inspection_Results__c = 'NoParentPIP';
            }else {
                inspectionItem.PIP_Item__c = pipItems.Id;
            }
            inspectionItem.LRA_AESI_Item_ID__c= 'LRA_AES'+Count;
            Count++;
            inspectionItems.add(inspectionItem);
        }

        Test.startTest();
        insert inspectionItems;
        Test.stopTest();

        List<TASKRAY__Project_Task__c> pipItemsListAfterInsert = [SELECT Id, Name, Status__c from TASKRAY__Project_Task__c];


        for(TASKRAY__Project_Task__c pipItems : pipItemsListAfterInsert){
            if(pipItems.Name == 'Complete'){
                System.assertEquals('Completed Pending Review', pipItems.Status__c);
            }else if(pipItems.Name == 'Incomplete'){
                System.assertEquals('Incomplete', pipItems.Status__c);
            }else if(pipItems.Name == 'Questionable'){
                System.assertEquals('Choice Review', pipItems.Status__c);
            }else if(pipItems.Name == 'Future'){
                System.assertEquals('Pending', pipItems.Status__c);
            }else if(pipItems.Name == 'OldPending'){
                System.assertEquals('Pending', pipItems.Status__c);
            }else if(pipItems.Name == 'Else'){
                System.assertEquals('Choice Review', pipItems.Status__c);
            }else if(pipItems.Name == 'NoParentPIP'){
                System.assertEquals(null, pipItems.Status__c);
            }
        }
    }


    /**
	 * @description This method will validate PIP Item Status depending on Inspection results of Latest Inspection Item
	 * inserted for the PIP Item
	 *
	 * @return void
	 */
    static testMethod void validatePIPItemStatusMultipleInspections() {
        List<TASKRAY__Project_Task__c> pipItemsList = [SELECT Id, Name from TASKRAY__Project_Task__c];
        List<PIP_Inspection_Item__c> inspectionItems = new List<PIP_Inspection_Item__c>();

        PIP_Inspection_Item__c inspectionItem = new PIP_Inspection_Item__c();
        inspectionItem.LRA_Inspection_Results__c = 'Complete';
        inspectionItem.PIP_Item__c = pipItemsList[0].Id;
        inspectionItem.LastModifiedDate = Datetime.now().addSeconds(5);
        inspectionItems.add(inspectionItem);

        inspectionItem = new PIP_Inspection_Item__c();
        inspectionItem.LRA_Inspection_Results__c = 'Incomplete';
        inspectionItem.PIP_Item__c = pipItemsList[0].Id;
        inspectionItem.LastModifiedDate = Datetime.now().addSeconds(1);
        inspectionItems.add(inspectionItem);

        inspectionItem = new PIP_Inspection_Item__c();
        inspectionItem.LRA_Inspection_Results__c = 'Questionable';
        inspectionItem.PIP_Item__c = pipItemsList[0].Id;
        inspectionItem.LastModifiedDate = Datetime.now().addSeconds(7);
        inspectionItems.add(inspectionItem);

        inspectionItem = new PIP_Inspection_Item__c();
        inspectionItem.LRA_Inspection_Results__c = 'Future';
        inspectionItem.PIP_Item__c = pipItemsList[0].Id;
        inspectionItem.LastModifiedDate = Datetime.now();
        inspectionItems.add(inspectionItem);


        Test.startTest();
        PIP_Inspection_ItemTriggerHelper pipInspectionItemTriggerHelper = new PIP_Inspection_ItemTriggerHelper();
        pipInspectionItemTriggerHelper.updatePIPItem(inspectionItems, false, null);
        Test.stopTest();

        List<TASKRAY__Project_Task__c> pipItemsListAfterInsert = [SELECT Id, Name, Status__c from TASKRAY__Project_Task__c];
        System.assertEquals('Choice Review', pipItemsListAfterInsert[0].Status__c);
    }

    /**
    * Method Tested: setFailedInspectionCountPIPItem
    * | Scenario: PIP Inspection Item is inserted as Incomplete
    * | Expected Result: Failed Inspection Count is updated on PIP Item
    **/
    @IsTest static void validateFailedInspectionCountIsUpdated(){
        List<PIP_Inspection_Item__c> PIPInspectionItemsToInsert = new List<PIP_Inspection_Item__c>();
        TaskRay__Project__c PIP = [SELECT Id, Name FROM TaskRay__Project__c];

        TASKRAY__Project_Task__c PIPItem =  TestDataFactory.createPIPItem(false);
        PIPItem.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem.TASKRAY__Project__c = PIP.Id;
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

        Test.startTest();
        insert PIPInspectionItemsToInsert;
        Test.stopTest();

        TASKRAY__Project_Task__c PIPItemUpdated = [SELECT Failed_Inspection_Count__c FROM TASKRAY__Project_Task__c
        WHERE Name = 'Test PIP Item'];
        System.assertEquals(3,PIPItemUpdated.Failed_Inspection_Count__c);

        PIP_Inspection_Item__c PIPInspectionItem = [SELECT Id, LRA_Inspection_Results__c FROM PIP_Inspection_Item__c
        WHERE Name = 'Complete PIP Inspection Item'];
        PIPInspectionItem.LRA_Inspection_Results__c = 'Incomplete';
        update PIPInspectionItem;

        TASKRAY__Project_Task__c PIPItemUpdated2 = [SELECT Failed_Inspection_Count__c FROM TASKRAY__Project_Task__c
        WHERE Name = 'Test PIP Item'];
        System.assertEquals(4,PIPItemUpdated2.Failed_Inspection_Count__c);
    }

}