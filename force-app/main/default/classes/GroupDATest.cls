@isTest
public with sharing class GroupDATest {

	@isTest
	private static void getGroupsById_GivenGroupIds_ShouldReturnGroupRecords() {
		Group group0 = new Group(Name = 'Group 0', Type = 'Regular');
		Group group1 = new Group(Name = 'Group 1', Type = 'Regular');
		insert new List<Group>{group0, group1};

		List<Group> groups = new List<Group>();
		Test.startTest();
			groups = GroupDA.getGroupsById(new List<Id>{group0.Id, group1.Id});
		Test.stopTest();

		List<String> groupNames = new List<String>();
		for (Group g: groups) {
			groupNames.add(g.Name);
		}

		System.assertEquals(2, groups.size());
		System.assert(groupNames.contains('Group 0'));
		System.assert(groupNames.contains('Group 1'));
	}

}