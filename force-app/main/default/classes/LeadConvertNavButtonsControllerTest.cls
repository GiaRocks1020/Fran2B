@isTest
public class LeadConvertNavButtonsControllerTest {
    @testSetup
    public static void setup(){
        Lead l = TestUtil.createLead('Test', 'Tester', 'Test Company', 'Choice Repositioning', 'Associate/AD Referral');
        l.Corporate_Address__c = '123 ABC';
        l.Corporate_City__c = 'Rockville';
        l.Corporate_Country__c = 'US';
        l.Corporate_State_Province__c = 'US-MD';
        l.Corporate_Zip_Postal_Code__c ='20854';
        l.Street = 'Test Street';
        l.City = 'Test';
        l.State = 'Arizona';
        l.Country = 'United States';
        l.PostalCode = '44444';
        l.status = 'In Progress';

        insert l;

        Contact c = TestUtil.createContact('Bob', 'Smith', '222-222-2222', 'testbobsmith@test.com');
        insert c;

        Account acc = TestUtil.createAccount('Test Account', 'Test Street', 'City', 'Alaska', 'United States');
        insert acc;

        Property__c prop = TestUtil.createProperty('Prop Address', 'Prop City', 'US-VA', 'US', '55555');
        insert prop;
    }

    @isTest
    public static void leadConversionStep2_givenNullContactAndAccount(){
        List<String> returnedString = new List<String>();
        Lead l = getLead();

        Test.startTest();
            returnedString = LeadConvertNavButtonsController.leadConversionStep2(l, null, null);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Id = :returnedString[0]];
        System.assert(accounts.size() > 0, 'An account should have been created');
    }

    @isTest
    public static void leadConversionStep2_givenContactAndAccount(){
        List<String> returnedString = new List<String>();
        Lead l = getLead();

        Contact c = [SELECT Id, Name, Phone FROM Contact WHERE Email = 'testbobsmith@test.com' LIMIT 1];

        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Test.startTest();
            returnedString = LeadConvertNavButtonsController.leadConversionStep2(l, (String) c.Id, (String) acc.Id);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, BillingState FROM Account WHERE Id = :returnedString[0]];
        System.assert(accounts.size() > 0, 'An account should have been created');
    }

    @isTest
    public static void leadConversionStep3_givenAll(){
        List<String> returnedString = new List<String>();

        Lead l = getLead();
            
        Contact c = [SELECT Id, Name, Phone FROM Contact WHERE Email = 'testbobsmith@test.com' LIMIT 1];

        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Property__c prop = [SELECT Id, Address_Line_1__c,City__c, State_Province__c, Country__c, Zip_Code__c 
                            FROM Property__c WHERE Address_Line_1__c = 'Prop Address' LIMIT 1];

        Test.startTest();
            returnedString = LeadConvertNavButtonsController.leadConversionStep3(l, (String) c.Id, (String) acc.Id, (String) prop.Id, true);
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Id = :returnedString[0]];

        System.assert(opps.size() > 0, 'A deal should have been created');
    }

    private static Lead getLead(){
        String fieldsToQuery = 'Id,';
         for(String field : FranchiseSalesUtilities.getSobjectFields('Lead')){
             fieldsToQuery += field + ', ';
        }
        fieldsToQuery = fieldsToQuery.removeEnd(', ');
        return Database.query('SELECT ' + fieldsToQuery + ' FROM Lead WHERE Name = \'Test Tester\' LIMIT 1');
    }
}