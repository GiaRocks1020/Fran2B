public without sharing class OpportunityTriggerHelper extends TriggerBase {

	// Trigger Variables
	public static Boolean bypassTrigger = false;

	// Constructor
	public OpportunityTriggerHelper() {
		setBypassTrigger(bypassTrigger);
	}

    /****************************************************************
    	DESCRIPTION:
    		During Trigger exection context method is executed before insert.  Append business logic methods here.
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public override void beforeInsert(){
        List<Opportunity> opps = (List<Opportunity>) Trigger.new;
        Set<Id> propIds = PopulateCustomApprover.getPropertyIdsFromOpps(opps);
        PopulateCustomApprover.UpdateOppCustomApprover(opps, propIds);		
	}
    /****************************************************************
    	DESCRIPTION:
    		During Trigger exection context method is executed after insert.  Append business logic methods here.
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public override void afterInsert(){
    }
	/****************************************************************
    	DESCRIPTION:
    		During Trigger exection context method is executed before update.  Append business logic methods here.
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public override void beforeUpdate(){
        List<Opportunity> oppsThatNeedUpdated = PopulateCustomApprover.getOpportunitiesThatNeedCustomApproverUpdated(
            (List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
        Set<Id> propIds = PopulateCustomApprover.getPropertyIdsFromOpps(oppsThatNeedUpdated);
        PopulateCustomApprover.UpdateOppCustomApprover(oppsThatNeedUpdated, propIds);

		oppsThatNeedUpdated = ApplicationCreator.getOpportunitiesThatNeedApplications((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
		ApplicationCreator.createApplicationData(oppsThatNeedUpdated);

	}
	/****************************************************************
    	DESCRIPTION:
    		During Trigger exection context method is executed before delete.  Append business logic methods here.
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	 public override void beforeDelete(){
	    
	 }
	/*******************************************************************************************
    	DESCRIPTION:
    		During Trigger exection context method is executed after update.  Append business logic methods here.
    	INPUTS:
    		None
    	RETURNS
    		void
    ************************************************************************************************/	
	public override void afterUpdate(){
		List<Opportunity> oppsThatNeedUpdated = PopulateDealTerms.getOpportunitiesThatNeedDealTermsUpdated(
            (List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
			if(oppsThatNeedUpdated.size() > 0){
				PopulateDealTerms.populateTerms(oppsThatNeedUpdated);	
			}

		// Updated related PIPs where the deal is dead
		PIPHelper opportunityHelper = new PIPHelper();
		opportunityHelper.updateDeadRelatedPIPs(Trigger.new, Trigger.oldMap);
    }
}