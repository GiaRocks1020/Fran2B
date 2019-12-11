/*
 * @Author: Jagan Gorre
 * @Desc: Execution handler for all triggers
*/
public with sharing class TriggerExecutionHandler {

    //To be used in test classes if there is a need for different execution order
	@TestVisible private static TriggerExecutor mockExecutor;
    //To be used in test classes if any particular trigger need to be disabled.
	@TestVisible private static Set<String> disableSObjectTriggers = new Set<String>();

	public static void execute(TriggerExecutor executor) {
		if (mockExecutor != null) {
			executor = mockExecutor;
		}
		if (runTrigger(executor.getSObjectName())) {
			if (Trigger.isBefore) {
				if (Trigger.isDelete) {
					executor.beforeDelete(Trigger.old);
				}
				else if (Trigger.isInsert) {
					executor.beforeInsert(Trigger.new);
				}
				else if (Trigger.isUpdate) {
					executor.beforeUpdate(Trigger.oldMap, Trigger.new);
				}
			} else if (Trigger.isAfter) {
				if (Trigger.isDelete) {
					executor.afterDelete(Trigger.old);
				}
				else if (Trigger.isInsert) {
					executor.afterInsert(Trigger.new);
				}
				else if (Trigger.isUpdate) {
					executor.afterUpdate(Trigger.oldMap, Trigger.new);
				}
			}
		}
	}
	//Incase if the trigger need to be disabled (ex: test class),
	//corresponding sobject name should be added to disableSObjectTriggers in that test class
	private static boolean runTrigger(String sObjectName) {
		return !disableSObjectTriggers.contains(sObjectName);
	}
}