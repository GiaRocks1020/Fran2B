/**
 * Created by sugandhac on 8/25/2019.
 */

@IsTest
private class ContentDocumentLinkTriggerHandlerTest {


    /**
    Scenario: Document is loaded on PIP Object
    Given Document is not duplicate
    Then Update File Name in format: Property Code, Brand Name, Product Name, Description
    */
    @IsTest static void testFileInsertion(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        User PIPWriter = TestDataFactory.createPIPWriterUser();
        System.runAs(PIPWriter){
            ContentDocument file = TestDataFactory.createContentDocument('Cafe File',true);
            ContentDocumentLink cdLink = new ContentDocumentLink();
            cdLink.ContentDocumentId = file.Id;
            cdLink.LinkedEntityId = PIP.Id;
            cdLink.ShareType = 'V';
            Test.startTest();
            insert cdLink;
            Test.stopTest();
        }
        ContentDocumentLink cdLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :pip.id];
        ContentDocument file = [SELECT Title FROM ContentDocument WHERE Id =: cdLink.ContentDocumentId];
        System.assert(file.Title.contains('Cafe File.jpg'));
    }

    /**
    Scenario: Document is loaded on PIP Object
    Given Document is a duplicate
    Then Update File Name in format: Property Code, Brand Name, Product Name, Description -Copy Date and Time
    */
    @IsTest static void testDuplicateFileInsertion(){
        TaskRay__Project__c PIP = TestDataFactory.createPIP(true);
        User PIPWriter = TestDataFactory.createPIPWriterUser();
        System.runAs(PIPWriter){
            ContentDocument file = TestDataFactory.createContentDocument('Cafe File',true);
            ContentDocumentLink cdLink = new ContentDocumentLink();
            cdLink.ContentDocumentId = file.Id;
            cdLink.LinkedEntityId = PIP.Id;
            cdLink.ShareType = 'V';
            insert cdLink;
            ContentDocument fileCopy = TestDataFactory.createContentDocument('Cafe File',true);
            ContentDocumentLink cdLinkCopy = new ContentDocumentLink();
            cdLinkCopy.ContentDocumentId = fileCopy.Id;
            cdLinkCopy.LinkedEntityId = PIP.Id;
            cdLinkCopy.ShareType = 'V';
            Test.startTest();
            insert cdLinkCopy;
            Test.stopTest();
        }

        List<ContentDocumentLink> cdLink = [SELECT ContentDocumentId
                                            FROM ContentDocumentLink
                                            WHERE LinkedEntityId = :PIP.Id];
        List<ContentDocument> lstFiles = [SELECT Title
                                            FROM ContentDocument
                                            WHERE Id =: cdLink[0].ContentDocumentId
                                            OR Id =: cdLink[1].ContentDocumentId];
        System.assert(lstFiles[0].Title.contains('Copy') || lstFiles[1].Title.contains('Copy'));
    }

}