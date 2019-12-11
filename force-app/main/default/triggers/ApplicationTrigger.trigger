/**
* @Description Trigger for Application object
* @Author : Esteban Woodring
* @Date 07/18/18
*
**/
trigger ApplicationTrigger on Application__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ApplicationTriggerHelper appHelper = new ApplicationTriggerHelper();
}