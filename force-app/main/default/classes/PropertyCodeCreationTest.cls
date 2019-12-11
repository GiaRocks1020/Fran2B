@isTest
public class PropertyCodeCreationTest {
    @isTest
    public static void getFirstTwoCharacters_givenUSProperty_ShouldReturnStateChar(){
        Map<String, String> isoCountryCodeToChoiceCountryCodeMap = PropertyCodeCreation.getIsoCountryCodeToChoiceCountryCodeMap();
        Property__c prop = new Property__c(Country__c = 'US', State_Province__c = 'US-MD');
        String chars = PropertyCodeCreation.getFirstTwoCharacters(prop, isoCountryCodeToChoiceCountryCodeMap);

        System.assert('MD' == chars, 'State codes should match. Expected MD, Actual ' + chars);
    }

    @isTest
    public static void getFirstTwoCharacters_givenNonUSPropertyWithChoiceCode_ShouldReturnChoiceCountryCode(){
        Map<String, String> isoCountryCodeToChoiceCountryCodeMap = PropertyCodeCreation.getIsoCountryCodeToChoiceCountryCodeMap();
        String firstChoiceCountryCode = new List<String>(isoCountryCodeToChoiceCountryCodeMap.keySet())[0];
        Property__c prop = new Property__c(Country__c = firstChoiceCountryCode);
        String chars = PropertyCodeCreation.getFirstTwoCharacters(prop, isoCountryCodeToChoiceCountryCodeMap);

        System.assert(prop.Country__c != chars, 'The property code should be different that the iso code');
    }

    @isTest
    public static void getFirstTwoCharacters_givenNonUSProperty_ShouldReturnCountryISO(){
        Map<String, String> isoCountryCodeToChoiceCountryCodeMap = PropertyCodeCreation.getIsoCountryCodeToChoiceCountryCodeMap();
        Property__c prop = new Property__c(Country__c = 'AF');
        String chars = PropertyCodeCreation.getFirstTwoCharacters(prop, isoCountryCodeToChoiceCountryCodeMap);

        System.assert(prop.Country__c == chars, 'Country codes should match');
    }

