@isTest
public class ApplicationCreatorTest {

    @testSetup
    static void setup(){
        User runningUser = TestUtil.createUser('System Administrator', 'runningUser', 'rUser', 'runningUserEmail@test.com', 'runningUser@choice.com', 'runUsr');
        runningUser.UserRoleId = [SELECT Id, Name from UserRole WHERE Name = 'Sr. VP, Global Development' LIMIT 1].Id;

        insert runningUser;



        System.runAs(runningUser){

            Id p = [select id from profile where name = :ApplicationCreator.CHOICE_COMMUNITY_PROFILE].Id;
        
            Account ac = TestUtil.createAccount('Test Acc');
            insert ac; 
        
            Contact con = TestUtil.createContact('fName', 'testCon', '0987654321', 'hotelChoiceUser@choicehotels.com');
            con.AccountId = ac.Id;
            insert con;  
                    
            User user = new User(
                    isActive = false,
                    ProfileId = p,
                    ContactId = con.Id,
                    LastName = con.LastName,
                    Username = con.Email + '.franchisedevelopment',
                    Email = con.Email,
                    CommunityNickname = 'choiceNickname',
                    Alias = 'test321',
                    TimeZoneSidKey = 'America/Phoenix', //required
                    LocaleSidKey = 'en_US', //required
                    EmailEncodingKey = 'ISO-8859-1', //required
                    LanguageLocaleKey = 'en_US' //required 
                    );

            
            insert user;
        }
    }

    @isTest
    static void getOpportunitiesThatNeedApplications_givenSendApplicationChanged_returnsOpps(){
        List<Opportunity> newOppList = new  List<Opportunity>();
        Map<Id,Opportunity> oldOppMap = new Map<Id,Opportunity>();

        Opportunity opp = new Opportunity(Id = TestUtil.getFakeId(Opportunity.SOBjectType), Name = 'test opp', Send_Application__c = false);
        oldOppMap.put(opp.Id, opp);

        Opportunity newOpp = opp.clone(true,true, true, true);
        newOpp.Send_Application__c = true;

        newOppList.add(newOpp);

        List<Opportunity> oppsReturned = new List<Opportunity>();
        Test.startTest();
        oppsReturned = ApplicationCreator.getOpportunitiesThatNeedApplications(newOppList, oldOppMap);
        Test.stopTest();

        System.assert(oppsReturned.size() > 0, 'An opportunity should have been returned');
    }

    @isTest
    static void createApplicationData_givenInactiveUser_ShouldReactiveUserAndCreateApplication(){
        Contact con = [SELECT Id, Email From Contact WHERE LastName = 'testCon' limit 1];
        Opportunity opp = new Opportunity(Name = 'test opp' , Applicant__c = con.Id, StageName = ApplicationCreator.DEAL_WORKING_STAGE);

        List<Opportunity> opps = new List<Opportunity>();
        opps.add(opp);


        Test.startTest();
            ApplicationCreator.createApplicationData(opps);
        Test.stopTest();

        List<User> u = [SELECT Id, IsActive FROM User WHERE Email = :con.Email AND IsActive = true];
        List<Application__c> app = [SELECT Id FROM Application__c WHERE OwnerId = :u[0].Id];

        System.assert(u.size() > 0, 'Expected active User');
        System.assert(app.size() > 0, 'Expected an application');
    }

    @isTest
    static void createApplicationData_givenNoPortalUser_ShouldCreateUserAndCreateApplication(){
        User runningUser = [SELECT Id FROM User WHERE LastName = 'runningUser' limit 1];
        System.runAs(runningUser){
            Account ac = TestUtil.createAccount('Test Account');
            insert ac;

            Contact con = TestUtil.createContact('Portal Test', 'Contact' , '1234567890', 'portaltestcontact@choice.com');
            con.AccountId = ac.Id;
            insert con;

            Opportunity opp = new Opportunity(Name = 'test opp' , Applicant__c = con.Id, StageName = ApplicationCreator.DEAL_WORKING_STAGE);

            List<Opportunity> opps = new List<Opportunity>();
            opps.add(opp);

            Test.startTest();
                    ApplicationCreator.createApplicationData(opps);
            Test.stopTest();

            List<User> u = [SELECT Id, IsActive FROM User WHERE Email = :con.Email AND IsActive = true];
            List<Application__c> app = [SELECT Id FROM Application__c WHERE OwnerId = :u[0].Id];

            System.assert(u.size() > 0, 'Expected active User');
            System.assert(app.size() > 0, 'Expected an application');
        }
    }

}