@isTest
public with sharing class ApplicationOtherInfoControllerTest {
    @isTest
    Public static void updateADACertificate_givenValidId_shouldUpdateApplication(){
        Application__c app = new Application__c(ADA_Certificate__c = false);
        insert app;

        Test.startTest();
            ApplicationOtherInfoController.updateADACertificate(app.Id);
        Test.stopTest();

        Application__c queriedApp = [SELECT ADA_Certificate__c FROM Application__c WHERE Id = :app.Id LIMIT 1];

        System.assert(queriedApp.ADA_Certificate__c == true, 'Checkbox should have been updated to true');
    }

    @isTest
    Public static void updateInsuranceCertificate_givenValidId_shouldUpdateApplication(){
        Application__c app = new Application__c(Insurance_Certificate__c = false);
        insert app;

        Test.startTest();
            ApplicationOtherInfoController.updateInsuranceCertificate(app.Id);
        Test.stopTest();

        Application__c queriedApp = [SELECT Insurance_Certificate__c FROM Application__c WHERE Id = :app.Id LIMIT 1];

        System.assert(queriedApp.Insurance_Certificate__c == true, 'Checkbox should have been updated to true');
    }
}