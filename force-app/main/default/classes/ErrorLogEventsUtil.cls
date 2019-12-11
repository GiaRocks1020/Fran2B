/**
 *  @description Util class to publish Error Log Events
 *  @author Pradnya Desai
 *  @date 2019-09-27
 */

public with sharing class ErrorLogEventsUtil {

    /**
	 * @description This method will trigger Error Log Platform Events for DML Exception
	 *
	 * @param ex - DMLException
	 * @param recordList - List<SObject> List of failed records
	 * @param fieldName - Schema.SObjectField for Name field on Parent SObject on which DML Exception occurred
	 * @param totalTimeInMilliSec - Long  Total time of transaction in Milli Second
	 */
    public static void publishErrorLogEventsForDMLException(DMLException ex, List<SObject> recordList,
            Schema.SObjectField fieldName, Long totalTimeInMilliSec, String className, String methodName){

        List<Error_Log_Event__e> errorLogEventsList = new List<Error_Log_Event__e>();
        //Add Exception handling logic here
        Integer index = null;
        for (Integer i = 0; i < ex.getNumDml(); i++) {
            Error_Log_Event__e errorLogEvent = new Error_Log_Event__e();
            errorLogEvent.Error_Message__c = ex.getDmlMessage(i);
            errorLogEvent.Failed_Record_Id__c = ex.getDmlId(i);
            index = ex.getDmlIndex(i);
            if(index != null && recordList.get(index) != null){
                errorLogEvent.Failed_Record_Name__c = (String)((recordList.get(index)).get(fieldName));
            }
            errorLogEvent.Error_Code__c = String.ValueOf(ex.getDmlType(i));
            errorLogEvent.Field_Names__c =  String.ValueOf(ex.getDmlFieldNames(i));
            errorLogEvent.Exception_Stack_Trace__c = ex.getStackTraceString();
            errorLogEvent.Total_Time_Taken__c = totalTimeInMilliSec;
            errorLogEvent.Class_Name__c = className;
            errorLogEvent.Method_Name__c = methodName;
            errorLogEvent.User__c = UserInfo.getUserId();
            errorLogEventsList.add(errorLogEvent);

        }
        List<Database.SaveResult> eventSaveResults = EventBus.publish(errorLogEventsList);
    }

    /**
	 * @description This method will trigger Error Log Platform Event for Generic Exception
	 *
	 * @param ex - Exception
	 * @param totalTimeInMilliSec - Long  Total time of transaction in Milli Second
	 * @param recordList - List<SObject> List of failed records
	 */
    public static Boolean publishErrorLogEventsForException(Exception ex, List<SObject> recordList,
            Long totalTimeInMilliSec, String className, String methodName){

        Error_Log_Event__e errorLogEvent = new Error_Log_Event__e();
        Boolean isSuccess = null;
        //Add Exception handling logic here

        errorLogEvent.Error_Message__c = ex.getMessage();
        errorLogEvent.Failed_Record_List__c = String.valueOf(recordList);
        errorLogEvent.Error_Code__c = 'Cause : '+ ex.getCause()+ ' , Type : ' + ex.getTypeName();
        errorLogEvent.Line_Number__c = String.valueOf(ex.getLineNumber());
        errorLogEvent.Exception_Stack_Trace__c = ex.getStackTraceString();
        errorLogEvent.Total_Time_Taken__c = totalTimeInMilliSec;
        errorLogEvent.Class_Name__c = className;
        errorLogEvent.Method_Name__c = methodName;
        errorLogEvent.User__c = UserInfo.getUserId();

        Database.SaveResult eventSaveResult = EventBus.publish(errorLogEvent);
        if(eventSaveResult != null){
            isSuccess = eventSaveResult.isSuccess();
        }
        return isSuccess;
    }

}