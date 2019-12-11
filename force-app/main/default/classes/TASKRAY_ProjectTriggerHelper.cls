/**
 * @description Helper class to be used by TASKRAY_ProjectTriggerHandler
 *
 * @author Zach French
 * @date 2019-08-12
 */
public inherited sharing class TASKRAY_ProjectTriggerHelper {

	// Variables
	public static final String PIP_METHOD_DESKTOP = StaticValue.getStaticValueText('PIP_METHOD_DESKTOP');
	public static final String PIP_METHOD_TRAVEL = StaticValue.getStaticValueText('PIP_METHOD_TRAVEL');
	public static final String TRAVEL_STATUS_NO_TRAVEL_NEEDED = StaticValue.getStaticValueText
		('TRAVEL_STATUS_NO_TRAVEL_NEEDED');
	public static final String TRAVEL_STATUS_TRAVEL_PENDING = StaticValue.getStaticValueText
		('TRAVEL_STATUS_TRAVEL_PENDING');
	public static final String PIP_TYPE_APPLICATION = StaticValue.getStaticValueText('PIP_TYPE_APPLICATION');
	public static final String PIP_SUB_STATUS_SENT_TO_LEGAL = StaticValue.getStaticValueText
		('PIP_SUB_STATUS_SENT_TO_LEGAL');
	public static final String PIP_SUB_STATUS_DRAFT = StaticValue.getStaticValueText
		('PIP_SUB_STATUS_DRAFT');
	public static final String PIP_SUB_STATUS_REJECTED = StaticValue.getStaticValueText
			('PIP_SUB_STATUS_REJECTED');
	public static final String PIP_SUB_STATUS_REVISIONS = StaticValue.getStaticValueText
		('PIP_SUB_STATUS_REVISIONS');
	public static final String PIP_SUB_STATUS_VERIFIED = StaticValue.getStaticValueText
		('PIP_SUB_STATUS_VERIFIED');
	public static final String EMAIL_TEMPLATE_PIP_WRITTEN_ALERT = StaticValue.getStaticValueText
			('EMAIL_TEMPLATE_PIP_WRITTEN_ALERT');
	public static final String EMAIL_TEMPLATE_PIP_VERIFIED_ALERT = StaticValue.getStaticValueText
			('EMAIL_TEMPLATE_PIP_VERIFIED_ALERT');
	public static final String ORG_WIDE_EMAIL_FRANCHISE_SALES_SUPPORT = StaticValue.getStaticValueText
		('ORG_WIDE_EMAIL_FRANCHISE_SALES_SUPPORT');
	public Set<String> targetCompletionDateEligiblePIPType = new Set<String>{
		PIP_TYPE_APPLICATION
	};
	public Set<String> targetCompletionDateEligiblePIPMethod = new Set<String> {
		PIP_METHOD_DESKTOP,
		PIP_METHOD_TRAVEL
	};

	public Set<String> pipUpdateInvalidStatus = new Set<String>{
		'Active',
		'Complete'
	};



	private Map<Id, Property__c> propertiesByIds;
	private Map<Id, Resource__c> resourcesByIds;
	private Set<Id> resourceIds;
	private Map<Id, Brand__c> brandsByIds;
	private Map<Id, Product__c> productsByIds;

	/**
	 * @description Used to assign the Target Assignment Date based on SLA rules for PIP records.
	 *
	 * @param newItems - New values for TASKRAY__Project__c records
	 * @param oldMapById - Old values for TASKRAY__Project__c records
	 * @return void
	 */
	public void setPIPTargetAssignmentDate(List<TASKRAY__Project__c> newItems, Map<Id, TASKRAY__Project__c>
		oldMapById) {

		List<TASKRAY__Project__c> eligibleForTargetCompletionDate = new List<TASKRAY__Project__c>();
		for(TASKRAY__Project__c newItem : newItems) {
			if(assignmentDateNotNull(newItem)
					&& (oldMapById == null
					|| (oldMapById.containsKey(newItem.Id)
						&& (pipTypeChanged(oldMapById, newItem) || pipMethodChanged(oldMapById, newItem)
						|| assignmentDateChanged(oldMapById, newItem))))){
				eligibleForTargetCompletionDate.add(newItem);
			}
		}

		BusinessDaysUtility.setPIPTargetAssignmentDate(eligibleForTargetCompletionDate);
	}

	/**
	 * @description Used to return a Boolean value if the assignment date field is not null
	 *
	 * @param newItem - TASKRAY__Project__c record
	 * @return Boolean
	 */
	private Boolean assignmentDateNotNull(TASKRAY__Project__c newItem) {
		Boolean value = false;

		if(newItem.PIP_Assignment_Date__c != null){
			value = true;
		}

		return value;
	}

	/**
	 * @description Used to return a Boolean value to determine if the PIP Type changed
	 *
	 * @param oldMapById - Old values for TASKRAY__Project__c records
	 * @param newItem - New values for a TASKRAY__Project__c record
	 * @return Boolean
	 */
	private Boolean pipTypeChanged(Map<Id, TASKRAY__Project__c> oldMapById, TASKRAY__Project__c newItem) {
		Boolean changed = false;

		if(oldMapById.get(newItem.Id).PIP_Type__c != newItem.PIP_Type__c
			&& targetCompletionDateEligiblePIPType.contains(newItem.PIP_Type__c)) {
			changed = true;
		}
		return changed;
	}

	/**
	 * @description Used to return a Boolean value to determine if the PIP Method changed
	 *
	 * @param oldMapById - Old values for TASKRAY__Project__c records
	 * @param newItem - New values for a TASKRAY__Project__c record
	 * @return Boolean
	 */
	private Boolean pipMethodChanged(Map<Id, TASKRAY__Project__c> oldMapById, TASKRAY__Project__c newItem) {
		Boolean changed = false;

		if(oldMapById.get(newItem.Id).PIP_Method__c != newItem.PIP_Method__c
			&& targetCompletionDateEligiblePIPMethod.contains(newItem.PIP_Method__c)) {
			changed = true;
		}
		return changed;
	}

	/**
	 * @description Used to return a Boolean value to determine if the Assignment date changed
	 *
	 * @param oldMapById - Old values for TASKRAY__Project__c records
	 * @param newItem - New values for a TASKRAY__Project__c record
	 * @return Boolean
	 */
	private Boolean assignmentDateChanged(Map<Id, TASKRAY__Project__c> oldMapById, TASKRAY__Project__c newItem) {
		Boolean changed = false;

		if(oldMapById.get(newItem.Id).PIP_Assignment_Date__c != newItem.PIP_Assignment_Date__c) {
			changed = true;
		}
		return changed;
	}

	public void performResourceAssignment(List<TASKRAY__Project__c> newList) {
		Map<Id, SObject> newMapById = new Map<Id, SObject>();

		if(System.isQueueable()) { return; }

		for(TASKRAY__Project__c newRecord : newList) {
			if((newRecord.PIP_Writer__c == null && RecordTypeUtils.isPIPRecordType(newRecord.RecordTypeId)) ||
					(RecordTypeUtils.isOpeningRecordType(newRecord.RecordTypeId) && (newRecord.OPD__c == null ||
							newRecord.Architect__c == null || newRecord.Project_Manager__c == null))) {
				newMapById.put(newRecord.Id, newRecord);
			}
		}

		if(newMapById != null & !newMapById.isEmpty()) {
			try {
				Id jobId = System.enqueueJob(new AssignmentProcessingQueueable(newMapById));
			} catch(Exception e) {
				System.debug('Exception caught: ' + e.getMessage());
			}
		}

	}

	/**
	 * @description Used to initiate the process to automatically assign a PIP Method
	 *
	 * @param newRecords - New List of TASKRAY__Project__c
	 * @param oldRecords - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void performPIPMethodAssignment(List<TASKRAY__Project__c> newRecords, Map<Id, TASKRAY__Project__c> oldMap) {
		List<TASKRAY__Project__c> recordsToBeProcessed = new List<TASKRAY__Project__c>();

		if(oldMap != null) {
			for(TASKRAY__Project__c record : (List<TASKRAY__Project__c>) newRecords) {
				if(!pipUpdateInvalidStatus.contains(record.TASKRAY__trStatus__c)
					&& oldMap.get(record.Id) != null
					&& (record.App_Type__c != oldMap.get(record.Id).App_Type__c
						|| record.Brand__c !=  oldMap.get(record.Id).Brand__c) ) {

					recordsToBeProcessed.add(record);
				}
			}
		} else {
			for(TASKRAY__Project__c record : (List<TASKRAY__Project__c>) newRecords) {
				if(!pipUpdateInvalidStatus.contains(record.TASKRAY__trStatus__c)) {
					recordsToBeProcessed.add(record);
				}
			}
		}

		if(recordsToBeProcessed != null && !recordsToBeProcessed.isEmpty()) {
			AssignmentProcessing ap = new AssignmentProcessing();
			ap.processPIPMethodRules(recordsToBeProcessed);
		}
	}

	/**
	 * @description Set Property Related Fields on TASKRAY__Project__c records if criteria is met.
	 *
	 * @param newRecords - New List of TASKRAY__Project__c
	 * @param oldMap - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void setPropertyFields(List<TASKRAY__Project__c> newItems, Map<Id, TASKRAY__Project__c> oldMap) {
		Set<Id> propertyIds = new Set<Id>();
		Set<TASKRAY__Project__c> eligiblePIPs = new Set<TASKRAY__Project__c>();

		for(TASKRAY__Project__c pip : newItems) {

			if(pip.Property__c != null) {
				propertyIds.add(pip.Property__c);
				if(oldMap == null
					|| (oldMap != null
					&& oldMap.containsKey(pip.Id)
					&& oldMap.get(pip.Id).Property__c != pip.Property__c)) {
					eligiblePIPs.add(pip);
				}
			}
		}
		System.debug('eligiblePIPs : ' + eligiblePIPs);

		if(!eligiblePIPs.isEmpty() && eligiblePIPs.size() > 0) {
			Map<Id, Property__c> propertyById = getPropertiesByIds(propertyIds);
			System.debug('propertyById : ' + propertyById);

			if(!propertyById.isEmpty() && propertyById.size() > 0) {
				for(TASKRAY__Project__c pip : eligiblePIPs) {
					System.debug('pip : ' + pip.Property__c);
					System.debug('propertyById.get(pip.Property__c : ' + propertyById.get(pip.Property__c));
					if(propertyById.containsKey(pip.Property__c)) {
						pip.Property_Code__c = propertyById.get(pip.Property__c).Property_Code__c.left(50);
						pip.Franchise_Owner__c = propertyById.get(pip.Property__c).GM_Name__c;
						pip.Standard_GM_Email__c = propertyById.get(pip.Property__c).Standard_GM_Email__c;
						pip.Property_Phone__c = propertyById.get(pip.Property__c).Property_Phone__c;
						pip.Property_Fax__c = propertyById.get(pip.Property__c).Property_Fax__c;
						pip.Additional_GM_Email__c = propertyById.get(pip.Property__c).Additional_GM_Email__c;
					}
				}
			}
		}
	}

	/**
	 * @description Set the Travel Status field on TASKRAY__Project__c
	 *
	 * @param newRecords - New List of TASKRAY__Project__c
	 * @param oldMap - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void setTravelStatus(List<TASKRAY__Project__c> newItems, Map<Id, TASKRAY__Project__c> oldMap) {
		for(TASKRAY__Project__c pip : newItems) {
			if(pip.PIP_Method__c != null) {
				if(oldMap == null
					|| (oldMap != null
					&& oldMap.containsKey(pip.Id)
					&& oldMap.get(pip.Id).PIP_Method__c != pip.PIP_Method__c)) {
						if(pip.PIP_Method__c == PIP_METHOD_DESKTOP) {
							pip.Travel_Status__c = TRAVEL_STATUS_NO_TRAVEL_NEEDED;
						} else if(pip.PIP_Method__c == PIP_METHOD_TRAVEL) {
							pip.Travel_Status__c = TRAVEL_STATUS_TRAVEL_PENDING;
						} else {
							pip.Travel_Status__c = '';
						}
				}
			}
		}
	}

	/**
	 * @description Set the DFS User email address
	 *
	 * @param newRecords - New List of TASKRAY__Project__c
	 * @param oldMap - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void setDFSUsersEmailField(List<TASKRAY__Project__c> newItems, Map<Id, TASKRAY__Project__c> oldMap) {
		populateResourceIdSet(newItems);

		if(!resourceIds.isEmpty() && resourceIds.size() > 0) {
			resourcesByIds = getResourcesByIds(resourceIds);

			for(TASKRAY__Project__c pip : newItems) {
				if(pip.DFS_User__c != null) {
					if(oldMap == null
						|| (oldMap != null
							&& oldMap.containsKey(pip.Id)
							&& oldMap.get(pip.Id).DFS_User__c != pip.DFS_User__c)) {
								if(resourcesByIds.containsKey(pip.DFS_User__c)) {
									pip.DFS_User_Email__c = resourcesByIds.get(pip.DFS_User__c).Email__c;
								}
					}
				}
			}
		}
	}

	/**
	 * @description Send PIP Written Emails
	 *
	 * @param newRecords - New List of TASKRAY__Project__c
	 * @param oldMap - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void sendPIPWrittenEmails(List<TASKRAY__Project__c> newItems, Map<Id, TASKRAY__Project__c> oldMap) {
		List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

		List<TASKRAY__Project__c> eligibleRecords = new List<TASKRAY__Project__c>();

		for(TASKRAY__Project__c pip : newItems) {
			if(pip.DFS_User__c != null && pip.DFS_User_Email__c != null) {
				if((oldMap == null
					|| (oldMap != null
						&& oldMap.containsKey(pip.Id)
						&& (oldMap.get(pip.Id).Sub_Status__c != pip.Sub_Status__c)))
					&& (pip.Sub_Status__c == PIP_SUB_STATUS_DRAFT
						|| pip.Sub_Status__c == PIP_SUB_STATUS_SENT_TO_LEGAL)){
					eligibleRecords.add(pip);
				}
			}
		}

		if(!eligibleRecords.isEmpty() && eligibleRecords.size() > 0) {
			List<EmailTemplate> templates = [SELECT ID FROM EmailTemplate WHERE DeveloperName =
				:EMAIL_TEMPLATE_PIP_WRITTEN_ALERT LIMIT 1];

			List<OrgWideEmailAddress> orgWideEmailAddresses = [
				SELECT Address, DisplayName, Id
				FROM OrgWideEmailAddress
				WHERE DisplayName = :ORG_WIDE_EMAIL_FRANCHISE_SALES_SUPPORT];

			if(!templates.isEmpty() && templates.size() > 0) {
				populateResourceIdSet(newItems);

				// RenderStoredEmailTemplate is invoked outside of for loop due to a SOQL query being utilized when
				// invoked as it will cause a governor limit issue if left inside for loop. Email Message object will
				// be modified each time before an email is actually sent.
				Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate
					(templates[0].Id, UserInfo.getUserId(), eligibleRecords[0].Id);

				if(!resourceIds.isEmpty() && resourceIds.size() > 0) {
					resourcesByIds = getResourcesByIds(resourceIds);
					for(TASKRAY__Project__c pip : eligibleRecords) {
						if(resourcesByIds.containsKey(pip.DFS_User__c)
							&& resourcesByIds.get(pip.DFS_User__c).User__c != null) {
							// Modify email message for each PIP record
							String subject = emailMessage.getSubject();
							String body = emailMessage.getHtmlBody();
							emailMessage.setSubject(subject);
							emailMessage.setHtmlBody(body);
							emailMessage.setToAddresses(new List<String>{resourcesByIds.get(pip.DFS_User__c).User__c});
							emailMessage.setWhatId(pip.Id);
							emailMessage.saveAsActivity = false;
							emailMessage.setOrgWideEmailAddressId(orgWideEmailAddresses[0].Id);
							emailMessages.add(emailMessage);
						}
					}
				}
			}
		}

		if(!emailMessages.isEmpty() && emailMessages.size() > 0) {
			try{
				// First, reserve email capacity for the current Apex transaction to ensure that we won't exceed our
				// daily email limits when sending email after the current transaction is committed.
				Messaging.reserveSingleEmailCapacity(2);

				Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emailMessages, true);
			} catch(Exception e) {
				system.debug('Email error: '+ e.getMessage() + ', Cause: ' + e.getCause());
			}
		}
	}

	/**
	 * @description Set PIP Status Effective Date on Change of Status (TASKRAY__trStatus__c)
	 *
	 * @param newRecords - New List of TASKRAY__Project__c
	 * @param oldMap - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void setPIPStatusEffectiveDate(List<TASKRAY__Project__c> newItems, Map<Id, TASKRAY__Project__c> oldMap) {
		for(TASKRAY__Project__c pip : newItems) {
			if(oldMap == null
				|| (oldMap != null
					&& oldMap.containsKey(pip.Id)
					&& (oldMap.get(pip.Id).TASKRAY__trStatus__c != pip.TASKRAY__trStatus__c))){
				pip.PIP_Status_Effective_Date__c = System.now();
			}
		}
	}

	/**
	 * @description Set PIP Status Effective Date on Change of Status (TASKRAY__trStatus__c)
	 *
	 * @param newRecords - New List of TASKRAY__Project__c
	 * @param oldMap - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void setPIPName(List<TASKRAY__Project__c> newItems, Map<Id, TASKRAY__Project__c> oldMap) {
		Set<Id> brandIds = new Set<Id>();
		Set<Id> productIds = new Set<Id>();

		for(TASKRAY__Project__c pip : newItems) {
			if(pip.Brand__c != null) {
				brandIds.add(pip.Brand__c);
			}
			if(pip.Product__c != null) {
				productIds.add(pip.Product__c);
			}
		}

		// Populate Brands by Ids Map
		getBrandsByIds(brandIds);
		// Populate Products by Ids Map
		getProductsByIds(productIds);

		for(TASKRAY__Project__c pip : newItems) {
			Date currentDate = pip.CreatedDate != null ? pip.CreatedDate.date() : Date.Today();
			if(oldMap == null
				|| (oldMap != null
					&& oldMap.containsKey(pip.Id)
					&& (oldMap.get(pip.Id).Property__c != pip.Property__c
						|| (RecordTypeUtils.isPIPRecordType(pip.RecordTypeId) && oldMap.get(pip.Id).PIP_Type__c != pip.PIP_Type__c)
						|| (RecordTypeUtils.isOpeningRecordType(pip.RecordTypeId) && oldMap.get(pip.Id).Project_Type__c != pip.Project_Type__c)
						|| oldMap.get(pip.Id).Brand__c != pip.Brand__c
						|| oldMap.get(pip.Id).Product__c != pip.Product__c))){

				String type = '';
				if(RecordTypeUtils.isPIPRecordType(pip.RecordTypeId)){
					type = String.isNotBlank(pip.PIP_Type__c) ? pip.PIP_Type__c : '';
				}else if(RecordTypeUtils.isOpeningRecordType(pip.RecordTypeId)){
					type = String.isNotBlank(pip.Project_Type__c) ? pip.Project_Type__c : '';
				}
				String brand = String.isNotBlank(pip.Brand__c) && brandsByIds.containsKey(pip.Brand__c) ? brandsByIds
					.get(pip.Brand__c).Brand_Code__c : '';
				String product = String.isNotBlank(pip.Product__c) && productsByIds.containsKey(pip.Product__c) ?
					productsByIds.get(pip.Product__c).Product_Code__c : '';

				String Name = pip.Property_Code__c + ' - '
					+ type + ' - '
					+ brand
					+ product + ' - '
					+ String.valueOf(currentDate.month()) + '/'
					+ String.valueOf(currentDate.day()) + '/'
					+ String.valueOf(currentDate.year()).right(2);

				if(oldMap == null && pip.Name != null && (((pip.Name).indexOf('/') > 0) || pip.TASKRAY__trTemplate__c)){
					Name = pip.Name;
				}

				pip.Name = Name;
			}
		}
	}

	/**
	 * @description Set PIP Owner Id (OwnerId) based on PIP Writer field.
	 *
	 * @param newRecords - New List of TASKRAY__Project__c
	 * @param oldMap - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void setPIPOwnerId(List<TASKRAY__Project__c> newItems, Map<Id, TASKRAY__Project__c> oldMap) {
		Map<Id, Id> PIPToOwnerMap = new Map<Id, Id>();
        List<TASKRAY__Project_Task__c > pipItemsToSetOwner = new List<TASKRAY__Project_Task__c >();
        populateResourceIdSet(newItems);

		if(!resourceIds.isEmpty() && resourceIds.size() > 0) {
			resourcesByIds = getResourcesByIds(resourceIds);

			for(TASKRAY__Project__c pip : newItems) {
				if(pip.PIP_Writer__c != null
                    && (oldMap == null ||
                        pip.PIP_Writer__c != oldMap.get(pip.Id).PIP_Writer__c)
					&& resourcesByIds.containsKey(pip.PIP_Writer__c)) {
					Id currentOwnerId = resourcesByIds.get(pip.PIP_Writer__c).User__c;

					if(currentOwnerId != null && pip.OwnerId != currentOwnerId) {
						pip.OwnerId = currentOwnerId;
                        PIPToOwnerMap.put(pip.Id,currentOwnerId);
					}
				}
			}
            // Now set the owner of the PIP Items to the PIP owner
            if (!PIPToOwnerMap.isEmpty()) {
                for(TASKRAY__Project_Task__c  pipItem : [SELECT OwnerId,TASKRAY__Project__c FROM TASKRAY__Project_Task__c  WHERE TASKRAY__Project__c IN : PIPToOwnerMap.keyset()]) {
                    Id pipOwnerId = PIPToOwnerMap.get(pipItem.TASKRAY__Project__c);
                    if(pipItem.OwnerId != pipOwnerId) {
                        pipItem.OwnerId = pipOwnerId;
                        pipItemsToSetOwner.add(pipItem);
                        
                    }
                }
                if (!pipItemsToSetOwner.isEmpty()) {
                    update pipItemsToSetOwner;
                }               
            }          
		}
	}

	/**
	 * @description Increment Number of Revisions field if Sub Status is 'Revisions' and previous value was not
	 * revisions
	 *
	 * @param newRecords - New List of TASKRAY__Project__c
	 * @param oldMap - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void incrementNumberOfRevisions(List<TASKRAY__Project__c> newItems, Map<Id, TASKRAY__Project__c> oldMap) {
		for(TASKRAY__Project__c pip : newItems) {
			if((oldMap == null
				|| (oldMap != null
					&& oldMap.containsKey(pip.Id)
					&& oldMap.get(pip.Id).Sub_Status__c != PIP_SUB_STATUS_REVISIONS))
				&& pip.Sub_Status__c == PIP_SUB_STATUS_REVISIONS) {
				pip.Revision__c += 1;
			}
		}
	}

	/**
	 * @description Set the Due Date field on PIP Items on TASKRAY__Project__c
	 *
	 * @param newRecords - New List of TASKRAY__Project__c
	 * @param oldMap - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void setUpdateDueDateAndQuantityOnPIPItems(List<TASKRAY__Project__c> newItems, Map<Id, TASKRAY__Project__c> oldMap) {
		Map<Id, Date> datesByPIPIds =  new Map<Id, Date>();
		Map<Id, Decimal> roomsByPIPIds = new Map<Id, Decimal>();
		Set<Id> pipIds = new Set<Id>();

		for(TASKRAY__Project__c pip : newItems) {
			if(pip.COMM_Date__c != null
				&& (oldMap == null
					|| (oldMap != null
					&& oldMap.containsKey(pip.Id)
					&& oldMap.get(pip.Id).COMM_Date__c != pip.COMM_Date__c))) {
				datesByPIPIds.put(pip.Id, pip.COMM_Date__c);
			}

			if(oldMap != null && oldMap.containsKey(pip.Id)
					&& oldMap.get(pip.Id).Number_of_Rooms__c != pip.Number_of_Rooms__c){
				roomsByPIPIds.put(pip.Id, pip.Number_of_Rooms__c);

			}
		}
		pipIds.addall(datesByPIPIds.keySet());

		pipIds.addall(roomsByPIPIds.keySet());

		List<TASKRAY__Project_Task__c> pipItemsForUpdate = new List<TASKRAY__Project_Task__c>();
		if(!pipIds.isEmpty() && pipIds.size() > 0) {
			List<TASKRAY__Project_Task__c> pipItems = [
				SELECT ID, PI_Due_In_Months__c, PI_Item_Due_Date__c, Update_Due_Date__c,
						PIP_Library_Item__r.PI_Cost_Units__c, TASKRAY__Project__c
						FROM TASKRAY__Project_Task__c
						WHERE TASKRAY__Project__c IN :pipIds];

			for (TASKRAY__Project_Task__c pipItem : pipItems) {
				boolean isPIPItemChanged = false;
				if(datesByPIPIds.containsKey(pipItem.TASKRAY__Project__c)) {
					if (pipItem.PI_Due_In_Months__c != null
							&& pipItem.PI_Item_Due_Date__c == null) {
						pipItem.Update_Due_Date__c = true;
						isPIPItemChanged = true;
					}
				}
				if(roomsByPIPIds.containsKey(pipItem.TASKRAY__Project__c)) {
					if (pipItem.PIP_Library_Item__r.PI_Cost_Units__c == AppConstants.COST_UNIT_PER_BUILDING) {
						pipItem.PI_Quantity__c = AppConstants.PER_BUILDING_QUANTITY;
					} else if (pipItem.PIP_Library_Item__r.PI_Cost_Units__c == AppConstants.COST_UNIT_PER_ROOM) {
						if (roomsByPIPIds.get(pipItem.TASKRAY__Project__c) != null) {
							pipItem.PI_Quantity__c = roomsByPIPIds.get(pipItem.TASKRAY__Project__c);
						}
					}
					isPIPItemChanged = true;
				}
				if(isPIPItemChanged) {
					pipItemsForUpdate.add(pipItem);
				}
			}

		}

		if(!pipItemsForUpdate.isEmpty() && pipItemsForUpdate.size() > 0) {
			try{
				update pipItemsForUpdate;
			} catch(DmlException e) {
				system.debug('Email error: '+ e.getMessage() + ', Cause: ' + e.getCause());
			}
		}
	}

	/** 
	 * @description Used to return a Map of Property by Id if not already populated.
	 * 
	 * @param propertyIds - Set of Property Ids contained in trigger.new
	 * @return Map<Id, Property__c>
	 */
	private Map<Id, Property__c> getPropertiesByIds(Set<Id> propertyIds) {

		if(propertiesByIds == null) { propertiesByIds = new  Map<Id, Property__c>(); }

		if(!propertiesByIds.isEmpty() && propertiesByIds.size() > 0) {
			propertiesByIds = propertiesByIds;
		} else if(propertiesByIds.isEmpty()) {
			propertiesByIds = new Map<Id, Property__c>([
				SELECT Id, Property_Code__c, Additional_GM_Email__c, GM_Name__c, Property_Fax__c, Property_Phone__c,
					Standard_GM_Email__c
				FROM Property__c
				WHERE Id IN :propertyIds]);
		}

		return propertiesByIds;
	}

	/**
	 * @description Used to return a Map of Resource by Id if not already populated.
	 *
	 * @param resourceIds - Set of Resource Ids contained in trigger.new
	 * @return Map<Id, Resource__c>
	 */
	private Map<Id, Resource__c> getResourcesByIds(Set<Id> resourceIds) {
		if(resourcesByIds == null) { resourcesByIds = new  Map<Id, Resource__c>(); }

		if(!resourcesByIds.isEmpty() && resourcesByIds.size() > 0) {
			resourcesByIds = resourcesByIds;
		} else if(resourcesByIds.isEmpty()) {
			resourcesByIds = new Map<Id, Resource__c>([
				SELECT Id, User__c, Email__c
				FROM Resource__c
				WHERE Id IN :resourceIds]);
		}

		return resourcesByIds;
	}

	/**
	 * @description Used to return a Map of Brand by Id if not already populated.
	 *
	 * @param brandIds - Set of Brand Ids contained in trigger.new
	 * @return Map<Id, Brand__c>
	 */
	private Map<Id, Brand__c> getBrandsByIds(Set<Id> brandIds) {
		if(brandsByIds == null) { brandsByIds = new  Map<Id, Brand__c>(); }

		if(!brandsByIds.isEmpty() && brandsByIds.size() > 0) {
			brandsByIds = brandsByIds;
		} else if(brandsByIds.isEmpty()) {
			brandsByIds = new Map<Id, Brand__c>([
				SELECT Id, Brand_Code__c
				FROM Brand__c
				WHERE Id IN :brandIds]);
		}

		return brandsByIds;
	}

	/**
	 * @description Used to return a Map of Products by Id if not already populated.
	 *
	 * @param brandIds - Set of Product Ids contained in trigger.new
	 * @return Map<Id, Product__c>
	 */
	private Map<Id, Product__c> getProductsByIds(Set<Id> productIds) {
		if(productsByIds == null) { productsByIds = new  Map<Id, Product__c>(); }

		if(!productsByIds.isEmpty() && productsByIds.size() > 0) {
			productsByIds = productsByIds;
		} else if(productsByIds.isEmpty()) {
			productsByIds = new Map<Id, Product__c>([
				SELECT Id, Product_Code__c
				FROM Product__c
				WHERE Id IN :productIds]);
		}

		return productsByIds;
	}

	private void populateResourceIdSet(List<TASKRAY__Project__c> newItems) {
		if(resourceIds == null) { resourceIds = new Set<Id>(); }

		if(resourceIds.isEmpty()) {
			for(TASKRAY__Project__c pip : newItems) {
				if(pip.PIP_Writer__c != null) {
					resourceIds.add(pip.PIP_Writer__c);
				}
				if(pip.Licensee_Rep__c != null) {
					resourceIds.add(pip.Licensee_Rep__c);
				}
				if(pip.Portfolio_Manager__c != null) {
					resourceIds.add(pip.Portfolio_Manager__c);
				}
				if(pip.Brand_Project_Manager__c != null) {
					resourceIds.add(pip.Brand_Project_Manager__c);
				}
				if(pip.DFS_User__c != null) {
					resourceIds.add(pip.DFS_User__c);
				}
				if(pip.Procurement_Manager__c != null) {
					resourceIds.add(pip.Procurement_Manager__c);
				}
				if(pip.Design_Coordinator__c != null) {
					resourceIds.add(pip.Design_Coordinator__c);
				}
				if(pip.Procurement_Coordinator__c != null) {
					resourceIds.add(pip.Procurement_Coordinator__c);
				}
				if(pip.Verifying_Manager__c != null) {
					resourceIds.add(pip.Verifying_Manager__c);
				}
			}
		}
	}

	/**
	* @description Method to automatically assign PIP record for Approval to RVP/OPS
	* @param newPIPs New PIP records
 	*/
	public void assignRecordForApproval(List<TASKRAY__Project__c> newPIPs, Map<Id, TASKRAY__Project__c> oldMap){
		List<Approval.ProcessSubmitRequest> allRequests = new List<Approval.ProcessSubmitRequest>();
		Map<Id,Id> mapManagerIdsByUserIds = getManagersForUsers();
		List<Id> PIPsToUnlock = new List<Id>();
		Set<String> setPIPAppTypes =
				new Set<String>{'Conversion','New Construction','Relicensing','Renewal','Repositioning'};
		for(TASKRAY__Project__c PIP :[SELECT Id,App_Type__c,Contract__r.Deal__r.Approval_Status__c, Pending_Approval__c
		FROM TASKRAY__Project__c
		WHERE Id IN :newPIPs]){
			Id userId = UserInfo.getUserId();
			if((oldMap == null || (oldMap != null
					&& oldMap.containsKey(PIP.Id) && oldMap.get(PIP.Id).App_Type__c != PIP.App_Type__c))
					&& PIP.Contract__r.Deal__r.Approval_Status__c != 'Approved'
					&& setPIPAppTypes.contains(PIP.App_Type__c)
					&& !PIP.Pending_Approval__c){
				if(((PIP.App_Type__c == 'Conversion'
						|| PIP.App_Type__c == 'New Construction'
						|| PIP.App_Type__c == 'Repositioning')
						&& mapManagerIdsByUserIds.get(userId) != null)
						|| PIP.App_Type__c == 'Renewal' || PIP.App_Type__c == 'Relicensing') {
					Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
					approvalRequest.setComments('PIP Submitted for approval');
					approvalRequest.setObjectId(PIP.Id);
					allRequests.add(approvalRequest);
					PIPsToUnlock.add(PIP.Id);
				}
			}
		}
			if (allRequests.size() != 0 && !allRequests.isEmpty()) {
				Approval.process(allRequests);
				Approval.unlock(PIPsToUnlock);
			}
	}

	/**
	* @description Method to send email to AD user when PIP is verified
	* @param newRecords - New List of TASKRAY__Project__c
	 * @param oldMap - Old Map of TASKRAY__Project__c
	 * @return void
	 */
	public void sendPIPVerifiedEmails(List<TASKRAY__Project__c> newPIPs, Map<Id, TASKRAY__Project__c> oldPIPsMapById) {
		List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
		List<TASKRAY__Project__c> eligiblePIPRecords = new List<TASKRAY__Project__c>();
		Set<String> setPIPAppTypes =
				new Set<String>{'Conversion','New Construction','Repositioning'};
		for(TASKRAY__Project__c pip : newPIPs) {
			if((oldPIPsMapById == null
					|| (oldPIPsMapById != null
					&& oldPIPsMapById.containsKey(pip.Id)
					&& (oldPIPsMapById.get(pip.Id).Sub_Status__c != pip.Sub_Status__c)))
					&& pip.Sub_Status__c == PIP_SUB_STATUS_VERIFIED){
				eligiblePIPRecords.add(pip);
			}
		}

		List<TASKRAY__Project__c> eligiblePIPRecordsWithAD = new List<TASKRAY__Project__c>();
		for(TASKRAY__Project__c PIP :[SELECT App_Type__c, PIP_Type__c, Property__r.AD_User__c,
				Property__r.AD_User__r.Email__c
		FROM TASKRAY__Project__c
		WHERE Id IN :eligiblePIPRecords]){
			if(PIP.Property__c != null
					&& PIP.Property__r.AD_User__c != null
					&& PIP.Property__r.AD_User__r.Email__c != null
					&& !setPIPAppTypes.contains(PIP.App_Type__c)
					&& PIP.PIP_Type__c == PIP_TYPE_APPLICATION){
				eligiblePIPRecordsWithAD.add(PIP);
			}
		}

		if(!eligiblePIPRecordsWithAD.isEmpty() && eligiblePIPRecordsWithAD.size() > 0) {
			List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName =
					:EMAIL_TEMPLATE_PIP_VERIFIED_ALERT LIMIT 1];

			List<OrgWideEmailAddress> orgWideEmailAddresses = [
					SELECT Address, DisplayName, Id
					FROM OrgWideEmailAddress
					WHERE DisplayName = :ORG_WIDE_EMAIL_FRANCHISE_SALES_SUPPORT];

			if(!templates.isEmpty() && templates.size() > 0) {
				Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate
						(templates[0].Id, UserInfo.getUserId(), eligiblePIPRecords[0].Id);
				for(TASKRAY__Project__c pip : eligiblePIPRecordsWithAD) {
					String subject = emailMessage.getSubject();
					String body = emailMessage.getHtmlBody();
					emailMessage.setSubject(subject);
					emailMessage.setHtmlBody(body);
					emailMessage.setToAddresses(new List<String>{pip.Property__r.AD_User__r.Email__c});

					emailMessage.setWhatId(pip.Id);
					emailMessage.saveAsActivity = false;
					emailMessage.setOrgWideEmailAddressId(orgWideEmailAddresses[0].Id);
					emailMessages.add(emailMessage);
				}
			}
		}

		if(!emailMessages.isEmpty() && emailMessages.size() > 0) {
			try{
				// First, reserve email capacity for the current Apex transaction to ensure that we won't exceed our
				// daily email limits when sending email after the current transaction is committed.
				Messaging.reserveSingleEmailCapacity(2);

				Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emailMessages, true);
			} catch(Exception e) {
				System.debug('Email error: '+ e.getMessage() + ', Cause: ' + e.getCause());
			}
		}
	}

	/**
	* @description Method to set submitted date when Sub Status changes to with Sent to Legal, Draft or Rejected
	*
	* @param newPIPs List of new inserted or updated pips
	 */
	public void setSubmittedDate(List<TASKRAY__Project__c> newPIPs){
		for(TASKRAY__Project__c pip :newPIPs){
			if((pip.Sub_Status__c == PIP_SUB_STATUS_SENT_TO_LEGAL
					|| pip.Sub_Status__c == PIP_SUB_STATUS_DRAFT
					|| pip.Sub_Status__c == PIP_SUB_STATUS_REJECTED)
					&& pip.Submitted_Date__c == null){
				pip.Submitted_Date__c = Date.today();
			}
		}
	}

	/**
	* @description Method to get all users with their manager Ids.
	*
	* @return Map of Manager id to user Id
	 */
	private Map<Id,Id> getManagersForUsers(){
		Map<Id,Id> mapManagerIdByUserIdsByIds = new Map<Id, Id>();
		for(User user : [SELECT Id, ManagerId FROM User]){
			mapManagerIdByUserIdsByIds.put(user.Id,user.ManagerId);
		}
		return mapManagerIdByUserIdsByIds;
	}
}