@isTest
public with sharing class ApplicationEntityControllerTest {
    @isTest
    public static void updateEntityDocuments_givenValidId_shouldUpdateApplication(){
        Application__c app = new Application__c(Entity_Document__c = false);
        insert app;

        Test.startTest();
            ApplicationEntityController.updateEntityDocuments(app.Id);
        Test.stopTest();

        Application__c queriedApp = [SELECT Entity_Document__c FROM Application__c WHERE Id = :app.Id LIMIT 1];

        System.assert(queriedApp.Entity_Document__c == true, 'Checkbox should have been updated to true');
    }
}