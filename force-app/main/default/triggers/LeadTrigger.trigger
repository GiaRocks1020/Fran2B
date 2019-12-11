/**
* @Description Trigger for Lead object
* @Author : Esteban Woodring
* @Date 02/14/18
*
**/
trigger LeadTrigger on Lead (after delete, after insert, after undelete, after update, before delete, before insert, before update)  { 
       LeadTriggerHelper leadHelper = new LeadTriggerHelper();
}