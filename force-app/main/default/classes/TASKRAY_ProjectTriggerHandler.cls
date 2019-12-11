/**
 * @description Trigger Handler for TASKRAY__Project__c object
 *
 * @author Zach French
 * @date 2019-08-10
 */
public inherited sharing class TASKRAY_ProjectTriggerHandler extends TriggerBase {
	// Trigger Variables
	public static Boolean bypassTrigger = false;

	public static Boolean isBeforeUpdateTriggerReEntry = false;
	public static Boolean isAfterUpdateTriggerReEntry = false;
	private static List<TASKRAY__Project__c> newPIPList = new List<TASKRAY__Project__c>();
	private static List<TASKRAY__Project__c> projectList = new List<TASKRAY__Project__c>();
	private static List<TASKRAY__Project__c> pipTemplateList = new List<TASKRAY__Project__c>();
	private static List<TASKRAY__Project__c> newOpeningList = new List<TASKRAY__Project__c>();
	private static List<TASKRAY__Project__c> openingTemplateList = new List<TASKRAY__Project__c>();

	// Constructor
	public TASKRAY_ProjectTriggerHandler() {
		setBypassTrigger(bypassTrigger);
	}

	// Before Insert execution context
	public override void beforeInsert() {

		TASKRAY_ProjectTriggerHelper triggerHelper = new TASKRAY_ProjectTriggerHelper();
		TASKRAY_ProjectTriggerHandler.populatePIPsAndOpeningList((List<TASKRAY__Project__c>) trigger.new);


		if(newPIPList.size() > 0) {

			// Set the target assignment date fields on PIPs
			triggerHelper.setPIPTargetAssignmentDate(newPIPList, null);

			// Set the PIP Method field based on criteria
			triggerHelper.performPIPMethodAssignment(newPIPList, null);

			// Set the Travel Status based on PIP Method
			triggerHelper.setTravelStatus(newPIPList, null);

			// Set the DFS User Email field which is used for sending emails
			triggerHelper.setDFSUsersEmailField(newPIPList, null);

			// Set the PIP Status Effective Date
			triggerHelper.setPIPStatusEffectiveDate(newPIPList, null);

			// Set PIP Owner Id
			triggerHelper.setPIPOwnerId(newPIPList, null);

			// Increment Number of Revisions (Revision__c) if Sub Status is Revision
			triggerHelper.incrementNumberOfRevisions(newPIPList, null);

			// Set Submitted Date
			triggerHelper.setSubmittedDate(newPIPList);
		}

		if(projectList.size() > 0 ) {

			// Set the Property Code based on Property Code from Project
			triggerHelper.setPropertyFields(projectList, null);

			// Set PIP/ Opening Name
			triggerHelper.setPIPName(projectList, null);

		}
	}

	// Before Update execution context
	public override void beforeUpdate() {

		TASKRAY_ProjectTriggerHandler.populatePIPsAndOpeningList((List<TASKRAY__Project__c>) trigger.new);
		TASKRAY_ProjectTriggerHelper triggerHelper = new TASKRAY_ProjectTriggerHelper();

		// Execute code for recursive Trigger
		if(isBeforeUpdateTriggerReEntry || !isBeforeUpdateTriggerReEntry){
			if(newPIPList.size() > 0) {
				// Increment Number of Revisions (Revision__c) if Sub Status is Revision
				triggerHelper.incrementNumberOfRevisions(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);

				// Set the target assignment date fields on PIPs
				triggerHelper.setPIPTargetAssignmentDate(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);

				// Set Submitted Date
				triggerHelper.setSubmittedDate(newPIPList);

			}

			if(projectList.size() > 0 ) {
				// Set the Property Code based on Property Code from Project
				triggerHelper.setPropertyFields(projectList, (Map<Id, TASKRAY__Project__c>) trigger.oldMap);

				// Set PIP/ Opening Name
				triggerHelper.setPIPName(projectList, null);

			}

		}

		if(!isBeforeUpdateTriggerReEntry){
			if(newPIPList.size() > 0) {
				// Set the PIP Method field based on criteria
				triggerHelper.performPIPMethodAssignment(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);

				// Set the Travel Status based on PIP Method
				triggerHelper.setTravelStatus(newPIPList, (Map<Id, TASKRAY__Project__c>) trigger.oldMap);

				// Set the DFS User Email field which is used for sending emails
				triggerHelper.setDFSUsersEmailField(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);

				// Set the PIP Status Effective Date
				triggerHelper.setPIPStatusEffectiveDate(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);

				// Set PIP Name
				triggerHelper.setPIPName(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);

				// Set PIP Owner Id
				triggerHelper.setPIPOwnerId(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);
			}
		}

		isBeforeUpdateTriggerReEntry = true;
	}

	// Before Delete execution context
	// (List<SObject> oldItems, Map<Id, SObject> oldItemsMap)

	// After Insert execution context
	// (List<SObject> newItems, Map<Id, SObject> newItemsMap)
	public override void afterInsert() {
		TASKRAY_ProjectTriggerHelper triggerHelper = new TASKRAY_ProjectTriggerHelper();

		if(projectList.size() > 0 ) {
			triggerHelper.performResourceAssignment(projectList);
		}

		if(newPIPList.size() > 0) {
			// Send Email Notifications for Written PIPs
			// This should occur after the DFS User has been set
			triggerHelper.sendPIPWrittenEmails(newPIPList, null);

			// Update Due Date on PIP Items
			triggerHelper.setUpdateDueDateAndQuantityOnPIPItems(newPIPList, null);

			//Submit record for approval
			triggerHelper.assignRecordForApproval(newPIPList, null);

			//Send email to AD User on Verified PIP
			triggerHelper.sendPIPVerifiedEmails(newPIPList, null);
		}
		ProjectTemplateTriggerHelper projectTemplateHelper = new ProjectTemplateTriggerHelper();

		if(pipTemplateList.size() > 0){
			projectTemplateHelper.validateDuplicateBrand(pipTemplateList, null);
		}

		if(openingTemplateList.size() > 0){
			projectTemplateHelper.validateDuplicateBrandProjectType(openingTemplateList, null);
		}
	}

	// After Update execution context
	// (List<SObject> oldItems, List<SObject> newItems, Map<Id, SObject> oldItemsMap, Map<Id, SObject> newItemsMap)
	public override void afterUpdate() {
		if(isAfterUpdateTriggerReEntry || !isAfterUpdateTriggerReEntry){
			if(newPIPList.size() > 0) {
				// Execute code for recursive Trigger
				TASKRAY_ProjectTriggerHelper triggerHelper = new TASKRAY_ProjectTriggerHelper();

				// Update Due Date on PIP Items
				triggerHelper.setUpdateDueDateAndQuantityOnPIPItems(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);

				//Submit record for approval
				triggerHelper.assignRecordForApproval(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);
			}
		}

		if(!isAfterUpdateTriggerReEntry){
			TASKRAY_ProjectTriggerHelper triggerHelper = new TASKRAY_ProjectTriggerHelper();

			if(projectList.size() > 0 ) {
				triggerHelper.performResourceAssignment(projectList);
			}

			if(newPIPList.size() > 0) {
				// Send Email Notifications for Written PIPs
				// This should occur after the DFS User has been set
				triggerHelper.sendPIPWrittenEmails(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);

				triggerHelper.sendPIPVerifiedEmails(newPIPList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);
			}
			if(System.isBatch() || System.isFuture() || System.isQueueable())
            	HistoryTracker_Util.createHistoryTrackerRecords(trigger.oldMap, trigger.newMap, 'TaskRay__Project__History');
            else
				HistoryTracker_Util.createHistoryTrackerRecords(JSON.serialize(trigger.oldMap), JSON.serialize(trigger.newMap), 'TaskRay__Project__History');
            
		}

		ProjectTemplateTriggerHelper projectTemplateHelper = new ProjectTemplateTriggerHelper();
		if(pipTemplateList.size() > 0){
			projectTemplateHelper.validateDuplicateBrand(pipTemplateList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);
		}
		if(openingTemplateList.size() > 0){
			projectTemplateHelper.validateDuplicateBrandProjectType(openingTemplateList, (Map<Id, TASKRAY__Project__c>) Trigger.oldMap);
		}

		isAfterUpdateTriggerReEntry = true;
	}

	/**
     * This method will sort out PIPs and Openings in two different lists.
     *
     * @param newProjectList
     */
	private static void populatePIPsAndOpeningList(List<TASKRAY__Project__c> newProjectList){
		for(TASKRAY__Project__c project: newProjectList) {
			if(RecordTypeUtils.isPIPRecordType(project.RecordTypeId)){
				newPIPList.add(project);
				projectList.add(project);
			}else if(RecordTypeUtils.isOpeningRecordType(project.RecordTypeId)){
				newOpeningList.add(project);
				projectList.add(project);
			}
			else if(RecordTypeUtils.isPIPTemplateRecordType(project.RecordTypeId)){
				pipTemplateList.add(project);
			}else if(RecordTypeUtils.isOpeningTemplateRecordType(project.RecordTypeId)){
				openingTemplateList.add(project);
			}
		}

	}


	// After Delete execution context
	// (List<SObject> oldItems, Map<Id, SObject> oldItemsMap)

	// After Undelete execution context
	// (List<SObject> newItems, Map<Id, SObject> newItemsMap)
}