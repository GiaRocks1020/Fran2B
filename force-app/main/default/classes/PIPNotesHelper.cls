/**
 * @description Used as the controller for the PIPNotes lightning component.
 *
 * @author Zach French
 * @date 2019-09-24
 */
public class PIPNotesHelper {

	@TestVisible
	private static List<ContentNote> mockNotes = new List<ContentNote>();

	/**
	 * @description Used to retrieve Notes to be displayed in Lightning Component. Records are sorted by CreatedDate.
	 *
	 * @param recordId - SObject Id
	 * @return List<ContentNoteLink>
	 */
	@AuraEnabled(cacheable = true)
	public static List<ContentNoteLink> getContentNotesByRecordId(Id recordId) {
		Map<Id, ContentNote> contentNotesByIds = new Map<Id, ContentNote>();
		List<ContentNoteLinkWrapper> contentNoteLinkWrappers = new List<ContentNoteLinkWrapper>();

		Set<Id> sObjectRecordIds = new Set<Id>();
		Set<Id> contentDocumentIds = new Set<Id>();
		List<ContentNoteLink> ContentNoteLinks = new List<ContentNoteLink>();

		// Add record to SObjectRecordIds
		sObjectRecordIds.add(recordId);

		// Get Related PIP and PIP Items
		sObjectRecordIds.addAll(getPIPAndPIPItemIds(recordId));
		// Get Related Contracts
		sObjectRecordIds.addAll(getContracts(recordId));
		// Get Related Deals
		sObjectRecordIds.addAll(getDeals(recordId));

		// Create Map of ContentDocumentLinks
		Map<Id, ContentDocumentLink> contentDocumentLinks = new Map<Id, ContentDocumentLink>(
			getContentDocumentLinks(sObjectRecordIds));

		// Populate set with ContentDocument Ids
		for(ContentDocumentLink contentDocumentLink : contentDocumentLinks.values()) {
			contentDocumentIds.add(contentDocumentLink.ContentDocumentId);
		}

		// Populate Map of ContentNotes by Id
		contentNotesByIds = new Map<Id, ContentNote>(getContentNotes(contentDocumentIds));

		Map<SObjectType, Schema.DescribeSObjectResult> describeSObjectResultsBySObjectTypes = new
			Map<SObjectType, Schema.DescribeSObjectResult>();

		// Iterate over ContentDocumentLinkValues
		for(ContentDocumentLink contentDocumentLink : contentDocumentLinks.values()) {
			if(contentNotesByIds.containsKey(contentDocumentLink.ContentDocumentId)) {
				ContentNote currentContentNote = contentNotesByIds.get(contentDocumentLink.ContentDocumentId);

				// Current SObjectType from LinkedEntityId field
				SObjectType sobjectTypeValue = getSObjectType(contentDocumentLink.LinkedEntityId);

				// Get Current Object Label
				String objectLabel = getSObjectLabel(sobjectTypeValue, describeSObjectResultsBySObjectTypes);

				// Create Content Note with LinkedEntityID
				ContentNoteLink contentNoteLink = createContentNoteLink(currentContentNote, contentDocumentLink,
					sobjectTypeValue, objectLabel);

				ContentNoteLinks.add(contentNoteLink);
				contentNoteLinkWrappers.add( new ContentNoteLinkWrapper(contentNoteLink));
			}
		}

		// Sort by Created Date Descending
		contentNoteLinkWrappers.sort();

		List<ContentNoteLink> sortedContentNoteLinks = new List<ContentNoteLink>();
		for(ContentNoteLinkWrapper contentNoteLinkWrapper : contentNoteLinkWrappers) {
			sortedContentNoteLinks.add(contentNoteLinkWrapper.contentNoteLink);
		}

		return sortedContentNoteLinks;
	}

	/**
	 * @description Used to retrieve a Set of PIP and PIP Item Ids in a single query.
	 *
	 * @param recordId - Current record Id
	 * @return Set<Id>
	 */
	public static Set<Id> getPIPAndPIPItemIds(Id recordId) {
		Set<Id> sObjectRecordIds = new Set<Id>();

		for(TASKRAY__Project__c pip : [
			SELECT Id, (SELECT Id FROM TASKRAY__Tasks__r), Property__c, Contract__c, Portfolio_Management_Record__c,
				TASKRAY__trOpportunity__c, Brand__c, Product__c, TASKRAY__trPrimaryOnboardingContact__c
			FROM TASKRAY__Project__c
			WHERE Property__c = :recordId
				OR Contract__c = :recordId
				OR Portfolio_Management_Record__c = :recordId
				OR TASKRAY__trOpportunity__c = :recordId
				OR Brand__c = :recordId
				OR Product__c = :recordId
				OR TASKRAY__trPrimaryOnboardingContact__c = :recordId]) {

			sObjectRecordIds.add(pip.Id);
			sObjectRecordIds.add(pip.Property__c);
			sObjectRecordIds.add(pip.Contract__c);
			sObjectRecordIds.add(pip.Portfolio_Management_Record__c);
			sObjectRecordIds.add(pip.TASKRAY__trOpportunity__c);
			sObjectRecordIds.add(pip.Brand__c);
			sObjectRecordIds.add(pip.Product__c);
			sObjectRecordIds.add(pip.TASKRAY__trPrimaryOnboardingContact__c);

			List<SObject> pipItems = pip.getSObjects('TASKRAY__Tasks__r');
			if(pipItems != null && !pipItems.isEmpty() && pipItems.size() > 0) {
				for (SObject pipItem : pipItems) {
					sObjectRecordIds.add(pipItem.Id);
				}
			}
		}

		return sObjectRecordIds;
	}

