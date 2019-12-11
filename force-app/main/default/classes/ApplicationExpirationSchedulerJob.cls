global class ApplicationExpirationSchedulerJob implements Schedulable {
	
	global void execute(SchedulableContext sc) {
		ApplicationExpirationBatch b = new ApplicationExpirationBatch();
		Database.executeBatch(b);
	}
}