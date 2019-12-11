@isTest
public class ApplicationContainerControllerTest {

    @isTest
    public static void getDataEnvelope_givenApplications(){
        Application__c app = new Application__c(
            Status__c = 'In Progress'
        );

        insert app;


        String dataEnv;
        Test.startTest();
           dataEnv = ApplicationContainerController.getDataEnvelope();
        Test.stopTest();

        System.debug(dataEnv);

        System.assert(dataEnv.contains('[]') != true, 'The string should contain data');
        System.assert(dataEnv.contains('Id') == true, 'Expected at least 1 application Id');
    }

    @isTest
    public static void getDataEnvelope_givenNoApplications_shouldReturnEmptyApplicationsString(){

        String dataEnv;
        Test.startTest();
           dataEnv = ApplicationContainerController.getDataEnvelope();
        Test.stopTest();

        System.debug(dataEnv);

        System.assert(dataEnv.contains('[]') == true, 'The string should contain an empty set of braces');
    }

}