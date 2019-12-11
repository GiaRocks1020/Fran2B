@isTest
public class LeadConvertUtilitiesTest {
    @isTest
    public static void sortRecordsBasedonMatchScore_givenAllMatches_shouldReturnList(){
        List<Lead> ls = TestUtil.createLead('Bob','Smith','Testing Account','Test','Associate/AD Referral',1,'CS;AC;CI;EL;RW;SL','MD','US');
        Lead l = ls[0];

        l.Street = '123 ABC';
        l.City = 'Rockville';
        l.State = 'Maryland';
        l.Country = 'United States';

        insert l;

        Account a = TestUtil.createAccount('Testing Account' , '123 ABC', 'Rockville', 'Maryland', 'United States');
        insert a;

        String queryString = LeadConvertUtilities.getSobjectQuery('Account', l);
        
        List<Account> accounts = Database.query(queryString);

        List<LeadConvertUtilities.SobjectMatchScore> returnedAccountsWrapper;
        Test.startTest();
        returnedAccountsWrapper = LeadConvertUtilities.sortRecordsBasedonMatchScore(accounts, l);
        Test.stopTest();

        System.assert(returnedAccountsWrapper.size() > 0, 'List size should be greater than 1');
    }

    @isTest
    public static void sortRecordsBasedonMatchScore_givenPartialMatchesAbove50_shouldReturnList(){
        Contact c = TestUtil.createContact('Bobby', 'Smith', '3333333333', 'bobtest@test.com');
        insert c;
        List<Lead> ls = TestUtil.createLead('Bob','Smith','Testing Account','Test','Associate/AD Referral',1,'CS;AC;CI;EL;RW;SL','MD','US');
        Lead l = ls[0];

        l.Phone = '3333333333';
        l.Email = 'test@test.com';
        insert l;     

        String queryString = LeadConvertUtilities.getSobjectQuery('Contact', l);
        
        List<Contact> contacts = Database.query(queryString);

        List<LeadConvertUtilities.SobjectMatchScore> returnedContactsWrapper;
        Test.startTest();
        returnedContactsWrapper = LeadConvertUtilities.sortRecordsBasedonMatchScore(contacts, l);
        Test.stopTest();

        System.assert(returnedContactsWrapper.size() > 0, 'List size should be greater than 1');
    }
}