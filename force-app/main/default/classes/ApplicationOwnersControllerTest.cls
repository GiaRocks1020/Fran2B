@isTest
private class ApplicationOwnersControllerTest {
	
	@testSetup
	static void setupData(){


		Application__c application = new Application__c();
		insert application;

		Applicant__c newApplicant = new Applicant__c(
			Application__c = application.Id,
			Are_you_Owner_or_Designated_Rep__c = 'Owner');
		insert newApplicant;

		Applicant__c newApplicant2 = new Applicant__c(
			Application__c = application.Id,
			First_Name__c = 'Test',
			Last_Name__c = 'Test',
			Are_you_Owner_or_Designated_Rep__c = 'Owner' );
		insert newApplicant2;

		Private_Files__c privateFile = new Private_Files__c(Applicant__c =newApplicant.Id);
		insert privateFile;



	}
	
	@isTest 
	static void givenApplicant_ShouldDelete() {
		Applicant__c applicant = [SELECT Id FROM Applicant__c LIMIT 1];

		Test.startTest();
			ApplicationOwnersController.deleteOwner(applicant);
		Test.stopTest();

		List<Applicant__c> applicants = [SELECT Id FROM Applicant__c];
		System.assertEquals(1, applicants.size(), 'The applicant should be deleted');
	}


	@isTest 
	static void givenApplication_ShouldReturnRelatedApplicants() {
		Application__c application = [SELECT Id FROM Application__c LIMIT 1];

		List<Applicant__c> applicants = new List<Applicant__c>();
		Test.startTest();
			applicants = ApplicationOwnersController.getApplicantsRelatedToApp(application.Id);
		Test.stopTest();

		
		//System.assertEquals(0, applicants.size(), 'The applicant should be deleted');
	}

	@isTest 
	static void givenPrivateFile_ShouldDeleteFile() {
		List<Private_Files__c> privateFiles = [SELECT Id FROM Private_Files__c];

		Test.startTest();
			ApplicationOwnersController.deletePrivateFiles(privateFiles);
		Test.stopTest();

		List<Private_Files__c> remainingPrivateFiles = [SELECT Id FROM Private_Files__c];

		
		System.assertEquals(0, remainingPrivateFiles.size(), 'The record should be deleted');
	}
	
}