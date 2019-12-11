/**
 *  @description Handler class for TASKRAY_Task trigger
 *  @author Pradnya Desai
 *  @date 2019-09-09
 */

public inherited sharing class TASKRAY_TaskTriggerHandler extends TriggerBase{

    //Trigger Variables
    public static Boolean bypassTrigger = false;
    public static Boolean isAfterUpdateTriggerReEntry = false;
    public static Boolean isBeforeUpdateTriggerReEntry = false;
    private static List<TASKRAY__Project_Task__c> newPIPItemsList = new List<TASKRAY__Project_Task__c>();
    private static List<TASKRAY__Project_Task__c> newMilestoneList = new List<TASKRAY__Project_Task__c>();

    public TASKRAY_TaskTriggerHandler() {
        setBypassTrigger(bypassTrigger);
    }

    // Before Insert execution context
    public override void beforeInsert() {
        TASKRAY_TaskTriggerHelper taskTriggerHelper = new TASKRAY_TaskTriggerHelper();
        TASKRAY_TaskTriggerHandler.populatePIPItemsAndMilestoneList((List<TASKRAY__Project_Task__c>) Trigger.new);
        if(newPIPItemsList.size() > 0) {
            // Used to set follow up date if status is incomplete
            taskTriggerHelper.setFollowUpDate(newPIPItemsList, null);
            //Set Status and Sub Status and clear Due Date and Due In Months for Clone PIP Items
            taskTriggerHelper.updateFieldsForClonedPIPItems(newPIPItemsList);
            taskTriggerHelper.setQuantityForPIPItem(newPIPItemsList, null);
        }
    }

    /**
     * This method will sort out PIP Items and Milestones in two different lists.
     *
     * @param newProjectTasksList
     */
    private static void populatePIPItemsAndMilestoneList(List<TASKRAY__Project_Task__c> newProjectTasksList){
        for(TASKRAY__Project_Task__c projectTask: newProjectTasksList) {
            if(RecordTypeUtils.isPIPItemRecordType(projectTask.RecordTypeId)){
                newPIPItemsList.add(projectTask);
            }else if(RecordTypeUtils.isMileStoneRecordType(projectTask.RecordTypeId)){
                newMilestoneList.add(projectTask);
            }
        }

    }

    // After Insert execution context
    public override void afterInsert() {
        TASKRAY_TaskTriggerHelper taskTriggerHelper = new TASKRAY_TaskTriggerHelper();
        if(newPIPItemsList.size() > 0) {
            Map<Id, TASKRAY__Project__c> pipsToUpdate = taskTriggerHelper.setPIPFields(newPIPItemsList, null);
            List<TASKRAY__Project__c> pipsToUpdateBillingInspCnt = taskTriggerHelper.updatePIPBillingInspectionCountOnTask(
                    newPIPItemsList, null);
            taskTriggerHelper.consolidateAndUpdatePIP(pipsToUpdate, pipsToUpdateBillingInspCnt);
        }

    }

    // Before Update execution context
    public override void beforeUpdate() {
        TASKRAY_TaskTriggerHelper taskTriggerHelper = new TASKRAY_TaskTriggerHelper();
        TASKRAY_TaskTriggerHandler.populatePIPItemsAndMilestoneList((List<TASKRAY__Project_Task__c>) Trigger.new);
        if(newPIPItemsList.size() > 0) {
            taskTriggerHelper.setFollowUpDate(newPIPItemsList, (Map<Id, TASKRAY__Project_Task__c>) Trigger.oldMap);
            taskTriggerHelper.updatePIPItemStatusToPending(newPIPItemsList, (Map<Id, TASKRAY__Project_Task__c>) Trigger.oldMap);
            if(!isBeforeUpdateTriggerReEntry){
                taskTriggerHelper.setQuantityForPIPItem(newPIPItemsList, (Map<Id, TASKRAY__Project_Task__c>) Trigger.oldMap);
            }
        }
        isBeforeUpdateTriggerReEntry = true;

    }

    // After Update execution context
    public override void afterUpdate() {
        if(isAfterUpdateTriggerReEntry){
            // Execute code for recursive Trigger
        }
        if(!isAfterUpdateTriggerReEntry) {
            TASKRAY_TaskTriggerHelper taskTriggerHelper = new TASKRAY_TaskTriggerHelper();
            Map<Id, TASKRAY__Project__c> pipsToUpdate = taskTriggerHelper.setPIPFields(
                    (List<TASKRAY__Project_Task__c>) Trigger.new, (Map<Id, TASKRAY__Project_Task__c>) Trigger.oldMap);
            List<TASKRAY__Project__c> pipsToUpdateBillingInspCnt =
                    taskTriggerHelper.updatePIPBillingInspectionCountOnTask((List<TASKRAY__Project_Task__c>) Trigger.new,
                            (Map<Id, TASKRAY__Project_Task__c>) Trigger.oldMap);
            taskTriggerHelper.consolidateAndUpdatePIP(pipsToUpdate, pipsToUpdateBillingInspCnt);
            If(System.isBatch() || System.isFuture() || System.isQueueable())
            	HistoryTracker_Util.createHistoryTrackerRecords(trigger.oldMap, trigger.newMap, 'TaskRay__Project_Task__History');
            else
				HistoryTracker_Util.createHistoryTrackerRecords(JSON.serialize(trigger.oldMap), JSON.serialize(trigger.newMap), 'TaskRay__Project_Task__History'); 
        }

        isAfterUpdateTriggerReEntry = true;
    }
}