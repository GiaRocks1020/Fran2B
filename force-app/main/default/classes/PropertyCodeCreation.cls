public with sharing class PropertyCodeCreation {
    private static final Integer START_OF_ASCII_NUMBERS = 48; // 0
    private static final Integer END_OF_ASCII_NUMBERS = 58; // :
    private static final Integer START_OF_ASCII_LETTERS = 65; // A
    private static final Integer END_OF_ASCII_LETTERS = 90; // Z
    private static final Integer ASCII_I = 73; // I
    private static final Integer ASCII_O = 79; // O
    private static final String MASTERED_STATUS = 'Mastered';
    private static final String UNITED_STATES_CODE = 'US';
    /******************************************************************************************
    If property delivery address country = US then first two characters are set to ISO 2-char state code
    If property delivery address country <> US then first two characters are set to Choice custom 2-char country code,
        if one is identified for the country, otherwise the ISO 2-char country code.
    ******************************************************************************************/
    public static String getFirstTwoCharacters(Property__c prop, Map<String, String> isoCountryCodeToChoiceCountryCodeMap) {
        String firstTwoCharacters = '';

       System.debug('isoCountryCodeToChoiceCountryCodeMap ' + isoCountryCodeToChoiceCountryCodeMap);
        if(isoCountryCodeToChoiceCountryCodeMap.containsKey(prop.Country__c)){
            System.debug('Map Contains Key ');
            firstTwoCharacters = isoCountryCodeToChoiceCountryCodeMap.get(prop.Country__c);
        }
        else if(prop.Country__c == UNITED_STATES_CODE){
            if(!String.isEmpty(prop.State_Province__c)){
                if(prop.State_Province__c.contains('US-')){
                    firstTwoCharacters = prop.State_Province__c.remove('US-');
                }
            }
        }
        else{
            if(prop.Country__c.length() == 2){
                firstTwoCharacters = prop.Country__c;
            }
        }

        if(firstTwoCharacters != null){
            return firstTwoCharacters.toUpperCase();
        }
        else {
            return firstTwoCharacters;
        }
        
    }

    

    /***************************************************************************************
    Assigns the latest property codes
    ****************************************************************************************/
     public static List<Property_Code_Metadata__c> getLatestRecords(List<Property__c> props){
        Map<String, String> isoCountryCodeToChoiceCountryCodeMap = getIsoCountryCodeToChoiceCountryCodeMap();
        Map<String, Property_Code_Metadata__c> twoLetterStateCountryCodeToPropertyCodeMetadata = 
        getTwoLetterStateCountryCodeToThreeDigitCodeMap(getStateCountryCodeList(props, isoCountryCodeToChoiceCountryCodeMap));
        for(Property__c prop : props){
            String stateCountryCode = getFirstTwoCharacters(prop, isoCountryCodeToChoiceCountryCodeMap);
            if(twoLetterStateCountryCodeToPropertyCodeMetadata.containsKey(stateCountryCode)){
                if(!String.isEmpty(stateCountryCode)){
                    Property_Code_Metadata__c pcm = twoLetterStateCountryCodeToPropertyCodeMetadata.get(stateCountryCode);
                    String threeDigitCode = pcm.Identifier_Code__c;
                    //creates new 3 digit code
                    //threeDigitCode = getLast3Characters(threeDigitCode);
                    threeDigitCode = PropertyCodeGenUtil.getNextCode(threeDigitCode);
                    prop.Property_Code__c = stateCountryCode + threeDigitCode;
                    pcm.Identifier_Code__c = threeDigitCode;
                    twoLetterStateCountryCodeToPropertyCodeMetadata.put(stateCountryCode, pcm);
                }
            }
            else {
                if(!String.isEmpty(stateCountryCode)){
                    prop.Property_Code__c = stateCountryCode + '001';
                    twoLetterStateCountryCodeToPropertyCodeMetadata.put(stateCountryCode, 
                    new Property_Code_Metadata__c(State_Country_Code__c = stateCountryCode, Identifier_Code__c = '001'));
                }
            }
        }
        return twoLetterStateCountryCodeToPropertyCodeMetadata.values();
    }

    /***************************************************************************************
    Gets a list of all the state/country 2 digit codes
    ****************************************************************************************/
    public static List<String> getStateCountryCodeList(List<Property__c> props, Map<String, String> isoCountryCodeToChoiceCountryCodeMap){
        List<String> stateCountryCodes = new List<String>();
        for(Property__c prop : props){
            stateCountryCodes.add(getFirstTwoCharacters(prop, isoCountryCodeToChoiceCountryCodeMap));
        }

        return stateCountryCodes;
    }

    /***************************************************************************************
    Builds a map using the two letter state/country code as a key
    ****************************************************************************************/
    public static Map<String, Property_Code_Metadata__c> getTwoLetterStateCountryCodeToThreeDigitCodeMap(List<String> stateCountryCodes){
        List<Property_Code_Metadata__c> propertyCodeDataList = PropertyCodeMetadataDA.returnPropertyCodeMetadataFromStateCountryCodes(stateCountryCodes);
        Map<String, Property_Code_Metadata__c> twoLetterStateCountryCodeToPropertyCodeMetadata = new Map<String, Property_Code_Metadata__c>();

        for(Property_Code_Metadata__c propertyCodeData : propertyCodeDataList){
            twoLetterStateCountryCodeToPropertyCodeMetadata.put(propertyCodeData.State_Country_Code__c, propertyCodeData);
        }

        return twoLetterStateCountryCodeToPropertyCodeMetadata;
    }

    /***************************************************************************************
    Creates a map from ISO code to Choice code for countries
    ****************************************************************************************/
    public static Map<String, String> getIsoCountryCodeToChoiceCountryCodeMap(){
        Map<String, String> countryCodeToChoiceCountryCodeMap = new Map<String, String>();
        for(PropertyCodeCountryMapping__mdt countryMapping : CustomMetadataDA.getPropertyCodeCountryMapping()){
            countryCodeToChoiceCountryCodeMap.put(countryMapping.Country_ISO_Code__c, countryMapping.Choice_Country_Code__c);
        }

        return countryCodeToChoiceCountryCodeMap;
    }
}