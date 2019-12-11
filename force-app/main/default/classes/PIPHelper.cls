/**
 * @description Helper class used with functionality related to PIP records
 *
 * @author Zach French
 * @date 9/4/19
 */
public inherited sharing class PIPHelper {

	public static String STAGE_NAME_DEAD_DEAL = 'Dead Deal';
	public static String CONTRACT_STATUS_DEAD_DEAL = 'DEAD';
	public static String CONTRACT_STATUS_TERMINATED = 'TERM';
	public static String PIP_STATUS_COMPLETED = 'Completed';
	public static String PIP_SUB_STATUS_DEAD = 'Dead';
	public List<String> eligibleDeadPIPStatus = new List<String>{
		CONTRACT_STATUS_DEAD_DEAL.toLowerCase(),
		CONTRACT_STATUS_TERMINATED.toLowerCase()
	};
	public static String TASKRAY_PROJECT_RECORDTYPE_PIP = StaticValue.getStaticValueText
		('TASKRAY_Project_RECORD_TYPE_PIP');


	/**
	 * @description Method is used to accept SObjects and is used to determine if the Status on the related PIP
	 * should be updated to Complete and the Sub-Status set to Dead.
	 *
	 * @param newItems - List of new SObjects
	 * @param  oldItems - Map of old SObject by Id
	 * @return void
	 */
	public void updateDeadRelatedPIPs(List<SObject> newItems, Map<Id, SObject> oldItems) {
		List<TASKRAY__Project__c> pipsForUpdate = new List<TASKRAY__Project__c>();

		if(newItems[0] instanceof Contract__c) {
			pipsForUpdate = relatedPIPsFromDeadContracts((List<Contract__c>) newItems, (Map<Id, Contract__c>) oldItems);

		} else if(newItems[0] instanceof Opportunity) {
			pipsForUpdate = relatedPIPsFromDeadDeals((List<Opportunity>) newItems, (Map<Id, Opportunity>) oldItems);
		}

		if(pipsForUpdate != null && !pipsForUpdate.isEmpty()) {
			try{
				update pipsForUpdate;
			} catch(DmlException e) {
				system.debug('Error occurred: ' +e.getMessage());
			}
		}

	}

	/**
	 * @description Used to return updates for PIPs related to a Dead Contract
	 *
	 * @param newItems - List of new Contract records
	 * @param oldItems - Map of old Contract records by Id
	 * @return List<TASKRAY__Project__c>
	 */
	private List<TASKRAY__Project__c> relatedPIPsFromDeadContracts(List<Contract__c> newItems, Map<Id, Contract__c>
		oldItems) {

		List<Contract__c> recordsToBeProcessed = new List<Contract__c>();
		List<TASKRAY__Project__c> pipsForUpdate = new List<TASKRAY__Project__c>();

		if(oldItems != null) {
			for(Contract__c record : newItems) {

				if(record.Contract_Status__c != oldItems.get(record.Id).Contract_Status__c
					&& eligibleDeadPIPStatus.contains(record.Contract_Status__c.toLowerCase())) {

					recordsToBeProcessed.add(record);
				}
			}
		} else {
			recordsToBeProcessed.addAll((List<Contract__c>) newItems);
		}

		if(recordsToBeProcessed != null && !recordsToBeProcessed.isEmpty()) {

			for(TASKRAY__Project__c relatedPIPs : [
				SELECT Id
				FROM TASKRAY__Project__c
				WHERE RecordType.DeveloperName = :TASKRAY_PROJECT_RECORDTYPE_PIP
					AND Contract__c IN:recordsToBeProcessed
					AND TASKRAY__trStatus__c != 'Completed' AND Sub_Status__c != 'Dead']) {

				pipsForUpdate.add(
					new TASKRAY__Project__c(
						Id = relatedPIPs.Id,
						TASKRAY__trStatus__c = PIP_STATUS_COMPLETED,
						Sub_Status__c = PIP_SUB_STATUS_DEAD
					)
				);
			}
		}

		return pipsForUpdate;
	}

	/**
	 * @description Used to return updates for PIPs related to a Dead Deals
	 *
	 * @param newItems - List of new Opportunity records
	 * @param oldItems - Map of old Opportunity records by Id
	 * @return List<TASKRAY__Project__c>
	 */
	private List<TASKRAY__Project__c> relatedPIPsFromDeadDeals(List<Opportunity> newItems, Map<Id, Opportunity>
		oldItems) {

		List<Opportunity> recordsToBeProcessed = new List<Opportunity>();
		List<TASKRAY__Project__c> pipsForUpdate = new List<TASKRAY__Project__c>();

		if(oldItems != null) {
			for(Opportunity record : newItems) {

				if(record.StageName != oldItems.get(record.Id).StageName
					&& record.StageName == STAGE_NAME_DEAD_DEAL) {

					recordsToBeProcessed.add(record);
				}
			}
		} else {
			recordsToBeProcessed.addAll((List<Opportunity>) newItems);
		}

		if(recordsToBeProcessed != null && !recordsToBeProcessed.isEmpty()) {
			for(TASKRAY__Project__c relatedPIPs : [
				SELECT Id
				FROM TASKRAY__Project__c
				WHERE RecordType.DeveloperName = :TASKRAY_PROJECT_RECORDTYPE_PIP
					AND TASKRAY__trOpportunity__c IN: recordsToBeProcessed
					AND TASKRAY__trStatus__c != 'Completed' AND Sub_Status__c != 'Dead']) {

				pipsForUpdate.add(
					new TASKRAY__Project__c(
						Id = relatedPIPs.Id,
						TASKRAY__trStatus__c = PIP_STATUS_COMPLETED,
						Sub_Status__c = PIP_SUB_STATUS_DEAD
					)
				);
			}
		}

		return pipsForUpdate;
	}

}