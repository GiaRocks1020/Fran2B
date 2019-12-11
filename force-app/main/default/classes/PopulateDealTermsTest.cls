@isTest
public class PopulateDealTermsTest {
    @isTest
    public static void getOpportunitiesThatNeedDealTermsUpdated_givenNewOppThatNeedsDealTermsUpdated_shouldReturnDealTerm(){
        List<Opportunity> opportunityList = new List<Opportunity>();

        Opportunity opp = new Opportunity(
                                Id = TestUtil.getFakeId(Opportunity.SObjectType),
                                Name = 'Test Opp',
                                StageName = System.Label.Opportunity_Status_for_Populating_Deal_Terms);
        System.debug(opp);
        opportunityList.add(opp);


        List<Opportunity> testOpps = new List<Opportunity>();
        Test.startTest();
            testOpps = PopulateDealTerms.getOpportunitiesThatNeedDealTermsUpdated(opportunityList, new Map<Id, Opportunity>());
        Test.stopTest();

        System.assert(testOpps.size() > 0, 'An Opportunity should have been returned');
    }

    @isTest
    public static void getOpportunitiesThatNeedDealTermsUpdated_givenUpdatedOppThatNeedsDealTermsUpdated_shouldReturnDealTerm(){
        List<Opportunity> opportunityList = new List<Opportunity>();
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>();

        Opportunity opp = new Opportunity(
                                Id = TestUtil.getFakeId(Opportunity.SObjectType),
                                Name = 'Test Opp',
                                StageName = null);

        oppsMap.put(opp.Id, opp);

        Opportunity opp2 = opp.clone(true,true,true,true);
        opp2.StageName = System.Label.Opportunity_Status_for_Populating_Deal_Terms;
        opportunityList.add(opp2);

        List<Opportunity> testOpps = new List<Opportunity>();
        Test.startTest();
            testOpps = PopulateDealTerms.getOpportunitiesThatNeedDealTermsUpdated(opportunityList, oppsMap);
        Test.stopTest();

        System.assert(testOpps.size() > 0, 'An Opportunity should have been returned');
    }

    @isTest
    public static void populateTerms_givenCorrectData_ShouldInsertAllObjects(){
        List<Standard_Terms__c> termsToInsert = new List<Standard_Terms__c>();
        Final String BRAND = 'BR';
        List<Opportunity> opps = new List<Opportunity>();

        Id waiverId = FranchiseSalesUtilities.getRecordTypeById(new Standard_Terms__c(), PopulateDealTerms.WAIVER_TERM_TYPE);
        Id feeId = FranchiseSalesUtilities.getRecordTypeById(new Standard_Terms__c(), PopulateDealTerms.FEE_TERM_TYPE);
        Id outDateId = FranchiseSalesUtilities.getRecordTypeById(new Standard_Terms__c(), PopulateDealTerms.OUT_DATE_TERM_TYPE);

        Opportunity opp = new Opportunity(Brand__c = BRAND,
                                            Name = 'test',
                                            CloseDate = Date.Today(),
                                            StageName = 'Deal Working',
                                            Product__c = 'AS');

        List<FranchiseSalesUtilities.Picklist> plst = FranchiseSalesUtilities.getPicklistValues(opp, 'Liquidated_Damages_Discount__c');

        opp.Liquidated_Damages_Discount__c = plst[0].value;

        Standard_Terms__c feeTerm = new Standard_Terms__c(
                                        RecordTypeId = feeId,
                                        Brand__c = BRAND,
                                        Status__c = 'Active');
                                        termsToInsert.add(feeTerm);

        Standard_Terms__c waveTerm = new Standard_Terms__c(
                                        RecordTypeId = waiverId,
                                        Brand__c = BRAND,
                                        Status__c = 'Active');
                                        termsToInsert.add(waveTerm);

        Standard_Terms__c suiteWaveTerm = new Standard_Terms__c(
                                        RecordTypeId = waiverId,
                                        Status__c = 'Active',
                                        Code__c = 'SUITE');
                                        termsToInsert.add(suiteWaveTerm);

        Standard_Terms__c dealTermsToWaiver = new Standard_Terms__c(
                                        RecordTypeId = waiverId,
                                        Status__c = 'Active',
                                        Deal_Terms_to_Waiver__c = plst[0].value);
                                        termsToInsert.add(dealTermsToWaiver);

        Standard_Terms__c dateTerm = new Standard_Terms__c(
                                        RecordTypeId = outDateId,
                                        Brand__c = BRAND,
                                        Status__c = 'Active');
                                        termsToInsert.add(dateTerm);

        insert termsToInsert;

        insert opp;

        opps.add(opp);

        Test.startTest();
            PopulateDealTerms.populateTerms(opps);
        Test.stopTest();

        List<Waivers__c> waivers = [SELECT Id FROM Waivers__c];
        System.assert(waivers.size() == 3, 'Expecting 3 waviers to get created, actual ' + waivers.size());
        
        List<Fees__c> fees = [SELECT Id FROM Fees__c];
        System.assert(fees.size() == 1, 'Expecting 1 fee to get created');

        List<Out_Dates__c> outDates = [SELECT Id FROM Out_Dates__c];
        System.assert(outDates.size() == 1, 'Expecting 1 out date to get created');
        
    }
}