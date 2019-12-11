public with sharing class ApplicationOtherInfoController {
    @AuraEnabled 
    public static void updateADACertificate(Id appId){
        update new Application__c(Id = appId, ADA_Certificate__c = true);
    }

    @AuraEnabled 
    public static void updateInsuranceCertificate(Id appId){
        update new Application__c(Id = appId, Insurance_Certificate__c = true);
    }
}