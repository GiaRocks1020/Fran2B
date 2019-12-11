public with sharing class LeadConvertPropertyListController {
    /***************************************************************************************
    Method to get contact fields for column data
    ****************************************************************************************/    
    @AuraEnabled
    public static List<Lead_Convert_Property_Fields_Metadata__mdt> getLeadConvertPropertyFields(){
        return CustomMetadataDA.getLeadConvertPropertyFieldsMetadata();
    }

    /***************************************************************************************
    Method to get property wrapper for Lead Conversion
    ****************************************************************************************/
    @AuraEnabled
    public static String getProperties(Lead l) {
        String queryString = LeadConvertUtilities.getSobjectQuery('Property__c', l);
        
        List<Property__c> properties = Database.query(queryString);
        return JSON.serialize(LeadConvertUtilities.sortRecordsBasedonMatchScore(properties, l));
    }
}