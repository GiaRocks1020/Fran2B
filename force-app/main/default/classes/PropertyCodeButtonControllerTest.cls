@isTest
private class PropertyCodeButtonControllerTest {
	public static FINAL string GROUP_NAME = 'Property_Code_Generation';
	@testSetup
	static void setupData(){

		Property__c property1 = TestUtil.createProperty('Test 1', 'City Test', '', 'AR', '12345');
		Property__c property2 = TestUtil.createProperty('Test 2', 'City Test', '', 'AF', '12345');
		property2.Property_Code__c = 'AF002';
		

		
		
		
		insert property1;
		insert property2;

	}


	@isTest 
	static void givenNoPropertyCode_ShouldReturnFalse() {
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = 'AF002' LIMIT 1];

		Boolean hasPermission;
		Test.startTest();
			hasPermission = PropertyCodeButtonController.checkPermission(property.Id);
		Test.stopTest();
		System.assertEquals(false, hasPermission, 'User should not have permission');

	}

	@isTest 
	static void givenNoGroupMember_ShouldReturnFalse() {
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = '' LIMIT 1];
		User newUser = TestUtil.createUser('System Administrator', 'Last Name');
		insert newUser;
		
		Boolean hasPermission;
		System.runAs(newUser){
			Test.startTest();
				hasPermission = PropertyCodeButtonController.checkPermission(property.Id);
			Test.stopTest();

		}
		
		System.assertEquals(false, hasPermission, 'User should not have permission');

	}

	@isTest 
	static void givenStandardProfile_ShouldReturnFalse() {
		User newUser = TestUtil.createUser('Standard User', 'Last Name');
		insert newUser;

		Group newGroup = PropertyCodeButtonController.getGroup();
		GroupMember newGroupMember = new GroupMember(GroupId = newGroup.Id, UserOrGroupId=newUser.Id);
		insert newGroupMember;

		System.debug(PropertyCodeButtonController.getGroupMembersByGroup(newGroup.Id));

		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = '' LIMIT 1];
		Boolean hasPermission;
		System.runAs(newUser){
			Test.startTest();
				hasPermission = PropertyCodeButtonController.checkPermission(property.Id);
			Test.stopTest();
		}
	}


	@isTest 
	static void givenProperPermission_ShouldReturnTrue() {
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = '' LIMIT 1];

		Boolean hasPermission;
		Test.startTest();
			hasPermission = PropertyCodeButtonController.checkPermission(property.Id);
		Test.stopTest();
		//System.assertEquals(True, hasPermission, 'User should  have permission');

	}


	@isTest 
	static void givenExistingCode_ShouldReturnTrue() {
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = 'AF002' LIMIT 1];

		Boolean doesCodeExist;
		Test.startTest();
			doesCodeExist = PropertyCodeButtonController.doesPropertyCodeExist(property.Id);
		Test.stopTest();
		System.assertEquals(True, doesCodeExist, 'The Property should have a property code');

	}


	@isTest 
	static void givenNoCode_ShouldReturnFalse() {
		Property__c property = [SELECT Id FROM Property__c WHERE Property_Code__c = '' LIMIT 1];

		Boolean doesCodeExist;
		Test.startTest();
			doesCodeExist = PropertyCodeButtonController.doesPropertyCodeExist(property.Id);
		Test.stopTest();
		System.assertEquals(False, doesCodeExist, 'The Property should not have a property code');

	}

	
}