/**
 *  @description Helper class for PIP_Inspection__c trigger
 *  @author Pradnya Desai
 *  @date 2019-09-30
 */

public with sharing class PIPInspectionTriggerHelper {

    /**
	 * @description This method will update Letter Sent Date and HGI Inspection Result on PIP Inspection object
	 * if Status Reason is changed to 'Letter Sent' 
	 *
	 * @param newInspectionsList - List<PIP_Inspection__c>
	 * @param oldInspections - Map<Id, PIP_Inspection__c>
	 */
    public void updateLetterSentDateHGIInspectionResults(List<PIP_Inspection__c> newInspectionsList,
            Map<Id, PIP_Inspection__c> oldInspections) {

        List<PIP_Inspection__c> inspectionForUpdates = new List<PIP_Inspection__c>();
        List<Id> pipIdsList = new List<Id>();

        Long startTime = System.currentTimeMillis();
        Long endTime = null;
        Long totalTime = null;
        try {

            for (PIP_Inspection__c newInspection : newInspectionsList) {
                if (newInspection.Status_Reason__c == 'Letter Sent' && (oldInspections == null
                        || (oldInspections.get(newInspection.Id) != null
                        && oldInspections.get(newInspection.Id).Status_Reason__c != newInspection.Status_Reason__c))
                        ) {
                    inspectionForUpdates.add(newInspection);
                    if(newInspection.PIP__c != null) {
                        pipIdsList.add(newInspection.PIP__c);
                    }
                }
            }
          if (inspectionForUpdates.size() > 0) {
                setLetterSentDateHGIInspectionResults(inspectionForUpdates, pipIdsList);
            }
        }catch(Exception ex){
            System.debug('Exception occurred in PIPInspectionTriggerHelper: '+ex.getMessage());
            endTime = System.currentTimeMillis();
            totalTime = endTime - startTime;
            ErrorLogEventsUtil.publishErrorLogEventsForException(ex, inspectionForUpdates, totalTime,
                    'PIPInspectionTriggerHelper', 'updateLetterSentDateHGIInspectionResults');
        }
    }

    /**
	 * @description This method will update Letter Sent Date and HGI Inspection Result on PIP Inspection object
	 * if Status Reason is changed to 'Letter Sent' 
	 *
	 * @param newInspectionsList - List<PIP_Inspection__c>
	 * @param pipIdsList - List<Id> List of PIP project Id
	 */
    private void setLetterSentDateHGIInspectionResults(List<PIP_Inspection__c> newInspectionsList, List<Id> pipIdsList){
         Map<Id, TASKRAY__Project__c> mapPIPById = null;
        if(pipIdsList != null && pipIdsList.size() >0) {
            mapPIPById = getPIPByIdMap(pipIdsList);
        }
        for(PIP_Inspection__c newInspection : newInspectionsList){
            newInspection.Letter_Sent_Date__c = Date.today();
            if(mapPIPById != null) {
                newInspection.HGI_Inspection_Results__c = (mapPIPById.get(newInspection.PIP__c) != null ?
                        mapPIPById.get(newInspection.PIP__c).PIP_Compliance_Status__c : null);
            }
        }

    }

    /**
	 * @description This method will get PIP Project details for input PIP Ids
	 *
	 * @param pipIdsList - List<Id> List of PIP project Id
	 */
    private Map<Id, TASKRAY__Project__c>  getPIPByIdMap(List<Id> pipIdsList){
        Map<Id, TASKRAY__Project__c> mapPIPById = new Map<Id, TASKRAY__Project__c>([Select Id,
                PIP_Compliance_Status__c from TASKRAY__Project__c Where Id In: pipIdsList]);
        return mapPIPById;
    }

}