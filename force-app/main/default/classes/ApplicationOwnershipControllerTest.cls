@isTest
public class ApplicationOwnershipControllerTest {
    @isTest
    public static void createOwner_givenValidId_shouldCreateAndReturnOwner(){
        Application__c app = new Application__c();
        insert app;


        Applicant__c applicant;
        Test.startTest();
            applicant = ApplicationOwnershipController.createOwner(app.Id);
        Test.stopTest();

        System.assert(applicant != null, 'Applicant should have been returned');
    }

    @isTest
    public static void updateFinancialStatement_givenValidId_shouldUpdateApplication(){
        Applicant__c appl = new Applicant__c(Salutation__c = 'Mr.',
                                            First_Name__c = 'test',
                                            Last_Name__c = 'tester',
                                            Business_Address_Line_1__c = '123 street',
                                            Business_State_Province__c = 'US-AZ',
                                            Business_City__c = 'test',
                                            Email__c = 'test@test.com',
                                            Business_Phone__c = '3333333333',
                                            Business_Zip_Postal_Code__c = '44444',
                                            Personal_Financial_Statement__c = false);
        insert appl;

        Test.startTest();
            ApplicationOwnershipController.updateFinancialStatement(appl.Id);
        Test.stopTest();

        Applicant__c queriedApp = [SELECT Personal_Financial_Statement__c FROM Applicant__c WHERE Id = :appl.Id LIMIT 1];

        System.assert(queriedApp.Personal_Financial_Statement__c == true, 'Checkbox should have been updated to true');
    }

    @isTest
    public static void updateOwnerResume_givenValidId_shouldUpdateApplication(){
        Applicant__c appl = new Applicant__c(Salutation__c = 'Mr.',
                                            First_Name__c = 'test',
                                            Last_Name__c = 'tester',
                                            Business_Address_Line_1__c = '123 street',
                                            Business_State_Province__c = 'US-AZ',
                                            Business_City__c = 'test',
                                            Email__c = 'test@test.com',
                                            Business_Phone__c = '3333333333',
                                            Business_Zip_Postal_Code__c = '44444',
                                            Owner_Resume__c = false);
        insert appl;

        Test.startTest();
            ApplicationOwnershipController.updateOwnerResume(appl.Id);
        Test.stopTest();

        Applicant__c queriedApp = [SELECT Owner_Resume__c FROM Applicant__c WHERE Id = :appl.Id LIMIT 1];

        System.assert(queriedApp.Owner_Resume__c == true, 'Checkbox should have been updated to true');
    }

    @isTest
    public static void handleDataInit_givenEmptyOwnerIdString_handlesNewOwner(){
        Application__c app = new Application__c();
        insert app;
        
        String jsonStr = '';
        Test.startTest();
            jsonStr = ApplicationOwnershipController.handleDataInit(app.Id, '');
        Test.stopTest();

        ApplicationOwnershipController.OwnershipEnvelope envelope = (ApplicationOwnershipController.OwnershipEnvelope) JSON.deserialize(jsonStr, ApplicationOwnershipController.OwnershipEnvelope.class);


        System.assert(envelope.owner != Null);
    }

    @isTest
    public static void handleDataInit_givenEmptyOwnerIdString_handlesExsistingOwner(){
        Application__c app = new Application__c();
        insert app;

        Applicant__c owner = new Applicant__c();
        insert owner;
        
        String jsonStr = '';
        Test.startTest();
            jsonStr = ApplicationOwnershipController.handleDataInit(app.Id, owner.Id);
        Test.stopTest();

        ApplicationOwnershipController.OwnershipEnvelope envelope = (ApplicationOwnershipController.OwnershipEnvelope) JSON.deserialize(jsonStr, ApplicationOwnershipController.OwnershipEnvelope.class);

        System.assert(envelope.owner.Id == owner.Id, envelope.owner);


    }
}