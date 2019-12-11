public with sharing class ApplicationSiteControlController {
    @AuraEnabled 
    public static void updatePAorLOI(Id appId){
       // update new Application__c(Id = appId, Upload_PA_or_LOI__c = true);
    }

    @AuraEnabled 
    public static void updateUploadDeed(Id appId){
        //update new Application__c(Id = appId, Upload_Deed__c = true);
    }

    @AuraEnabled 
    public static void updateLeaseAgreement(Id appId){
        //update new Application__c(Id = appId, Upload_Lease_Agreement__c = true);
    }
}