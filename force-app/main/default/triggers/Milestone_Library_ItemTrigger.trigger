trigger Milestone_Library_ItemTrigger on Milestone_Library_Item__c (before insert, before update, before delete, after insert, after
  update, after delete, after undelete) {
Milestone_Library_ItemTriggerHandler handler = new Milestone_Library_ItemTriggerHandler();
}