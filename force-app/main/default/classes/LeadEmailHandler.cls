public with sharing class LeadEmailHandler {

	private final String GROUP_PREFIX = Schema.SObjectType.Group.getKeyPrefix();
	private final String USER_PREFIX = Schema.SObjectType.User.getKeyPrefix();

	@TestVisible private Map<Lead, List<String>> leadsToOwnerEmails = new Map<Lead, List<String>>();
	private EmailTemplate template;

	public LeadEmailHandler(List<Lead> leads, String emailTemplateDeveloperName) {
		this.leadsToOwnerEmails = getLeadOwnerEmails(leads);
		this.template = EmailTemplateDA.getEmailTemplateByDeveloperName(emailTemplateDeveloperName);
	}

	public void sendEmailsToOwners() {
		Messaging.reserveSingleEmailCapacity(this.leadsToOwnerEmails.size());

		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
		for(Lead l : this.leadsToOwnerEmails.keySet()) {
			messages.add(createMessageFromLead(l, template.Id));
		}
		Messaging.sendEmail(messages, false);
	}

	@TestVisible
	private Messaging.SingleEmailMessage createMessageFromLead(Lead leadToEmail, Id emailTemplateId) {
		Messaging.SingleEmailMessage messageFromLead = new Messaging.SingleEmailMessage();
		messageFromLead.setTemplateId(emailTemplateId);
		messageFromLead.setTargetObjectId(leadToEmail.Id);
		messageFromLead.setToAddresses(this.leadsToOwnerEmails.get(leadToEmail));
		return messageFromLead;
	}

	private Map<Lead, List<String>> getLeadOwnerEmails(List<Lead> leads) {
		Map<Id, List<Lead>> userOwnerIdsToOwnedLeads = new Map<Id, List<Lead>>();
		Map<Id, List<Lead>> groupOwnerIdsToOwnedLeads = new Map<Id, List<Lead>>();
		
		for (Lead l: leads) {
			List<Lead> ownedLeads = new List<Lead>();
			if (String.valueOf(l.OwnerId).startsWith(USER_PREFIX)) {
				ownedLeads = userOwnerIdsToOwnedLeads.get(l.OwnerId);
				if (ownedLeads == null) {
					userOwnerIdsToOwnedLeads.put(l.OwnerId, new List<Lead>{l});
				} else {
					ownedLeads.add(l);
					userOwnerIdsToOwnedLeads.put(l.OwnerId, ownedLeads);
				}
			} else if (String.valueOf(l.OwnerId).startsWith(GROUP_PREFIX)) {
				if (ownedLeads == null) {
					groupOwnerIdsToOwnedLeads.put(l.OwnerId, new List<Lead>{l});
				} else {
					ownedLeads.add(l);
					groupOwnerIdsToOwnedLeads.put(l.OwnerId, ownedLeads);
				}
			}
		}
		
		Map<Lead, List<String>> leadEmails = new Map<Lead, List<String>>();

		Map<Id, List<Id>> groupIdToUsersInGroupIds = new Map<Id, List<Id>>();
		if (!groupOwnerIdsToOwnedLeads.isEmpty()) {
			GroupTraverser traverser = new GroupTraverser();
			groupIdToUsersInGroupIds = traverser.getUsersInSubGroups(new List<Id>(groupOwnerIdsToOwnedLeads.keySet()));
		}

		Map<Id, List<User>> groupIdToRespectiveUsers = fillGroupUserInformationFromUserIds(groupIdToUsersInGroupIds);

		List<User> userOwners = UserDA.getUsersById(new List<Id>(userOwnerIdsToOwnedLeads.keySet()));
		for (User u : userOwners) {
			List<Lead> userOwnedLeads = userOwnerIdsToOwnedLeads.get(u.Id);
			List<String> userEmail = new List<String>{u.Email};
			for (Lead userOwnedLead: userOwnedLeads) {
				leadEmails.put(userOwnedLead, userEmail);
			}
		}

		for(Id groupId: groupIdToRespectiveUsers.keySet()) {
			List<Lead> groupOwnedLeads = groupOwnerIdsToOwnedLeads.get(groupId);
			List<User> usersInGroup = groupIdToRespectiveUsers.get(groupId);
			List<String> userEmails = new List<String>();
			for (User userInGroup: usersInGroup) {
				userEmails.add(userInGroup.Email);
			}
			for (Lead groupOwnedLead: groupOwnedLeads) {
				leadEmails.put(groupOwnedLead, userEmails);
			}
		}

		return leadEmails;
	}

	private Map<Id, List<User>> fillGroupUserInformationFromUserIds(Map<Id, List<Id>> groupIdToRespectiveUserIds) {
		List<Id> userInGroupIds = new List<Id>();
		for (List<Id> usersInSpecificGroupIds: groupIdToRespectiveUserIds.values()) {
			userInGroupIds.addAll(usersInSpecificGroupIds);
		}
		List<User> usersBeloningToGroup = UserDA.getUsersById(userInGroupIds);

		Map<Id, List<User>> groupIdToRespectiveUsers = new Map<Id, List<User>>();
		for (User userInGroup: usersBeloningToGroup) {
			for(Id groupId: groupIdToRespectiveUserIds.keySet()) {
				if (groupIdToRespectiveUserIds.get(groupId).contains(userInGroup.Id)) {

					List<User> currentRespectiveUsers = groupIdToRespectiveUsers.get(groupId);
					if (currentRespectiveUsers == null) {
						groupIdToRespectiveUsers.put(groupId, new List<User>{userInGroup});
					} else {
                        currentRespectiveUsers.add(userInGroup);
						groupIdToRespectiveUsers.put(groupId, currentRespectiveUsers);
					}

				}
			}
		}
		return groupIdToRespectiveUsers;
	}

}