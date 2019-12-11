/**
 * @description Unit tests for OpportunityHelper class
 *
 * @author Zach French
 * @date 9/4/19
 */
@IsTest
private class PIPHelperTest {

	/**
	 * @description Used to validate the Status and Sub Status on a PIP was updated to Dead when a deal is marked as
	 * as dead.
	 *
	 * @return void
	 */
	@IsTest
	static void testPIPStatusUpdateOnDeadDeal() {
		User pipAdmin = TestDataFactory.createAdminUser();
		User pipManager = TestDataFactory.createPIPManagerUser();

		pipAdmin.ManagerId = pipManager.Id;

		update pipAdmin;

		System.runAs(pipAdmin) {

			Opportunity deal = TestDataFactory.createDeal(true);

			TASKRAY__Project__c pip = TestDataFactory.createPIP(false);

			pip.TASKRAY__trOpportunity__c = deal.Id;
			pip.TASKRAY__trStatus__c = 'Requested';
			pip.Sub_Status__c = 'Pending Approval';
			insert pip;

			deal.StageName = PIPHelper.STAGE_NAME_DEAD_DEAL;
			deal.Dead_Deal_Reason__c = 'Lost interest';
			update deal;
		}

		List<TASKRAY__Project__c> deals = [SELECT Id, TASKRAY__trStatus__c, Sub_Status__c FROM TASKRAY__Project__c
			LIMIT 1];
		System.assertEquals(PIPHelper.PIP_STATUS_COMPLETED, deals[0].TASKRAY__trStatus__c);
		System.assertEquals(PIPHelper.PIP_SUB_STATUS_DEAD, deals[0].Sub_Status__c);
	}

	/**
	 * @description Used to validate the Status and Sub Status on a PIP was updated to Dead when a Contract is marked as
	 * as dead.
	 *
	 * @return void
	 */
	@IsTest
	static void testPIPStatusUpdateOnDeadContract() {
		User pipAdmin = TestDataFactory.createAdminUser();
		User pipManager = TestDataFactory.createPIPManagerUser();

		pipAdmin.ManagerId = pipManager.Id;

		update pipAdmin;

		System.runAs(pipAdmin) {

			Contract__c contract = TestDataFactory.createContract(true);

			TASKRAY__Project__c pip = TestDataFactory.createPIP(false);

			pip.Contract__c = contract.Id;
			pip.TASKRAY__trStatus__c = 'Requested';
			pip.Sub_Status__c = 'Pending Approval';
			insert pip;

			contract.Contract_Status__c = PIPHelper.CONTRACT_STATUS_DEAD_DEAL;
			update contract;
		}

		List<TASKRAY__Project__c> deals = [SELECT Id, TASKRAY__trStatus__c, Sub_Status__c FROM TASKRAY__Project__c
		LIMIT 1];
		System.assertEquals(PIPHelper.PIP_STATUS_COMPLETED, deals[0].TASKRAY__trStatus__c);
		System.assertEquals(PIPHelper.PIP_SUB_STATUS_DEAD, deals[0].Sub_Status__c);
	}

	/**
	 * @description Used to validate the Status and Sub Status on a PIP was updated to Dead when a Contract is marked as
	 * as dead.
	 *
	 * @return void
	 */
	@IsTest
	static void testPIPStatusUpdateOnTerminatedContract() {
		User pipAdmin = TestDataFactory.createAdminUser();
		User pipManager = TestDataFactory.createPIPManagerUser();

		pipAdmin.ManagerId = pipManager.Id;

		update pipAdmin;

		System.runAs(pipAdmin) {

			Contract__c contract = TestDataFactory.createContract(true);

			TASKRAY__Project__c pip = TestDataFactory.createPIP(false);

			pip.Contract__c = contract.Id;
			pip.TASKRAY__trStatus__c = 'Requested';
			pip.Sub_Status__c = 'Pending Approval';
			insert pip;

			contract.Contract_Status__c = PIPHelper.CONTRACT_STATUS_TERMINATED;
			update contract;
		}

		List<TASKRAY__Project__c> deals = [SELECT Id, TASKRAY__trStatus__c, Sub_Status__c FROM TASKRAY__Project__c
		LIMIT 1];
		System.assertEquals(PIPHelper.PIP_STATUS_COMPLETED, deals[0].TASKRAY__trStatus__c);
		System.assertEquals(PIPHelper.PIP_SUB_STATUS_DEAD, deals[0].Sub_Status__c);
	}
}