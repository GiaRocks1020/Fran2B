/**
 * @description Handler class to be associated with the Contract__c object which extends the Trigger Base class. This
  * also includes the built-in trigger override functionality.
 *
 * @author Zach French
 * @date 9/4/19
 */
public inherited sharing class ContractTriggerHandler extends TriggerBase {

	// Trigger Variables
	public static Boolean bypassTrigger = false;

	// Constructor
	public ContractTriggerHandler() {
		setBypassTrigger(bypassTrigger);
	}

	public override void afterInsert() {
		// Update property
		ContractTrigger_Handler.updateProperty((List<Contract__c>) trigger.new);
	}

	public override void afterUpdate() {
		// Update property
		ContractTrigger_Handler.updateProperty((List<Contract__c>) trigger.new);

		// Used to update related pips status to dead if the Contract is dead
		PIPHelper helper = new PIPHelper();
		helper.updateDeadRelatedPIPs(Trigger.new, Trigger.oldMap);
	}
}