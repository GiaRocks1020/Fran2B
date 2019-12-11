@isTest
public with sharing class ApplicationSiteControlControllerTest {
    /*
    @isTest
    public static void updatePAorLOI_givenValidId_shouldUpdateApplication(){
        Application__c app = new Application__c(Upload_PA_or_LOI__c = false);
        insert app;

        Test.startTest();
            ApplicationSiteControlController.updatePAorLOI(app.Id);
        Test.stopTest();

        Application__c queriedApp = [SELECT Upload_PA_or_LOI__c FROM Application__c WHERE Id = :app.Id LIMIT 1];

        System.assert(queriedApp.Upload_PA_or_LOI__c == true, 'Checkbox should have been updated to true');
    }

    @isTest
    public static void updateUploadDeed_givenValidId_shouldUpdateApplication(){
        Application__c app = new Application__c(Upload_Deed__c = false);
        insert app;

        Test.startTest();
            ApplicationSiteControlController.updateUploadDeed(app.Id);
        Test.stopTest();

        Application__c queriedApp = [SELECT Upload_Deed__c FROM Application__c WHERE Id = :app.Id LIMIT 1];

        System.assert(queriedApp.Upload_Deed__c == true, 'Checkbox should have been updated to true');
    }

    @isTest
    public static void updateLeaseAgreement_givenValidId_shouldUpdateApplication(){
        Application__c app = new Application__c(Upload_Lease_Agreement__c = false);
        insert app;

        Test.startTest();
            ApplicationSiteControlController.updateLeaseAgreement(app.Id);
        Test.stopTest();

        Application__c queriedApp = [SELECT Upload_Lease_Agreement__c FROM Application__c WHERE Id = :app.Id LIMIT 1];

        System.assert(queriedApp.Upload_Lease_Agreement__c == true, 'Checkbox should have been updated to true');
    }
    */
}