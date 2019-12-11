/**
 * @description Trigger for TASKRAY__Project__c object
 *
 * @author Zach French
 * @date 2019-08-10
 */
trigger TASKRAY_Project on TASKRAY__Project__c (before insert, before update, before delete, after insert, after
	update, after delete, after undelete) {
	TASKRAY_ProjectTriggerHandler handler = new TASKRAY_ProjectTriggerHandler();
}