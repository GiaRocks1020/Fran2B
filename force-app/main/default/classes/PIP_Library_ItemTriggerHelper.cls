/**
 * @description Trigger Helper  for PIP_Library_Item__c object
 *
 * @author Madan Morusu
 * @date 2019-08-22
 */
public without sharing class PIP_Library_ItemTriggerHelper {
    public PIP_Library_ItemTriggerHelper() {

    }
    public Map<id,TaskRay__Project__c> mapProjs;
    public Map<Id, PIP_Library_Item__c> mapPIPs;
    //Method to perform the sync of the Task line items
    public void syncTasksWithLineItems(List<PIP_Library_Item__c> libraryItemList){
        List<PIP_Library_Item__c> syncLibraryItems	 = new List<PIP_Library_Item__c>();
        mapPIPs = new Map<Id, PIP_Library_Item__c>();
        //check the fields on PIP Library Item to see if any of associated fields have changed and add brands on to set for use in the Query
        for(PIP_Library_Item__c pipLibraryLineItem : libraryItemList){
            if(syncRequired(pipLibraryLineItem)){
                    syncLibraryItems.add(pipLibraryLineItem);
                    mapPIPs.put(pipLibraryLineItem.id,pipLibraryLineItem);
            }

        }
        if(syncLibraryItems	.size()>0){
            Map<String, List<TASKRAY__Project_Task__c>> mapTasks = new Map<String, List<TASKRAY__Project_Task__c>>();
            //Query Associated Tasks and collect associated Projects
            mapTasks = getTasks(syncLibraryItems);
            for(String Operation : mapTasks.keySet()){
                if(mapTasks.get(Operation).size()>0){
                    List<TASKRAY__Project_Task__c> setTasks = mapTasks.get(Operation);
                    if(Operation == 'Update'){
                        Update SyncTaskFields(setTasks);
                    }
                    if(Operation == 'Delete'){
                        Delete setTasks;
                    }
                    if(Operation == 'Insert'){
                        Insert setTasks;
                    }
                }
            }
        }

    }

    //Filter out the PIP Lines 
    private boolean syncRequired(PIP_Library_Item__c libraryItem){
        boolean syncRequired; 
        //Add checks. 
        if(libraryItem.PI_Baseline__c)
        syncRequired = true;
        else 
        syncRequired = false;

        return syncRequired;
    }

    //Build a map with operation and task list. 
    private Map<String, List<TASKRAY__Project_Task__c>> getTasks(List<PIP_Library_Item__c> syncLibraryItems	){
        Map<String, List<TASKRAY__Project_Task__c>> mapTasks = new Map<String, List<TASKRAY__Project_Task__c>>();
        Set<String> pipBrandProjIds = new Set<String>();
        mapProjs = new Map<Id, TaskRay__Project__c>();

        //Collect the Brands of the Library line item
        Set<ID> LibraryLineItemIds = (new Map<ID,PIP_Library_Item__c>(syncLibraryItems)).KeySet();

        //Query Associated Tasks
        for(TASKRAY__Project_Task__c task : queryAssociatedTasks(libraryLineItemIds)){
            //Seperate out the tasks to update/Delete
            pipBrandProjIds.add(task.TaskRay__Project__r.Brand__r.Name+''+task.TaskRay__Project__c); 
            mapProjs.put(task.TaskRay__Project__c, task.TaskRay__Project__r);
            mapTasks = buildOperationMap(new List<TASKRAY__Project_Task__c>{task},mapTasks);
            
        } 
        //Initialize tasks for new Insertion 
        if(!Trigger.isDelete)
        for(TASKRAY__Project_task__c task : getNewTasks(syncLibraryItems, pipBrandProjIds)){
            mapTasks = buildOperationMap(new List<TASKRAY__Project_Task__c>{task},mapTasks);
        }
        return mapTasks; 
    }

    private Map<String, List<TASKRAY__Project_Task__c>> buildOperationMap(List<TASKRAY__Project_Task__c> tasks, Map<String, List<TASKRAY__Project_Task__c>> mapTasks){
        for(TASKRAY__Project_Task__c task : tasks){
        string  Operation = taskOperation(task);
        List<TASKRAY__Project_Task__c> listTasks = new List<TASKRAY__Project_Task__c>();
        if(mapTasks.ContainsKey(Operation))
            {   
                listTasks = mapTasks.get(Operation);
                listTasks.add(task);
            }
            else{
                listTasks.add(task);
            }    
        mapTasks.put(Operation, listTasks);
    
        }
        return mapTasks;
    }

    //Identify the operation to be assigned for task. 
    private string taskOperation(TASKRAY__Project_Task__c task){
        String Operation; 
        String taskid = task.id;
        if(trigger.isDelete || (taskId != null && task.PIP_Library_Item__c != Null && mapPIPs.get(task.PIP_Library_Item__c).Brand__c != Null &&
            (mapPIPs != null && mapProjs != null && !mapPIPs.get(task.PIP_Library_Item__c).Brand__c.Contains(mapProjs.get(task.TASKRAY__Project__c).Brand__r.Name)) || (taskID != null && mapPIPs != null && (!mapPIPs.get(task.PIP_Library_Item__c).Active__c) || mapPIPs.get(task.PIP_Library_Item__c).BRAND__c == null)))
            Operation = 'Delete';
        else if(task.id != null && task.PIP_Library_Item__c != Null && task.PIP_Library_Item__r.Brand__c != Null &&
             (mapPIPs != null && mapProjs != null && mapPIPs.get(task.PIP_Library_Item__c).Brand__c.Contains(mapProjs.get(task.TASKRAY__Project__c).Brand__r.Name)))
            Operation  = 'Update';
        
        else if(task.id == null)
            Operation = 'Insert';
        return Operation;
    }
    //query Associated Tasks
    private List<TASKRAY__Project_Task__c> queryAssociatedTasks(Set<ID> libraryLineItemIds){
        List<TASKRAY__Project_Task__c> tasksList = new List<TASKRAY__Project_Task__c>();
        tasksList = [Select id, TASKRAY__Project__c, TASKRAY__Project__r.Brand__r.Name, PIP_Library_Item__r.Brand__c, PIP_Library_Item__r.Active__c, Category__c, Program__c
                        , PI_Quantity__c, TASKRAY__Project__r.Number_of_Rooms__c from TASKRAY__Project_Task__c
                            Where PIP_Library_Item__c IN: libraryLineItemIds and TaskRay__Project__r.TASKRAY__trTemplate__c = true
                            And TaskRay__Project__r.RecordType.DeveloperName =: AppConstants.TASKRAY_PROJECT_RECORDTYPE_PIP_TEMPLATE];
        return tasksList;
    }

    //Get new Tasks
    private List<TASKRAY__Project_Task__c> getNewTasks(List<PIP_Library_Item__c> syncLibraryItems	, Set<String> pipBrandProjIds){
        List<TASKRAY__Project_Task__c> projTaskList = new List<TASKRAY__Project_Task__c>();
        Map<String, List<PIP_Library_Item__c>> brandLibraryMap = new Map<String, List<PIP_Library_Item__c>>();
        Set<String> brandSet = new Set<String>();
        for(PIP_Library_Item__c pipLibraryLineItem : syncLibraryItems	){
            if(pipLibraryLineItem.Active__c && pipLibraryLineItem.Brand__c != Null){
                set<String> tempBrandSet = new Set<String>(pipLibraryLineItem.Brand__c.split(';'));
                for(String brandTemp : tempBrandSet){
                    List<PIP_Library_Item__c> tempPIPLibraryList = new List<PIP_Library_Item__c>();
                    if(brandLibraryMap.ContainsKey(brandTemp)){
                        tempPIPLibraryList = brandLibraryMap.get(brandTemp);
                        tempPIPLibraryList.add(pipLibraryLineItem);
                    }
                    else{
                        tempPIPLibraryList.add(pipLibraryLineItem);
                    }
                    brandLibraryMap.put(brandTemp, tempPIPLibraryList);
                    brandSet.add(brandTemp);
                }
            }
        }
        
        for(TASKRAY__Project__c taskProject :  [Select id, BRAND__c, Brand__r.Name, Number_of_Rooms__c from TASKRAY__Project__c Where
                TASKRAY__trTemplate__c = true  And RecordType.DeveloperName =: AppConstants.TASKRAY_PROJECT_RECORDTYPE_PIP_TEMPLATE
                and BRAND__r.Name IN:  brandSet]){
            //Initialize Tasks 
            mapProjs.put(taskProject.id, taskProject);
            if(!pipBrandProjIds.Contains(taskProject.Brand__r.Name+''+taskProject.id) 
                    &&  brandLibraryMap.get(taskProject.Brand__r.Name) != Null){
                projTaskList.addall(initTasks(taskProject,brandLibraryMap.get(taskProject.Brand__r.Name)));
            }
        }
        return projTaskList;
    }

    private List<TASKRAY__Project_Task__c> syncTaskFields(List<TASKRAY__Project_Task__c> tasks){
        List<TASKRAY__Project_Task__c> taskList = new List<TASKRAY__Project_Task__c>();
        for(TASKRAY__Project_Task__c task : tasks)
            taskList.add(initTask(task.TaskRay__Project__r, mapPIPs.get(task.PIP_Library_Item__c), task));
        return taskList;
    }

    private List<TASKRAY__Project_Task__c> initTasks(TaskRay__Project__c taskProj, List<PIP_Library_Item__c> pipLibraryLineItems){
        List<TASKRAY__Project_Task__c> initializedTasks = new  List<TASKRAY__Project_Task__c>();
        for(PIP_Library_Item__c pipLI : pipLibraryLineItems){
           initializedTasks.add(initTask(taskProj,pipLI));
        }
        return initializedTasks;
    }

    private TASKRAY__Project_Task__c initTask(TaskRay__Project__c taskProj, PIP_Library_Item__c pipLibraryLineItem){
        TASKRAY__Project_Task__c task = new TASKRAY__Project_Task__c();
        return initTask(taskProj,pipLibraryLineItem,task);
    }

    private TASKRAY__Project_Task__c initTask(TaskRay__Project__c taskProj, PIP_Library_Item__c pipLI, TASKRAY__Project_Task__c task){
        task.TASKRAY__Project__c = taskProj.id;
        task.PIP_Library_Item__c = pipLI.id;
        task.TaskRay__Project__r = taskProj;
        task.PIP_Library_Item__r = pipLi;
        task.PI_Architecture__c = pipLI.PI_Architecture__c;
        task.PI_Brands__c = pipLI.PI_Brands__c;
        task.PI_Design__c = pipLI.PI_Design__c;
        task.PI_Education__c = pipLI.PI_Education__c;
        task.PI_HGI__c = pipLI.PI_HGI__c;
        task.PI_Incentive_Program__c = pipLI.PI_Incentive_Program__c;
        task.PI_Maintenance__c = pipLI.PI_Maintenance__c;
        task.PI_Procurement__c = pipLI.PI_Procurement__c;
        task.PI_QA__c = pipLI.PI_QA__c;
        task.PI_Signage__c = pipLI.PI_Signage__c;
        task.PI_Verify__c = pipLI.PI_Verify__c;
        task.TaskRay__Description__c = pipLI.PI_Description__c;
        task.Name = pipLI.Name;
        task.PI_Short_Name__c = pipLI.PI_Short_Name__c;
        task.PI_Major_Minor__c = pipLI.PI_Major_Minor__c;
        task.PI_Type__c = pipLI.PI_Type__c;
        task.Active__c	= pipLI.Active__c;
        task.PI_Baseline__c = pipLI.PI_Baseline__c; 
        if(task.id == null)       
            task.PI_Item_Due_Date__c = System.Today().addMonths(12);
		task.PI_Estimated_Cost_per_Cost_Unit__c = pipLI.PI_Average_Cost__c;
        task.PI_Cost_Units__c = pipLI.PI_Cost_Units__c;
        task.Category__c = pipLI.Category__c;
        task.Program__c = pipLI.Program__c;

        if (pipLI.PI_Cost_Units__c == AppConstants.COST_UNIT_PER_BUILDING) {
            task.PI_Quantity__c = AppConstants.PER_BUILDING_QUANTITY;
        }else if (pipLI.PI_Cost_Units__c == AppConstants.COST_UNIT_PER_ROOM) {
            if(taskProj != null && taskProj.Number_of_Rooms__c != null){
                task.PI_Quantity__c = taskProj.Number_of_Rooms__c;
            }
        }

        return task;
    }

    /**
     * @description Method to update In Use checkbox on the PIP Library Item when Active checkbox is set to true
     *
     * @param lstNewPipLibraryItems - List of new PIP_Library_Item__c
     * @param mapOldPipLibraryItemsByIds - Map of old PIP_Library_Item__c
     */
    public void updateInUseCheckbox(List<PIP_Library_Item__c> lstNewPipLibraryItems,
            Map<Id,PIP_Library_Item__c> mapOldPIPLibraryItemsByIds){

        for(PIP_Library_Item__c pipLibraryItem : lstNewPipLibraryItems){
            if(pipLibraryItem.Active__c == true) {
                //if Insert, default Active as false
                if(mapOldPIPLibraryItemsByIds == null){
                    pipLibraryItem.Active__c = false;
                }
                else if(mapOldPIPLibraryItemsByIds != null
                        && mapOldPIPLibraryItemsByIds.containsKey(pipLibraryItem.Id)
                        && mapOldPIPLibraryItemsByIds.get(pipLibraryItem.Id).Active__c == false){
                    pipLibraryItem.In_Use__c = true;
                }
            }
        }
    }

}