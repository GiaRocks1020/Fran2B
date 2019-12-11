@isTest
private class ApplicationFileDisplayControllerTest {
    
        @testSetup
    static void setupData(){


        Application__c application = new Application__c();
        insert application;

        Applicant__c newApplicant = new Applicant__c(
           Application__c = application.Id,
           Business_Address_Line_1__c = '1234 Thomas Rd',
           Business_City__c ='Phoenix',
           Business_Country__c = 'US',
           Business_Phone__c = '6021112345',
           Business_State_Province__c = 'US-AZ',
           Business_Zip_Postal_Code__c = '85016',
           Email__c = 'test@test.com',
           Home_Address_Line_1__c ='1010 Central Ave',
           Home_City__c = 'Phoenix',
           Home_country__c = 'US',
           Home_State_Province__c = 'US-AZ',
           Home_Zip_Postal_Code__c = '85012',
           First_Name__c = 'Test',
           Last_Name__c = 'Testersmith',
           Salutation__c = 'Mr',
           U_S_Citizen__c = 'Yes',
           SSN__c = '111-22-3333',
           Ownership__c = 10,
           Date_of_Birth__c = Date.parse('01/02/1978')    
           );
        insert newApplicant;

        

        Private_Files__c pf = new Private_Files__c();
        pf.Uploaded_Location__c = 'Entity_Document__c';
        pf.Application__c = application.id;
        insert pf;

        ContentVersion cv = new ContentVersion(
            ContentLocation = 'S',
            VersionData = Blob.toPdf('Test'),
            Title = 'Application',
            PathOnClient = 'Application'
        );
                insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = pf.Id;
        cdl.ShareType = 'V';
        insert cdl;

        Private_Files__c pf2 = new Private_Files__c();
        pf2.Uploaded_Location__c = 'Owner_Resume__c';
        pf2.Applicant__c = newApplicant.id;
        insert pf2;

        ContentVersion cv2 = new ContentVersion(
            ContentLocation = 'S',
            VersionData = Blob.toPdf('Test'),
            Title = 'Applicant',
            PathOnClient = 'Applicant'
        );
                insert cv2;

        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv2.Id].ContentDocumentId;
        cdl2.LinkedEntityId = pf2.Id;
        cdl2.ShareType = 'V';
        insert cdl2;


    }
    
    @isTest 
    static void getFileUploadsTest() {
        Application__c application = [SELECT ID FROM Application__c LIMIT 1];
        
        List<ApplicationFileDisplayController.UploadWrapper> fileUploads = 
        new List<ApplicationFileDisplayController.UploadWrapper>();
        Test.startTest();
            fileUploads=ApplicationFileDisplayController.getFileUploads(application.Id);
        Test.stopTest();

        System.assertEquals(2, fileUploads.size(), 'There should be two attachments returned');
    }

    @isTest 
    static void givenApplicationFile_ShouldDeleteFile() {
        Id contentDocuemntId = [
        SELECT Id, ContentDocumentId 
        FROM ContentVersion 
        WHERE Title = 'Application'
        LIMIT 1].ContentDocumentId;

        Private_Files__c privateFile  = [
            SELECT Id,Application__c, Applicant__c,Uploaded_Location__c 
            FROM Private_Files__c
            WHERE Application__c != null
            LIMIT 1 ];
        String section = 'Entity_Document__c';

        string jsonResult  = '';

        Test.startTest();
            jsonResult= ApplicationFileDisplayController.handleDeletionProcess(contentDocuemntId,section,privateFile.Id);
        Test.stopTest();

        ApplicationFileDisplayController.DeleteWrapper envelope =
         (ApplicationFileDisplayController.DeleteWrapper) JSON.deserialize(jsonResult, ApplicationFileDisplayController.DeleteWrapper.class);
        
         List<ContentDocument> cds = [SELECT Id FROM ContentDocument];
         System.assertEquals(1,cds.size(), 'The file should be deleted and thus one file remains');


    }

        @isTest 
    static void givenApplicantFile_ShouldDeleteFile() {
        Id contentDocuemntId = [
        SELECT Id, ContentDocumentId 
        FROM ContentVersion 
        WHERE Title = 'Applicant'
        LIMIT 1].ContentDocumentId;


        Private_Files__c privateFile  = [
            SELECT Id,Application__c, Applicant__c,Uploaded_Location__c 
            FROM Private_Files__c
            WHERE Applicant__c != null
            LIMIT 1 ];
        String section = 'Owner_Resume__c';

        string jsonResult  = '';

        Test.startTest();
            jsonResult= ApplicationFileDisplayController.handleDeletionProcess(contentDocuemntId,section,privateFile.Id);
        Test.stopTest();

        ApplicationFileDisplayController.DeleteWrapper envelope =
         (ApplicationFileDisplayController.DeleteWrapper) JSON.deserialize(jsonResult, ApplicationFileDisplayController.DeleteWrapper.class);
        
         List<ContentDocument> cds = [SELECT Id FROM ContentDocument];
         System.assertEquals(1,cds.size(), 'The file should be deleted and thus one file remains');


    }
    
}