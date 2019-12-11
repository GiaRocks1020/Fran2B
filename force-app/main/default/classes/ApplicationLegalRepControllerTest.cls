@isTest
public class ApplicationLegalRepControllerTest {
    private static final String DESIGNATED_REP = 'Designated Representative';
    @isTest
    public static void getLegalRepInfo_givenValidAppIdAndValidRep_shouldReturnRep(){
        Application__c app = new Application__c();
        insert app;
        
        Applicant__c applicant = new Applicant__c(Are_you_Owner_or_Designated_Rep__c = DESIGNATED_REP, Application__c = app.Id);
        insert applicant;

        List<Applicant__c> applicants = new List<Applicant__c>();

        Test.startTest();
            applicants = ApplicationLegalRepController.getLegalRepInfo(app.Id);
        Test.stopTest();
        
        System.assert(applicants.size() == 1, 'Expected an applicant to get returned');
    }

    @isTest
    public static void createLegalRep_givenVaildAppId_shouldCreateApplicant(){
        Application__c app = new Application__c();
        insert app;
        
        Applicant__c applicant = new Applicant__c();

        Test.startTest();
            applicant = ApplicationLegalRepController.createLegalRep(app.Id);
        Test.stopTest();
        
        System.assert(applicant.Are_you_Owner_or_Designated_Rep__c == DESIGNATED_REP, 'Expected an applicant that is a ' + DESIGNATED_REP);
        System.assert(applicant.Application__c == app.Id, 'Expected an applicant that is related to the provided application');

        List<Applicant__c> applicants = [SELECT Id FROM Applicant__c 
                                        WHERE Are_you_Owner_or_Designated_Rep__c = :DESIGNATED_REP 
                                        AND Application__c = :app.Id LIMIT 1];

        System.assert(applicants.size() == 1, 'An applicant was expected');
    }
}