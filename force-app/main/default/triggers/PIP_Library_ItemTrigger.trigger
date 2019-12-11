/**
 * @description Trigger for PIP_Library_Item__C object
 *
 * @author Madan Morusu
 * @date 2019-08-22
 */
trigger PIP_Library_ItemTrigger on PIP_Library_Item__c (before insert, before update, before delete, after insert, after
	update, after delete, after undelete) {
	PIP_Library_ItemTriggerHandler handler = new PIP_Library_ItemTriggerHandler();
}