public without sharing class LeadAssignmentAsyncRouting implements Queueable{
    private List<Lead> leadsToRoute;
    private Map<Id, Lead> oldLeads;

    public LeadAssignmentAsyncRouting(List<Lead> leads) {
        this.leadsToRoute = leads;
        this.oldLeads = new Map<Id, Lead>();
    }

    public LeadAssignmentAsyncRouting(List<Lead> leads, Map<Id, Lead> triggerOldMap){
        this.leadsToRoute = leads;
        this.oldLeads = triggerOldMap;
    }

    public void execute(QueueableContext context){
        Set<Id> successfulIds = new Set<Id>();
        Boolean errors = false;

        Database.SaveResult[] srList = Database.update(leadsToRoute, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated lead. Lead ID: ' + sr.getId());
                successfulIds.add(sr.getId());
            }
            else {
                // Operation failed, so get all errors             
                for(Database.Error err : sr.getErrors()) {
                    errors = true;
                    System.debug('The following error has occurred.');                 
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }

        List<Lead> failedLeadsToUpdate = new List<Lead>();
        if(errors){
            List<Group> devOpsQueue = QueueDA.getDefaultRoutingGroup();
            for(Lead l : leadsToRoute) {
                if(!successfulIds.contains(l.Id)){
                    l.OwnerId = devOpsQueue[0].Id;
                    failedLeadsToUpdate.add(l);
                }
            }

            try{
                update failedLeadsToUpdate;
            }
            catch(Exception e){
                failedLeadsToUpdate.clear();
                System.debug('Failed to update the queued Leads a second time');
            }   
        }

        List<Lead> updatedLeads = mergeLeadsFromUpdateRounds(new List<Id>(successfulIds), failedLeadsToUpdate);
        List<Lead> leadsRequiringEmail = stripOutLeadsThatDoNotRequireEmail(updatedLeads, this.oldLeads);
        emailNotificationsToLeadOwners(leadsRequiringEmail);
    }

    private List<Lead> mergeLeadsFromUpdateRounds(List<Id> successfulIds, List<Lead> firstFailedUpdateLeads) {
        List<Lead> updatedLeads = new List<Lead>();
        for (Lead l : this.leadsToRoute) {
            if (successfulIds.contains(l.Id)) {
                updatedLeads.add(l);
            }
        }
        updatedLeads.addAll(firstFailedUpdateLeads);
        return updatedLeads;
    }

    private List<Lead> stripOutLeadsThatDoNotRequireEmail(List<Lead> leadsRequiringEmail, Map<Id, Lead> oldLeads) {
        for (Integer i = 0; i < leadsRequiringEmail.size(); i++) {
            Lead oldLead = oldLeads.get(leadsRequiringEmail[i].Id);
            if (leadsRequiringEmail[i].LeadSource == 'Development Marketing') {
                leadsRequiringEmail.remove(i);
            }
            if (oldLead != null && leadsRequiringEmail[i].OwnerId == oldLead.OwnerId) {
                leadsRequiringEmail.remove(i);
            }
        }
        return leadsRequiringEmail;
    }

    private void emailNotificationsToLeadOwners(List<Lead> updatedLeads) {
        LeadEmailHandler leadMessager = new LeadEmailHandler(updatedLeads, 'DFS_New_Lead_Alert');
        try {
            leadMessager.sendEmailsToOwners();
        } catch (Exception e) {
            System.debug('Failed to send emails to lead owners');
            System.debug('Error: ' + e.getStackTraceString());
        }
    }
        
}