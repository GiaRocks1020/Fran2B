/**
 * @description Test class for PIPItemStatusUpdateToPastDueBatch
 *
 * @author Sugu Chugh
 * @date 2019-09-13
 */

@IsTest
private class PIPItemStatusUpdateToPastDueBatchTest {

    /**
     * @description Creates test data for PIP and PIP Items
     **/
    @TestSetup static void init(){
        Contract__c contract = TestDataFactory.createContract(false);
        contract.Contract_Status__c = 'OPEN';
        insert contract;

        TaskRay__Project__c PIP = TestDataFactory.createPIP(false);
        PIP.Send_For_AES_Inspection__c = true;
        PIP.Sub_Status__c = 'verified';
        PIP.Contract__c = contract.Id;
        insert PIP;
    }

    /**
     * Method Tested: executeBatch
     * | Scenario: PIP Item records exist with PIP as Verified, sendForAESInspection is true, status is Pending
     *              Item Type is AES, due date is older than today, is verified and Contract is Open
     * | Expected Result: PIP Item status is updated to Past Due
     **/
    @IsTest static void executeBatch_PassListOfPIPItemsValidCriteria(){
        TASKRAY__Project__c PIP = [SELECT Id,Contract__r.Contract_Status__c FROM TASKRAY__Project__c];
        TASKRAY__Project_Task__c PIPItem = TestDataFactory.createPIPItem(false);
        PIPItem.Status__c = 'Pending';
        PIPItem.PI_Type__c = 'AES';
        PIPItem.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem.PI_Verify__c = true;
        PIPItem.TASKRAY__Project__c = PIP.Id;
        insert PIPItem;

        Test.startTest();
        PIPItemStatusUpdateToPastDueBatch obj = new PIPItemStatusUpdateToPastDueBatch();
        Database.executeBatch(obj);
        Test.stopTest();

        TASKRAY__Project_Task__c PIPItemAfterUpdate = [SELECT Name, Status__c FROM TASKRAY__Project_Task__c];
        System.assertEquals(PIPItemAfterUpdate.Status__c, 'Past Due');
    }

    /**
     * Method Tested: executeBatch
     * | Scenario: PIP Item do not records exist with PIP as Verified, sendForAESInspection is true, status is Pending
     *              Item Type is AES, due date is older than today, is verified and Contract is Open
     * | Expected Result: PIP Item status is not updated to Past Due
     **/
    @IsTest static void executeBatch_PassListOfPIPItemsInvalidCriteria(){
        TASKRAY__Project__c PIP = [SELECT Id,Contract__r.Contract_Status__c FROM TASKRAY__Project__c];
        TASKRAY__Project_Task__c PIPItem = TestDataFactory.createPIPItem(false);
        PIPItem.Status__c = 'Pending';
        PIPItem.PI_Type__c = 'BES';
        PIPItem.PI_Item_Due_Date__c = Date.today().addDays(-10);
        PIPItem.PI_Verify__c = true;
        PIPItem.TASKRAY__Project__c = PIP.Id;
        insert PIPItem;

        Test.startTest();
        PIPItemStatusUpdateToPastDueBatch obj = new PIPItemStatusUpdateToPastDueBatch();
        Database.executeBatch(obj);
        Test.stopTest();

        TASKRAY__Project_Task__c PIPItemAfterUpdate = [SELECT Name, Status__c FROM TASKRAY__Project_Task__c];
        System.assertEquals(PIPItemAfterUpdate.Status__c, 'Pending');
    }

    /**
     * Method Tested: executeBatch
     * | Scenario: Bulk PIP Item records exist with PIP as Verified, sendForAESInspection is true, status is Pending
     *              Item Type is AES, due date is older than today, is verified and Contract is Open
     * | Expected Result: PIP Item status for all records is updated to Past Due
     **/
    @IsTest static void executeBatch_PassListOfPIPItemsValidCriteriaBulk(){
        TASKRAY__Project__c PIP = [SELECT Id,Contract__r.Contract_Status__c FROM TASKRAY__Project__c];
        List<TASKRAY__Project_Task__c> PIPItemsToInsert = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<200; i++) {
            TASKRAY__Project_Task__c PIPItem = TestDataFactory.createPIPItem(false);
            PIPItem.Status__c = 'Pending';
            PIPItem.PI_Type__c = 'AES';
            PIPItem.PI_Item_Due_Date__c = Date.today().addDays(-10);
            PIPItem.PI_Verify__c = true;
            PIPItem.TASKRAY__Project__c = PIP.Id;
            PIPItemsToInsert.add(PIPItem);
        }
        insert PIPItemsToInsert;

        Test.startTest();
        PIPItemStatusUpdateToPastDueBatch obj = new PIPItemStatusUpdateToPastDueBatch();
        Database.executeBatch(obj);
        Test.stopTest();

        List<TASKRAY__Project_Task__c> PIPItemsAfterUpdate = [SELECT Name, Status__c
                                                                FROM TASKRAY__Project_Task__c
                                                                WHERE Status__c = 'Past Due'];
        System.assertEquals(PIPItemsAfterUpdate.size(),200);
    }

}