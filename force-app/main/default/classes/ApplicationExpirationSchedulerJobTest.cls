@isTest
private class ApplicationExpirationSchedulerJobTest {
	
	@testSetup
    static void setupTestData() {
	}
	
	@isTest 
	static void scheduleIt_shouldScheduleJob() {
		
		String jobId = '';
		String jobName = 'Test job for Application Expiration Scheduler Job';
		Datetime executeTime = (System.now()).addSeconds(1);
		String cronExpression ='0 0 12 1/1 * ? *';


		Test.startTest();
			ApplicationExpirationSchedulerJob scheduledJob = new ApplicationExpirationSchedulerJob(); 
			jobId = System.schedule('ScheduledJob ' + executeTime.getTime(),cronExpression,scheduledJob);
		Test.stopTest();
		
		List<CronTrigger> ct = [SELECT Id , CronExpression FROM CronTrigger WHERE Id = :jobId];

		System.assertEquals(1, ct.size(), 'There should be a schedlued job created');

	}
	
}