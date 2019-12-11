@isTest
public with sharing class LeadConvertPropertyListControllerTest {
    @isTest
     public static void getProperties_givenValidLead_shouldReturnValidString(){
        Property__c prop = TestUtil.createProperty('123 ABC', 'Rockville', 'US-MD', 'US', '55555');
        insert prop;

        List<Lead> ls = TestUtil.createLead('Bob','Smith','Testing Account','Test','Associate/AD Referral',1,'CS;AC;CI;EL;RW;SL','MD','US');
        Lead l = ls[0];

        l.Phone = '3333333333';
        l.Email = 'bobtest@test.com';
        l.Street = '123 ABC';
        l.City = 'Rockville';
        l.State = 'Maryland';
        l.Country = 'United States';
        l.PostalCode = '55555';

        insert l;     

        String propetiesString;
        Test.startTest();
              propetiesString = LeadConvertPropertyListController.getProperties(l);
        Test.stopTest();

        System.assert(propetiesString.contains('Property'), 'Method should return a string with properties');
    }

    @isTest
    public static void getLeadConvertPropertyFields_shouldReturnRecords(){
        List<Lead_Convert_Property_Fields_Metadata__mdt> metadata = new List<Lead_Convert_Property_Fields_Metadata__mdt>();
        Test.startTest();    
            metadata = LeadConvertPropertyListController.getLeadConvertPropertyFields();
        Test.stopTest();

        System.assert(metadata.size() > 0, 'Metadata should have been returned');
    }
}