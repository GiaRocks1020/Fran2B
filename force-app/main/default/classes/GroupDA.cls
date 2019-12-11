public with sharing class GroupDA {

	public static List<Group> getGroupsById(List<Id> groupIds) {
		if (!groupIds.isEmpty()) {
			return [
				SELECT 	Id,
						Name,
						Email
				FROM Group
				WHERE Id IN :groupIds
			];
		} else {
			return new List<Group>();
		}
	}

}