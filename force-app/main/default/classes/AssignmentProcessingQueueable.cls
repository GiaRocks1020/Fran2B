/**
 * @description Queueable class used for processing Resource Assignments
 *
 * @author Zach French
 * @date 2019-08-24
 */
public class AssignmentProcessingQueueable implements Queueable {

	private Map<Id, SObject> sObjectById;
	private List<SObject> recordsForUpdate;
	private AssignmentProcessing assignmentProcessing;

	// Constructor
	public AssignmentProcessingQueueable(Map<Id, SObject> sObjectById) {
		this.sObjectById = sObjectById;
		assignmentProcessing = new AssignmentProcessing();
	}

	/**
	 * @description Method required indicated by Queueable interface. A limit of 100 callouts was added in the logic
	 * to prevent exceptions from occurring.
	 *
	 * @param context Case records passed as argument
	 * @return void
	 */
	public void execute(QueueableContext context) {
		recordsForUpdate = new List<SObject>();

		Integer count = 0;

		Set<Id> recordIdsForRemoval = new Set<Id>();


		assignmentProcessing.initializeData(sObjectById.values());

		for(SObject record : sObjectById.values()) {

			Map<String, AssignmentProcessing.AssignmentRulesMatching> matchedResources = assignmentProcessing
				.getProcessedResources(record);

			SObject processedSObject = assignmentProcessing.assignResources(record, matchedResources);
			recordsForUpdate.add(processedSObject);

			// Add Pickup Request to be removed from map
			recordIdsForRemoval.add(record.Id);

			count++;

			if(count == 50) {
				break;
			}
		}

		// Update Pickup Request records, if needed
		if(!recordsForUpdate.isEmpty() && recordsForUpdate.size() > 0) {
			//updateServiceRequests(recordsForUpdateById.values());
			updateRecords(recordsForUpdate);
		}

		// Remove SObjects from class initialization map
		for(Id recordId : recordIdsForRemoval) {
			sObjectById.remove(recordId);
		}

		// Requeue map for additional processing, if necessary
		if(!sObjectById.isEmpty() && sObjectById.size() > 0) {
			requeueAsync(sObjectById);
		}
	}

	/**
	 * @description Used for chaining queueable jobs.
	 *
	 * @param cases list of case records
	 * @return void
	 */
	private void requeueAsync(Map<Id, SObject> sObjectById) {
		if(!(Test.isRunningTest() && System.isQueueable())) {
			try{
				System.enqueueJob(new AssignmentProcessingQueueable(sObjectById));
			} catch(Exception e) {
				System.debug('Exception caught: ' + e.getMessage());
			}

		}
	}

	/**
	 * @description Update SObject recortds
	 *
	 * @param records - List of SObjects
	 * @return void
	 */
	private void updateRecords(List<SObject> records) {

		Database.SaveResult[] results = Database.update(records, false);

		// Iterate over SaveResult
		for(Database.SaveResult sr : results) {
			if(!sr.isSuccess()) {
				// Operation failed, so get all errors
				for(Database.Error err : sr.getErrors()) {
					System.debug('The following error has occurred.');
					System.debug(err.getStatusCode() + ': ' + err.getMessage());
					System.debug('Account fields that affected this error: ' + err.getFields());
				}
			}
		}
	}
}