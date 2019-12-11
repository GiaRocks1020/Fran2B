/*
 * @Author: Jagan Gorre
 * @Desc: Executor for Customer trigger. Contains the methods to execute after insert and after update.
*/
public with sharing class CustomerTriggerExecutor implements TriggerExecutor{
	@TestVisible
	private CustomerTriggerHandler triggerHandler = new CustomerTriggerHandler();

	public String getSObjectName() {
		return Customer__c.sObjectType.getDescribe().getName();
	}

	public void beforeInsert(List<Customer__c > triggerNew) {}

	public void beforeUpdate(Map<Id,SObject> triggerOldMap, List<Customer__c > triggerNew) {}

	public void beforeDelete(List<Customer__c > triggerOld) {}

	public void afterInsert(List<Customer__c > triggerNew) {
        CustomerTriggerHandler.createPlatformEventOrInsertCustomObjectRecords(triggerNew,null);
    }

	public void afterUpdate(Map<Id,SObject> triggerOldMap, List<Customer__c > triggerNew) {
        Map<Id, Customer__c  > triggerOld = (Map<Id, Customer__c  >) triggerOldMap;
        CustomerTriggerHandler.createPlatformEventOrInsertCustomObjectRecords(triggerNew, triggerOld);
	}

	public void afterDelete(List<Customer__c> triggerOld) {}
}