public with sharing class LeadConvertAccountListController {
    /***************************************************************************************
    Method to get accounts related to the selected contact Id for lead conversion
    ****************************************************************************************/
    @AuraEnabled
    public static List<Account> getAccountsFromContactId(Id contactId) {
        List<Lead_Convert_Account_Fields_Metadata__mdt> accountFields = CustomMetadataDA.getLeadConvertAccountFieldsMetadata();
        List<String> accountIds = getAccountIdsFromContactId(contactId);
        
        String fields ='Id';
        
        for(Lead_Convert_Account_Fields_Metadata__mdt accountField : accountFields){
            fields += ',' + accountField.Field_API_Name__c;
        }
        String query = 'SELECT ' + fields + ' FROM Account WHERE Id IN ' + accountIds;
        try{
            return Database.query(query);
        }
        catch(Exception e){
            System.debug(e.getMessage());
            return new List<Account>();
        }

    }
    /***************************************************************************************
    Method to get account fields for column data
    ****************************************************************************************/        
    @AuraEnabled
    public static List<Lead_Convert_Account_Fields_Metadata__mdt> getLeadConvertAccountFields(){
        return CustomMetadataDA.getLeadConvertAccountFieldsMetadata();
    }

    /***************************************************************************************
    Method to get accounts Ids related to the selected contact Id for lead conversion
    ****************************************************************************************/
    public static List<String> getAccountIdsFromContactId(Id contactId){
        List<String> formattedAccountIds = new List<String>();

        List<AccountContactRelation> relations = new List<AccountContactRelation>([SELECT Id, AccountId, ContactId 
                                                                                  FROM AccountContactRelation 
                                                                                  WHERE ContactId = :contactId]);

        for(AccountContactRelation relation : relations){
            formattedAccountIds.add('\''+ relation.AccountId + '\'');
        }

        return formattedAccountIds;
    }
    /***************************************************************************************
    Method to get accounts wrapper related to the lead for lead conversion
    ****************************************************************************************/
    @AuraEnabled
    public static String getAccountsRelatedToLead(Lead l){
        String queryString = LeadConvertUtilities.getSobjectQuery('Account', l);
        
        if(!String.isEmpty(queryString)) {
	        List<Account> accounts = Database.query(queryString);
	        return JSON.serialize(LeadConvertUtilities.sortRecordsBasedonMatchScore(accounts, l));
        }
        else
           return queryString;
    }
}