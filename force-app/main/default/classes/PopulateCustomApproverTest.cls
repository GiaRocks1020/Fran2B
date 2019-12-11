@isTest
public class PopulateCustomApproverTest {
    @isTest
    static void updateOppCustomApprover_givenValidNewData_ShouldPopulateCustomApprover(){
        Property__c prop = TestUtil.createProperty('Test Street', 'Rockville', 'US-MD', 'US', '22032');
        insert prop;

        Account acc = testUtil.createAccount('Test acc', 'Test Street', 'Rockville', 'Maryland', 'United States');
        insert acc;

        User u = TestUtil.createUser('System Administrator', 'Manager');
        insert u;

        User u2 = TestUtil.createUser('System Administrator', 'Tester', 'TestAl', 'test@test2.com', 'TestUserName@ChoiceTest.com', 'Testee');
        u2.Manager = u;
        insert u2;

        System.runAs(u2){
            Approver__c approver = TestUtil.createApprover('CI', 'US', 'US-MD');
            insert approver;
        }

        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Deal Working', acc.Id, prop.Id);
        opp.Brand__c = 'CI';
        Test.startTest();
            insert opp;
        Test.stopTest();

        Opportunity updatedOpp = [SELECT CustomApprover__c FROM Opportunity WHERE Id = :opp.Id];

        System.assert(updatedOpp != null);
    }

    @isTest
    static void updateOppCustomApprover_givenValidUpdatedData_ShouldPopulateCustomApprover(){
        Property__c prop = TestUtil.createProperty('Test Street', 'Rockville', 'US-MD', 'US', '22032');
        insert prop;

        Account acc = testUtil.createAccount('Test acc', 'Test Street', 'Rockville', 'Maryland', 'United States');
        insert acc;

        User u = TestUtil.createUser('System Administrator', 'Manager');
        insert u;

        User u2 = TestUtil.createUser('System Administrator', 'Tester', 'TestAl', 'test@test2.com', 'TestUserName@ChoiceTest.com', 'Testee');
        u2.Manager = u;
        insert u2;

        System.runAs(u2){
            Approver__c approver = TestUtil.createApprover('CI', 'US', 'US-MD');
            insert approver;
        }

        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Deal Working', acc.Id, prop.Id);
        insert opp;

        Opportunity opp2 = TestUtil.createOpportunity('Test Opp2', 'Deal Working', acc.Id, prop.Id);
        insert opp2;

        Contact c = TestUtil.createContact('Test', 'Tester', '222-222-2222', 'emailhere@test.com');
        insert c;

        opp.Brand__c = 'CI';
        opp.StageName = System.Label.Opportunity_Status_for_Populating_Custom_Approver;
        opp.Licensee_Name__c = c.Id;
        opp.Number_of_Floors__c = 2;
        opp.Number_of_Rooms__c = 2;
        opp.Product__c = 'Lodge';
        opp.Corridor__c = 'Both';
        opp.Former_Affiliation__c = '3 Palms';
        opp.Application_Type__c = 'New Construction';
        opp.Hotel_Summary__c = 'test';
        opp.Market_Summary__c = 'test';
        opp.Sponsor_Summary__c = 'test';
        opp.Deal_Term_Summary__c = 'test';
        opp.LeadSource = 'Development Marketing';
        opp.Site_Type__c = 'New Construction';
        opp.Site_Control_Status__c = 'Currently Owns';
        opp.Anticipated_Ground_Break_Date__c = Date.Today();
        opp.Anticipated_Opening_Date__c = Date.Today();
        opp.Current_Market_OCC__c = 2;
        opp.Current_Market_ADR__c = 2;
        opp.Replacement_Property__c = prop.Id;
        opp.Anticipated_Objections_Impact_Issues__c = 'test';
        //opp.Affiliation_Fee__c = 2;
        opp.Contract_Length__c = '2';
        opp.Contract_Windows__c = '2';
        opp.Fee_Discounts__c = '2';
        opp.Deal_Incentive__c = 'Not Applicable';
        opp.Amount = 2;
        opp.Num_of_Months_to_Start_Construction__c = 2;
        opp.Num_of_Months_to_Complete_Construction__c = 3;
        opp.Replacement_Opportunity__c = 'No';


        Test.startTest();
            update opp;
        Test.stopTest();



        Opportunity updatedOpp = [SELECT CustomApprover__c FROM Opportunity WHERE Id = :opp.Id];

        System.assert(updatedOpp != null);
    }
}