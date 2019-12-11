/**
 * @description Test CLass for PIP_Library_ItemTriggerHelper
 *
 * @author Madan Morusu
 * @date 2019-08-23
 */
@isTest
public class PIP_Library_ItemTriggerHelperTest {

    private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id  pipTemplateRecordTypeId = recordTypeMap.get('PIP Template').getRecordTypeId();


    @TestSetup
    static void testDataSetup(){
        // Brand
        string BRAND_NAMES = getBrandNameString();
        List<String> brandValues = BRAND_NAMES.split(';'); 
		List<Brand__c> brands = new List<Brand__c>();
        for(integer i = 0; i<brandValues.size(); i++)
        {  
            if(brandValues[i].length()<11)           
            brands.add(new Brand__c(
				Brand_Code__c = brandValues[i],
				Name = brandValues[i],
				External_ID__c = '1234'+i,
				Start_Date__c = System.today()-10,
				End_Date__c = System.today()+10,
				Status__c = 'Active'
			));
        }
        insert brands; 
        List<Contract__c> contractList = new List<Contract__c>();
        for(integer i = 0; i<10; i++)
        {  
            contractList.add(new Contract__c(
                name = 'Sample Contract'+i,
			    AD__c = 'Harper,Stephen',
                Application_Type__c = 'NEWC',
                Billable_Rooms__c = 109.0,
                Contract_Status__c = 'PROP',
                Effective_Contract_Flag__c = true,
                LR1__c = 'Branch,Susan',
                RVP__c = 'Manger,Tanner'
			));
        }
        insert contractList; 
        
        List<TaskRay__Project__c> taskProjects = new List<TaskRay__Project__c>();
        for(integer i=0;i<10;i++){
            TaskRay__Project__c tPrj = new TaskRay__Project__c(
            Name = 'Task Proj'+i,
            Brand__c = brands[i].id,
            Contract__c = contractList[i].id,
            TASKRAY__trTemplate__c = true,
            RecordTypeId = pipTemplateRecordTypeId
            );
            taskProjects.add(tPrj);
        }
        insert taskProjects;

        //Create Tasks 
        List<TaskRay__Project_Task__c> projectTasks = new List<TaskRay__Project_Task__c>();
        for(integer i=0;i<taskProjects.size();i++){
            TaskRay__Project_Task__c projectTask = new TaskRay__Project_Task__c(
                TASKRAY__Project__c = taskProjects[i].id
            );
        projectTasks.add(projectTask);
        }
        insert projectTasks;

    }
    static testMethod void testPIPInsert(){
        PIP_Library_Item__c pipLineItem  = new PIP_Library_Item__c();
        // Brand
        string BRAND_NAMES = getBrandNameString();
        List<String> brandValues = BRAND_NAMES.split(';'); 
		List<Brand__c> brands = new List<Brand__c>();
        pipLineItem.Name = 'PIP';
        pipLineItem.Brand__c = BRAND_NAMES;
        pipLineItem.PI_BaseLine__c = true;
        pipLineItem.Active__c = true;
        List<TaskRay__Project_Task__c> prePIPTasks = new List<TaskRay__Project_Task__c>();
        prePIPTasks = [Select id from TaskRay__Project_Task__c where PIP_Library_Item__c = Null and TaskRay__Project__r.Brand__r.Name IN: brandValues];
        insert pipLineItem;
        pipLineItem.Active__c = true;
		update pipLineItem;        
        List<TaskRay__Project_Task__c> postPIPTasks = new List<TaskRay__Project_Task__c>();
        postPIPTasks = [Select id from TaskRay__Project_Task__c where PIP_Library_Item__c != null and TaskRay__Project__r.Brand__r.Name IN: brandValues];
        if(prePIPTasks.size()>0)
            System.assert(postPIPTasks.size()>0,'TaskRay tasks were not assigned to PIP Library Items');
        //Check if Tasks are created already.


    }

