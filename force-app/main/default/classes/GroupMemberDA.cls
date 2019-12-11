public with sharing class GroupMemberDA {

	public static List<GroupMember> getGroupMembersByGroupId(List<Id> groupIds) {
		return [SELECT 	Id,
						GroupId,
						UserOrGroupId
				FROM GroupMember
				WHERE GroupId IN :groupIds];
	}

}