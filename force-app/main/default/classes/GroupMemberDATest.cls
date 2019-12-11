@isTest
public with sharing class GroupMemberDATest {

	@isTest
	private static void getGroupMembersByGroupId_GivenGroupIds_ShouldsReturnMembersInGroup() {
		User user0 = TestUtil.createUser('System Administrator', 'User0', 'user0', 'user0@example.com', 'user0@example.com.test', 'user0');
        User user1 = TestUtil.createUser('System Administrator', 'User1', 'user1', 'user1@example.com', 'user1@example.com.test', 'user1');
        insert new List<User>{user0, user1};

		Group group0 = new Group(Name = 'Group 0', Type = 'Regular');
		insert group0;

		GroupMember member0 = new GroupMember(GroupId = group0.Id, UserOrGroupId = user0.Id);
		GroupMember member1 = new GroupMember(GroupId = group0.Id, UserOrGroupId = user1.Id);
		insert new List<GroupMember>{member0, member1};

		List<GroupMember> groupMembers = new List<GroupMember>();
		Test.startTest();
			groupMembers = GroupMemberDA.getGroupMembersByGroupId(new List<Id>{group0.Id});
		Test.stopTest();

		List<Id> groupMemberIds = new List<Id>();
		for (GroupMember member : groupMembers) {
			groupMemberIds.add(member.Id);
		}

		System.assertEquals(2, groupMembers.size());
		System.assert(groupMemberIds.contains(member0.Id));
		///System.assert(!groupMemberIds.contains(member1.Id));
	}

}