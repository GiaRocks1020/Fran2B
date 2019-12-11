public with sharing class ApplicationTriggerHelper extends TriggerBase{
/****************************************************************
    	DESCRIPTION:
    		During Trigger exection context method is executed before insert.  Append business logic methods here.
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	//public override void beforeInsert(){
	//}
    /****************************************************************
    	DESCRIPTION:
    		During Trigger exection context method is executed after insert.  Append business logic methods here.
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	//public override void afterInsert(){
    //}
	/****************************************************************
    	DESCRIPTION:
    		During Trigger exection context method is executed before update.  Append business logic methods here.
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	public override void beforeUpdate(){
        List<Application__c> applicationsThatNeedTimeExtended = ApplicationHelper.getExpiredAppsWithStartDateRenewed((List<Application__c>) Trigger.new, (Map<Id,Application__c>) Trigger.oldMap);
        if(applicationsThatNeedTimeExtended.size() > 0){
            ApplicationHelper.changeStatusToInProgressAndActivateUsers(applicationsThatNeedTimeExtended);
        }
	}
	/****************************************************************
    	DESCRIPTION:
    		During Trigger exection context method is executed before delete.  Append business logic methods here.
    	INPUTS:
    		None
    	RETURNS
    		void
    ****************************************************************/	
	//public override void beforeDelete(){   
	//}
	/*******************************************************************************************
    	DESCRIPTION:
    		During Trigger exection context method is executed after update.  Append business logic methods here.
    	INPUTS:
    		None
    	RETURNS
    		void
    ************************************************************************************************/	
	//public override void afterUpdate(){
    //}
}