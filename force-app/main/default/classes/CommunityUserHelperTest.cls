@isTest
public with sharing class CommunityUserHelperTest {

    @isTest
    public static void createCommunityUser_givenContact_shouldReturnUser(){
        Profile pf = [Select Id, Name from Profile where name = :ApplicationCreator.CHOICE_COMMUNITY_PROFILE limit 1];

        Contact c = TestUtil.createContact('Test', 'LongTesterName', '3333333', 'longTesterNameForEmailAddress@test.com');
        User usr;
        Test.startTest();
            usr = CommunityUserHelper.getNewCommunityUser(c,pf.Id);
        Test.stopTest();

        System.assert(usr != null, 'User should have been returned');


    }
}