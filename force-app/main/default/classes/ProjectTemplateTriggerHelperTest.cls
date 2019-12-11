/**
 * Created by pradnya.desai on 11/4/19.
 */

@IsTest
private class ProjectTemplateTriggerHelperTest {

    private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id  pipTemplateRecordTypeId = recordTypeMap.get('PIP Template').getRecordTypeId();
    private static Id  openingTemplateRecordTypeId = recordTypeMap.get('Opening Template').getRecordTypeId();

    @TestSetup
    static void dataSetup(){
        Brand__c ascendBrand = TestDataFactory.createBrand(true, 'Ascend');
        Brand__c clarionBrand = TestDataFactory.createBrand(true, 'Clarion');
        TestDataFactory.createBrand(true, 'Comfort');
        TestDataFactory.createPIPTemplate(true, ascendBrand.Id, true, pipTemplateRecordTypeId, 'Ascend1');
        TestDataFactory.createPIPTemplate(true, clarionBrand.Id, true, pipTemplateRecordTypeId, 'Clarion1');

        TestDataFactory.createOpeningTemplate(true, ascendBrand.Id, true, openingTemplateRecordTypeId,
                'Ascend1', 'New Build');
        TestDataFactory.createOpeningTemplate(true, clarionBrand.Id, true, openingTemplateRecordTypeId,
                'Clarion1', 'Minor Renovation');

    }

