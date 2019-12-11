@isTest
public class TestUtil {

   static Integer s_num = 1;

   public static String getFakeId(Schema.SObjectType sot)
   {
      String result = String.valueOf(s_num++);
      return sot.getDescribe().getKeyPrefix() + 
         '0'.repeat(12-result.length()) + result;
   }

    public static Lead createLead(String firstName, String lastName, String company, String applicationType, String source){
        return new Lead(
            Company = company,
            LastName = lastName,
            FirstName = firstName,
            Application_Type__c = applicationType,
            LeadSource = source,
            OwnerId = UserInfo.getUserId(),
            Phone = '1234567890',
            Current_Hotel_Name__c = 'test',
            Referral_Name__c = 'referer',
            Referral_Name_Email__c = 'test@test.com',
            Email = 'tester@test.com'
        );
    }

    public static User createUser(String profileName, String lastName, String alias, String email, String userName, String nickName){
        return new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
            LastName = lastName,
            Alias = alias,
            Email = email,
            UserName = userName,
            CommunityNickname = nickName,
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
    }

    public static User createUser(String profileName, String LastName){
        return new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
            LastName = LastName,
            Alias = 'testerr',
            Email = 'test@test.com',
            UserName = createRandomUserName(),
            CommunityNickname = 'test_terr',
            EmployeeNumber = 'ABC123',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
    }

    public static List<Lead> createLead(String firstName, String lastName, String company, String applicationType, String source, Integer numberOfLeads,string ChoiceBrandOfInterest,String stateCode,String countryCode){
        List<Lead> leads = new List<Lead>();

        for(Integer i = 0; i < numberOfLeads; i++){
            leads.add(new Lead(
            Company = company + i,
            LastName = lastName,
            FirstName = firstName + i,
            Application_Type__c = applicationType,
            Choice_Brand_of_Interest__c = ChoiceBrandOfInterest,
            LeadSource = source,
            OwnerId = UserInfo.getUserId(),
            Phone = '1234567890',
            Current_Hotel_Name__c = 'test' + i,
            Referral_Name__c = 'referer' + i,
            Referral_Name_Email__c = 'test@test' + i + '.com',
            stateCode = stateCode,
            CountryCode = countryCode,
            Email = 'tester' + i + '@test.com'
        ));
        }
    return leads;
    }

    public static Contact createContact(String firstName, String lastName, String phone, String email){
        return new Contact(
            FirstName = firstName,
            LastName = lastName,
            Phone = phone,
            Email = email,
            MailingCity = 'Rockville',
            MailingState = 'Maryland',
            MailingCountry = 'United States'
        );

    }

    public static Account createAccount(String name, String street, String city, String state, String country){
        return new Account(
            Name = name,
            BillingStreet = street,
            BillingCity = city,
            BillingState = state,
            BillingCountry = country
            );
    }

    public static Account createAccount(String name){
        return new Account(
            Name = name,
            BillingStreet = '123 ABC',
            BillingCity = 'test city',
            BillingState = 'Maryland',
            BillingCountry = 'United States'
            );
    }

    public static Approver__c createApprover(String brand, String country, String state){
        return new Approver__c(
            Brand__c = brand,
            State__c = state,
            Country__c = country
        );
    }

    public static Property__c createProperty(String address, String city, String state, String country, String postalCode){
        return new Property__c(
            Address_Line_1__c = address,
            City__c = city,
            State_Province__c = state,
            Country__c = country,
            Zip_Code__c = postalCode,
            Number_of_Rooms__c = 4
        );
    }

    public static Opportunity createOpportunity(String name, String stage, Id accountId, Id propertyId){
        return new Opportunity(
            Name = name,
            StageName = stage,
            AccountId = accountId,
            Property__c = propertyId,
            CloseDate = Date.Today()
        );
    }

    private static String createRandomUserName(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;

        return uniqueName + '@test' + orgId + '.org';
    }

    public static Property_Code_Metadata__c createPropertyCodeMetadata(String name,String isoCode, String countryCode){
        return new Property_Code_Metadata__c(
            State_Country_Code__c = countryCode,
            Identifier_Code__c = isoCode,
            name = name

        );

    }

    }