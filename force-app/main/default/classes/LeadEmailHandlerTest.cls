@isTest
public with sharing class LeadEmailHandlerTest {

    @TestSetup
    static void setupTestData(){
        User testUser = TestUtil.createUser('System Administrator', 'Owner0');
        insert new List<User>{testUser};

        User groupUser = TestUtil.createUser('System Administrator', 'Tester', 'ttest', 'groupuser@example.com', 'ttteeesssttt@example.com', 'testnickname');
        insert groupUser;

        Group testGroup = new Group(
            Name = 'Test Group',
            Email = 'groupmember@example.com',
            Type = 'Queue'
        );
        insert testGroup;

        GroupMember member = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = groupUser.Id
        );
        insert member;
    }

    @isTest
    private static void leadEmailHandler_GivenUserOwner_ShouldDetermineOwnerEmail() {
        List<User> potentailOwners = [SELECT Id FROM User WHERE Name = 'Owner0'];
        Lead testLead = new Lead(
            LastName = 'LastName',
            OwnerId = potentailOwners[0].Id,
            Id = '00Q000000000001'
        );

        Test.startTest();
            LeadEmailHandler leadMessenger = new LeadEmailHandler(new List<Lead>{testLead}, 'DFS_New_Lead_Alert');
        Test.stopTest();

        System.assertEquals(1, leadMessenger.leadsToOwnerEmails.size());
        System.assertEquals('test@test.com', leadMessenger.leadsToOwnerEmails.values()[0][0]);
    }

    @isTest 
    private static void leadEmailHandler_GivenGroupOwner_ShouldDetermineOwnerEmail() {
        List<Group> potentailOwners = [SELECT Id FROM Group WHERE Name = 'Test Group'];
        Lead testLead = new Lead(
            LastName = 'LastName',
            OwnerId = potentailOwners[0].Id,
            Id = '00Q000000000001'
        );

        Test.startTest();
            LeadEmailHandler leadMessenger = new LeadEmailHandler(new List<Lead>{testLead}, 'DFS_New_Lead_Alert');
        Test.stopTest();

        System.assertEquals(1, leadMessenger.leadsToOwnerEmails.size());
        System.assertEquals('groupuser@example.com', leadMessenger.leadsToOwnerEmails.values()[0][0]);
    }

    @isTest
    private static void leadEmailHandle_GivenMultipleLeads_ShouldDetermineEmails() {
        List<Group> groupOwners = [SELECT Id FROM Group WHERE Name = 'Test Group'];
        List<User> userOwners = [SELECT Id FROM User WHERE Name = 'Owner0'];
        Lead groupLead = new Lead(
            LastName = 'LastName',
            OwnerId = groupOwners[0].Id,
            Id = '00Q000000000001'
        );
        Lead userLead = new Lead(
            LastName = 'LastName',
            OwnerId = userOwners[0].Id,
            Id = '00Q000000000002'
        );

        Test.startTest();
            LeadEmailHandler leadMessenger = new LeadEmailHandler(new List<Lead>{groupLead, userLead}, 'DFS_New_Lead_Alert');
        Test.stopTest();

        System.assertEquals(2, leadMessenger.leadsToOwnerEmails.size());
        System.assert(leadMessenger.leadsToOwnerEmails.get(groupLead).contains('groupuser@example.com'));
        System.assert(leadMessenger.leadsToOwnerEmails.get(userLead).contains('test@test.com'));
    }

    @isTest
    private static void leadEmailHandle_GivenMultipleLeadsWithDuplicateOwners_ShouldDetermineEmails() {
        List<Group> groupOwners = [SELECT Id FROM Group WHERE Name = 'Test Group'];
        List<User> userOwners = [SELECT Id FROM User WHERE Name = 'Owner0'];
        Lead groupLead = new Lead(
            LastName = 'LastName',
            OwnerId = groupOwners[0].Id,
            Id = '00Q000000000001'
        );
        Lead userLead = new Lead(
            LastName = 'LastName',
            OwnerId = userOwners[0].Id,
            Id = '00Q000000000002'
        );
        Lead userLead2 = new Lead(
            LastName = 'LastName',
            OwnerId = userOwners[0].Id,
            Id = '00Q000000000003'
        );

        Test.startTest();
            LeadEmailHandler leadMessenger = new LeadEmailHandler(new List<Lead>{groupLead, userLead, userLead2}, 'DFS_New_Lead_Alert');
        Test.stopTest();

        System.assertEquals(3, leadMessenger.leadsToOwnerEmails.size());
        System.assert(leadMessenger.leadsToOwnerEmails.get(userLead).contains('test@test.com'));
        System.assert(leadMessenger.leadsToOwnerEmails.get(userLead2).contains('test@test.com'));
        System.assert(leadMessenger.leadsToOwnerEmails.get(groupLead).contains('groupuser@example.com'));
    }

    @isTest
    private static void createMessageFromLead_GivenLeadAndTemplateId_ShouldCreateAnEmailMessage() {
        List<User> userOwners = [SELECT Id FROM User WHERE Name = 'Owner0'];
        Lead userLead = new Lead(
            LastName = 'LastName',
            OwnerId = userOwners[0].Id,
            Id = '00Q000000000001'
        );
        LeadEmailHandler leadMessenger = new LeadEmailHandler(new List<Lead>{userLead}, 'DFS_New_Lead_Alert');

        Test.startTest();
            Messaging.SingleEmailMessage message = leadMessenger.createMessageFromLead(userLead, '00X000000000000001');
        Test.stopTest();

        System.assert(message.getToAddresses().contains('test@test.com'));
    }

}