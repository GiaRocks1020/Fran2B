/**
* @Description Trigger for Opportunity /Deal object
* @Author : Esteban Woodring
* @Date 04/10/18
*
**/
trigger OpportunityTrigger on Opportunity (after delete, after insert, after undelete, after update, before delete, before insert, before update)  { 
       OpportunityTriggerHelper oppHelper = new OpportunityTriggerHelper();
}