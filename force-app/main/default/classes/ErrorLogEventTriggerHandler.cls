/**
 *  @description Handler class for ErrorLogEvent trigger
 *  @author Pradnya Desai
 *  @date 2019-09-29
 */

public with sharing class ErrorLogEventTriggerHandler extends TriggerBase{

    //Trigger Variables
    public static Boolean bypassTrigger = false;
    public static Boolean isAfterUpdateTriggerReEntry = false;

    public ErrorLogEventTriggerHandler() {
        setBypassTrigger(bypassTrigger);
    }

    // After Insert execution context
    public override void afterInsert() {
        ErrorLogEventTriggerHelper errorLogEventTriggerHelper = new ErrorLogEventTriggerHelper();
        errorLogEventTriggerHelper.writeErrorLogs((List<Error_Log_Event__e>) Trigger.new);
    }

}