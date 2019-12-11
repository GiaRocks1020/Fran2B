public with sharing class ApplicationEntityController {
    @AuraEnabled 
    public static void updateEntityDocuments(Id appId){
        update new Application__c(Id = appId, Entity_Document__c = true);
    }
}