/**
 *  @description Handler class for PIP_Inspection_Item trigger
 *  @author Pradnya Desai
 *  @date 2019-09-13
 */
public inherited sharing class PIP_Inspection_ItemTriggerHandler extends TriggerBase{

    //Trigger Variables
    public static Boolean bypassTrigger = false;
    public static Boolean isAfterUpdateTriggerReEntry = false;

    public PIP_Inspection_ItemTriggerHandler() {
        setBypassTrigger(bypassTrigger);
    }

    // After Insert execution context
    public override void afterInsert() {
        PIP_Inspection_ItemTriggerHelper pipInspectionItemTriggerHelper = new PIP_Inspection_ItemTriggerHelper();
        pipInspectionItemTriggerHelper.updatePIPItem((List<PIP_Inspection_Item__c>) Trigger.new, false,
                null);
    }

    // After Insert execution context
    public override void afterUpdate() {
        PIP_Inspection_ItemTriggerHelper pipInspectionItemTriggerHelper = new PIP_Inspection_ItemTriggerHelper();
        if(!isAfterUpdateTriggerReEntry) {
            pipInspectionItemTriggerHelper.updatePIPItem((List<PIP_Inspection_Item__c>) Trigger.new, true,
                    (Map<Id, PIP_Inspection_Item__c>) Trigger.oldMap );
        }
        isAfterUpdateTriggerReEntry = true;
    }

}