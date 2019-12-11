public with sharing class LeadConvertController {
    /***************************************************************************************
    Method to get lead record for lead conversion
    ****************************************************************************************/
    @AuraEnabled
    public static Lead getLeadById(String leadId){
        String fieldsToQuery = 'Id,';

         for(String field : FranchiseSalesUtilities.getSobjectFields('Lead')){
             fieldsToQuery += field + ', ';
        }

        fieldsToQuery = fieldsToQuery.removeEnd(', ');

        return Database.query('SELECT ' + fieldsToQuery + ' FROM Lead WHERE Id = \'' + leadId + '\' LIMIT 1');
    }
}