/**
 *  @description Test class for PIP_Inspection_Item trigger
 *  @author Pradnya Desai
 *  @date 2019-09-17
 */

@IsTest
private class ErrorLogEventUtilsTest {

    private static Map <String,Schema.RecordTypeInfo> recordTypeMap = TASKRAY__Project_Task__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id  pipItemRecordTypeId = recordTypeMap.get('PIP Item').getRecordTypeId();

    @IsTest
    static void testSystemException() {

        Long startTime = System.currentTimeMillis();
        Long endTime = null;
        Long totalTime = null;
        TaskRay__Project__c pipProject = TestDataFactory.createPIP(true);
        PIP_Library_Item__c pipPerBuildingLibraryItem = TestDataFactory.createPIPLibItemForCostUnit(AppConstants.COST_UNIT_PER_BUILDING);
        insert pipPerBuildingLibraryItem;
        List<TASKRAY__Project_Task__c> pipItemsList = TestDataFactory.createPIPItems(false, 2, pipProject.Id,
                pipPerBuildingLibraryItem.Id, pipItemRecordTypeId);
        pipItemsList[0] = null;
        try{
            update pipItemsList[0];
        }catch(Exception ex){
            System.debug('Exception occurred in ErrorLogEventUtilsTest: '+ex.getMessage());
            endTime = System.currentTimeMillis();
            totalTime = endTime - startTime;
            Boolean isSuccess = ErrorLogEventsUtil.publishErrorLogEventsForException(ex, pipItemsList, totalTime,
                    'ErrorLogEventUtilsTest','testSystemException');
            System.assertEquals(true, isSuccess);
        }
    }

}