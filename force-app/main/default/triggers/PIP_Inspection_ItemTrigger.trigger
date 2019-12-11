/**
 *  @description Trigger for PIP_Inspection_Item__c object
 *  @author Pradnya Desai
 *  @date 2019-09-15
 */


trigger PIP_Inspection_ItemTrigger on PIP_Inspection_Item__c (before insert, before update, after insert, after update) {
    PIP_Inspection_ItemTriggerHandler pipInspectionItemTriggerHandler = new PIP_Inspection_ItemTriggerHandler();
}