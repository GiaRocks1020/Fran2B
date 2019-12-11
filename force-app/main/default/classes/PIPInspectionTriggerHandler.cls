/**
 *  @description Handler class for PIP_Inspection__c trigger
 *  @author Pradnya Desai
 *  @date 2019-09-30
 */

public inherited sharing class PIPInspectionTriggerHandler extends TriggerBase{

    //Trigger Variables
    public static Boolean bypassTrigger = false;
    public static Boolean isAfterUpdateTriggerReEntry = false;

    public PIPInspectionTriggerHandler() {
        setBypassTrigger(bypassTrigger);
    }

    // After Insert execution context
    public override void beforeInsert() {
        PIPInspectionTriggerHelper pipInspectionTriggerHelper = new PIPInspectionTriggerHelper();
        pipInspectionTriggerHelper.updateLetterSentDateHGIInspectionResults((List<PIP_Inspection__c>) Trigger.new, null);
    }

    // After Insert execution context
    public override void beforeUpdate() {
        PIPInspectionTriggerHelper pipInspectionTriggerHelper = new PIPInspectionTriggerHelper();
        pipInspectionTriggerHelper.updateLetterSentDateHGIInspectionResults((List<PIP_Inspection__c>) Trigger.new
                , (Map<Id, PIP_Inspection__c>) Trigger.oldMap);
    }

}