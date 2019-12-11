@isTest
public class LeadConvertContactListControllerTest {
    @isTest
    public static void getContacts_givenValidLead_shouldReturnValidString(){
        Contact c = TestUtil.createContact('Bob', 'Smith', '3333333333', 'bobtest@test.com');
        insert c;
        List<Lead> ls = TestUtil.createLead('Bob','Smith','Testing Account','Test','Associate/AD Referral',1,'CS;AC;CI;EL;RW;SL','MD','US');
        Lead l = ls[0];

        l.Phone = '3333333333';
        l.Email = 'bobtest@test.com';
        insert l;     

        String contactsString;
        Test.startTest();
             contactsString = LeadConvertContactListController.getContacts(l);
        Test.stopTest();

        System.assert(contactsString.contains('Contact'), 'Method should return a string with contacts');
    }

    @isTest
    public static void getLeadConvertContactFields_shouldReturnRecords(){
        List<Lead_Convert_Contact_Fields_Metadata__mdt> metadata = new List<Lead_Convert_Contact_Fields_Metadata__mdt>();
        Test.startTest();    
            metadata = LeadConvertContactListController.getLeadConvertContactFields();
        Test.stopTest();

        System.assert(metadata.size() > 0, 'Metadata should have been returned');
    }
}