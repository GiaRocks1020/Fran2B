@isTest
public class LeadConvertAccountListControllerTest {
    @isTest
    public static void getAccountsFromContactId_givenValidId_shouldReturnAccounts(){
        Account a = TestUtil.createAccount('Testing Account' , '123 ABC', 'Rockville', 'Maryland', 'United States');
        insert a;

        Contact c = TestUtil.createContact('Bob', 'Smith', '3333333333', 'bobtest@test.com');
        c.AccountId = a.Id;
        insert c;

        List<Account> accountList = new List<Account>();
        Test.startTest();
             accountList = LeadConvertAccountListController.getAccountsFromContactId(c.Id);
        Test.stopTest();

        System.assert(accountList.size() > 0, 'Accounts should have been returned');
    }

    @isTest
    public static void getAccountsFromContactId_givenNoMatchingContacts_shouldReturnNoAccounts(){

        Contact c = TestUtil.createContact('Bob', 'Smith', '3333333333', 'bobtest@test.com');
        insert c;

        List<Account> accountList = new List<Account>();
        Test.startTest();
             accountList = LeadConvertAccountListController.getAccountsFromContactId(c.Id);
        Test.stopTest();

        System.assert(accountList.size() == 0, 'Accounts should have been returned');
    }

    @isTest
    public static void getLeadConvertAccountFields_shouldReturnRecords(){
        List<Lead_Convert_Account_Fields_Metadata__mdt> metadata = new List<Lead_Convert_Account_Fields_Metadata__mdt>();
        Test.startTest();    
            metadata = LeadConvertAccountListController.getLeadConvertAccountFields();
        Test.stopTest();

        System.assert(metadata.size() > 0, 'Metadata should have been returned');
    }

    @isTest
    public static void getAccountsRelatedToLead_givenValidLead_shouldReturnValidString(){
        List<Lead> ls = TestUtil.createLead('Bob','Smith','Testing Account','Test','Associate/AD Referral',1,'CS;AC;CI;EL;RW;SL','MD','US');
        Lead l = ls[0];

        l.Street = '123 ABC';
        l.City = 'Rockville';
        l.State = 'MaryLand';
        l.Country = 'United States';

        insert l;

        Account a = TestUtil.createAccount('Testing Account' , '123 ABC', 'Rockville', 'Maryland', 'United States');
        insert a;        

        String accountsString;
        Test.startTest();
             accountsString = LeadConvertAccountListController.getAccountsRelatedToLead(l);
        Test.stopTest();

        System.assert(accountsString.contains('Account'), 'Method should return a string with accounts');
    }
}