	/**
	 * @description Retrieves set of Contract Ids by record Id
	 *
	 * @param record - Id of SObject
	 * @return Set<Id>
	 */
	public static Set<Id> getContracts(Id recordId) {
		Set<Id> sObjectRecordIds = new Set<Id>();
		for(Contract__c contract : [
			SELECT Id
			FROM Contract__c
			WHERE Property__c = :recordId
				OR Product__c = :recordId
				OR Deal__c = :recordId
				OR Brand__c = :recordId]) {
			sObjectRecordIds.add(contract.Id);
		}

		return sObjectRecordIds;
	}

	/**
	 * @description Retrieves set of Deals Ids by record Id
	 *
	 * @param record - Id of SObject
	 * @return Set<Id>
	 */
	public static Set<Id> getDeals(Id recordId) {
		Set<Id> sObjectRecordIds = new Set<Id>();
		for(Opportunity opportunity :[
			SELECT Id
			FROM Opportunity
			WHERE Property__c = :recordId
				OR Contract__c = :recordId
				OR Deal_for_Dual_Brand__c = :recordId]) {
			sObjectRecordIds.add(opportunity.Id);
		}
		return sObjectRecordIds;
	}

	/**
	 * @description Used retrieve ContentNote records based on a set of Record Ids
	 *
	 * @param recordIds - Set of Ids
	 * @return List<ContentNote>
	 */
	public static List<ContentNote> getContentNotes(Set<Id> recordIds) {
		return [SELECT Content, ContentSize, CreatedById, CreatedBy.Name, CreatedDate, FileExtension, FileType, Id,
					IsReadOnly, LastModifiedById, LastModifiedDate, OwnerId, SharingPrivacy, TextPreview, Title
				FROM ContentNote
				WHERE Id IN :recordIds
				ORDER BY CreatedDate DESC];
	}

	/**
	 * @description Used retrieve ContentDocumentLink records based on a set of LinkedEntityIds
	 *
	 * @param linkedEntityIds - Set of Ids
	 * @return List<ContentNote>
	 */
	public static List<ContentDocumentLink> getContentDocumentLinks(Set<Id> linkedEntityIds) {
		return [
			SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, LinkedEntityId,
				LinkedEntity.Name, ShareType, Visibility
			FROM ContentDocumentLink
			WHERE LinkedEntityId IN :linkedEntityIds
			AND ContentDocument.FileType = 'SNOTE'
			AND Visibility = 'InternalUsers'];
	}

	/**
	 * @description Used to retrieve the SObjectType of the LinkedEntityId from ContentDocumentLinks
	 *
	 * @param value - ContentDocumentLink record
	 * @return SObjectType
	 */
/*	public static SObjectType getSObjectType(ContentDocumentLink value) {
		return value.LinkedEntityId != null ? value.LinkedEntityId.getSObjectType() : null;
	}*/

	/**
	 * @description Used to retrieve the SObjectType of the Id from SObject
	 *
	 * @param value - Id of SObject
	 * @return SObjectType
	 */
	public static SObjectType getSObjectType(Id sobjectId) {
		return sobjectId != null ? sobjectId.getSObjectType() : null;
	}

	/**
	 * @description Used to retrieve the Label for an SObjectType
	 *
	 * @param sobjectTypeValue - SObjectType value
	 * @param describeSObjectResultsBySObjectTypes - Map of DescribeSObjectResults by SObjectType
	 * @return String
	 */
	public static String getSObjectLabel(SObjectType sobjectTypeValue, Map<SObjectType, Schema.DescribeSObjectResult>
		describeSObjectResultsBySObjectTypes) {
		String objectLabel = '';

		if(sobjectTypeValue != null) {
			Sobject objectRecord = sobjectTypeValue.newSObject();
			if(!describeSObjectResultsBySObjectTypes.containsKey(sobjectTypeValue)) {
				Schema.DescribeSObjectResult describeSObjectResult = objectRecord.getSObjectType()
					.getDescribe();
				describeSObjectResultsBySObjectTypes.put(sobjectTypeValue, describeSObjectResult);
			}

			if(describeSObjectResultsBySObjectTypes.containsKey(sobjectTypeValue)) {
				objectLabel = describeSObjectResultsBySObjectTypes.get(sobjectTypeValue).getLabel();
			}
		}

		return objectLabel;
	}

