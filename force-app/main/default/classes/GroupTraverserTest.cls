@isTest
public with sharing class GroupTraverserTest {

	@isTest
	private static void getUserInSubGroups_GivenOneTopLevelGroupWithNoSubGroups_ShouldReturnAllUsersOfGroup() {
		Group topLevelGroup = new Group(Name = 'Top Level Group', Type = 'Queue');
		insert topLevelGroup;
		
		User topGroupUser = TestUtil.createUser('System Administrator', 'Jones', 'hjones1', 'hjones@example.com', 'hjones@example.com.test', 'hjones1');
		insert topGroupUser;

		GroupMember userMember = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = topGroupUser.Id);
		insert userMember;

		Test.startTest();
			GroupTraverser traverser = new GroupTraverser();
			Map<Id, List<Id>> groupIdToGroupUserIds = traverser.getUsersInSubGroups(new List<Id>{topLevelGroup.Id});
		Test.stopTest();

		List<User> groupUsers = UserDA.getUsersById(groupIdToGroupUserIds.values()[0]);

		System.assertEquals(1, groupUsers.size());
		System.assertEquals('hjones@example.com', groupUsers[0].Email);
	}

	@isTest
	private static void getUserInSubGroups_GivenOneTopLevelGroupWithOneSubGroup_ShouldReturnAllUsersOfSubGroup() {
		Group topLevelGroup = new Group(Name = 'Top Level Group', Type = 'Queue');
		Group subGroup = new Group(Name = 'Sub Group',Type = 'Regular');
		insert new List<Group>{topLevelGroup, subGroup};

		User subGroupUser = TestUtil.createUser('System Administrator', 'Jones', 'hjones1', 'hjones@example.com', 'hjones@example.com.test', 'hjones1');
		insert subGroupUser;

		GroupMember userMember = new GroupMember(GroupId = subGroup.Id, UserOrGroupId = subGroupUser.Id);
		GroupMember groupMember = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = subGroup.Id);
		insert new List<GroupMember>{userMember, groupMember};

		Test.startTest();
			GroupTraverser traverser = new GroupTraverser();
			Map<Id, List<Id>> groupIdToGroupUserIds = traverser.getUsersInSubGroups(new List<Id>{topLevelGroup.Id});
		Test.stopTest();

		List<User> groupUsers = UserDA.getUsersById(groupIdToGroupUserIds.values()[0]);

		System.assertEquals(1, groupUsers.size());
		System.assertEquals('hjones@example.com', groupUsers[0].Email);
	}

	@isTest private static void getUserInSubGroups_GivenOneTopLevelGroupWithThreeUsersAndOneSubGroup_ShouldReturnAllUsersOfGroupAndSubGroup() {
		Group topLevelGroup = new Group(Name = 'Top Level Group', Type = 'Queue');
		Group subGroup = new Group(Name = 'Sub Group',Type = 'Regular');
		insert new List<Group>{topLevelGroup, subGroup};

		User topLevelGroupUser0 = TestUtil.createUser('System Administrator', 'TopLevelGroupUser0', 'tlgroup0', 'toplevelgroupuser0@example.com', 'toplevelgroupuser0@example.com.test', 'tlgroup0');
		User topLevelGroupUser1 = TestUtil.createUser('System Administrator', 'TopLevelGroupUser1', 'tlgroup1', 'toplevelgroupuser1@example.com', 'toplevelgroupuser1@example.com.test', 'tlgroup1');
		User topLevelGroupUser2 = TestUtil.createUser('System Administrator', 'TopLevelGroupUser2', 'tlgroup2', 'toplevelgroupuser2@example.com', 'toplevelgroupuser2@example.com.test', 'tlgroup2');
		User subGroupUser = TestUtil.createUser('System Administrator', 'SubGroup', 'sgroup0', 'subgroupuser0@example.com', 'subgroupuser0@example.com.test', 'sgroup0');
		insert new List<User>{topLevelGroupUser0, topLevelGroupUser1, topLevelGroupUser2, subGroupUser};

		GroupMember topLevelMember0 = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = topLevelGroupUser0.Id);
		GroupMember topLevelMember1 = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = topLevelGroupUser1.Id);
		GroupMember topLevelMember2 = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = topLevelGroupUser2.Id);
		GroupMember subGroupMember = new GroupMember(GroupId = subGroup.Id, UserOrGroupId = subGroupUser.Id);
		GroupMember groupMember = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = subGroup.Id);
		insert new List<GroupMember>{subGroupMember, groupMember, topLevelMember0, topLevelMember1, topLevelMember2};

		Test.startTest();
			GroupTraverser traverser = new GroupTraverser();
			Map<Id, List<Id>> groupIdToGroupUserIds = traverser.getUsersInSubGroups(new List<Id>{topLevelGroup.Id});
		Test.stopTest();

		List<User> groupUsers = UserDA.getUsersById(groupIdToGroupUserIds.values()[0]);
		List<String> userEmails = new List<String>();
		for (User userInGroup : groupUsers) {
			userEmails.add(userInGroup.Email);
		}

		System.assertEquals(4, groupUsers.size());
		System.assert(userEmails.contains('subgroupuser0@example.com'));
		System.assert(userEmails.contains('toplevelgroupuser0@example.com'));
		System.assert(userEmails.contains('toplevelgroupuser1@example.com'));
		System.assert(userEmails.contains('toplevelgroupuser2@example.com'));
	}

	@isTest private static void getUserInSubGroups_GivenOneTopLevelGroupWithThreeUsersAnd2SubGroupConsistingOf4MembersTotal_ShouldReturnAllUsersOfGroupAndSubGroup() {
		Group topLevelGroup = new Group(Name = 'Top Level Group', Type = 'Queue');
		Group subGroup1 = new Group(Name = 'Sub Group1',Type = 'Regular');
		Group subGroup2 = new Group(Name = 'Sub Group1',Type = 'Regular');
		insert new List<Group>{topLevelGroup, subGroup1, subGroup2};
		

		User topLevelGroupUser0 = TestUtil.createUser('System Administrator', 'TopLevelGroupUser0', 'tlgroup0', 'toplevelgroupuser0@example.com', 'toplevelgroupuser0@example.com.test', 'tlgroup0');
		User topLevelGroupUser1 = TestUtil.createUser('System Administrator', 'TopLevelGroupUser1', 'tlgroup1', 'toplevelgroupuser1@example.com', 'toplevelgroupuser1@example.com.test', 'tlgroup1');
		User topLevelGroupUser2 = TestUtil.createUser('System Administrator', 'TopLevelGroupUser2', 'tlgroup2', 'toplevelgroupuser2@example.com', 'toplevelgroupuser2@example.com.test', 'tlgroup2');

		User subGroup1User0 = TestUtil.createUser('System Administrator', 'SubGroup1User0', 'sg1u0', 'sgroup1user0@example.com', 'sgroup1user0@example.com.test', 'sg1u0');

		User subGroup2User0 = TestUtil.createUser('System Administrator', 'SubGroup2User0', 'sg2u0', 'sgroup2user0@example.com', 'sgroup2user0@example.com.test', 'sg2u0');
		User subGroup2User1 = TestUtil.createUser('System Administrator', 'SubGroup2User1', 'sg2u1', 'sgroup2user1@example.com', 'sgroup2user1@example.com.test', 'sg2u1');
		User subGroup2User2 = TestUtil.createUser('System Administrator', 'SubGroup2User2', 'sg2u2', 'sgroup2user2@example.com', 'sgroup2user2@example.com.test', 'sg2u2');
		insert new List<User>{topLevelGroupUser0, topLevelGroupUser1, topLevelGroupUser2, subGroup1User0, subGroup2User0, subGroup2User1, subGroup2User2};


		GroupMember topLevelMember0 = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = topLevelGroupUser0.Id);
		GroupMember topLevelMember1 = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = topLevelGroupUser1.Id);
		GroupMember topLevelMember2 = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = topLevelGroupUser2.Id);

		GroupMember subGroup1Member0 = new GroupMember(GroupId = subGroup1.Id, UserOrGroupId = subGroup1User0.Id);

		GroupMember subGroup2Member0 = new GroupMember(GroupId = subGroup2.Id, UserOrGroupId = subGroup2User0.Id);
		GroupMember subGroup2Member1 = new GroupMember(GroupId = subGroup2.Id, UserOrGroupId = subGroup2User1.Id);
		GroupMember subGroup2Member2 = new GroupMember(GroupId = subGroup2.Id, UserOrGroupId = subGroup2User2.Id);

		GroupMember groupTopLevelMember0 = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = subGroup1.Id);
		GroupMember groupTopLevelMember1 = new GroupMember(GroupId = topLevelGroup.Id, UserOrGroupId = subGroup2.Id);
		insert new List<GroupMember>{groupTopLevelMember0, groupTopLevelMember1,topLevelMember0, topLevelMember1, topLevelMember2, subGroup1Member0, subGroup2Member0, subGroup2Member1, subGroup2Member2};

		Test.startTest();
			GroupTraverser traverser = new GroupTraverser();
			Map<Id, List<Id>> groupIdToGroupUserIds = traverser.getUsersInSubGroups(new List<Id>{topLevelGroup.Id});
		Test.stopTest();

		List<User> groupUsers = UserDA.getUsersById(groupIdToGroupUserIds.values()[0]);
		List<String> userEmails = new List<String>();
		for (User userInGroup : groupUsers) {
			userEmails.add(userInGroup.Email);
		}

		System.assertEquals(7, groupUsers.size());
		System.assert(userEmails.contains('toplevelgroupuser0@example.com'));
		System.assert(userEmails.contains('toplevelgroupuser1@example.com'));
		System.assert(userEmails.contains('toplevelgroupuser2@example.com'));
		System.assert(userEmails.contains('sgroup1user0@example.com'));
		System.assert(userEmails.contains('sgroup2user0@example.com'));
		System.assert(userEmails.contains('sgroup2user1@example.com'));
		System.assert(userEmails.contains('sgroup2user2@example.com'));
	}

}