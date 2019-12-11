@isTest
public class PIPSelectionCompCtrlTest {
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
            TASKRAY__trTemplate__c = true
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
		
        //Create PIP Library Items
        PIP_Library_Item__c pipLibItem =  new PIP_Library_Item__c();
        pipLibItem.Name = 'PIP';
        pipLibItem.Brand__c = BRAND_NAMES;
        pipLibItem.PI_BaseLine__c = true;
        pipLibItem.Active__c = true;
        insert pipLibItem;
        pipLibItem.Active__c = true;
		update pipLibItem; 
    }
	static testMethod void testgetLibraryItemWrapperList(){
		List<TaskRay__Project__c> taskProjects = [Select id from TaskRay__Project__c Limit 1];
        TaskRay__Project__c prj = taskProjects[0];
        PIP_Library_Item__c pipLineItem  = new PIP_Library_Item__c();   
        List<PIP_Library_Item__c> libItems = [Select id from PIP_Library_Item__c Limit 1 ];        
        Test.startTest();
        String LibraryItemWrapper = PIPSelectionCompCtrl.getLibraryItemWrapperList(prj.id,'Name,Category__c','ASC');
		List<PIPSelectionCompCtrl.PIPLibraryItemWrapper> wrapperList = (List<PIPSelectionCompCtrl.PIPLibraryItemWrapper>)JSON.deserialize(LibraryItemWrapper, List<PIPSelectionCompCtrl.PIPLibraryItemWrapper>.class);
        	System.assert(wrapperList.size()>0, 'Wrapper list not prepared');
        Test.StopTest();
    }
    static testMethod void testcreatePIPItems(){
		List<TaskRay__Project__c> taskProjects = [Select id from TaskRay__Project__c Limit 1];
        TaskRay__Project__c prj = taskProjects[0];
        PIP_Library_Item__c pipLineItem  = new PIP_Library_Item__c();   
        List<PIP_Library_Item__c> libItems = [Select id from PIP_Library_Item__c Limit 1 ];        
        Test.startTest();
        String pipId = PIPSelectionCompCtrl.createPIPItems(prj.id,JSON.Serialize(new List<String>{libItems[0].id}));
        Test.StopTest();
    }
    static testMethod void testDependentPicklist(){
		String picklistValues = PIPSelectionCompCtrl.getSubCategoryPickList();
        List<PIPSelectionCompCtrl.dependentPicklistWrapper> depListWrp = (List<PIPSelectionCompCtrl.dependentPicklistWrapper>)JSON.deserialize(picklistValues, List<PIPSelectionCompCtrl.dependentPicklistWrapper>.class);
        System.assert(depListWrp.size()>0,'Depenendent Picklist Wrapper not created');
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
}