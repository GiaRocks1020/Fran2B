public with sharing class GroupTraverser {

	// WARNING: THE NUMBER OF SOQL QUERIES IN THIS CLASS SCALES BY
	// 			N*H. WHERE N IS THE NUMEBR OF TOP LEVEL GROUPS AND
	//			H IS THE NUMBER OF SUBGROUPS EACH TOP LEVEL GROUP HAS

	private List<Id> groupIdsTraversed = new List<Id>();

	private final String GROUP_PREFIX = Schema.SObjectType.Group.getKeyPrefix();
	private final String USER_PREFIX = Schema.SObjectType.User.getKeyPrefix();

	public Map<Id, List<Id>> getUsersInSubGroups(List<Id> groupIds) {
		Map<Id, List<Id>> groupIdToGroupUsers = new Map<Id, List<Id>>();
		for(Id groupId : groupIds) {
			groupIdToGroupUsers.put(groupId, getAllUsersOfGroup(new List<Id>{groupId}));
			this.groupIdsTraversed.clear();
		}
		return groupIdToGroupUsers;
	}

	private List<Id> getAllUsersOfGroup(List<Id> groupIds) {
		List<GroupMember> groupMembers = GroupMemberDA.getGroupMembersByGroupId(groupIds);
		this.groupIdsTraversed.addAll(groupIds);
		List<Id> userMemberIds = new List<Id>();
		List<Id> groupMemberIds = new List<Id>();
		for (GroupMember member : groupMembers) {
			if (String.valueOf(member.UserOrGroupId).startsWith(GROUP_PREFIX)) {
				groupMemberIds.add(member.UserOrGroupId);
			} else if (String.valueOf(member.UserOrGroupId).startsWith(USER_PREFIX)) {
				userMemberIds.add(member.UserOrGroupId);
			}
		}

		groupMemberIds = removeCircularGroupDependencies(groupMemberIds);

		if (!groupMemberIds.isEmpty()) {
			userMemberIds.addAll(getAllUsersOfGroup(groupMemberIds));
		}
		return userMemberIds;
	}

	private List<Id> removeCircularGroupDependencies(List<Id> groupIds) {
		for (Integer i = 0; i < groupIds.size(); i++) {
			if (this.groupIdsTraversed.contains(groupIds[i])) {
				groupIds.remove(i);
			}
		}
		return groupIds;
	}

}