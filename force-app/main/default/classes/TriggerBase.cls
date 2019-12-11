public virtual class TriggerBase{
	// Variables
	@TestVisible
	private Boolean bypassTrigger = false;
	@TestVisible
	private SObjectType sObjectTypeValue = null;

	public static boolean initialized {get;set;} 
	public static boolean updateCalled {get;set;} // Used to prevent double firing updates

    /****************************************************************
    	DESCRIPTION:
    		Constructor
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public TriggerBase(){
		if (updateCalled == null){
			updateCalled = false;
		}
		if (initialized == null || initialized == false){
			initializeStatics();
			initialized = true;
		}
		dispatcher();
	}
	
    /****************************************************************
    	DESCRIPTION:
    		Override method to initializes static properties that can be used across context.  
    		Only use this method for reference data that will not be impacted by trigger logic.
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public virtual void initializeStatics(){
		initialized = true;
	}

    /****************************************************************
    	DESCRIPTION:
    		Dispacther method to call the appropriate method based on the triggers execution context.
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public void dispatcher(){
		if (overrideTrigger() || ! Trigger.isExecuting){
			return;
		}
		if (Trigger.isBefore && Trigger.isInsert){
			beforeInsert();	
		}
		if (Trigger.isAfter && Trigger.isInsert){
			afterInsert();
		}
		if (Trigger.isBefore && Trigger.isUpdate){
			beforeUpdate();
		}
		if (Trigger.isAfter && Trigger.isUpdate){
			afterUpdate();
		}
		if (Trigger.isBefore && Trigger.isDelete){
			beforeDelete();
		}
		if (Trigger.isAfter && Trigger.isDelete){
			afterDelete();
		}
		if (Trigger.isAfter && Trigger.isUndelete){
			afterUndelete();
		}
	}
	
    /****************************************************************
    	DESCRIPTION:
    		Override this method for logic to be executed before insert
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public virtual void beforeInsert(){
	}

    /****************************************************************
    	DESCRIPTION:
    		Override this method for logic to be executed after insert
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public virtual void afterInsert(){		
	}

    /****************************************************************
    	DESCRIPTION:
    		Override this method for logic to be executed before udpate
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/		
	public virtual void beforeUpdate(){		
	}

    /****************************************************************
    	DESCRIPTION:
    		Override this method for logic to be executed after update
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public virtual void afterUpdate(){		
	}

    /****************************************************************
    	DESCRIPTION:
    		Override this method for logic to be executed before delete
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/		
	public virtual void beforeDelete(){		
	}
	
    /****************************************************************
    	DESCRIPTION:
    		Override this method for logic to be executed after delete
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/		
	public virtual void afterDelete(){		
	}

    /****************************************************************
    	DESCRIPTION:
    		Override this method for logic to be executed after undelete
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public virtual void afterUndelete(){		
	}

	/**
	 * @description Determines if the trigger will be overridden.
	 *
	 * @return Boolean
	 */
	private Boolean overrideTrigger() {
		Boolean overrideTrigger = false;

		SObjectType triggerObject = trigger.new != null ? trigger.new.getSObjectType() : trigger.oldMap != null ?
			trigger.oldMap.getSObjectType() : sObjectTypeValue;

		if(TriggerOverride.bypassTrigger(triggerObject) || bypassTrigger) {
			system.debug(triggerObject + ' trigger bypassed');
			overrideTrigger = true;
		}

		return overrideTrigger;
	}

	/**
	 * @description Used to Override Process Builder. Takes no action from Apex.
	 *
	 * @return void
	 */
	@InvocableMethod(label='Disable Process Builder' description='Used to disable a process builder. Takes no action.')
	public static void disableProcessBuilder() { }

	/**
	 * @description Used to set the bypassTrigger variable which allows for a trigger to be overridden from
	 * the object trigger handler. This method would be called from the constructor passing in the static variable
	 * set in trigger handler specific to an object.
	 *
	 * @param bypassTrigger Boolean value to determine if the trigger should be bypassed
	 * @return void
	 */
	public virtual void setBypassTrigger(Boolean bypassTrigger) { this.bypassTrigger = bypassTrigger; }

	public Boolean getBypassTrigger() { return bypassTrigger; }
}