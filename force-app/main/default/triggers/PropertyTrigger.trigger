/**
* @Description Trigger for Property object
* @Author : Esteban Woodring
* @Date 05/08/18
*
**/
trigger PropertyTrigger on Property__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)  { 
       PropertyTriggerHelper propHelper = new PropertyTriggerHelper();
}