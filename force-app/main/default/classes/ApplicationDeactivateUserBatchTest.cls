@isTest
private class ApplicationDeactivateUserBatchTest {
	
	@testSetup
    static void setupTestData() {
		User newUser = TestUtil.createUser('System Administrator', 'lastName' );
		newUser.isActive = true;
		insert NewUser;	
	}
	
	@isTest 
	static void executeBatch_shouldDeactivateUser() {
		
		Id batchId = null;
		User newUser = [SELECT Id,isActive FROM USER LIMIT 1];
		System.assertEquals(true, newUser.isActive, 'The user should be active');

		System.runAs(newUser){
			Test.startTest();
				ApplicationDeactivateUserBatch batchProcessor = new ApplicationDeactivateUserBatch();
				batchId = Database.executeBatch(batchProcessor);
			Test.stopTest();
		}
		List<User> userList = [Select Id, isActive from User];

		System.assertNotEquals(null, batchId, 'A batch job should have been created');
		System.assertNotEquals(false, userList[0].isActive, 'The user should be deactivated');


	}
	
}