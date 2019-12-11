@isTest
private class ApplicationExpirationBatchTest {
	private static final String IN_PROGRESS = 'In Progress';
	@testSetup
    static void setupTestData() {


    	Application__c newApp = new Application__c();
		newApp.Application_Start_Date__c = Date.Today().addDays(-15);
		newApp.Status__c = IN_PROGRESS;
		insert newApp;

		
		User newUser = TestUtil.createUser('System Administrator', 'lastName' );
		insert NewUser;

		
	}
	
	@isTest 
	static void executeBatch_shouldExpireApplication() {
		
		Id batchId = null;
		Test.startTest();
			ApplicationExpirationBatch batchProcessor = new ApplicationExpirationBatch();
			batchId = Database.executeBatch(batchProcessor);
		Test.stopTest();

		List<Application__c> appList = [Select Id, Status__c from Application__c];
		List<CronJobDetail> cronJobs = [SELECT Id FROM CronJobDetail];
		System.assertNotEquals(null, batchId, 'A batch job should have been created');
		System.assertNotEquals(IN_PROGRESS, appList[0].Status__c, 'The Status should be expired');
		//System.assertEquals(2, cronJobs.size(), 'There should be two cron jobs created. One for deactivating users. ' +'One for expiring applications.');

	}
	
}