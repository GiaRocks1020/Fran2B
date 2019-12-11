@isTest
public class ApplicationHelperTest {

    @isTest
    public static void getExpiredAppsWithStartDateRenewed_givenRenewedStartDate_shouldReturnApplication(){
        List<Application__c> appList = new List<Application__c>();
        Map<Id, Application__c> appMap = new Map<Id, Application__c>();
        Application__c oldApp = new Application__c(
            Status__c = ApplicationHelper.EXPIRED_STATUS,
            Application_Start_Date__c = Date.Today().addDays(-5)
        );

        insert oldApp;

        appMap.put(oldApp.Id, oldApp);

        Application__c newApp = oldApp.clone(true, true, true, true);
        newApp.Application_Start_Date__c = Date.Today().addDays(5);

        appList.add(newApp);

        List<Application__c> testAppList = new List<Application__c>();

        Test.startTest();
            testAppList = ApplicationHelper.getExpiredAppsWithStartDateRenewed(appList,appMap);
        Test.stopTest();

        System.assertEquals(1, testApplist.size(), 'One application should have been returned');

    }

    @isTest
    public static void changeStatusToInProgressAndActivateUsers_givenAppThatisNotInProgress_ShouldChangeToInProgress(){
        List<Application__c> appList = new List<Application__c>();
        Application__c app = new Application__c(
            Status__c = ApplicationHelper.EXPIRED_STATUS,
            Application_Start_Date__c = Date.Today().addDays(-5)
        );

        appList.add(app);

        Test.startTest();
            ApplicationHelper.changeStatusToInProgressAndActivateUsers(appList);
        Test.stopTest();

        System.assertEquals(ApplicationHelper.IN_PROGRESS_STATUS, appList[0].Status__c, 'Application status should match');
    }

}