    /**
	 * @description Method to validate if two PIP Template that Active and having same Brand will throw error on Insert
	 *
	 * @return void
	 */
    @IsTest
    static void testDuplicateBrandOnInsert() {

        List<Brand__c> brand = [Select Id from Brand__c where Name =: 'Ascend'];
        Boolean duplicateError = false;

        Test.startTest();
        try{
            TASKRAY__Project__c duplicateAscend = TestDataFactory.createPIPTemplate(false, brand[0].Id, true,
                    pipTemplateRecordTypeId,'Ascend2');
            insert duplicateAscend;
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already a PIP Template for this Brand. ' +
                    'Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(true, duplicateError);
    }

    /**
	 * @description Method to validate if two Opening Template that Active and having same Brand and Project Type will throw error on Insert
	 *
	 * @return void
	 */
    @IsTest
    static void testDuplicateOpeningOnInsert() {

        List<Brand__c> brand = [Select Id from Brand__c where Name =: 'Ascend'];
        Boolean duplicateError = false;

        Test.startTest();
        try{
            TASKRAY__Project__c duplicateAscend = TestDataFactory.createOpeningTemplate(false, brand[0].Id, true,
                    openingTemplateRecordTypeId,'Ascend2', 'New Build');
            insert duplicateAscend;
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already an Opening Template for this ' +
                    'Brand and Project Type. Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(true, duplicateError);
    }

    /**
	 * @description Method to validate if two Opening Template that Active and having same Brand and Project Type will throw error on Insert
	 *
	 * @return void
	 */
    @IsTest
    static void testNoErrorOpeningOnInsert() {

        List<Brand__c> brand = [Select Id from Brand__c where Name =: 'Ascend'];
        Boolean duplicateError = false;

        Test.startTest();
        try{
            TASKRAY__Project__c duplicateAscend = TestDataFactory.createOpeningTemplate(false, brand[0].Id, true,
                    openingTemplateRecordTypeId,'Ascend2', 'International');
            insert duplicateAscend;
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already an Opening Template for this ' +
                    'Brand and Project Type. Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(false, duplicateError);
    }

    /**
	 * @description Method to validate if two PIP Template that Active and having same Brand will throw error
	 * on Update of Brand
	 *
	 * @return void
	 */
    @IsTest
    static void testDuplicateBrandOnUpdateBrand() {

        Boolean duplicateError = false;
        List<Brand__c> comfortBrand = [Select Id from Brand__c where Name =: 'Comfort'];
        List<Brand__c> ascendBrand = [Select Id from Brand__c where Name =: 'Ascend'];
        TASKRAY__Project__c duplicateBrand = TestDataFactory.createPIPTemplate(false, comfortBrand[0].Id,
                true, pipTemplateRecordTypeId, 'Comfort');
        insert duplicateBrand;
        List<TASKRAY__Project__c> duplicateBrandUpdate = [Select Id, Brand__c from TASKRAY__Project__c where Id =: duplicateBrand.Id];
        duplicateBrandUpdate[0].Brand__c = ascendBrand[0].Id;
        Test.startTest();
        try{
            update duplicateBrandUpdate;
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already a PIP Template for this Brand. ' +
                    'Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(true, duplicateError);
    }

    /**
	 * @description Method to validate if two PIP Template that Active and having same Brand will throw error
	 * on Update of Brand
	 *
	 * @return void
	 */
    @IsTest
    static void testDuplicateOpeningOnUpdateBrand() {

        Boolean duplicateError = false;
        List<Brand__c> comfortBrand = [Select Id from Brand__c where Name =: 'Comfort'];
        List<Brand__c> ascendBrand = [Select Id from Brand__c where Name =: 'Ascend'];
        TASKRAY__Project__c duplicateBrand = TestDataFactory.createOpeningTemplate(false, comfortBrand[0].Id,
                true, openingTemplateRecordTypeId, 'Comfort' ,'New Build');
        insert duplicateBrand;
        List<TASKRAY__Project__c> duplicateBrandUpdate = [Select Id, Brand__c from TASKRAY__Project__c where Id =: duplicateBrand.Id];
        duplicateBrandUpdate[0].Brand__c = ascendBrand[0].Id;
        Test.startTest();
        try{
            update duplicateBrandUpdate;
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already an Opening Template for this ' +
                    'Brand and Project Type. Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(true, duplicateError);
    }

    /**
	 * @description Method to validate if two PIP Template that Active and having same Brand will throw error
	 * on Update of Brand
	 *
	 * @return void
	 */
    @IsTest
    static void testNoErrorOpeningOnUpdateBrand() {

        Boolean duplicateError = false;
        List<Brand__c> comfortBrand = [Select Id from Brand__c where Name =: 'Comfort'];
        List<Brand__c> ascendBrand = [Select Id from Brand__c where Name =: 'Ascend'];
        TASKRAY__Project__c duplicateBrand = TestDataFactory.createOpeningTemplate(false, comfortBrand[0].Id,
                true, openingTemplateRecordTypeId, 'Comfort' ,'Fast Track');
        insert duplicateBrand;
        List<TASKRAY__Project__c> duplicateBrandUpdate = [Select Id, Brand__c from TASKRAY__Project__c where Id =: duplicateBrand.Id];
        duplicateBrandUpdate[0].Brand__c = ascendBrand[0].Id;
        Test.startTest();
        try{
            update duplicateBrandUpdate;
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already an Opening Template for this ' +
                    'Brand and Project Type. Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(false, duplicateError);
    }

    /**
	 * @description Method to validate if two PIP Template that Active and having same Brand will throw error
	 * on Update of Brand
	 *
	 * @return void
	 */
    @IsTest
    static void testDuplicateOpeningOnUpdateActive() {

        Boolean duplicateError = false;
        List<Brand__c> comfortBrand = [Select Id from Brand__c where Name =: 'Comfort'];
        List<Brand__c> ascendBrand = [Select Id from Brand__c where Name =: 'Ascend'];
        TASKRAY__Project__c duplicateBrand = TestDataFactory.createOpeningTemplate(false, ascendBrand[0].Id,
                false, openingTemplateRecordTypeId, 'Ascend3' ,'New Build');
        insert duplicateBrand;
        List<TASKRAY__Project__c> duplicateBrandUpdate = [Select Id, Brand__c from TASKRAY__Project__c where Id =: duplicateBrand.Id];
        duplicateBrandUpdate[0].Active__c = true;
        Test.startTest();
        try{
            update duplicateBrandUpdate;
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already an Opening Template for this ' +
                    'Brand and Project Type. Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(true, duplicateError);
    }

    /**
	 * @description Method to validate if two PIP Template that Active and having same Brand will throw error
	 * on Update of Brand
	 *
	 * @return void
	 */
    @IsTest
    static void testDuplicateOpeningOnUpdateProject() {

        Boolean duplicateError = false;
        List<Brand__c> comfortBrand = [Select Id from Brand__c where Name =: 'Comfort'];
        List<Brand__c> ascendBrand = [Select Id from Brand__c where Name =: 'Ascend'];
        TASKRAY__Project__c duplicateBrand = TestDataFactory.createOpeningTemplate(false, ascendBrand[0].Id,
                true, openingTemplateRecordTypeId, 'Ascend3' ,'Fast Track');
        insert duplicateBrand;
        List<TASKRAY__Project__c> duplicateBrandUpdate = [Select Id, Brand__c from TASKRAY__Project__c where Id =: duplicateBrand.Id];
        duplicateBrandUpdate[0].Project_Type__c = 'New Build';
        Test.startTest();
        try{
            update duplicateBrandUpdate;
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already an Opening Template for this ' +
                    'Brand and Project Type. Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(true, duplicateError);
    }

    /**
	 * @description Method to validate if two PIP Template that Active and having same Brand will throw error
	 * on Update of Brand
	 *
	 * @return void
	 */
    @IsTest
    static void testNoErrorOpeningOnUpdateProject() {

        Boolean duplicateError = false;
        List<Brand__c> comfortBrand = [Select Id from Brand__c where Name =: 'Comfort'];
        List<Brand__c> ascendBrand = [Select Id from Brand__c where Name =: 'Ascend'];
        TASKRAY__Project__c duplicateBrand = TestDataFactory.createOpeningTemplate(false, ascendBrand[0].Id,
                false, openingTemplateRecordTypeId, 'Ascend3' ,'Fast Track');
        insert duplicateBrand;
        List<TASKRAY__Project__c> duplicateBrandUpdate = [Select Id, Brand__c from TASKRAY__Project__c where Id =: duplicateBrand.Id];
        duplicateBrandUpdate[0].Project_Type__c = 'New Build';
        Test.startTest();
        try{
            update duplicateBrandUpdate;
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already an Opening Template for this ' +
                    'Brand and Project Type. Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(false, duplicateError);
    }

    /**
	 * @description Method to validate if two PIP Template that Active and having same Brand will throw error
	 * on Update of Active flag
	 *
	 * @return void
	 */
    @IsTest
    static void testDuplicateBrandOnUpdateActiveChange() {

        Boolean duplicateError = false;
        List<Brand__c> ascendBrand = [Select Id from Brand__c where Name =: 'Ascend'];
        TASKRAY__Project__c duplicateBrand = TestDataFactory.createPIPTemplate(true, ascendBrand[0].Id, false,
                pipTemplateRecordTypeId, 'Ascend2');
        duplicateBrand.Active__c = true;
        Test.startTest();
        try{
            update duplicateBrand;
        }catch(Exception ex){
            System.debug('Exception : ' + ex.getMessage());
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already a PIP Template for this Brand. ' +
                    'Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(true, duplicateError);
    }

    /**
	 * @description Method to PIP & OpeningTemplate name is not changed when record is inserted.
	 *
	 * @return void
	 */
    @IsTest
    static void testTemplateNameNotChanged() {

        List<Brand__c> comfortBrand = [Select Id from Brand__c where Name =: 'Comfort'];

        List<TASKRAY__Project__c> templates = new List<TASKRAY__Project__c>();
        TASKRAY__Project__c pipTemplate = TestDataFactory.createPIPTemplate(false, comfortBrand[0].Id, true,
                pipTemplateRecordTypeId, 'ComfortPIPTemplate');
        templates.add(pipTemplate);

        List<Brand__c> ascendBrand = [Select Id from Brand__c where Name =: 'Ascend'];
        TASKRAY__Project__c openingTemplate = TestDataFactory.createOpeningTemplate(false, ascendBrand[0].Id,
                false, openingTemplateRecordTypeId, 'AscendOpeningTemplate' ,'Fast Track');
        templates.add(openingTemplate);

        Test.startTest();

        insert templates;

        Test.stopTest();
        TASKRAY__Project__c readPipTemplate = [Select Id, Name from TASKRAY__Project__c where Id = :pipTemplate.Id];
        System.assertEquals('ComfortPIPTemplate', readPipTemplate.Name);

        TASKRAY__Project__c readOpeningTemplate = [Select Id, Name from TASKRAY__Project__c where Id = :openingTemplate.Id];
        System.assertEquals('AscendOpeningTemplate', readOpeningTemplate.Name);
    }

    /**
	 * @description Method to PIP & OpeningTemplate name is not changed when record is updated.
	 *
	 * @return void
	 */
    @IsTest
    static void testTemplateNameNotChangedOnUpdate() {

        List<Brand__c> comfortBrand = [Select Id from Brand__c where Name =: 'Comfort'];
        Brand__c cambriaBrand = TestDataFactory.createBrand(true, 'Cambria');
        List<TASKRAY__Project__c> templates = new List<TASKRAY__Project__c>();
        TASKRAY__Project__c pipTemplate = TestDataFactory.createPIPTemplate(false, comfortBrand[0].Id, true,
                pipTemplateRecordTypeId, 'ComfortPIPTemplate');
        templates.add(pipTemplate);

        List<Brand__c> ascendBrand = [Select Id from Brand__c where Name =: 'Ascend'];
        TASKRAY__Project__c openingTemplate = TestDataFactory.createOpeningTemplate(false, ascendBrand[0].Id,
                false, openingTemplateRecordTypeId, 'AscendOpeningTemplate' ,'Fast Track');
        templates.add(openingTemplate);
        insert templates;

        List<TASKRAY__Project__c> insertedTemplates = [Select Id, Name, Brand__c from TASKRAY__Project__c];
        for(TASKRAY__Project__c project: insertedTemplates){
            project.Brand__c = cambriaBrand.Id;
        }

        Test.startTest();
        update insertedTemplates;
        Test.stopTest();

        TASKRAY__Project__c readPipTemplate = [Select Id, Name from TASKRAY__Project__c where Id = :pipTemplate.Id];
        System.assertEquals('ComfortPIPTemplate', readPipTemplate.Name);

        TASKRAY__Project__c readOpeningTemplate = [Select Id, Name from TASKRAY__Project__c where Id = :openingTemplate.Id];
        System.assertEquals('AscendOpeningTemplate', readOpeningTemplate.Name);
    }

    /**
	 * @description Method to validate if two PIP Template that Active and having same Brand will throw error
	 * on Update of Template
	 *
	 * @return void
	 */
    @IsTest
    static void testDuplicateBrandOnUpdateTemplateChange() {

        Boolean duplicateError = false;
        List<Brand__c> ascendBrand = [Select Id from Brand__c where Name =: 'Ascend'];
        TASKRAY__Project__c duplicateBrand = new TaskRay__Project__c(
                Name = 'Ascend2',
                TASKRAY__trTemplate__c = false,
                Active__c = true,
                Brand__c = ascendBrand[0].Id,
                recordTypeId = pipTemplateRecordTypeId
        );
        insert duplicateBrand;

        duplicateBrand.TASKRAY__trTemplate__c = true;
        Test.startTest();
        try{
            update duplicateBrand;
        }catch(Exception ex){
            System.debug('testDuplicateBrandOnUpdateTemplateChange Exception : ' + ex.getMessage());
            System.assertNotEquals(null, ex.getMessage());
            if(ex.getMessage() != null && ex.getMessage().contains('There is already a PIP Template for this Brand. ' +
                    'Please deactivate the existing one, before creating a new template.')){
                duplicateError = true;
            }
        }
        Test.stopTest();
        System.assertEquals(true, duplicateError);
    }
}