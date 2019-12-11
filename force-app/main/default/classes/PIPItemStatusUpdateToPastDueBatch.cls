/**
 * @description Batch class to Update PIP Item Status to Past Due
 *
 * @author Sugu Chugh
 * @date 2019-09-13
 */

global class PIPItemStatusUpdateToPastDueBatch implements Database.Batchable<sObject>{

    String PENDING_STATUS = StaticValue.getStaticValueText('PIP_ITEM_STATUS_PENDING');
    String AES_TYPE = StaticValue.getStaticValueText('PIP_TYPE_AES');
    String OPEN_STATUS = StaticValue.getStaticValueText('CONTRACT_STATUS_OPEN');
    String VERIFIED_STATUS = StaticValue.getStaticValueText('PIP_STATUS_VERIFIED');
    String PAST_DUE_STATUS = StaticValue.getStaticValueText('PIP_ITEM_STATUS_PAST_DUE');

    global final String SelectString = 'SELECT Id, Status__c ';
    global final String FromString = 'FROM TASKRAY__Project_Task__c ';
    global final String WhereString = 'WHERE TASKRAY__Project__r.Sub_Status__c =: VERIFIED_STATUS ' +
            'AND TaskRAY__Project__r.Send_For_AES_Inspection__c = true ' +
            'AND Status__c =: PENDING_STATUS ' +
            'AND PI_Type__c =: AES_TYPE ' +
            'AND PI_Item_Due_Date__c < today ' +
            'AND PI_Verify__c = true ' +
            'AND TASKRAY__Project__r.Contract__r.Contract_Status__c =: OPEN_STATUS';
    global final String Query = SelectString + FromString + WhereString;

    /**
     * @description: Start Method to get a list of TASKRAY__Project_Task__c which are past due
     * @param: BC Database.BatchableContext
     * @return: List of TASKRAY__Project_Task__c records
     **/
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }

    /**
     * @description: Execute Method that updates the PIP Item Status to 'Past Due'
     * @param BC Database.BatchableContext
     * @param scope List of TASKRAY__Project_Task__c returned by execute method
     **/
    global void execute(Database.BatchableContext BC, List<TASKRAY__Project_Task__c> scope){
        System.debug(scope.size());
        for(TASKRAY__Project_Task__c pipItem :scope){
            pipItem.Status__c = PAST_DUE_STATUS;
        }
        try {
            update scope;
        }catch(Exception ex){
            System.debug('Exception Occurred in PIPItemStatusUpdateToPastDueBatch class. Error Message: '+ex.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}