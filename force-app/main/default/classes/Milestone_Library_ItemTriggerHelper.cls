public without sharing class Milestone_Library_ItemTriggerHelper {
    public Milestone_Library_ItemTriggerHelper() {

    }
    public Map<id,TaskRay__Project__c> mapProjs;
    public Map<Id, Milestone_Library_Item__c> mapMilestones;
    //Method to perform the sync of the Task line items
    public void syncTasksWithMilestones(List<Milestone_Library_Item__c> libraryItemList){
        List<Milestone_Library_Item__c> syncLibraryItems   = new List<Milestone_Library_Item__c>();
        mapMilestones = new Map<Id, Milestone_Library_Item__c>();
        //check the fields on Milestone Library Item to see if any of associated fields have changed 
        for(Milestone_Library_Item__c milestoneLibraryLineItem : libraryItemList){
            if(syncRequired(milestoneLibraryLineItem)){
                    syncLibraryItems.add(milestoneLibraryLineItem);
                    mapMilestones.put(milestoneLibraryLineItem.id,milestoneLibraryLineItem);
            }

        }
        if(syncLibraryItems  .size()>0){
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

    //Filter out the Milestone Lines 
    private boolean syncRequired(Milestone_Library_Item__c libraryItem){
        boolean syncRequired; 
        //Add checks. 
        if(libraryItem.Baseline__c)
        syncRequired = true;
        else 
        syncRequired = false;

        return syncRequired;
    }

    //Build a map with operation and task list. 
    private Map<String, List<TASKRAY__Project_Task__c>> getTasks(List<Milestone_Library_Item__c> syncLibraryItems  ){
        Map<String, List<TASKRAY__Project_Task__c>> mapTasks = new Map<String, List<TASKRAY__Project_Task__c>>();
        Set<String> openingBrandProjIds = new Set<String>();
        mapProjs = new Map<Id, TaskRay__Project__c>();

        //Collect the Brands of the Library line item
        Set<ID> LibraryLineItemIds = (new Map<ID,Milestone_Library_Item__c>(syncLibraryItems)).KeySet();

        //Query Associated Tasks
        for(TASKRAY__Project_Task__c task : queryAssociatedTasks(libraryLineItemIds)){
            //Seperate out the tasks to update/Delete
openingBrandProjIds.add(task.TaskRay__Project__r.Brand__r.Name+''+task.TaskRay__Project__c); 
            mapProjs.put(task.TaskRay__Project__c, task.TaskRay__Project__r);
            mapTasks = buildOperationMap(new List<TASKRAY__Project_Task__c>{task},mapTasks);
            
        } 
        //Initialize tasks for new Insertion 
        if(!Trigger.isDelete)
        for(TASKRAY__Project_task__c task : getNewTasks(syncLibraryItems, openingBrandProjIds)){
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
        if(trigger.isDelete || (taskId != null && task.Milestone_Library_Item__c != Null && mapMilestones.get(task.Milestone_Library_Item__c).Brand__c != Null && 
            (mapMilestones != null && mapProjs != null && !mapMilestones.get(task.Milestone_Library_Item__c).Brand__c.Contains(mapProjs.get(task.TASKRAY__Project__c).Brand__r.Name)) || (taskID != null && mapMilestones != null && (!mapMilestones.get(task.Milestone_Library_Item__c).Active__c) || mapMilestones.get(task.Milestone_Library_Item__c).Brand__c == null)))
            Operation = 'Delete';
        else if(task.id != null && task.Milestone_Library_Item__c != Null && task.Milestone_Library_Item__r.Brand__c != Null &&
             (mapMilestones != null && mapProjs != null && mapMilestones.get(task.Milestone_Library_Item__c).Brand__c.Contains(mapProjs.get(task.TASKRAY__Project__c).Brand__r.Name)))
            Operation  = 'Update';
        
        else if(task.id == null)
            Operation = 'Insert';
        return Operation;
    }
    //query Associated Tasks
    private List<TASKRAY__Project_Task__c> queryAssociatedTasks(Set<ID> libraryLineItemIds){
        List<TASKRAY__Project_Task__c> tasksList = new List<TASKRAY__Project_Task__c>();
        tasksList = [Select id, TASKRAY__Project__c, TASKRAY__Project__r.Brand__r.Name, Milestone_Library_Item__r.Brand__c, Milestone_Library_Item__r.Active__c from TASKRAY__Project_Task__c
                            Where Milestone_Library_Item__c IN: libraryLineItemIds and TaskRay__Project__r.TASKRAY__trTemplate__c = true
                            And TaskRay__Project__r.RecordType.DeveloperName =: AppConstants.TASKRAY_PROJECT_RECORDTYPE_OPENING_TEMPLATE];
        return tasksList;
    }

    //Get new Tasks
    private List<TASKRAY__Project_Task__c> getNewTasks(List<Milestone_Library_Item__c> syncLibraryItems  , Set<String> openingBrandProjIds){
        List<TASKRAY__Project_Task__c> projTaskList = new List<TASKRAY__Project_Task__c>();
        Map<String, List<Milestone_Library_Item__c>> brandLibraryMap = new Map<String, List<Milestone_Library_Item__c>>();
        Set<String> brandSet = new Set<String>();
        for(Milestone_Library_Item__c milestoneLibraryLineItem : syncLibraryItems  ){
            if(milestoneLibraryLineItem.Active__c && milestoneLibraryLineItem.Brand__c != Null){
                set<String> tempBrandSet = new Set<String>(milestoneLibraryLineItem.Brand__c.split(';'));
                for(String brandTemp : tempBrandSet){
                    List<Milestone_Library_Item__c> tempMilestoneLibraryList = new List<Milestone_Library_Item__c>();
                    if(brandLibraryMap.ContainsKey(brandTemp)){
                        tempMilestoneLibraryList = brandLibraryMap.get(brandTemp);
                        tempMilestoneLibraryList.add(milestoneLibraryLineItem);
                    }
                    else{
                        tempMilestoneLibraryList.add(milestoneLibraryLineItem);
                    }
                    brandLibraryMap.put(brandTemp, tempMilestoneLibraryList);
                    brandSet.add(brandTemp);
                }
            }
        }
        
        for(TASKRAY__Project__c taskProject :  [Select id, BRAND__c, Brand__r.Name from TASKRAY__Project__c Where
                TASKRAY__trTemplate__c = true  And RecordType.DeveloperName =: AppConstants.TASKRAY_PROJECT_RECORDTYPE_OPENING_TEMPLATE
                and BRAND__r.Name IN:  brandSet]){
            //Initialize Tasks 
            mapProjs.put(taskProject.id, taskProject);
            if(!openingBrandProjIds.Contains(taskProject.Brand__r.Name+''+taskProject.id) 
                    &&  brandLibraryMap.get(taskProject.Brand__r.Name) != Null){
                projTaskList.addall(initTasks(taskProject,brandLibraryMap.get(taskProject.Brand__r.Name)));
            }
        }
        return projTaskList;
    }

    private List<TASKRAY__Project_Task__c> syncTaskFields(List<TASKRAY__Project_Task__c> tasks){
        List<TASKRAY__Project_Task__c> taskList = new List<TASKRAY__Project_Task__c>();
        for(TASKRAY__Project_Task__c task : tasks)
            taskList.add(initTask(task.TaskRay__Project__r, mapMilestones.get(task.Milestone_Library_Item__c), task));
        return taskList;
    }

    private List<TASKRAY__Project_Task__c> initTasks(TaskRay__Project__c taskProj, List<Milestone_Library_Item__c> milestoneLibraryLineItems){
        List<TASKRAY__Project_Task__c> initializedTasks = new  List<TASKRAY__Project_Task__c>();
        for(Milestone_Library_Item__c milestoneLI : milestoneLibraryLineItems){
           initializedTasks.add(initTask(taskProj,milestoneLI));
        }
        return initializedTasks;
    }

    private TASKRAY__Project_Task__c initTask(TaskRay__Project__c taskProj, Milestone_Library_Item__c milestoneLibraryLineItem){
        TASKRAY__Project_Task__c task = new TASKRAY__Project_Task__c();
        return initTask(taskProj,milestoneLibraryLineItem,task);
    }

    private TASKRAY__Project_Task__c initTask(TaskRay__Project__c taskProj, Milestone_Library_Item__c milestoneLI, TASKRAY__Project_Task__c task){
        task.TASKRAY__Project__c = taskProj.id;
        task.Milestone_Library_Item__c = milestoneLI.id;
        task.TaskRay__Project__r = taskProj;
        task.Milestone_Library_Item__r = milestoneLi;
        task.Name = milestoneLI.Name;
        task.MI_Milestone_Type__c = milestoneLI.Milestone_Type__c;
                    
return task;
    
				}

}