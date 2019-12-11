/**
 *  @description Trigger for TASKRAY__Project_Task__c object
 *  @author Pradnya Desai
 *  @date 2019-09-09
 */

trigger TASKRAY_Task on TASKRAY__Project_Task__c (before insert, before update, after insert, after update, after delete, after undelete) {

    TASKRAY_TaskTriggerHandler taskTriggerHandler = new TASKRAY_TaskTriggerHandler();

}