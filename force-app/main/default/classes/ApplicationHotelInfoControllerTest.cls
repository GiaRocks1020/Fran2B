@isTest
public with sharing class ApplicationHotelInfoControllerTest {
    @isTest
    public static void populateStartDate_givenValidString_shouldPopulateStartDate(){
        Application__c app = new Application__c(Application_Start_Date__c = null);

        insert app;

        String str = JSON.serialize(app);

        Test.startTest();
            ApplicationHotelInfoController.populateStartDate(str);
        Test.stopTest();

        Application__c updatedApp = [SELECT Id, Application_Start_Date__c FROM Application__c WHERE Id = :app.Id LIMIT 1];

        System.assertEquals(Date.Today(), updatedApp.Application_Start_Date__c);
    }

    @isTest
    public static void createPrivateFiles_givenValidAppId_shouldReturnPrivateFilesList(){
        String mockId = TestUtil.getFakeId(Application__c.SOBjectType);
        List<Private_Files__c> privateFiles = new List<Private_Files__c>();

        Application__c app = new Application__c(Id = mockId);
        String appStr = JSON.serialize(app);

        Test.startTest();
            privateFiles = ApplicationHotelInfoController.createPrivateFiles(appStr);
        Test.stopTest();

        System.assert(privateFiles.size() > 0, 'A list of private files should be returned');

        for(Private_Files__c file : privateFiles){
            System.assert(file.Application__c == mockId, 'Ids should match');
            System.assert(!String.isEmpty(file.Uploaded_Location__c), 'Uploaded location should be populated');
        }
    }

    @isTest
    public static void handleFirstTime_givenValidAppString_shouldReturnIdToPrivateFileMap(){
        Application__c app = new Application__c();
        insert app;

        String appStr = JSON.serialize(app);

        Map<String,Private_Files__c> idToPrivateFile = new Map<String,Private_Files__c>();

        Test.startTest();
            idToPrivateFile = ApplicationHotelInfoController.handleFirstTime(appStr);
        Test.stopTest();

        System.assert(idToPrivateFile.size() > 0, 'Expected map values to be populated');
    }

    @isTest
    public static void getPrivateFiles_givenValidAppString_shouldReturnIdToPrivateFileMap(){
        Application__c app = new Application__c();
        insert app;

        List<Private_Files__c> newPrivateFiles  = new List<Private_Files__c>();

        newPrivateFiles.add(new Private_Files__c(
				Uploaded_Location__c = Private_Files__c.Uploaded_Location__c.getDescribe().getPicklistValues()[0].getValue(),
				Application__c = app.id
				));

        newPrivateFiles.add(new Private_Files__c(
				Uploaded_Location__c = Private_Files__c.Uploaded_Location__c.getDescribe().getPicklistValues()[1].getValue(),
				Application__c = app.id
				));

        insert newPrivateFiles;

        String appStr = JSON.serialize(app);

        Map<String,Private_Files__c> idToPrivateFile = new Map<String,Private_Files__c>();

        Test.startTest();
            idToPrivateFile = ApplicationHotelInfoController.getPrivateFiles(appStr);
        Test.stopTest();

        System.assert(idToPrivateFile.size() == 2, 'Expected 2 map values to be populated');
    }
}