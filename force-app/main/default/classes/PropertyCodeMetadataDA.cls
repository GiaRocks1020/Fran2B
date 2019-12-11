public with sharing class PropertyCodeMetadataDA {
    public static List<Property_Code_Metadata__c> returnPropertyCodeMetadataFromStateCountryCodes(List<String> stateCountryCodes){
        return [SELECT State_Country_Code__c, Identifier_Code__c FROM Property_Code_Metadata__c 
                                                            WHERE State_Country_Code__c IN :stateCountryCodes]; 
    }
    
    public static void upsertPropertyCodeMetaDataList(List<Property_Code_Metadata__c> codesToUpdate){
        upsert codesToUpdate;
    }
}