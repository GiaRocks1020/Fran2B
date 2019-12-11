public with sharing class LeadConvertContactListController {
    /***************************************************************************************
    Method to get contacts wrapper for Lead Conversion
    ****************************************************************************************/
    @AuraEnabled
    public static String getContacts(Lead l) {
        String queryString = LeadConvertUtilities.getSobjectQuery('Contact', l);
        List<Contact> contacts = Database.query(queryString);
        System.debug('Contacts ' + contacts);
        return JSON.serialize(LeadConvertUtilities.sortRecordsBasedonMatchScore(contacts, l));
    }

    /***************************************************************************************
    Method to get contact fields for column data
    ****************************************************************************************/    
    @AuraEnabled
    public static List<Lead_Convert_Contact_Fields_Metadata__mdt> getLeadConvertContactFields(){
        return CustomMetadataDA.getLeadConvertContactFieldsMetadata();
    }


}