    static testMethod void testPIPInsertCostUnit(){
        PIP_Library_Item__c pipLineItem  = new PIP_Library_Item__c();
        // Brand
        string BRAND_NAMES = getBrandNameString();
        List<String> brandValues = BRAND_NAMES.split(';');
        List<Brand__c> brands = new List<Brand__c>();
        pipLineItem.Name = 'PIP';
        pipLineItem.Brand__c = BRAND_NAMES;
        pipLineItem.PI_Cost_Units__c = AppConstants.COST_UNIT_PER_BUILDING;
        pipLineItem.PI_Average_Cost__c = 10;
        pipLineItem.PI_BaseLine__c = true;
        pipLineItem.Active__c = true;
        List<TaskRay__Project_Task__c> prePIPTasks = new List<TaskRay__Project_Task__c>();
        prePIPTasks = [Select id from TaskRay__Project_Task__c where PIP_Library_Item__c = Null and TaskRay__Project__r.Brand__r.Name IN: brandValues];
        insert pipLineItem;
        pipLineItem.Active__c = true;
        update pipLineItem;
        List<TaskRay__Project_Task__c> postPIPTasks = new List<TaskRay__Project_Task__c>();
        postPIPTasks = [Select Id, PI_Estimated_Cost_per_Cost_Unit__c, PI_Cost_Units__c from TaskRay__Project_Task__c where PIP_Library_Item__c =: pipLineItem.Id and TaskRay__Project__r.Brand__r.Name IN: brandValues];
        //Check if Tasks are created already.

        System.assertEquals(10,postPIPTasks[0].PI_Estimated_Cost_per_Cost_Unit__c);
        System.assertEquals(AppConstants.COST_UNIT_PER_BUILDING,postPIPTasks[0].PI_Cost_Units__c);

    }
   
    static testMethod void testPIPUpdatetoRemoveTasks(){
        PIP_Library_Item__c pipLineItem  = new PIP_Library_Item__c();
        // Brand
        string BRAND_NAMES = getBrandNameString();
        List<String> brandValues = BRAND_NAMES.split(';'); 
		List<Brand__c> brands = new List<Brand__c>();
        pipLineItem.Name = 'PIP';
        pipLineItem.Brand__c = BRAND_NAMES;
        pipLineItem.PI_BaseLine__c = true;
        pipLineItem.Active__c = true;
        insert pipLineItem;
        pipLineItem.Active__c = true;
        update pipLineItem;
        List<TaskRay__Project_Task__c> taskList = new List<TaskRay__Project_Task__c>();
        taskList= [Select id, TASKRAY__Description__c from TaskRay__Project_Task__c Where PIP_Library_Item__c =: pipLineItem.id];
        System.assert(taskList.size()!=0,'Tasks not created after the insert');
        pipLineItem.PI_Description__c = 'Test Description';
        pipLineItem.Brand__c = '';
        pipLineItem.Active__c = false;
        PIP_Library_ItemTriggerHandler.isAfterUpdateTriggerReEntry = false;
        update pipLineItem;
        //Check if Tasks are created already. 
        taskList= [Select id, TASKRAY__Description__c, TASKRAY__Project__r.Brand__r.Name, PIP_Library_Item__r.Brand__c from TaskRay__Project_Task__c Where PIP_Library_Item__c =: pipLineItem.id];
        System.assert(taskList.size()==0,'Tasks not removed after the update');
    
    }
    static testMethod void testPIPUpdatetoUpdateTasks(){
        PIP_Library_Item__c pipLineItem  = new PIP_Library_Item__c();
        string BRAND_NAMES = getBrandNameString();
        List<String> brandValues = BRAND_NAMES.split(';'); 
		List<Brand__c> brands = new List<Brand__c>();
        pipLineItem.Name = 'PIP';
        pipLineItem.Brand__c = BRAND_NAMES;
        pipLineItem.PI_BaseLine__c = true;
        pipLineItem.Active__c = true;
        insert pipLineItem;
        pipLineItem.Active__c = true;
        update pipLineItem;
        List<TaskRay__Project_Task__c> taskList = new List<TaskRay__Project_Task__c>();
        taskList= [Select id, TASKRAY__Description__c from TaskRay__Project_Task__c Where PIP_Library_Item__c =: pipLineItem.id];
        System.assert(taskList.size()!=0,'Tasks not created after the insert');
        pipLineItem.PI_Description__c = 'Test Description';
        PIP_Library_ItemTriggerHandler.isAfterUpdateTriggerReEntry = false;        
        update pipLineItem;
        taskList= [Select id, TASKRAY__Description__c from TaskRay__Project_Task__c Where PIP_Library_Item__c =: pipLineItem.id];
        System.assert(taskList[0].TaskRay__Description__c==pipLineItem.PI_Description__c,'Tasks not updated after the PIP Library Change');
       
    
    }
    static testMethod void testPIPDelete(){
        PIP_Library_Item__c pipLineItem  = new PIP_Library_Item__c();
        
        string BRAND_NAMES = getBrandNameString();
        List<String> brandValues = BRAND_NAMES.split(';'); 
		List<Brand__c> brands = new List<Brand__c>();
        brandValues = new List<String>();
        
        pipLineItem.Name = 'PIP';
        pipLineItem.Brand__c = BRAND_NAMES;
        pipLineItem.PI_BaseLine__c = true;
        pipLineItem.Active__c = true;        
        insert pipLineItem;
        pipLineItem.Active__c = true;
        update pipLineItem;
        List<TaskRay__Project_Task__c> taskList = new List<TaskRay__Project_Task__c>();
        taskList= [Select id from TaskRay__Project_Task__c Where PIP_Library_Item__c =: pipLineItem.id];
        System.assert(taskList.size()!=0,'Tasks not created after the insert');
        pipLineItem.Active__c = false;
        PIP_Library_ItemTriggerHandler.isAfterUpdateTriggerReEntry = false;
        Test.startTest();
        PIP_Library_Item__c localLib = new PIP_Library_Item__c(id=pipLineItem.id,Active__c = false);
        update localLib;
        Test.stopTest();
        taskList= [Select id from TaskRay__Project_Task__c Where PIP_Library_Item__c =: pipLineItem.id];
         //Check if Tasks are created already. 
        System.assert(taskList.size()==0,'Tasks not removed after the update');
        //Check if Tasks are created already. 
    }

