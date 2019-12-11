/**
 *  @description Helper class for ErrorLogEvent trigger
 *  @author Pradnya Desai
 *  @date 2019-09-29
*/

public inherited sharing class ErrorLogEventTriggerHelper {

    /**
	 * @description This method will insert Error Log record 
	 *
	 * @param newInspectionItems - List<PIP_Inspection_Item__c>
	 * @return Map<Id, List<PIP_Inspection_Item__c>>
	 */
    public void writeErrorLogs(List<Error_Log_Event__e> newErrorEvent){
        List<Error_Log__c> errorLogsList = new List<Error_Log__c>();
        for(Error_Log_Event__e errorEvent: newErrorEvent){
            Error_Log__c objErrorLog = new Error_Log__c();
            objErrorLog.Class_Name__c = errorEvent.Class_Name__c;
            objErrorLog.Error_Code__c = errorEvent.Error_Code__c;
            objErrorLog.Error_Message__c = errorEvent.Error_Message__c;
            objErrorLog.Exception_Stack_Trace__c = errorEvent.Exception_Stack_Trace__c;
            objErrorLog.Failed_Record_List__c = errorEvent.Failed_Record_List__c;
            objErrorLog.HTTP_Status_Code__c = errorEvent.HTTP_Status_Code__c;
            objErrorLog.Line_Number__c = errorEvent.Line_Number__c;
            objErrorLog.Log_Time__c = errorEvent.Log_Time__c;
            objErrorLog.Method_Name__c = errorEvent.Method_Name__c;
            objErrorLog.Failed_Record_Id__c = errorEvent.Failed_Record_Id__c;
            objErrorLog.Failed_Record_Name__c = errorEvent.Failed_Record_Name__c;
            objErrorLog.Field_Names__c = errorEvent.Field_Names__c;
            objErrorLog.Total_Time_Taken__c = errorEvent.Total_Time_Taken__c;
            objErrorLog.User__c = errorEvent.User__c;

            errorLogsList.add(objErrorLog);
        }
        try{
            if(errorLogsList.size() > 0){
                insert errorLogsList;
            }
        }catch(Exception ex){
            System.debug('Exception occurred in ErrorLogEventTriggerHelper : '+ ex.getMessage());
        }

    }

}