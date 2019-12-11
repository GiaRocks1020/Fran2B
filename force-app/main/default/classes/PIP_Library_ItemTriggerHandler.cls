/**
 * @description TriggerHandler for PIP_Library_Item__C object
 *
 * @author Madan Morusu
 * @date 2019-08-22
 */
public without  sharing class PIP_Library_ItemTriggerHandler extends TriggerBase{
    //Trigger Variables
    public static Boolean bypassTrigger = false;
    public static Boolean isBeforeInsertTriggerReEntry = false;
    public static Boolean isBeforeUpdateTriggerReEntry = false;
    public static Boolean isAfterInsertTriggerReEntry = false;
    public static Boolean isAfterUpdateTriggerReEntry = false;
    public static Boolean isBeforeDeleteTriggerReEntry = false;

    public PIP_Library_ItemTriggerHandler() {
        setBypassTrigger(bypassTrigger);
    }

    //Before Insert context
    public override void beforeInsert(){
        PIP_Library_ItemTriggerHelper triggerHelper = new PIP_Library_ItemTriggerHelper();

        if(isBeforeInsertTriggerReEntry){
            // Execute code for recursive Trigger
        }
        if(!isBeforeInsertTriggerReEntry){
            triggerHelper.updateInUseCheckbox((List<PIP_Library_Item__c>) trigger.new, null);
        }
        isBeforeInsertTriggerReEntry = true;
    }

    //Before Update context
    public override void beforeUpdate(){
        PIP_Library_ItemTriggerHelper triggerHelper = new PIP_Library_ItemTriggerHelper();

        if(isBeforeUpdateTriggerReEntry){
            // Execute code for recursive Trigger
        }
        if(!isBeforeUpdateTriggerReEntry){
            triggerHelper.updateInUseCheckbox((List<PIP_Library_Item__c>) Trigger.new,
                    (Map<Id, PIP_Library_Item__c>) Trigger.oldMap);
        }
        isBeforeUpdateTriggerReEntry = true;
    }


    // Before Insert execution context
	public override void AfterInsert() {
		// Query the Associated Tasks and update them. 

		PIP_Library_ItemTriggerHelper triggerHelper = new PIP_Library_ItemTriggerHelper();
        if(isAfterInsertTriggerReEntry){
            // Execute code for recursive Trigger
        }
        if(!isAfterInsertTriggerReEntry){
            triggerHelper.syncTasksWithLineItems((List<PIP_Library_Item__C>) trigger.new);
        }
        isAfterInsertTriggerReEntry = true;

	}

	// Before Update execution context
	public override void AfterUpdate() {
		// Query the Associated Tasks and update them. 
		PIP_Library_ItemTriggerHelper triggerHelper = new PIP_Library_ItemTriggerHelper();
        if(isAfterUpdateTriggerReEntry){
            // Execute code for recursive Trigger
        }
        if(!isAfterUpdateTriggerReEntry){
            triggerHelper.syncTasksWithLineItems((List<PIP_Library_Item__C>) trigger.new);
        }
        isAfterUpdateTriggerReEntry = true;

	}
    // Before Delete execution context
	public override void beforeDelete() {
		// Query the Associated Tasks and update them. 
		PIP_Library_ItemTriggerHelper triggerHelper = new PIP_Library_ItemTriggerHelper();
        if(isbeforeDeleteTriggerReEntry){
            // Execute code for recursive Trigger
        }
        if(!isbeforeDeleteTriggerReEntry){
            triggerHelper.syncTasksWithLineItems((List<PIP_Library_Item__C>) trigger.new);
        }
        isbeforeDeleteTriggerReEntry = true;

	}
}