/**
 * @description Test Class for TASKRAY_ProjectTriggerHelper
 *
 * @author Pradnya Desai
 * @date 2019-11-14
 */
@IsTest
public class TASKRAY_OpeningTriggerHelperTest {

    private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id  openingRecordTypeId = recordTypeMap.get('Opening').getRecordTypeId();
    private static Id  pipRecordTypeId = recordTypeMap.get('PIP').getRecordTypeId();

    private static String todayDate = + String.valueOf(Date.today().month()) + '/'
            + String.valueOf(Date.today().day()) + '/'
            + String.valueOf(Date.today().year()).right(2);

    /**
	 * @description Used to setup test data used for unit tests
	 *
	 * @return void
	 */
    @TestSetup
    static void dataSetup() {
        Contract__c contract = new Contract__c(
                Name = 'Sample Contract',
                AD__c = 'Harper,Stephen',
                Application_Type__c = 'NEWC',
                Billable_Rooms__c = 109.0,
                Contract_Status__c = 'PROP',
                Effective_Contract_Flag__c = true,
                LR1__c = 'Branch,Susan',
                RVP__c = 'Manger,Tanner'
        );

        insert Contract;

        Brand__c ascendBrand = TestDataFactory.createBrand(true, 'Ascend');
        TestDataFactory.createBrand(true, 'Clarion');

        TestDataFactory.createProperty(true);
        TestDataFactory.createProductRE(true, 'Resort Collection', ascendBrand.Id, 'AC-RE');
    }

    /**
	 * @description Validate the name field was set on a Opening record was changed.
	 *
	 * @return void
	 */
    @isTest
    private static void validateOpeningName() {
        Contract__c contract = TestDataFactory.createContract(true);
        User user = TestDataFactory.createPIPManagerUser();
        Resource__c resource = TestDataFactory.createResource(user.Id);
        List<Brand__c> brands = [Select Id from Brand__c];
        List<Product__c> products = [SELECT Id from Product__c];
        List<Property__c> properties = [SELECT Id from Property__c];

        Test.startTest();
        TASKRAY__Project__c openingProject = new TASKRAY__Project__c(
                Name = 'Opening TEST',
                Contract__c = contract.Id,
                RecordTypeId = openingRecordTypeId,
                Project_Type__c = 'As Is',
                Brand__c = brands[0].Id,
                Product__c = products[0].Id,
                Property__c = properties[0].Id,
                TASKRAY__trStatus__c = 'Writing',
                Sub_Status__c = 'Sent to Legal'
        );

        insert openingProject;
        Test.stopTest();

        List<TASKRAY__Project__c> openings = [SELECT Id, Name FROM TASKRAY__Project__c];

        for(TASKRAY__Project__c opening : openings) {
            System.assertEquals('AZ083 - As Is - AscendRE - ' + todayDate, opening.Name);
        }
    }

    /**
	 * @description Validate property code field is populated on TASKRAY__Project__c record. Value is being set by
	 * method in trigger.
	 *
	 * @return void
	 */
    @isTest
    private static void validatePropertyCodePopulatedPostive() {
        Contract__c contract = TestDataFactory.createContract(true);
        List<Brand__c> brands = [Select Id from Brand__c];
        List<Product__c> products = [SELECT Id from Product__c];
        List<Property__c> properties = [SELECT Id from Property__c];
        List<TASKRAY__Project__c> projects = new List<TASKRAY__Project__c>();


        TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
                Name = 'PIP TEST',
                PIP_Type__c = 'Application',
                PIP_Method__c = 'Desktop',
                PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
                RecordTypeId = pipRecordTypeId,
                Contract__c = contract.Id,
                Property__c = properties[0].Id
        );
        projects.add(pipProject);

        TASKRAY__Project__c openingProject = new TASKRAY__Project__c(
                Name = 'Opening TEST',
                Contract__c = contract.Id,
                RecordTypeId = openingRecordTypeId,
                Project_Type__c = 'As Is',
                Brand__c = brands[0].Id,
                Product__c = products[0].Id,
                Property__c = properties[0].Id,
                TASKRAY__trStatus__c = 'Writing',
                Sub_Status__c = 'Sent to Legal'
        );

        projects.add(openingProject);
        insert projects;


        List<TASKRAY__Project__c> insertedProjects = [
                SELECT Id, Property_Code__c, Standard_GM_Email__c, Franchise_Owner__c, Property_Phone__c,
                        Property_Fax__c, Additional_GM_Email__c
                FROM TASKRAY__Project__c];

        for(TASKRAY__Project__c project : insertedProjects) {
            system.debug(project);
            System.assertEquals('AZ083', project.Property_Code__c);
            System.assertEquals('gm.az083@choicehotels.com', project.Standard_GM_Email__c);
            System.assertNotEquals(null, project.Franchise_Owner__c);
            System.assertEquals('000-222-3333', project.Property_Phone__c);
            System.assertEquals('000-111-2222', project.Property_Fax__c);
            System.assertEquals('additionalgm123@123.com', project.Additional_GM_Email__c);
        }
    }

    /**
     * @description Validate property code field is *not* populated on TASKRAY__Project__c record. Value is being set by
     * method in trigger.
     *
     * @return void
     */
    @isTest
    private static void validatePropertyCodePopulatedNegative() {
        Contract__c contract = TestDataFactory.createContract(true);
        List<TASKRAY__Project__c> projects = new List<TASKRAY__Project__c>();
        List<Brand__c> brands = [Select Id from Brand__c];
        List<Product__c> products = [SELECT Id from Product__c];

        Test.startTest();
        TASKRAY__Project__c pipProject = new TASKRAY__Project__c(
                Name = 'PIP TEST',
                PIP_Type__c = 'Application',
                PIP_Method__c = 'Desktop',
                PIP_Assignment_Date__c = Date.newInstance(2019, 8, 13),
                RecordTypeId = pipRecordTypeId,
                Contract__c = contract.Id
        );
        projects.add(pipProject);

        TASKRAY__Project__c openingProject = new TASKRAY__Project__c(
                Name = 'Opening TEST',
                Contract__c = contract.Id,
                RecordTypeId = openingRecordTypeId,
                Project_Type__c = 'As Is',
                Brand__c = brands[0].Id,
                Product__c = products[0].Id,
                TASKRAY__trStatus__c = 'Writing',
                Sub_Status__c = 'Sent to Legal'
        );

        projects.add(openingProject);
        insert projects;
        Test.stopTest();

        List<TASKRAY__Project__c> insertedProjects = [
                SELECT Id, Property_Code__c, Standard_GM_Email__c, Franchise_Owner__c, Property_Phone__c,
                        Property_Fax__c, Additional_GM_Email__c
                FROM TASKRAY__Project__c];

        for(TASKRAY__Project__c project : insertedProjects) {
            system.debug(project);
            System.assertEquals(null, project.Property_Code__c);
            System.assertEquals(null, project.Standard_GM_Email__c);
            System.assertEquals(null, project.Franchise_Owner__c);
            System.assertEquals(null, project.Property_Phone__c);
            System.assertEquals(null, project.Property_Fax__c);
            System.assertEquals(null, project.Additional_GM_Email__c);
        }

    }
}