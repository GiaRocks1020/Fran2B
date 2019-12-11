@isTest
public class CustomMetadataDATest {
    @isTest
    static void getBrandRankings_shouldReturnRecords(){
        List<Brand_Ranking__mdt> br;
        Test.startTest();
            br = CustomMetadataDA.getBrandRankings();
        Test.stopTest();

        System.assert(br.size() > 0, 'Records should have been returned');
    }

    @isTest
    static void getLeadAssignments_shouldReturnRecords(){
        List<Lead_Assignment_Mapping__mdt> lam;
        Test.startTest();
            lam = CustomMetadataDA.getLeadAssignments();
        Test.stopTest();

        System.assert(lam.size() > 0, 'Records should have been returned');
    }

    @isTest
    static void getLeadSourcesForRouting_shouldReturnRecords(){
        List<Lead_Source_for_Routing__mdt> lsr;
        Test.startTest();
            lsr = CustomMetadataDA.getLeadSourcesForRouting();
        Test.stopTest();

        System.assert(lsr.size() > 0, 'Records should have been returned');
    }
}