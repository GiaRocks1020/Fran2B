public without sharing class LeadAssignmentDelayAsyncJob implements Queueable {
    private List<Lead> assignLeads;
    private Map<Id, Lead> oldLeads;

    public LeadAssignmentDelayAsyncJob(List<Lead> leads) {
        this.assignLeads = leads;
        this.oldLeads = new Map<Id, Lead>();
    }

    public LeadAssignmentDelayAsyncJob(List<Lead> leads, Map<Id, Lead> triggerOldMap){
        this.assignLeads = leads;
        this.oldLeads = triggerOldMap;
    }
    public void execute(QueueableContext context){
        // add 10 second delay before scheduling the lead assignment job
         DateTime dt = system.now().addSeconds(10);
         do {
            
         }while(dt.getTime() > system.now().getTime());
         // Chain this job to next job by submitting the next job
        if(!Test.isRunningTest()) {
            if (this.oldLeads.isEmpty()){
                System.enqueueJob(new LeadAssignmentAsyncRouting(this.assignLeads));
            } else {
                System.enqueueJob(new LeadAssignmentAsyncRouting(this.assignLeads, this.oldLeads));
            }
        }
    }
}