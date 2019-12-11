@isTest
private class PropertyCodeGeneratorControllerTest {
    
    @testSetup
    static void setupData(){
        Property__c property = TestUtil.createProperty('Address Test', 'City Test', '', 'AR', '12345');
        insert property;
        Property_Code_Metadata__c propMTD = TestUtil.createPropertyCodeMetadata('Test', '005', 'AA');
        insert propMTD;
    }

    @isTest 
    static void givenProperty_ShouldReturnDataEnvelope() {
        Property__c property = [SELECT Id, Country__c FROM Property__c LIMIT 1];
        String dataJSON = '';

        Test.startTest();
            dataJSON = PropertyCodeGeneratorController.getDataEnvelope(property.id);
        Test.stopTest();

        PropertyCodeGeneratorController.PropertyCodeEnvelope envelope = 
        (PropertyCodeGeneratorController.PropertyCodeEnvelope) JSON.deserialize(dataJSON, PropertyCodeGeneratorController.PropertyCodeEnvelope.class);


        Property_Code_Metadata__c propCode = [SELECT Id, State_Country_Code__c,Identifier_Code__c FROM Property_Code_Metadata__c LIMIT 1];
        System.assertEquals(envelope.property.Id, property.Id, 'Should be the same property');
        System.assertEquals(envelope.propMtd.Identifier_Code__c,'006', 'Should be incramented by 1 ');
        System.assertEquals(envelope.propMtd.State_Country_Code__c, propCode.State_Country_Code__c, 'Should be the same property code');
        System.assertEquals(envelope.propertiesByAccount.size(), 0, 'Thre should be no other properties by this account');
        System.assertEquals(envelope.propertyCodeMap.size(), 0, 'The map should be empty');
    }

    @isTest 
    static void givenUSProperty_ShouldNotUpdatePropertyCode() {
        Property_Code_Metadata__c propMtd = [SELECT Id,State_Country_Code__c FROM Property_Code_Metadata__c LIMIT 1];
        List<PropertyCodeCountryMapping__mdt > propertyCodeList = new List<PropertyCodeCountryMapping__mdt >();
        Property_Code_Metadata__c updatedMtd = new Property_Code_Metadata__c();
        Test.startTest();
            updatedMtd = PropertyCodeGeneratorController.isCountryInMetadata(propMtd,propertyCodeList,'US');
        Test.stopTest();

        System.assertEquals(updatedMtd.State_Country_Code__c, propMtd.State_Country_Code__c, 
            'The country code should not have been changed');
    }

    @isTest 
    static void givenInvalidProperty_ShouldClearPropertyCode() {
        Property_Code_Metadata__c propMtd = [SELECT Id,State_Country_Code__c FROM Property_Code_Metadata__c LIMIT 1];
        List<PropertyCodeCountryMapping__mdt > propertyCodeList = new List<PropertyCodeCountryMapping__mdt >();
        Property_Code_Metadata__c updatedMtd = new Property_Code_Metadata__c();
        Test.startTest();
            updatedMtd = PropertyCodeGeneratorController.isCountryInMetadata(propMtd,propertyCodeList,'');
        Test.stopTest();

        System.assertEquals(updatedMtd.State_Country_Code__c, '', 'The country code should have been cleared out');
    }

    @isTest 
    static void givenNoBusinessCountry_ShouldClearPropertyCode() {
        Property_Code_Metadata__c propMtd = [SELECT Id,State_Country_Code__c FROM Property_Code_Metadata__c LIMIT 1];
        List<PropertyCodeCountryMapping__mdt > propertyCodeList = [
            SELECT id,Country_ISO_Code__c,Choice_Country_Code__c
            FROM PropertyCodeCountryMapping__mdt
            WHERE Choice_Country_Code__c  = null];

        

        Property_Code_Metadata__c updatedMtd = new Property_Code_Metadata__c();
        Test.startTest();
            updatedMtd = PropertyCodeGeneratorController.isCountryInMetadata(propMtd,propertyCodeList,'ZZ');
        Test.stopTest();

        System.assertEquals(updatedMtd.State_Country_Code__c, '', 'The country code should have been cleared out');
    }


