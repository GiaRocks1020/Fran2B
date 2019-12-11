public with sharing class ApplicationLegalRepController {
    private static final String DESIGNATED_REP = 'Designated Representative';

    @AuraEnabled
    public static List<Applicant__c> getLegalRepInfo(String id){
        String fieldsToQuery = 'Id, Name, ';

        for(String field : FranchiseSalesUtilities.getSobjectFields('Applicant__c')){
             fieldsToQuery += field + ', ';
        }

        fieldsToQuery = fieldsToQuery.removeEnd(', ');
        
        return Database.query('SELECT ' + fieldsToQuery + ' FROM Applicant__c WHERE Are_you_Owner_or_Designated_Rep__c = \'' + 
                                DESIGNATED_REP + '\' AND Application__c =\'' + id + '\' Limit 1' );
    }

    @AuraEnabled
    public static Applicant__c createLegalRep(String id){
        Applicant__c applicant = new Applicant__c(
            Are_you_Owner_or_Designated_Rep__c = DESIGNATED_REP,
            Application__c = id
        );

        insert applicant;

        return applicant;
    }
}