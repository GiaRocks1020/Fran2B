/**
 *  @description Trigger for Error_Log_Event__e object
 *  @author Pradnya Desai
 *  @date 2019-09-29
 */


trigger ErrorLogEventTrigger on Error_Log_Event__e (after insert) {

    ErrorLogEventTriggerHandler errorLogEventTriggerHandler = new ErrorLogEventTriggerHandler();

}