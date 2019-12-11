public with sharing class PropertyCodeButtonController {
	public static FINAL string GROUP_NAME = 'Property_Code_Generation';

	@AuraEnabled
	public static Boolean checkPermission(Id propertyId){
		Id userID = UserInfo.getUserId();
		if(doesPropertyCodeExist(propertyId)){
			return false;
		}

		Group propertyGroup = getGroup();
		List<GroupMember> groupMembers = getGroupMembersByGroup(propertyGroup.Id);
		if(groupMembers.size() == 0 ){
			return false;
		}
		if(!Property_Code_Metadata__c.sObjectType.getDescribe().isAccessible()){
			return false;
		}

		return true;
	}

	public static Boolean doesPropertyCodeExist(Id propertyId){
		Property__c property = getPropertyById(propertyId);
		if(property.Property_Code__c != null && property.Property_Code__c !=''){
			return true;
		}
		return false;

	}

	public static List<GroupMember> getGroupMembersByGroup(Id groupId){
		return[
		SELECT Id 
		FROM GroupMember
		WHERE GroupId =:groupId 
		AND UserOrGroupId =:UserInfo.getUserId()];
	}

	public static Group getGroup(){
		return[
		SELECT Id, DeveloperName 
		FROM Group
		WHERE DeveloperName =:GROUP_NAME];
	}

	public static Property__c getPropertyById(Id propertyId){
		return[
		SELECT Property_Code__c 
		FROM Property__c
		WHERE Id=:propertyId];
	}
}