    @isTest 
    static void givenProperties_ShouldCreateMap() {
        List<Property__c> properties = [SELECT Id,Property_Code__c FROM Property__c];

        Map<String,String> propertyCodeMap = new Map<String,String>();
        Test.startTest();
            propertyCodeMap = PropertyCodeGeneratorController.generatePropertyCodeMap(properties);
        Test.stopTest();

        System.assertNotEquals(propertyCodeMap.size(), 0, 'The map should have 1 item in it');
    }


    @isTest 
    static void givenValidCode_ShouldIncramentCode() {
        List<Property__c> properties = [SELECT Id,Property_Code__c FROM Property__c];
        Map<String,String> propertyCodeMap = PropertyCodeGeneratorController.generatePropertyCodeMap(properties);
        System.debug(propertyCodeMap);
        String code='';
        Test.startTest();
            code = PropertyCodeGeneratorController.incramentCode('002',propertyCodeMap,'ZZ');
        Test.stopTest();

        System.assertEquals('003', code, 'The code should be incramented to 003');
    }


    @isTest 
    static void givenTakenCode_ShouldIncramentCode_ForMultipleCombinations() {
        List<Property__c> properties = [SELECT Id,Property_Code__c FROM Property__c];
        Map<String,String> propertyCodeMap = new Map<String,String>();
        propertyCodeMap.put('ZZ002', 'test');

        String code='';
        Test.startTest();
            code = PropertyCodeGeneratorController.incramentCode('001',propertyCodeMap,'ZZ');
            System.assertEquals('003',code , 'The code should be incramented to 003');
            code = PropertyCodeGeneratorController.incramentCode('Z9Z',propertyCodeMap,'ZZ');
            System.assertEquals('0AA',code , 'The code should be incramented to 0AA');
            code = PropertyCodeGeneratorController.incramentCode('0AA',propertyCodeMap,'ZZ');
            System.assertEquals('1AA',code , 'The code should be incramented to 1AA');
            code = PropertyCodeGeneratorController.incramentCode('9AA',propertyCodeMap,'ZZ');
            System.assertEquals('0AB',code , 'The code should be incramented to 0AB');
            code = PropertyCodeGeneratorController.incramentCode('9AH',propertyCodeMap,'ZZ');
            System.assertEquals('0AJ',code , 'The code should be incramented to 0AJ');
            code = PropertyCodeGeneratorController.incramentCode('A9A',propertyCodeMap,'ZZ');
            System.assertEquals('A0B',code , 'The code should be incramented to A0B');
            code = PropertyCodeGeneratorController.incramentCode('A9H',propertyCodeMap,'ZZ');
            System.assertEquals('A0J',code , 'The code should be incramented to A0J');
            code = PropertyCodeGeneratorController.incramentCode('A8A',propertyCodeMap,'ZZ');
            System.assertEquals('A9A',code , 'The code should be incramented to A9A');
            code = PropertyCodeGeneratorController.incramentCode('A9Z',propertyCodeMap,'ZZ');
            System.assertEquals('B0A',code , 'The code should be incramented to B0A');
            code = PropertyCodeGeneratorController.incramentCode('ZZ0',propertyCodeMap,'ZZ');
            System.assertEquals('ZZ1',code , 'The code should be incramented to ZZ1');
            code = PropertyCodeGeneratorController.incramentCode('AZZ',propertyCodeMap,'ZZ');
            System.assertEquals('BAA',code , 'The code should be incramented to BAA');
            code = PropertyCodeGeneratorController.incramentCode('ABZ',propertyCodeMap,'ZZ');
            System.assertEquals('ACA',code , 'The code should be incramented to ACA');
            code = PropertyCodeGeneratorController.incramentCode('ABC',propertyCodeMap,'ZZ');
            System.assertEquals('ABD',code , 'The code should be incramented to ABD');
            code = PropertyCodeGeneratorController.incramentCode('AHZ',propertyCodeMap,'ZZ');
            System.assertEquals('AJA',code , 'The code should be incramented to AJA');
            code = PropertyCodeGeneratorController.incramentCode('ABH',propertyCodeMap,'ZZ');
            System.assertEquals('ABJ',code , 'The code should be incramented to ABJ');
            code = PropertyCodeGeneratorController.incramentCode('08A',propertyCodeMap,'ZZ');
            System.assertEquals('09A',code , 'The code should be incramented to 09A');
            code = PropertyCodeGeneratorController.incramentCode('99H',propertyCodeMap,'ZZ');
            System.assertEquals('00J',code , 'The code should be incramented to 00J');
            code = PropertyCodeGeneratorController.incramentCode('0A9',propertyCodeMap,'ZZ');
            System.assertEquals('1A0',code , 'The code should be incramented to 1A0');
            code = PropertyCodeGeneratorController.incramentCode('A09',propertyCodeMap,'ZZ');
            System.assertEquals('A10',code , 'The code should be incramented to A10');
            code = PropertyCodeGeneratorController.incramentCode('A99',propertyCodeMap,'ZZ');
            System.assertEquals('B00',code , 'The code should be incramented to B00');
            code = PropertyCodeGeneratorController.incramentCode('026',propertyCodeMap,'ZZ');
            System.assertEquals('027',code , 'The code should be incramented to 027');
            code = PropertyCodeGeneratorController.incramentCode('226',propertyCodeMap,'ZZ');
            System.assertEquals('227',code , 'The code should be incramented to 227');
            code = PropertyCodeGeneratorController.incramentCode('ZZZ',propertyCodeMap,'ZZ');
            System.assertEquals(null, code, 'After ZZZ should return null');
        Test.stopTest();
    }


