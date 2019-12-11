/**
 *  @description Trigger for PIP_Inspection__c object
 *  @author Pradnya Desai
 *  @date 2019-09-30
 */

trigger PIPInspectionTrigger on PIP_Inspection__c (before insert, before update) {
    PIPInspectionTriggerHandler pipInspectionTriggerHandler = new PIPInspectionTriggerHandler();

}