@isTest
private class LeadRoutingTest {
    @isTest
    static void testLeadAssignment() {
        list<Lead> leads = TestUtil.createLead('Test','Test','test','Test','Associate/AD Referral',50,'CS;AC;CI;EL;RW;SL',null,'US');
        Set<String> ownerIds = new Set<String>();
        Test.startTest();
                insert leads;
        Test.stopTest();

       leads = [SELECT OwnerId,Brand_of_Interest__c,StateCode FROM Lead WHERE id = :leads[0].id];

       leads = LeadRoutingHelper.assignLeads(leads);

       list<Group> devOps = QueueDA.getDefaultRoutingGroup();
        if(!devOps.isEmpty()) {
            system.assertEquals(leads[0].OwnerId == devOps[0].Id, true);
        }

        Lead l = leads[0];
        l.stateCode = null;
        l.Brand_of_Interest__c = null;
        update l;

        if(!devOps.isEmpty()) {
            system.assertEquals(l.OwnerId == devOps[0].Id, true);
        }
    }
}