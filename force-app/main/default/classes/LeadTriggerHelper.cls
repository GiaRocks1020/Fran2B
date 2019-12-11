public without sharing class LeadTriggerHelper extends TriggerBase{
   
    /****************************************************************
        DESCRIPTION:
            During Trigger exection context method is executed before insert.  Append business logic methods here.
        INPUTS:
            None
        RETURNS
            void
    ****************************************************************/   
    public override void beforeInsert(){ 
        LeadRoutingHelper.assignBrandOfInterestIfEmpty((List<Lead>) Trigger.new);
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
        
        // Assign Leads
        List<Lead> leadsNeedRouting = LeadRoutingHelper.getLeadsThatNeedRouting((List<Lead>) Trigger.new);
        if(!leadsNeedRouting.isEmpty()) {
            list<Lead> assignLeads = LeadRoutingHelper.assignLeads(leadsNeedRouting);
            System.enqueueJob(new LeadAssignmentDelayAsyncJob(assignLeads));
        }
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
        LeadRoutingHelper.assignBrandOfInterestIfEmpty((List<Lead>) Trigger.new);
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
        // Assign Leads
        List<Lead> leadsNeedRouting = LeadRoutingHelper.getLeadsThatNeedRouting((List<Lead>) Trigger.new);
        List<Lead> leadsUpdated = LeadRoutingHelper.checkIfLeadStateOrBrandOfInterestHasChanged(leadsNeedRouting,Trigger.OldMap);
        if(!leadsUpdated.isEmpty()) {
            list<Lead> assignLeads = LeadRoutingHelper.assignLeads(leadsUpdated); 
            if(!Test.isRunningTest()) {
                System.debug(Trigger.OldMap);
                System.enqueueJob(new LeadAssignmentDelayAsyncJob(assignLeads, (Map<Id, Lead>)Trigger.OldMap));
            }
        }
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
 }