    @isTest
    public static void getLast3Characters_givenNonUSProperty_ShouldReturnCountryChar(){
        String chars = PropertyCodeGenUtil.getNextCode('001');
        System.assertEquals('002', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar2(){
        String chars = PropertyCodeGenUtil.getNextCode('089');
        System.assertEquals('090', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar3(){
        String chars = PropertyCodeGenUtil.getNextCode('099');
        System.assertEquals('100', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar4(){
        String chars = PropertyCodeGenUtil.getNextCode('999');
        System.assertEquals('A00', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar5(){
        String chars = PropertyCodeGenUtil.getNextCode('B09');
        System.assertEquals('B10', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar6(){
        String chars = PropertyCodeGenUtil.getNextCode('A99');
        System.assertEquals('B00', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar7(){
        String chars = PropertyCodeGenUtil.getNextCode('Z00');
        System.assertEquals('Z01', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar8(){
        String chars = PropertyCodeGenUtil.getNextCode('B99');
        System.assertEquals('C00', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar9(){
        String chars = PropertyCodeGenUtil.getNextCode('Z99');
        System.assertEquals('0A0', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar10(){
        String chars = PropertyCodeGenUtil.getNextCode('0A0');
        System.assertEquals('0A1', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar11(){
        String chars = PropertyCodeGenUtil.getNextCode('0A9');
        System.assertEquals('1A0', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar12(){
        String chars = PropertyCodeGenUtil.getNextCode('9A9');
        System.assertEquals('0B0', chars);
    }

    // @isTest
    // public static void getLast3Characters_ShouldReturnCountryChar12(){
    //     String chars = PropertyCodeGenUtil.getNextCode('9Z9');
    //     System.assertEquals('AZ0', chars);
    // }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar13(){
        String chars = PropertyCodeGenUtil.getNextCode('9Z9');
        System.assertEquals('00A', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar14(){
        String chars = PropertyCodeGenUtil.getNextCode('00A');
        System.assertEquals('01A', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar15(){
        String chars = PropertyCodeGenUtil.getNextCode('09A');
        System.assertEquals('10A', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar16(){
        String chars = PropertyCodeGenUtil.getNextCode('10A');
        System.assertEquals('11A', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar17(){
        String chars = PropertyCodeGenUtil.getNextCode('19A');
        System.assertEquals('20A', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar18(){
        String chars = PropertyCodeGenUtil.getNextCode('99A');
        System.assertEquals('00B', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar19(){
        String chars = PropertyCodeGenUtil.getNextCode('00B');
        System.assertEquals('01B', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar20(){
        String chars = PropertyCodeGenUtil.getNextCode('99Z');
        System.assertEquals('AA0', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar21(){
        String chars = PropertyCodeGenUtil.getNextCode('AA0');
        System.assertEquals('AA1', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar23(){
        String chars = PropertyCodeGenUtil.getNextCode('AA9');
        System.assertEquals('AB0', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar24(){
        String chars = PropertyCodeGenUtil.getNextCode('AB9');
        System.assertEquals('AC0', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar25(){
        String chars = PropertyCodeGenUtil.getNextCode('AZ9');
        System.assertEquals('BA0', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar26(){
        String chars = PropertyCodeGenUtil.getNextCode('BA0');
        System.assertEquals('BA1', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar27(){
        String chars = PropertyCodeGenUtil.getNextCode('BA9');
        System.assertEquals('BB0', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar28(){
        String chars = PropertyCodeGenUtil.getNextCode('BB9');
        System.assertEquals('BC0', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar29(){
        String chars = PropertyCodeGenUtil.getNextCode('BZ9');
        System.assertEquals('CA0', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar30(){
        String chars = PropertyCodeGenUtil.getNextCode('YZ9');
        System.assertEquals('ZA0', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar31(){
        String chars = PropertyCodeGenUtil.getNextCode('ZZ9');
        System.assertEquals('A0A', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar32(){
        String chars = PropertyCodeGenUtil.getNextCode('0AA');
        System.assertEquals('1AA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar33(){
        String chars = PropertyCodeGenUtil.getNextCode('9AA');
        System.assertEquals('0AB', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar34(){
        String chars = PropertyCodeGenUtil.getNextCode('9AB');
        System.assertEquals('0AC', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar35(){
        String chars = PropertyCodeGenUtil.getNextCode('9AZ');
        System.assertEquals('0BA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar36(){
        String chars = PropertyCodeGenUtil.getNextCode('9BA');
        System.assertEquals('0BB', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar37(){
        String chars = PropertyCodeGenUtil.getNextCode('9BH');
        System.assertEquals('0BJ', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar38(){
        String chars = PropertyCodeGenUtil.getNextCode('9NZ');
        System.assertEquals('0PA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar39(){
        String chars = PropertyCodeGenUtil.getNextCode('9ZZ');
        System.assertEquals('AAA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar40(){
        String chars = PropertyCodeGenUtil.getNextCode('AAA');
        System.assertEquals('AAB', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar41(){
        String chars = PropertyCodeGenUtil.getNextCode('AAZ');
        System.assertEquals('ABA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar42(){
        String chars = PropertyCodeGenUtil.getNextCode('ABZ');
        System.assertEquals('ACA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar43(){
        String chars = PropertyCodeGenUtil.getNextCode('AZZ');
        System.assertEquals('BAA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar44(){
        String chars = PropertyCodeGenUtil.getNextCode('BAA');
        System.assertEquals('BAB', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar45(){
        String chars = PropertyCodeGenUtil.getNextCode('BAZ');
        System.assertEquals('BBA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar46(){
        String chars = PropertyCodeGenUtil.getNextCode('BBZ');
        System.assertEquals('BCA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar47(){
        String chars = PropertyCodeGenUtil.getNextCode('BZZ');
        System.assertEquals('CAA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar48(){
        String chars = PropertyCodeGenUtil.getNextCode('HZZ');
        System.assertEquals('JAA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar49(){
        String chars = PropertyCodeGenUtil.getNextCode('AAZ');
        System.assertEquals('ABA', chars);
    }

    @isTest
    public static void getLast3Characters_ShouldReturnCountryChar50(){
        String chars = PropertyCodeGenUtil.getNextCode('9N9');
        System.assertEquals('0P0', chars);
    }
}