	/**
	 * @description Creates an instance of the ContentNoteLink Class (Object)
	 *
	 * @param currentContentNote - Content Note record
	 * @param contentDocumentLink - ContentDocumentLink record
	 * @param SObjectType - SObject Type of EntityLinkId
	 * @param objectLabel - String value of SObject Label for EntityLinkId
	 * @return ContentNoteLink
	 */
	public static ContentNoteLink createContentNoteLink(ContentNote currentContentNote, ContentDocumentLink
		contentDocumentLink, SObjectType sobjectTypeValue, String objectLabel) {
		// Create Content Note with LinkedEntityID
		ContentNoteLink contentNoteLink = new ContentNoteLink();
		contentNoteLink
			.Id(currentContentNote.Id)
			.IdURL(currentContentNote.Id)
			.Title(currentContentNote.Title)
			.TextPreview(currentContentNote.TextPreview)
			.CreatedDate(currentContentNote.CreatedDate)
			.CreatedByName(currentContentNote.CreatedBy.Name)
			.LinkedEntityId(contentDocumentLink.LinkedEntityId)
			.linkedEntityName(contentDocumentLink.LinkedEntity.Name)
			.sObjectType(String.valueOf(sobjectTypeValue))
			.sObjectTypeLabel(objectLabel)
			.linkedEntityURL(contentDocumentLink.LinkedEntityId);

		return contentNoteLink;
	}

	/**
	 * @description Used for creating a new type of record which joins data from both ContentNote and
	 * ContentDocumentLink.
	 *
	 */
	public class ContentNoteLink {
		@AuraEnabled
		public String Id;
		@AuraEnabled
		public String IdURL;
		@AuraEnabled
		public String Title;
		@AuraEnabled
		public String TextPreview;
		@AuraEnabled
		public Datetime CreatedDate;
		@AuraEnabled
		public String CreatedByName;
		@AuraEnabled
		public String LinkedEntityId;
		@AuraEnabled
		public String LinkedEntityName;
		@AuraEnabled
		public String linkedEntityURL;
		@AuraEnabled
		public String sObjectType;
		@AuraEnabled
		public String sObjectTypeLabel;

		public ContentNoteLink() { }

		public ContentNoteLink id(String value){
			this.Id = value;
			return this;
		}

		public ContentNoteLink idURL(String value){
			this.IdURL = '/' + value;
			return this;
		}

		public ContentNoteLink title(String value){
			this.Title = value;
			return this;
		}

		public ContentNoteLink textPreview(String value){
			this.TextPreview = value;
			return this;
		}

		public ContentNoteLink createdDate(Datetime value){
			this.CreatedDate = value;
			return this;
		}

		public ContentNoteLink createdByName(String value){
			this.CreatedByName = value;
			return this;
		}

		public ContentNoteLink linkedEntityId(String value){
			this.LinkedEntityId = value == null ? '' : value;
			return this;
		}

		public ContentNoteLink linkedEntityName(String value){
			this.LinkedEntityName = value == null ? '' : value;
			return this;
		}

		public ContentNoteLink linkedEntityURL(String value){
			this.linkedEntityURL = '/' + value;
			return this;
		}

		public ContentNoteLink sObjectType(String value){
			this.sObjectType = value;
			return this;
		}

		public ContentNoteLink sObjectTypeLabel(String value){
			this.sObjectTypeLabel = value;
			return this;
		}
	}

	/**
	 * @description Comparable method used for sorting ContentNoteLink Objects by CreatedDate in descending order.
	 *
	 */
	public class ContentNoteLinkWrapper implements comparable {
		public ContentNoteLink contentNoteLink;

		// Constructor
		public ContentNoteLinkWrapper(ContentNoteLink cnl) {
			contentNoteLink = cnl;
		}

		// Compare opportunities based on the opportunity amount.
		public Integer compareTo(Object compareTo) {
			// Cast argument to OpportunityWrapper
			ContentNoteLinkWrapper compareToContentNotLink = (ContentNoteLinkWrapper)compareTo;

			// The return value of 0 indicates that both elements are equal.
			Integer returnValue = 0;
			if (contentNoteLink.CreatedDate < compareToContentNotLink.contentNoteLink.CreatedDate) {
				// Set return value to a positive value.
				returnValue = 1;
			} else if (contentNoteLink.CreatedDate > compareToContentNotLink.contentNoteLink.CreatedDate) {
				// Set return value to a negative value.
				returnValue = -1;
			}

			return returnValue;
		}
	}
}