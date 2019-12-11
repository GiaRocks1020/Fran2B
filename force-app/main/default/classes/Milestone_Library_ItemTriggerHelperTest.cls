@isTest
public class Milestone_Library_ItemTriggerHelperTest {

    private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id  milestoneTemplateRecordTypeId = recordTypeMap.get('OPENING Template').getRecordTypeId();


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
            RecordTypeId = milestoneTemplateRecordTypeId
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
    static testMethod void testMilestoneInsert(){
        Milestone_Library_Item__c milestoneLineItem  = new Milestone_Library_Item__c();
        // Brand
        string BRAND_NAMES = getBrandNameString();
        List<String> brandValues = BRAND_NAMES.split(';'); 
		List<Brand__c> brands = new List<Brand__c>();
        milestoneLineItem.Name = 'Milestone';
        milestoneLineItem.Brand__c = BRAND_NAMES;
        milestoneLineItem.BaseLine__c = true;
        milestoneLineItem.Active__c = true;
        List<TaskRay__Project_Task__c> preMilestoneTasks = new List<TaskRay__Project_Task__c>();
        preMilestoneTasks = [Select id from TaskRay__Project_Task__c where Milestone_Library_Item__c = Null and TaskRay__Project__r.Brand__r.Name IN: brandValues];
        insert milestoneLineItem;
        milestoneLineItem.Active__c = true;
		update milestoneLineItem;        
        List<TaskRay__Project_Task__c> postMilestoneTasks = new List<TaskRay__Project_Task__c>();
        postMilestoneTasks = [Select id from TaskRay__Project_Task__c where Milestone_Library_Item__c != null and TaskRay__Project__r.Brand__r.Name IN: brandValues];
        if(preMilestoneTasks.size()>0)
            System.assert(postMilestoneTasks.size()>0,'TaskRay tasks were not assigned to Milestone Library Items');
        //Check if Tasks are created already.


    }

       
    static testMethod void testMilestoneUpdatetoRemoveTasks(){
        Milestone_Library_Item__c milestoneLineItem  = new Milestone_Library_Item__c();
        // Brand
        string BRAND_NAMES = getBrandNameString();
        List<String> brandValues = BRAND_NAMES.split(';'); 
		List<Brand__c> brands = new List<Brand__c>();
        milestoneLineItem.Name = 'Milestone';
        milestoneLineItem.Brand__c = BRAND_NAMES;
        milestoneLineItem.BaseLine__c = true;
        milestoneLineItem.Active__c = true;
        insert milestoneLineItem;
        milestoneLineItem.Active__c = true;
        update milestoneLineItem;
        List<TaskRay__Project_Task__c> taskList = new List<TaskRay__Project_Task__c>();
        taskList= [Select id, TASKRAY__Description__c from TaskRay__Project_Task__c Where Milestone_Library_Item__c =: milestoneLineItem.id];
        System.assert(taskList.size()!=0,'Tasks not created after the insert');
        milestoneLineItem.Brand__c = '';
        milestoneLineItem.Active__c = false;
        Milestone_Library_ItemTriggerHandler.isAfterUpdateTriggerReEntry = false;
        update milestoneLineItem;
        //Check if Tasks are created already. 
        taskList= [Select id, TASKRAY__Description__c, TASKRAY__Project__r.Brand__r.Name, Milestone_Library_Item__r.Brand__c from TaskRay__Project_Task__c Where Milestone_Library_Item__c =: milestoneLineItem.id];
        System.assert(taskList.size()==0,'Tasks not removed after the update');
    
    }
        static testMethod void testMilestoneDelete(){
        Milestone_Library_Item__c milestoneLineItem  = new Milestone_Library_Item__c();
        
        string BRAND_NAMES = getBrandNameString();
        List<String> brandValues = BRAND_NAMES.split(';'); 
		List<Brand__c> brands = new List<Brand__c>();
        brandValues = new List<String>();
        
        milestoneLineItem.Name = 'Milestone';
        milestoneLineItem.Brand__c = BRAND_NAMES;
        milestoneLineItem.BaseLine__c = true;
        milestoneLineItem.Active__c = true;        
        insert milestoneLineItem;
        milestoneLineItem.Active__c = true;
        update milestoneLineItem;
        List<TaskRay__Project_Task__c> taskList = new List<TaskRay__Project_Task__c>();
        taskList= [Select id from TaskRay__Project_Task__c Where Milestone_Library_Item__c =: milestoneLineItem.id];
        System.assert(taskList.size()!=0,'Tasks not created after the insert');
        milestoneLineItem.Active__c = false;
        Milestone_Library_ItemTriggerHandler.isAfterUpdateTriggerReEntry = false;
        Test.startTest();
        Milestone_Library_Item__c localLib = new Milestone_Library_Item__c(id=milestoneLineItem.id,Active__c = false);
        update localLib;
        Test.stopTest();
        taskList= [Select id from TaskRay__Project_Task__c Where Milestone_Library_Item__c =: milestoneLineItem.id];
         //Check if Tasks are created already. 
        System.assert(taskList.size()==0,'Tasks not removed after the update');
        //Check if Tasks are created already. 
    }

    static String getBrandNameString(){
        String BRAND_NAMES;
        Schema.DescribeFieldResult fieldResult =
            Milestone_Library_Item__c.Brand__c.getDescribe();
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

}