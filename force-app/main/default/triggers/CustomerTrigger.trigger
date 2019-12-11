/*
 * @Author: Jagan Gorre
 * @Desc: Trigger for Customer object to do the following
 * 1) Create cutom object records or publish platform events whenever a customer record is created or updated.
*/
trigger CustomerTrigger on Customer__c (before insert, after insert, before update, after update, before delete, after delete) {
	if(!Metadata_Control__c.getInstance().Disable_All_Triggers__c && !Metadata_Control__c.getInstance().Disable_Customer_Trigger__c ){
        TriggerExecutionHandler.execute(new CustomerTriggerExecutor());
    }
}