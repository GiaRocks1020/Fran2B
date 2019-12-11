/*
 * @Author: Jagan Gorre
 * @Desc: Executor for Ownership Relation trigger. Contains the methods to execute after insert and after update.
*/
public with sharing class OwnershipRelationTriggerExecutor implements TriggerExecutor{
	@TestVisible
	private OwnershipRelationTriggerHandler triggerHandler = new OwnershipRelationTriggerHandler();

	public String getSObjectName() {
		return Ownership_Relation__c.sObjectType.getDescribe().getName();
	}

	public void beforeInsert(List<Ownership_Relation__c> triggerNew) {}

	public void beforeUpdate(Map<Id,SObject> triggerOldMap, List<Ownership_Relation__c> triggerNew) {}

	public void beforeDelete(List<Ownership_Relation__c> triggerOld) {}

	public void afterInsert(List<Ownership_Relation__c> triggerNew) {
        OwnershipRelationTriggerHandler.createPlatformEventOrInsertCustomObjectRecords(triggerNew,null);
    }

	public void afterUpdate(Map<Id,SObject> triggerOldMap, List<Ownership_Relation__c> triggerNew) {
        Map<Id, Ownership_Relation__c > triggerOld = (Map<Id, Ownership_Relation__c >) triggerOldMap;
        OwnershipRelationTriggerHandler.createPlatformEventOrInsertCustomObjectRecords(triggerNew, triggerOld);
	}

	public void afterDelete(List<Ownership_Relation__c> triggerOld) {}
}