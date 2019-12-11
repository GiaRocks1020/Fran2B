@isTest
public  class LeadConvertControllerTest {
    @isTest
    public static void getLeadById_givenVaildLeadId_shouldReturnLead(){
        Lead l = TestUtil.createLead('firstName', 'lastName', 'company', 'test', 'Associate/AD Referral');
        insert l;

        Lead returnedLead;
        Test.startTest();
            returnedLead = LeadConvertController.getLeadById(l.Id);
        Test.stopTest();

        System.assert(returnedLead != null, 'A lead should have gotten returned');
    }
}