    static String getBrandNameString(){
        String BRAND_NAMES;
        Schema.DescribeFieldResult fieldResult =
            PIP_Library_Item__c.Brand__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            if(BRAND_NAMES==null){
                BRAND_NAMES=f.getValue();
            }
            else
                BRAND_NAMES =  BRAND_NAMES + ';'+f.getValue();
        } 
        return BRAND_NAMES;
    }

    /**
    * Method Tested: updateInUseCheckbox
    * | Scenario: PIP Library Item is Inserted and Active is set to true
    * | Expected Result: Active is set to false.
    **/
    @IsTest static void updateInUseOnActiveTrue(){
        PIP_Library_Item__c pipLibraryItem = TestDataFactory.createPIPLibraryItem(false);
        pipLibraryItem.Active__c = true;

        Test.startTest();
        insert pipLibraryItem;
        Test.stopTest();

        PIP_Library_Item__c pipLibraryItemInserted = [SELECT Active__c,In_Use__c FROM PIP_Library_Item__c];
        System.assertEquals(pipLibraryItemInserted.In_Use__c, false);
        System.assertEquals(pipLibraryItemInserted.Active__c, false);
    }

    /**
    * Method Tested: updateInUseCheckbox
    * | Scenario: PIP Library Item is Inserted and Active updated to true
    * | Expected Result: In Use checkbox is set to true
    **/
    @IsTest static void updateInUseOnActiveFalse(){
        PIP_Library_Item__c pipLibraryItem = TestDataFactory.createPIPLibraryItem(false);
        insert pipLibraryItem;

        pipLibraryItem.Active__c = true;

        Test.startTest();
        update pipLibraryItem;
        Test.stopTest();

        PIP_Library_Item__c pipLibraryItem3 = [SELECT Active__c, In_Use__c FROM PIP_Library_Item__c];
        System.assertEquals(pipLibraryItem3.In_Use__c, true);
    }

    /**
    * Method Tested: updateInUseCheckbox
    * | Scenario: PIP Library Item Active updated to false
    * | Expected Result: In Use checkbox is not changed
    **/
    @IsTest static void updateInUseOnActiveFalseInUseRemainTrue(){
        PIP_Library_Item__c pipLibraryItem = TestDataFactory.createPIPLibraryItem(false);
        insert pipLibraryItem;

        pipLibraryItem.Active__c = true;
        update pipLibraryItem;

        pipLibraryItem.Active__c = false;

        Test.startTest();
        update pipLibraryItem;
        Test.stopTest();

        PIP_Library_Item__c pipLibraryItem3 = [SELECT Active__c, In_Use__c FROM PIP_Library_Item__c];
        System.assertEquals(pipLibraryItem3.Active__c, false);
        System.assertEquals(pipLibraryItem3.In_Use__c, true);
    }
}