    @isTest 
    static void givenProperty_ShouldReturnLatestCode() {
        Property__c property = [SELECT Id,Property_Code__c,Country__c FROM Property__c LIMIT 1];

        List<Property_Code_Metadata__c> propertyCodes = new List<Property_Code_Metadata__c>();
        Test.startTest();
            propertyCodes = PropertyCodeGeneratorController.getLatestCode(property);
        Test.stopTest();

        System.assertEquals('006',propertyCodes[0].Identifier_Code__c, 'The code should be incramented to 003');
    }


    @isTest 
    static void givenAutoCode_ShouldUpdateProperty() {
        Property__c property = [SELECT Id,Property_Code__c,Country__c FROM Property__c LIMIT 1];
        Property_Code_Metadata__c propCode = [SELECT Id, State_Country_Code__c,Identifier_Code__c FROM Property_Code_Metadata__c LIMIT 1];
        property.Property_Code__c = 'ZZZ';
        propCode.Identifier_Code__c = 'ZZZ';
        
        String propertyJSON = JSON.serialize(property);
        String propMtdJson = JSON.serialize(propCode);
        Test.startTest();
            PropertyCodeGeneratorController.saveAutoGenCode(propertyJSON,propMtdJson);
        Test.stopTest();

        Property__c updatedProperty = [SELECT Id,Property_Code__c,Country__c FROM Property__c LIMIT 1];
        Property_Code_Metadata__c updatedPropCode = [SELECT Id, State_Country_Code__c,Identifier_Code__c FROM Property_Code_Metadata__c LIMIT 1];

        System.assertEquals('ZZZ',updatedProperty.Property_Code__c, 'The field should be updated to ZZZ');
        System.assertEquals('ZZZ',updatedPropCode.Identifier_Code__c, 'The field should be updated to ZZZ');
    }

    @isTest 
    static void givenManualCode_ShouldUpdateProperty() {
        Property__c property = [SELECT Id,Property_Code__c,Country__c FROM Property__c LIMIT 1];
        Property_Code_Metadata__c propCode = [SELECT Id, State_Country_Code__c,Identifier_Code__c FROM Property_Code_Metadata__c LIMIT 1];
        property.Property_Code__c = 'ZZZ';
        propCode.Identifier_Code__c = 'ZZZ';
        
        String propertyJSON = JSON.serialize(property);
        Test.startTest();
            PropertyCodeGeneratorController.saveManualCode(propertyJSON);
        Test.stopTest();

        Property__c updatedProperty = [SELECT Id,Property_Code__c,Country__c FROM Property__c LIMIT 1];

        System.assertEquals('ZZZ',updatedProperty.Property_Code__c, 'The field should be updated to ZZZ');
    }
    
}