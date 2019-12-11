/*
 * @Author: Jagan Gorre
 * @Desc: Trigger for Ownership Relation to do the following
 * 1) Create cutom object records or publish platform events whenever Ownership Relation record is created or updated.
*/
trigger OwnershipRelationTrigger on Ownership_Relation__c (before insert, after insert, before update, after update, before delete, after delete) {
    if(!Metadata_Control__c.getInstance().Disable_All_Triggers__c && !Metadata_Control__c.getInstance().Disable_Ownership_Relation_Trigger__c){
        TriggerExecutionHandler.execute(new OwnershipRelationTriggerExecutor());
    }
}