public without  sharing class Milestone_Library_ItemTriggerHandler extends TriggerBase{
    //Trigger Variables
    public static Boolean bypassTrigger = false;
    public static Boolean isBeforeInsertTriggerReEntry = false;
    public static Boolean isBeforeUpdateTriggerReEntry = false;
    public static Boolean isAfterInsertTriggerReEntry = false;
    public static Boolean isAfterUpdateTriggerReEntry = false;
    public static Boolean isBeforeDeleteTriggerReEntry = false;

    public Milestone_Library_ItemTriggerHandler() {
        setBypassTrigger(bypassTrigger);
    }

    //Before Insert context
    public override void beforeInsert(){
        Milestone_Library_ItemTriggerHelper triggerHelper = new Milestone_Library_ItemTriggerHelper();

        if(isBeforeInsertTriggerReEntry){
            // Execute code for recursive Trigger
        }
        
        isBeforeInsertTriggerReEntry = true;
    }

    //Before Update context
    public override void beforeUpdate(){
        Milestone_Library_ItemTriggerHelper triggerHelper = new Milestone_Library_ItemTriggerHelper();

        if(isBeforeUpdateTriggerReEntry){
            // Execute code for recursive Trigger
        }
        
        isBeforeUpdateTriggerReEntry = true;
    }


    // Before Insert execution context
  public override void AfterInsert() {
    	// Query the Associated Tasks and update them. 
    	Milestone_Library_ItemTriggerHelper triggerHelper = new Milestone_Library_ItemTriggerHelper();
        if(isAfterInsertTriggerReEntry){
            // Execute code for recursive Trigger
        }
        if(!isAfterInsertTriggerReEntry){
            triggerHelper.syncTasksWithMilestones((List<Milestone_Library_Item__C>) trigger.new);
        }
        isAfterInsertTriggerReEntry = true;

  }

  // Before Update execution context
  public override void AfterUpdate() {
    	// Query the Associated Tasks and update them. 
    	Milestone_Library_ItemTriggerHelper triggerHelper = new Milestone_Library_ItemTriggerHelper();
        if(isAfterUpdateTriggerReEntry){
            // Execute code for recursive Trigger
        }
        if(!isAfterInsertTriggerReEntry){
            triggerHelper.syncTasksWithMilestones((List<Milestone_Library_Item__C>) trigger.new);
        }
        isAfterUpdateTriggerReEntry = true;

  }
    // Before Delete execution context
  public override void beforeDelete() {
    	// Query the Associated Tasks and update them. 
   		Milestone_Library_ItemTriggerHelper triggerHelper = new Milestone_Library_ItemTriggerHelper();
        if(isbeforeDeleteTriggerReEntry){
            // Execute code for recursive Trigger
        }
        if(!isAfterInsertTriggerReEntry){
            triggerHelper.syncTasksWithMilestones((List<Milestone_Library_Item__C>) trigger.new);
        }
        isbeforeDeleteTriggerReEntry = true;

  }
}