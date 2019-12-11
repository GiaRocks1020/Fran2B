/**
 *  @description Helper class for TASKRAY_Task trigger
 *  @author Pradnya Desai
 *  @date 2019-09-10
 */

public inherited sharing class TASKRAY_TaskTriggerHelper {

    List<String> reviewStatusList = new List<String>{'CHI Verify', 'Choice Review', 'Completed Pending Review'};
    List<String> completeStatus = new List<String>{'Completed', 'Exception'};

    String PIP_ITEM_PAST_DUE = StaticValue.getStaticValueText('PIP_ITEM_STATUS_PAST_DUE');
    String PIP_ITEM_PENDING = StaticValue.getStaticValueText('PIP_ITEM_STATUS_PENDING');
    String PIP_ITEM_INCOMPLETE = StaticValue.getStaticValueText('PIP_ITEM_STATUS_INCOMPLETE');
    String PIP_ITEM_REVIEW_SET = StaticValue.getStaticValueText('PIP_ITEM_STATUS_REVIEW_SET');
    String PIP_ITEM_COMPLETE_SET = StaticValue.getStaticValueText('PIP_ITEM_STATUS_COMPLETE_SET');
    String PIP_ITEM_DEACTIVATED = StaticValue.getStaticValueText('PIP_ITEM_STATUS_DEACTIVATED');
    String PIP_OVERDUE = StaticValue.getStaticValueText('PIP_COMPLIANCE_STATUS_OVERDUE');
    String PIP_PENDING = StaticValue.getStaticValueText('PIP_COMPLIANCE_STATUS_PENDING');
    String PIP_COMPLETE = StaticValue.getStaticValueText('PIP_COMPLIANCE_STATUS_COMPLETE');
    String PIP_NO_AES = StaticValue.getStaticValueText('PIP_COMPLIANCE_STATUS_NO_AES');
    String PIP_PENDING_REVIEW = StaticValue.getStaticValueText('PIP_COMPLIANCE_STATUS_PENDING_REVIEW');
    String PIP_INCOMPLETE = StaticValue.getStaticValueText('PIP_COMPLIANCE_STATUS_INCOMPLETE');
    String PIP_TYPE_AES = StaticValue.getStaticValueText('PIP_TYPE_AES');
    String PIP_INSP_LETTER_COMPLETE = StaticValue.getStaticValueText('PIP_INSP_LETTER_COMPLETE');
    String PIP_INSP_LETTER_COMPLIANT = StaticValue.getStaticValueText('PIP_INSP_LETTER_COMPLIANT');
    String PIP_INSP_LETTER_NON_COMPLIANT = StaticValue.getStaticValueText('PIP_INSP_LETTER_NON_COMPLIANT');
    String INSPECTION_RESULT_INCOMPLETE = StaticValue.getStaticValueText('INSPECTION_RESULT_INCOMPLETE');

    /**
       * @description This method will set Quantity field on PIP Item depending on Cost Units.
       *
       * @param newPIPItems - List of TASKRAY__Project_Task__c Ids
       */
    public void setQuantityForPIPItem(List<TASKRAY__Project_Task__c> newPIPItems, Map<Id, TASKRAY__Project_Task__c> oldPIPItems){

        Set<Id> libraryItemsList = new Set<Id>();
        Set<Id> parentProjectIds = new Set<Id>();
        for(TASKRAY__Project_Task__c projectTask: newPIPItems){
            if(oldPIPItems == null ||
                        projectTask.PI_Cost_Units__c != oldPIPItems.get(projectTask.Id).PI_Cost_Units__c) {
                libraryItemsList.add(projectTask.PIP_Library_Item__c);
                parentProjectIds.add(projectTask.TASKRAY__Project__c);
            }
        }

        if(parentProjectIds.size() > 0 && libraryItemsList.size() > 0) {
            Map<Id, PIP_Library_Item__c> pipLibraryMapByIds =  queryLibraryItemsForPIPItems(libraryItemsList);
            Map<Id, TASKRAY__Project__c> pipProjectMapByIds = queryPIPProjects(parentProjectIds);
            mapQuantityForPIPItem(newPIPItems, pipLibraryMapByIds, pipProjectMapByIds);
        }

    }

    /**
       * @description This method will set values for various fields on PIP Object depending on PIP Items
       * PIP fields to be updated - PIP Compliance Status, Total Cost, Estimated Cost, Sub Status,
       * AES Inspection Letter Type etc.
       *
       * @param newPIPItems - List of Updated TASKRAY__Project_Task__c
       * @param oldPIPItems - Original values for TASKRAY__Project_Task__c
       */
    public Map<Id, TASKRAY__Project__c> setPIPFields(List<TASKRAY__Project_Task__c> newPIPItems, Map<Id, TASKRAY__Project_Task__c> oldPIPItems){
        Set<Id> parentProjectIds = new Set<Id>();

        //Get PIP Ids for Cost Updates
        Set<Id> parentProjectIdsForCostUpdate = populatePIPIdsForCostUpdates(newPIPItems, oldPIPItems);
        parentProjectIds.addAll(parentProjectIdsForCostUpdate);

        //Get PIP Ids for Cost Status
        Set<Id> parentPIPIdsForStatusUpdate = populatePIPIdsForStatusUpdates(newPIPItems, oldPIPItems);
        parentProjectIds.addAll(parentPIPIdsForStatusUpdate);

        Map<Id, TASKRAY__Project__c> updatedPIPs = null;

        if(parentProjectIds.size() > 0) {
            updatedPIPs = getUpdatesForPIP(parentProjectIds, parentProjectIdsForCostUpdate,
                    parentPIPIdsForStatusUpdate);
        }
        return updatedPIPs;
    }

    /**
       * @description This method will populate Set of PIP Ids for which Cost fields needs to be updated
       *
       * @param newPIPItems - List of Updated TASKRAY__Project_Task__c
       * @param oldPIPItems - Original values for TASKRAY__Project_Task__c
       *
       * @return Set<Id> - Set of PIP Ids
       */
    private Set<Id> populatePIPIdsForCostUpdates(List<TASKRAY__Project_Task__c> newPIPItems, Map<Id, TASKRAY__Project_Task__c> oldPIPItems) {
        Set<Id> parentProjectIdsForCostUpdate = new Set<Id>();
        for (TASKRAY__Project_Task__c projectTask : newPIPItems) {
            if (oldPIPItems == null) {
                parentProjectIdsForCostUpdate.add(projectTask.TASKRAY__Project__c);
            } else {
                TASKRAY__Project_Task__c oldProjectTask = oldPIPItems.get(projectTask.Id);
                if (oldProjectTask != null) {
                    if (oldProjectTask.PI_Quantity__c != projectTask.PI_Quantity__c
                            || oldProjectTask.PI_Actual_Cost__c != projectTask.PI_Actual_Cost__c
                            || oldProjectTask.PI_Estimated_Cost_per_Cost_Unit__c != projectTask.PI_Estimated_Cost_per_Cost_Unit__c) {
                        parentProjectIdsForCostUpdate.add(projectTask.TASKRAY__Project__c);
                    }

                }
            }

        }
        return parentProjectIdsForCostUpdate;
    }

    /**
       * @description This method will populate Set of PIP Ids for which PIP Compliance Status needs to be updated
       *
       * @param newPIPItems - List of Updated TASKRAY__Project_Task__c
       * @param oldPIPItems - Original values for TASKRAY__Project_Task__c
       *
       * @return Set<Id> - Set of PIP Ids
       */
    private Set<Id> populatePIPIdsForStatusUpdates(List<TASKRAY__Project_Task__c> newPIPItems,
            Map<Id, TASKRAY__Project_Task__c> oldPIPItems){
        Set<Id> parentProjectIdsForComplianceStatusUpdate = new Set<Id>();
        for (TASKRAY__Project_Task__c projectTask : newPIPItems) {
            if (oldPIPItems == null) {
                parentProjectIdsForComplianceStatusUpdate.add(projectTask.TASKRAY__Project__c);
            } else {
                TASKRAY__Project_Task__c oldProjectTask = oldPIPItems.get(projectTask.Id);
                if (oldProjectTask != null) {
                    if (oldProjectTask.Status__c != projectTask.Status__c || oldProjectTask.PI_HGI__c != projectTask.PI_HGI__c
                            || oldProjectTask.PI_Verify__c != projectTask.PI_Verify__c
                            || oldProjectTask.PI_Type__c != projectTask.PI_Type__c) {
                        parentProjectIdsForComplianceStatusUpdate.add(projectTask.TASKRAY__Project__c);
                    }
                }
            }
        }
        return parentProjectIdsForComplianceStatusUpdate;
    }

    /**
       * @description This method queries PIP Library Items for input Ids
       *
       * @param libraryItemsList - List of PIP_Library_Item__c Ids
       * @return Map<Id, PIP_Library_Item__c>
       */
    private Map<Id, PIP_Library_Item__c> queryLibraryItemsForPIPItems(Set<Id> libraryItemsList){
        Map<Id, PIP_Library_Item__c> pipLibraryMapByIds = new Map<Id, PIP_Library_Item__c>([Select Id,
                PI_Cost_Units__c from PIP_Library_Item__c Where Id  IN: libraryItemsList]);
        return pipLibraryMapByIds;

    }
    /**
       * @description This method maps Quantity for PIP Item depending on Cost Units.
       * If Cost Units is Per Building then it will have Quantity as 1. Or it will be same Number of Rooms on
       * PIP Project
       *
       * @param pipLibraryMapByIds - Map of Library Items
       * @param pipProjectMapByIds - Map of Parent Projects
       * @param newPIPItems - List of Inserted PIP Items
       */
    private void mapQuantityForPIPItem(List<TASKRAY__Project_Task__c> newPIPItems, Map<Id,
            PIP_Library_Item__c> pipLibraryMapByIds, Map<Id, TASKRAY__Project__c> pipProjectMapByIds){
        for(TASKRAY__Project_Task__c projectTask: newPIPItems){
            if(projectTask.PIP_Library_Item__c != null && pipLibraryMapByIds != null && pipProjectMapByIds != null){
                PIP_Library_Item__c libraryItem = pipLibraryMapByIds.get(projectTask.PIP_Library_Item__c);
                if(libraryItem != null && libraryItem.PI_Cost_Units__c != null) {
                    if (libraryItem.PI_Cost_Units__c == AppConstants.COST_UNIT_PER_BUILDING) {
                        projectTask.PI_Quantity__c = AppConstants.PER_BUILDING_QUANTITY;
                    } else if (libraryItem.PI_Cost_Units__c == AppConstants.COST_UNIT_PER_ROOM) {
                        if (projectTask.TASKRAY__Project__c != null) {
                            TASKRAY__Project__c parentProject = pipProjectMapByIds.get(projectTask.TASKRAY__Project__c);
                            if(parentProject != null && parentProject.Number_of_Rooms__c != null){
                                projectTask.PI_Quantity__c = parentProject.Number_of_Rooms__c;
                            }else if(parentProject != null && parentProject.Property__r != null
                                    && parentProject.Property__r.Number_of_Rooms__c != null){
                                projectTask.PI_Quantity__c = parentProject.Property__r.Number_of_Rooms__c;
                            }
                        }
                    }
                }
            }
        }
    }


    /**
       * @description This method will consolidate all updates to PIP object and trigger update method.
       *
       * @param pipToBeUpdated - Map<Id, TASKRAY__Project__c>
       * @param PIPsToUpdateBillingInspectionCount - List<TASKRAY__Project__c>
       */
    public void consolidateAndUpdatePIP(Map<Id, TASKRAY__Project__c> pipToBeUpdated, List<TASKRAY__Project__c> PIPsToUpdateBillingInspectionCount){

        if(PIPsToUpdateBillingInspectionCount != null && PIPsToUpdateBillingInspectionCount.size() != 0 &&
                    !PIPsToUpdateBillingInspectionCount.isEmpty()){
            for(TASKRAY__Project__c pipProject : PIPsToUpdateBillingInspectionCount){
                if(pipToBeUpdated == null){
                    pipToBeUpdated = new Map<Id, TASKRAY__Project__c>();
                }
                if(pipToBeUpdated.get(pipProject.Id) != null){
                    TASKRAY__Project__c pipProjectWithBillingInsp = pipToBeUpdated.get(pipProject.Id);
                    pipProjectWithBillingInsp.Billing_Inspection_Count__c = pipProject.Billing_Inspection_Count__c;
                    pipToBeUpdated.put(pipProject.Id, pipProjectWithBillingInsp);
                }else{
                    pipToBeUpdated.put(pipProject.Id, pipProject);
                }
            }
        }
        if(pipToBeUpdated != null && pipToBeUpdated.size() > 0 && pipToBeUpdated.keySet() != null){
            update pipToBeUpdated.values();
        }
    }

    /**
       * @description This method calculates and updates on PIP like
       * Effective PIP cost, Actual PIP cost and PIP Compliance status from all tasks associated with it.
       *
       * @param parentProjectIds - List of TASKRAY__Project__c Ids
       */
    private Map<Id, TASKRAY__Project__c> getUpdatesForPIP(Set<Id> parentProjectIds,
                Set<Id> parentProjectIdsForCostUpdate, Set<Id> parentPIPIdsForStatusUpdate){
        Map<Id, TASKRAY__Project__c> pipProjectMapByIds = queryPIPProjects(parentProjectIds);
        Map<Id, List<TASKRAY__Project_Task__c>> pipItemsByProjectIds = queryPIPItems(parentProjectIds);

        mapPIPTotalCostFromTasks(pipProjectMapByIds, pipItemsByProjectIds, parentProjectIdsForCostUpdate);
        mapPIPStatus(pipProjectMapByIds, pipItemsByProjectIds, parentPIPIdsForStatusUpdate);

        return pipProjectMapByIds;
    }

    /**
       * @description This method queries PIP projects for the input projectIds of the task which are inserted or updated.
       *
       * @param parentProjectIds - List of TASKRAY__Project__c Ids
       */
    private Map<Id, TASKRAY__Project__c> queryPIPProjects(Set<Id> pipProjectIds){
        Map<Id, TASKRAY__Project__c> pipProjectMapByIds = new Map<Id, TASKRAY__Project__c>([SELECT Id,
                Total_PIP_Cost__c, PIP_Total_Estimated_Cost__c, Number_of_Rooms__c, HGI_Status__c, TASKRAY__Status__c,
                TASKRAY__trStatus__c, Sub_Status__c, Property__r.Number_of_Rooms__c
        FROM TASKRAY__Project__c WHERE Id  IN: pipProjectIds]);
        return pipProjectMapByIds;
    }

    /**
       * @description This method queries All PIP Tasks for the input projectIds of the task which are inserted or updated.
       *
       * @param parentProjectIds - List of TASKRAY__Project__c Ids
       */
    public  Map<Id, List<TASKRAY__Project_Task__c>> queryPIPItems(Set<Id> pipProjectIds){
        List<TASKRAY__Project_Task__c> pipProjectTasks = [Select Id, TASKRAY__Project__c, PI_Total_Cost__c,
                PI_Estimated_Cost_for_PIP_Item__c, PI_HGI__c, Status__c, PI_Verify__c, PI_Type__c
                from TASKRAY__Project_Task__c where TASKRAY__Project__c IN: pipProjectIds];
        Map<Id, List<TASKRAY__Project_Task__c>> pipItemsByProjectIds = new Map<Id, List<TASKRAY__Project_Task__c>>();

        if(pipProjectTasks != null && pipProjectTasks.size() > 0) {
            for (TASKRAY__Project_Task__c pipTask : pipProjectTasks) {
                List<TASKRAY__Project_Task__c> projectTasksList = null;
                if (pipItemsByProjectIds.containsKey(pipTask.TASKRAY__Project__c)) {
                    projectTasksList = pipItemsByProjectIds.get(pipTask.TASKRAY__Project__c);
                } else {
                    projectTasksList = new List<TASKRAY__Project_Task__c>();
                }
                projectTasksList.add(pipTask);
                pipItemsByProjectIds.put(pipTask.TASKRAY__Project__c, projectTasksList);
            }
        }

        return pipItemsByProjectIds;
    }

    /**
       * @description This method method iterates through all PIP tasks for given project and calculates effective PIP cost.
       * And populates the value in list of projects to be updated
       *
       * @param pipProjectMapByIds - Map of PIP Id and corresponding PIP object
       * @param pipTasksByProjectIds - Map of PIP Id and corresponding list of PIP Items
       *
       */
    public void mapPIPTotalCostFromTasks(Map<Id, TASKRAY__Project__c> pipProjectMapByIds, Map<Id,
            List<TASKRAY__Project_Task__c>> pipTasksByProjectIds, Set<Id>  parentProjectIdsForCostUpdate){

        if(pipProjectMapByIds != null && pipTasksByProjectIds != null && parentProjectIdsForCostUpdate != null){
            for(Id projectId : parentProjectIdsForCostUpdate){
                List<TASKRAY__Project_Task__c> projectTasksList = pipTasksByProjectIds.get(projectId);
                Decimal totalPIPCost = 0;
                Decimal totalEstimatedPIPCost = 0;
                if(projectTasksList != null && projectTasksList.size() > 0){
                    for(TASKRAY__Project_Task__c projectTask : projectTasksList){
                        if(projectTask.PI_Total_Cost__c != null) {
                            totalPIPCost = totalPIPCost + projectTask.PI_Total_Cost__c;
                        }
                        if(projectTask.PI_Estimated_Cost_for_PIP_Item__c != null){
                            totalEstimatedPIPCost = totalEstimatedPIPCost + projectTask.PI_Estimated_Cost_for_PIP_Item__c;
                        }
                    }
                }
                TASKRAY__Project__c pipProjects = pipProjectMapByIds.get(projectId);
                if(pipProjects != null){
                    pipProjects.Total_PIP_Cost__c = totalPIPCost;
                    pipProjects.PIP_Total_Estimated_Cost__c = totalEstimatedPIPCost;
                }
            }
        }

    }

    /**
     * @description Sets the Follow Up Date. Value will be set to null value when the Status equals 'Incomplete' on before
     * insert/update trigger contexts. For Incomplete pip inspection item, set the follow up date on the pip item
     * to be 120 days from the inspection date. 
     *
     * @param newPIPItems - List of new TASKRAY__Project_Task__c
     * @param oldPIPItems - Map of old TASKRAY__Project_Task__c
     * @return void
     */
    public void setFollowUpDate(List<TASKRAY__Project_Task__c> newPIPItems, Map<Id,
            TASKRAY__Project_Task__c> oldPIPItems) {
        Map<Id, List<PIP_Inspection_Item__c>> pipItemInspectionItemMap = getMapPIPInspectionByPIPItemMap(newPIPItems);

        String PIP_ITEM_STATUS_INCOMPLETE = StaticValue.getStaticValueText('PIP_ITEM_STATUS_INCOMPLETE');
        Integer FOLLOW_UP_DAYS_COUNT = Integer.valueOf(StaticValue.getStaticValueText('FOLLOW_UP_DAYS_COUNT'));

        for(TASKRAY__Project_Task__c pipItem : newPIPItems) {
            List<PIP_Inspection_Item__c> inspectionItems = pipItemInspectionItemMap.get(pipItem.Id);
            if (pipItem.Status__c != PIP_ITEM_STATUS_INCOMPLETE
                    && pipItem.PI_Follow_Up_Date__c != null) {
                if (oldPIPItems == null
                        || (oldPIPItems != null
                        && oldPIPItems.containsKey(pipItem.Id)
                        && oldPIPItems.get(pipItem.Id).Status__c != pipItem.Status__c)) {
                    pipItem.PI_Follow_Up_Date__c = null;
                }
            } else if (pipItem.Status__c == PIP_ITEM_STATUS_INCOMPLETE && (
                    (oldPIPItems == null && pipItem.PI_Follow_Up_Date__c == null)) ||
                    (oldPIPItems != null && oldPIPItems.containsKey(pipItem.Id)
                            && oldPIPItems.get(pipItem.Id).Status__c != pipItem.Status__c)) {
                pipItem.PI_Follow_Up_Date__c = Date.today().addDays(FOLLOW_UP_DAYS_COUNT);
            }
            if(oldPIPItems == null
                    || (oldPIPItems != null
                    && oldPIPItems.containsKey(pipItem.Id)
                    && oldPIPItems.get(pipItem.Id).PI_Item_Due_Date__c != pipItem.PI_Item_Due_Date__c)
                    && pipItem.PI_Item_Due_Date__c != null
                    && inspectionItems != null && inspectionItems.size() > 0 && !inspectionItems.isEmpty()){
                updateFailedInspectionCount(pipItem, inspectionItems);
            }

        }
    }


    /**
     * @description Method to Check if Inserted/Updated PIP Item are AES type, HGI is true, Status isIncomplete and
     * PIP Billing Inspection count is not null
     * @param lstNewPIPItems - List of new TASKRAY__Project_Task__c
     * @param mapOldPIPItems - Map of old TASKRAY__Project_Task__c
     */
    public List<TASKRAY__Project__c> updatePIPBillingInspectionCountOnTask(List<TASKRAY__Project_Task__c> lstNewPIPItems,
            Map<Id, TASKRAY__Project_Task__c> mapOldPIPItems){
        Set<Id> setPIPIds = new Set<Id>();
        for (TASKRAY__Project_Task__c PIPItem : lstNewPIPItems) {
            if (mapOldPIPItems == null
                    && PIPItem.PI_Billing_Inspection_Count__c != null
                    && PIPItem.PI_Type__c == 'AES'
                    && PIPItem.PI_HGI__c
                    && PIPItem.Status__c == 'Incomplete'
                    && PIPItem.TASKRAY__Project__c != null) {
                setPIPIds.add(PIPItem.TASKRAY__Project__c);
            }
            //check for if Billing Inspection count or other criteria fields are updated
            else if(mapOldPIPItems != null
                    && mapOldPIPItems.containsKey(PIPItem.Id)
                    && (mapOldPIPItems.get(PIPItem.Id).PI_Billing_Inspection_Count__c != PIPItem.PI_Billing_Inspection_Count__c
                    || mapOldPIPItems.get(PIPItem.Id).PI_Type__c != PIPItem.PI_Type__c
                    || mapOldPIPItems.get(PIPItem.Id).Status__c != PIPItem.Status__c
                    || mapOldPIPItems.get(PIPItem.Id).PI_HGI__c != PIPItem.PI_HGI__c)
                    ) {
                setPIPIds.add(PIPItem.TASKRAY__Project__c);
            }
        }
        List<TASKRAY__Project__c> pipsToUpdateBillingInspectionCount = null;
        try {
            if (setPIPIds.size() != 0 && !setPIPIds.isEmpty()) {
                pipsToUpdateBillingInspectionCount = updateBillingInspectionCountOnPIP(setPIPIds);
            }
        }catch(Exception ex) {
            System.debug('Exception occurred in TASKRAY_TaskTriggerHelper: ' + ex.getMessage());
        }

        return pipsToUpdateBillingInspectionCount;
    }

    /**
     * @description  Method to get the MAX of all the Child PIP records Billing Inspection and update the Billing Inspection count
     * on PIP
     * @param setPIPIds Id for PIPs to be updated
     */
    public List<TASKRAY__Project__c> updateBillingInspectionCountOnPIP(Set<Id> setPIPIds){
        List<TASKRAY__Project__c> PIPsToUpdateBillingInspectionCount = new List<TASKRAY__Project__c>();
        for(AggregateResult ar :[SELECT TASKRAY__Project__c, MAX(PI_Billing_Inspection_Count__c) maxBillingInspectionCount
        FROM TASKRAY__Project_Task__c
        WHERE TASKRAY__Project__c IN :setPIPIds
        AND PI_Type__c = 'AES'
        AND PI_HGI__c = TRUE
        AND Status__c = 'Incomplete'
        GROUP BY TASKRAY__Project__c]){

            // We can set the Id of an sObject if we pass it into that sObject's constructor.
            // This is a common pattern used for updating records of related sObjects,
            // and saves us from needing to write another query
            PIPsToUpdateBillingInspectionCount.add(new TASKRAY__Project__c(
                    Id = (Id)ar.get('TASKRAY__Project__c'),
                    // When fetching an aggregated field, it comes back as an instance of Object.
                    // Thus, it's required to cast the result. Number field type = Decimal
                    Billing_Inspection_Count__c = (Decimal)ar.get('maxBillingInspectionCount')
            ));
            // remove PIPs that were able to get a PIP Item where criteria matched
            setPIPIds.remove((Id)ar.get('TASKRAY__Project__c'));
        }
        // PIP Ids that did not get a criteria match, update the Billing Inspection count to Null
        for(Id PIPId :setPIPIds){
            if(PIPId != null) {
                PIPsToUpdateBillingInspectionCount.add(new TASKRAY__Project__c(
                        Id = PIPId, Billing_Inspection_Count__c = null));
            }
        }

        if(PIPsToUpdateBillingInspectionCount.size() != 0 && !PIPsToUpdateBillingInspectionCount.isEmpty()) {
            //    update PIPsToUpdateBillingInspectionCount;
        }

        return PIPsToUpdateBillingInspectionCount;
    }

    /**
     * @description Method to update PIP Item's status to Pending if current Status is Past Due and Due date is updated
     * to a future date
     * @param lstNewPIPItems - List of new TASKRAY__Project_Task__c
     * @param mapOldPIPItems - Map of old TASKRAY__Project_Task__c
     */
    public void updatePIPItemStatusToPending(List<TASKRAY__Project_Task__c> lstNewPIPItems,
            Map<Id, TASKRAY__Project_Task__c> mapOldPIPItems){
        String PIP_ITEM_STATUS_PAST_DUE = StaticValue.getStaticValueText('PIP_ITEM_STATUS_PAST_DUE');
        String PIP_ITEM_STATUS_PENDING = StaticValue.getStaticValueText('PIP_ITEM_STATUS_PENDING');

        for (TASKRAY__Project_Task__c PIPItem : lstNewPIPItems) {
            if(mapOldPIPItems != null && mapOldPIPItems.containsKey(PIPItem.Id)){
                TASKRAY__Project_Task__c oldPIPItem = mapOldPIPItems.get(PIPItem.Id);
                if(oldPIPItem.PI_Item_Due_Date__c != PIPItem.PI_Item_Due_Date__c
                        && PIPItem.PI_Item_Due_Date__c > Date.today()
                        && PIPItem.Status__c == PIP_ITEM_STATUS_PAST_DUE
                        && PIPItem.PI_Type__c == PIP_TYPE_AES){
                    PIPItem.Status__c = PIP_ITEM_STATUS_PENDING;
                }
            }
        }
    }

    /**
       * @description This method method will set PIP Compliance status depending on PIP Item Status
       *
       * @param pipProjectMapByIds - Map of PIP Id and corresponding PIP object
       * @param pipTasksByProjectIds - Map of PIP Id and corresponding list of PIP Items
       * @param parentProjectIdsForComplianceStatusUpdate - Set<Id> Set of PIP Ids for which Compliance status needs to change
       *
       */
    private void mapPIPStatus(Map<Id, TASKRAY__Project__c> pipProjectMapByIds,
            Map<Id, List<TASKRAY__Project_Task__c>> pipTasksByProjectIds, Set<Id>  parentPIPIdsForStatusUpdate) {

        for (Id pipId : parentPIPIdsForStatusUpdate) {

            TASKRAY__Project__c pipProjectToUpdate = pipProjectMapByIds.get(pipId);
            if (pipProjectToUpdate != null) {
                pipProjectToUpdate = pipProjectMapByIds.get(pipId);
                List<TASKRAY__Project_Task__c> aesPipItemList = new List<TASKRAY__Project_Task__c>();
                Map<String, List<TASKRAY__Project_Task__c>> statusMapForPIPItems = getMapForPIPItemStatus(pipId,
                        pipTasksByProjectIds, aesPipItemList);
                List<TASKRAY__Project_Task__c> pipItemList = pipTasksByProjectIds.get(pipId);
                pipProjectToUpdate.PIP_Compliance_Status__c = getPIPComplianceStatus(pipItemList, statusMapForPIPItems,
                        aesPipItemList);

                pipProjectToUpdate.AES_Inspection_Letter_Type__c = getPipAESInspectionLetterType(pipItemList,
                        statusMapForPIPItems);

            }
        }
    }

    /**
     * @description Method to clear out Due Date and Due in Months AND if PIP is same for cloned and source PIP Item
     * then clear PIP too
     * @param lstClonedPIPItems:
     */
    public void updateFieldsForClonedPIPItems(List<TASKRAY__Project_Task__c> lstPIPItems){
        List<TASKRAY__Project_Task__c> lstClonedPIPItemS = new List<TASKRAY__Project_Task__c>();
        Set<Id> setSourcePIPItems = new Set<Id>();
        Map<Id,Id> mapSourcePIPItemsByPIPId = new Map<Id, Id>();

        //get list of the PIPItems that were cloned and their source PIP Items
        for(TASKRAY__Project_Task__c PIPItem :lstPIPItems){
            if(PIPItem.isClone()){
                lstClonedPIPItemS.add(PIPItem);
                setSourcePIPItems.add(PIPItem.getCloneSourceId());
            }
        }

        //get PIPs for the source PIP Items
        for(TASKRAY__Project_Task__c clonedFromPIPItem :[SELECT Id, TASKRAY__Project__c FROM TASKRAY__Project_Task__c
        WHERE Id IN:setSourcePIPItems]){
            mapSourcePIPItemsByPIPId.put(clonedFromPIPItem.Id,clonedFromPIPItem.TASKRAY__Project__c);
        }

        //if the cloned PIP Item has same PIP as source PIP Item, clear out the PIP on cloned PIP Item
        for(TASKRAY__Project_Task__c clonedPIPItem :lstClonedPIPItemS){
            clonedPIPItem.PI_Item_Due_Date__c = null;
            clonedPIPItem.PI_Due_In_Months__c = null;
            clonedPIPItem.Status__c = 'Pending';
            if(clonedPIPItem.TASKRAY__Project__c == mapSourcePIPItemsByPIPId.get(clonedPIPItem.getCloneSourceId())){
                clonedPIPItem.TASKRAY__Project__c = null;
            }
        }
    }

    /**
     * @description - This method will derive PIP Compliance Status for given PIP
     *
     * @param pipId - ID of PIP to be updated
     * @param pipTasksByProjectIds - Map of PIP Id and corresponding list of PIP Items
     */
    private String getPIPComplianceStatus(List<TASKRAY__Project_Task__c> pipItemList,
            Map<String, List<TASKRAY__Project_Task__c>> statusMapForPIPItems, List<TASKRAY__Project_Task__c> aesPipItemList){

        String pipComplianceStatus = '';

        if (statusMapForPIPItems == null || statusMapForPIPItems.size() == 0) {
            pipComplianceStatus = PIP_NO_AES;
        } else if(pipItemList != null) {
            if (statusMapForPIPItems.get(PIP_ITEM_COMPLETE_SET) != null
                    && statusMapForPIPItems.get(PIP_ITEM_COMPLETE_SET).size() == aesPipItemList.size()) {
                pipComplianceStatus = PIP_COMPLETE;
            }else if(statusMapForPIPItems.get(PIP_ITEM_REVIEW_SET) != null
                    && statusMapForPIPItems.get(PIP_ITEM_REVIEW_SET).size() > 0){
                pipComplianceStatus = PIP_PENDING_REVIEW;
            }else if(statusMapForPIPItems.get(PIP_ITEM_INCOMPLETE) != null
                    && statusMapForPIPItems.get(PIP_ITEM_INCOMPLETE).size() > 0){
                pipComplianceStatus = getStatusFlag(statusMapForPIPItems.get(PIP_ITEM_INCOMPLETE), PIP_INCOMPLETE, true);
            }else if(statusMapForPIPItems.get(PIP_ITEM_PAST_DUE) != null
                    && statusMapForPIPItems.get(PIP_ITEM_PAST_DUE).size() > 0) {
                pipComplianceStatus = getStatusFlag(statusMapForPIPItems.get(PIP_ITEM_PAST_DUE), PIP_OVERDUE, false);
            }else if(statusMapForPIPItems.get(PIP_ITEM_PENDING) != null
                    && statusMapForPIPItems.get(PIP_ITEM_PENDING).size() > 0) {
                pipComplianceStatus = getStatusFlag(statusMapForPIPItems.get(PIP_ITEM_PENDING), PIP_PENDING, false);
            }
        }
        return pipComplianceStatus;
    }

    /**
     * @description - This method will derive AES Inspection Letter Type for given PIP
     *
     * @param pipId - ID of PIP to be updated
     * @param pipTasksByProjectIds - Map of PIP Id and corresponding list of PIP Items
     */
    private String getPipAESInspectionLetterType(List<TASKRAY__Project_Task__c> pipItemList,
            Map<String, List<TASKRAY__Project_Task__c>> statusMapForPIPItems){

        String pipAESInspectionLetterType = '';
        if(statusMapForPIPItems != null && pipItemList != null) {

            if(statusMapForPIPItems.get(PIP_ITEM_INCOMPLETE) != null
                    && statusMapForPIPItems.get(PIP_ITEM_INCOMPLETE).size() > 0) {
                pipAESInspectionLetterType = PIP_INSP_LETTER_NON_COMPLIANT;
            }else if(statusMapForPIPItems.get(PIP_ITEM_PENDING) != null
                    && statusMapForPIPItems.get(PIP_ITEM_PENDING).size() > 0) {
                pipAESInspectionLetterType = PIP_INSP_LETTER_COMPLIANT;
            }else if(statusMapForPIPItems.get(PIP_ITEM_COMPLETE_SET) != null
                    && statusMapForPIPItems.get(PIP_ITEM_COMPLETE_SET).size() > 0) {
                    pipAESInspectionLetterType = PIP_INSP_LETTER_COMPLETE;
            }
        }
        return pipAESInspectionLetterType;
    }

    /**
     * @description - This method will derive Incomplete value for  PIP Compliance Status
     *
     * @param pipItemIncompleteList - List<TASKRAY__Project_Task__c>  List of PIP Items with Incomplete Status
     * @return String - value for Incomplete Status
     */
    private String getStatusFlag(List<TASKRAY__Project_Task__c> pipItemIncompleteList, String pipItemStatus,
            Boolean isIncomplete){
        String status = '';
        Boolean verify = false;
        for(TASKRAY__Project_Task__c pipItemIncomplete: pipItemIncompleteList){
            if(pipItemIncomplete.PI_HGI__c == true){
                status = 'HGI ';
            }
            if(pipItemIncomplete.PI_Verify__c == true){
                verify = true;
            }
        }
        if(isIncomplete) {
            status = status + pipItemStatus + ' - ' + pipItemIncompleteList.size() + ' Visits';
        }else{
            status = pipItemStatus;
        }
        if(!verify){
            status = status + ' - Internal';
        }

        return status;

    }

    /**
     * @description - This method will prepare map of PIP Item status and corresponding PIP Items
     *
     * @param pipId - Id of PIP to be updated
     * @param pipTasksByProjectIds - Map of PIP Id and corresponding list of PIP Items
     * @param aesPipItemList - List<TASKRAY__Project_Task__c>  this field return PIP Items list of AES Type
     * @return String - value for Incomplete Status
     */
    private Map<String, List<TASKRAY__Project_Task__c>> getMapForPIPItemStatus(Id pipId,
            Map<Id, List<TASKRAY__Project_Task__c>> pipTasksByProjectIds,  List<TASKRAY__Project_Task__c> aesPipItemList){

        List<TASKRAY__Project_Task__c> pipItemsList = pipTasksByProjectIds.get(pipId);
        Map<String, List<TASKRAY__Project_Task__c>> statusMapForPIPItems = new Map<String, List<TASKRAY__Project_Task__c>>();
        if(pipItemsList != null){
            for(TASKRAY__Project_Task__c pipItem : pipItemsList){
                if(pipItem.PI_Type__c == PIP_TYPE_AES && pipItem.Status__c != PIP_ITEM_DEACTIVATED) {
                    aesPipItemList.add(pipItem);
                    String shortStatus = getStatusShortForm(pipItem.Status__c);
                    if (shortStatus != null) {
                        List<TASKRAY__Project_Task__c> pipItemsForStatus = statusMapForPIPItems.get(shortStatus);
                        if (pipItemsForStatus == null) {
                            pipItemsForStatus = new List<TASKRAY__Project_Task__c>();
                        }
                        pipItemsForStatus.add(pipItem);
                        statusMapForPIPItems.put(shortStatus, pipItemsForStatus);
                    }
                }
            }
        }

        return statusMapForPIPItems;
    }


    /**
     * @description - This method will return short form of PIP Item Statuses
     * e.g. CompleteStatusSet = ‘Completed’, or ‘Exception’
     * e.g. reviewStatusList = 'CHI Verify', 'Choice Review', Or 'Completed Pending Review';
     *
     * @param pipId - Id of PIP to be updated
     * @param pipTasksByProjectIds - Map of PIP Id and corresponding list of PIP Items
     * @param aesPipItemList - List<TASKRAY__Project_Task__c>  this field return PIP Items list of AES Type
     * @return String - value for Incomplete Status
     */
    private String getStatusShortForm(String status){

        String shortStatus = status;
        if(completeStatus.contains(status)){
            shortStatus = PIP_ITEM_COMPLETE_SET;
        }else if(reviewStatusList.contains(status)){
            shortStatus = PIP_ITEM_REVIEW_SET;
        }

        return shortStatus;

    }

	 /**
	 *  @description Method to populate map of parent PIP Items and corresponding Inspection Items 
	 *
	 * @param newPIPItems - List<TASKRAY__Project_Task__c>
	 * @return Map<Id, List<PIP_Inspection_Item__c>>
	 */
    private Map<Id, List<PIP_Inspection_Item__c>> getMapPIPInspectionByPIPItemMap(List<TASKRAY__Project_Task__c> newPIPItems){
        Map<Id, List<PIP_Inspection_Item__c>> pipItemInspectionItemMap = new Map<Id, List<PIP_Inspection_Item__c>>();
        if(newPIPItems != null) {
            for (PIP_Inspection_Item__c pipInspectionItem : [
                    SELECT Id, LRA_Inspection_Results__c, CreatedDate, PIP_Item__c
                    FROM PIP_Inspection_Item__c
                    WHERE PIP_Item__c IN:newPIPItems
            ]) {
                List<PIP_Inspection_Item__c> inspectionItemsForPIPItem = null;
                if (pipItemInspectionItemMap.containsKey(pipInspectionItem.PIP_Item__c)) {
                    inspectionItemsForPIPItem = pipItemInspectionItemMap.get(pipInspectionItem.PIP_Item__c);
                } else {
                    inspectionItemsForPIPItem = new List<PIP_Inspection_Item__c>();
                }
                inspectionItemsForPIPItem.add(pipInspectionItem);
                pipItemInspectionItemMap.put(pipInspectionItem.PIP_Item__c, inspectionItemsForPIPItem);
            }
        }
        return pipItemInspectionItemMap;
    }

    /**
     * @description Method to update the failed Inspection count on PIP Item
     *
     * @param newPIPItem new PIP Item record
     * @param lstPIPInspectionItems List of PIP Inspection Items for the PIP Item
     */
    public void updateFailedInspectionCount(TASKRAY__Project_Task__c newPIPItem,
            List<PIP_Inspection_Item__c> lstPIPInspectionItems){
        Boolean incompleteInspectionItemFound = false;
        if(lstPIPInspectionItems != null) {
            for (PIP_Inspection_Item__c pii : lstPIPInspectionItems) {
                if (pii.LRA_Inspection_Results__c == INSPECTION_RESULT_INCOMPLETE && pii.CreatedDate > newPIPItem.PI_Item_Due_Date__c) {
                    if (newPIPItem.Failed_Inspection_Count__c == null) {
                        newPIPItem.Failed_Inspection_Count__c = 1;
                    } else {
                        newPIPItem.Failed_Inspection_Count__c += 1;
                    }
                    incompleteInspectionItemFound = true;
                }
            }
        }
        if(!incompleteInspectionItemFound){
            newPIPItem.Failed_Inspection_Count__c = 0;
        }
    }
}