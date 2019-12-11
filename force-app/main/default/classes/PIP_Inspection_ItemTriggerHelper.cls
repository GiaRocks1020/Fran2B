/**
 *  @description Helper class for TASKRAY_Task trigger
 *  @author Pradnya Desai
 *  @date 2019-09-16
 */

public inherited sharing class PIP_Inspection_ItemTriggerHelper {

    String INSPECTION_RESULT_INCOMPLETE = StaticValue.getStaticValueText('INSPECTION_RESULT_INCOMPLETE');

    /**
	 * @description This method will update various fields on parent PIP Item on insertion of Inspection Item 
	 *
	 * @param newInspectionItems - List<PIP_Inspection_Item__c>
	 * @return Map<Id, List<PIP_Inspection_Item__c>>
	 */
    public void updatePIPItem(List<PIP_Inspection_Item__c> newInspectionItems, Boolean isUpdateFlow,
            Map<Id,PIP_Inspection_Item__c> oldMap){
        Long startTime = System.currentTimeMillis();
        Long endTime = null;
        Long totalTime = null;
        Map<Id, List<PIP_Inspection_Item__c>> pipItemInspectionItemMap = getPPIPItemInspectionMap(newInspectionItems);
        List<TASKRAY__Project_Task__c> pipItemsList = null;
        try {
            if (pipItemInspectionItemMap.keySet() != null && pipItemInspectionItemMap.keySet().size() > 0) {
                pipItemsList = getParentPIPItemForInspectionItem(pipItemInspectionItemMap.keySet());
                if (pipItemsList != null && pipItemsList.size() > 0) {
                    mapValuesForPIPItems(pipItemsList, pipItemInspectionItemMap, isUpdateFlow, oldMap);
                    update pipItemsList;
                }
            }
            endTime = System.currentTimeMillis();
            totalTime = endTime - startTime;
        }catch(DMLException ex){
            System.debug('DML Exception occurred in PIP_Inspection_ItemTriggerHelper: '+ex.getStackTraceString());
            endTime = System.currentTimeMillis();
            totalTime = endTime - startTime;
            ErrorLogEventsUtil.publishErrorLogEventsForDMLException(ex, pipItemsList,
                    TASKRAY__Project_Task__c.Name.getDescribe().getSobjectField(), totalTime,
                    'PIP_Inspection_ItemTriggerHelper', 'updatePIPItem');
        }catch(Exception ex){
            System.debug('Exception occurred in PIP_Inspection_ItemTriggerHelper: '+ex.getStackTraceString());
            endTime = System.currentTimeMillis();
            totalTime = endTime - startTime;
            ErrorLogEventsUtil.publishErrorLogEventsForException(ex, pipItemsList, totalTime,
                    'PIP_Inspection_ItemTriggerHelper', 'updatePIPItem');
        }

    }

    /**
	 * @description Method to populate map of parent PIP Items and corresponding Inspection Items 
	 *
	 * @param newInspectionItems - List<PIP_Inspection_Item__c>
	 * @return Map<Id, List<PIP_Inspection_Item__c>>
	 */
    private Map<Id, List<PIP_Inspection_Item__c>> getPPIPItemInspectionMap(List<PIP_Inspection_Item__c> newInspectionItems){

        Map<Id, List<PIP_Inspection_Item__c>> pipItemInspectionItemMap = new Map<Id, List<PIP_Inspection_Item__c>>();
        if(newInspectionItems != null) {
            for (PIP_Inspection_Item__c pipInspectionItem : newInspectionItems) {
                List<PIP_Inspection_Item__c> inspectionItemsForPIPItem = null;
                //Ignore Inspection record if PIP Item is not associated with it.
                if(pipInspectionItem.PIP_Item__c != null) {
                    if (pipItemInspectionItemMap.containsKey(pipInspectionItem.PIP_Item__c)) {
                        inspectionItemsForPIPItem = pipItemInspectionItemMap.get(pipInspectionItem.PIP_Item__c);
                    } else {
                        inspectionItemsForPIPItem = new List<PIP_Inspection_Item__c>();
                    }
                    inspectionItemsForPIPItem.add(pipInspectionItem);
                    pipItemInspectionItemMap.put(pipInspectionItem.PIP_Item__c, inspectionItemsForPIPItem);
                }
            }

        }
        return pipItemInspectionItemMap;

    }

    /**
	 * @description Method to get list of parent PIP Items to update the records 
	 *
	 * @param parentPIPItemIds - Set<Id> list of parent PIP Items
	 * @return List<TASKRAY__Project_Task__c>
	 */
    private List<TASKRAY__Project_Task__c> getParentPIPItemForInspectionItem(Set<Id> parentPIPItemIds){

        List<TASKRAY__Project_Task__c> pipItemsList = [SELECT Id, TASKRAY__Status__c, Status__c, PI_Follow_Up_Date__c,
                PI_HGI__c, PI_Type__c, PI_Billing_Inspection_Count__c, PI_Number_Of_Visits__c, PI_Item_Due_Date__c, Name,
                Failed_Inspection_Count__c
        from TASKRAY__Project_Task__c  where Id IN: parentPIPItemIds];

        return  pipItemsList;

    }

    /**
	 * @description Method to map values for PIP Items, depending on Inspection Item values 
	 *
	 * @param pipItemsList - List<TASKRAY__Project_Task__c> List of PIP Items
	 * @param pipItemInspectionItemMap - Map<Id, List<PIP_Inspection_Item__c>> Map of PIP Items and
	 * corresponding Inspection Items
	 */
    private void mapValuesForPIPItems(List<TASKRAY__Project_Task__c> pipItemsList, Map<Id,
            List<PIP_Inspection_Item__c>> pipItemInspectionItemMap, Boolean isUpdateFlow,
            Map<Id, PIP_Inspection_Item__c> oldMap){

        for(TASKRAY__Project_Task__c pipItem : pipItemsList){
            List<PIP_Inspection_Item__c> inspectionItems = pipItemInspectionItemMap.get(pipItem.Id);
            if(inspectionItems != null && inspectionItems.size() > 0){
                /*If trigger receives more than one Inspection Item for given PIP Item, then refer latest Inspection Item
                for evaluating fields on PIP Items.*/
                PIP_Inspection_Item__c latestInspectionItem = getLatestInspectionItem(inspectionItems);
                if(latestInspectionItem != null) {
                    if(!isUpdateFlow) {
                        pipItem.PI_Number_Of_Visits__c = getNumberOfVisitsCount(pipItem, latestInspectionItem);
                    }
                    pipItem.Status__c = getPIPItemStatus(pipItem, latestInspectionItem);
                    pipItem.PI_Billing_Inspection_Count__c = getBillingInspectionCount(pipItem, latestInspectionItem);
                }
                setFailedInspectionCountPIPItem(pipItem, inspectionItems, oldMap);
            }

        }
        
    }

    /**
	 * @description Method to get PIP Item status depending on Inspection Result of the latest Inspection Item. 
	 *
	 * @param pipItem - TASKRAY__Project__c record
	 * @param latestInspectionItem - Recent record
	 * @return String
	 */
    private String getPIPItemStatus(TASKRAY__Project_Task__c pipItem, PIP_Inspection_Item__c latestInspectionItem){
        String pipItemStatus = null;

        if(latestInspectionItem.LRA_Inspection_Results__c == StaticValue.getStaticValueText('INSPECTION_RESULT_COMPLETE')){
            pipItemStatus = StaticValue.getStaticValueText('PIP_ITEM_STATUS_COMPLETE');
        }else if(latestInspectionItem.LRA_Inspection_Results__c == StaticValue.getStaticValueText('INSPECTION_RESULT_QUESTIONABLE')){
            pipItemStatus = StaticValue.getStaticValueText('PIP_ITEM_STATUS_REVIEW');
        }else if(latestInspectionItem.LRA_Inspection_Results__c == StaticValue.getStaticValueText('INSPECTION_RESULT_FUTURE')){
            pipItemStatus = StaticValue.getStaticValueText('PIP_ITEM_STATUS_PENDING');
        }else if(latestInspectionItem.LRA_Inspection_Results__c == StaticValue.getStaticValueText('INSPECTION_RESULT_INCOMPLETE')){
            if(pipItem.Status__c == 'Pending' && pipItem.PI_Item_Due_Date__c != null &&
                    pipItem.PI_Item_Due_Date__c  > Date.today()){
                pipItemStatus = StaticValue.getStaticValueText('PIP_ITEM_STATUS_PENDING');
            }else{
                pipItemStatus = StaticValue.getStaticValueText('PIP_ITEM_STATUS_INCOMPLETE');
            }
        }else{
            pipItemStatus = StaticValue.getStaticValueText('PIP_ITEM_STATUS_REVIEW');
        }

        return pipItemStatus;
    }

    /**
	 * @description This method will calculate Billing Inspection count depending on Inspection result
	 *
	 * @param pipItem - TASKRAY__Project__c record
	 * @param latestInspectionItem - Recent record
	 * @return Decimal
	 */
    private Decimal getBillingInspectionCount(TASKRAY__Project_Task__c pipItem, PIP_Inspection_Item__c latestInspectionItem){

        Decimal billingInspectionCount = pipItem.PI_Billing_Inspection_Count__c;
        if(pipItem.PI_Type__c == 'AES' && pipItem.PI_HGI__c) {
            if (latestInspectionItem.LRA_Inspection_Results__c == StaticValue.getStaticValueText('INSPECTION_RESULT_INCOMPLETE')){
                if (billingInspectionCount != null) {
                    billingInspectionCount = billingInspectionCount + 1;
                } else {
                    billingInspectionCount = 1;
                }
            }else{
                billingInspectionCount = null;
            }
        }
        return billingInspectionCount;
    }

    /**
	 * @description This method will calculate Number of Visits for on PIP Item. Increment the number of visits field on
	 * the PIP Item for every inspection that LRA does.  Except: If the inspection result is incomplete and current
	 * pip item status is past due then the number of visits is 1. 
	 *
	 * @param pipItem - TASKRAY__Project__c record
	 * @param latestInspectionItem - Recent record
	 * @return Boolean
	 */
    private Decimal getNumberOfVisitsCount(TASKRAY__Project_Task__c pipItem, PIP_Inspection_Item__c latestInspectionItem){
        Decimal numberOfVisits = pipItem.PI_Number_Of_Visits__c;

        if(latestInspectionItem.LRA_Inspection_Results__c == StaticValue.getStaticValueText('INSPECTION_RESULT_INCOMPLETE')
                && pipItem.Status__c == StaticValue.getStaticValueText('PIP_ITEM_STATUS_PAST_DUE')){
            numberOfVisits = 1;
        }else{
            if(numberOfVisits != null){
                numberOfVisits = numberOfVisits + 1;
            }else{
                numberOfVisits = 1;
            }
        }
        return numberOfVisits;
    }

    /**
	 * @description Method to get Latest Inspection Item inserted for a given PIP Item. 
	 *
	 * @param inspectionItems - List of Inspection Items for given PIP Item
	 * @return PIP_Inspection_Item__c
	 */
    private PIP_Inspection_Item__c getLatestInspectionItem(List<PIP_Inspection_Item__c> inspectionItems){
        List<PIP_Inspection_ItemSortWrapper> inspectionItemWrapper = new List<PIP_Inspection_ItemSortWrapper>();
        for(PIP_Inspection_Item__c inspectionItem2 : inspectionItems){
            PIP_Inspection_ItemSortWrapper item = new PIP_Inspection_ItemSortWrapper(inspectionItem2);
            inspectionItemWrapper.add(item);
        }
        //sort Inspection Items by Last Modified Date desc
        inspectionItemWrapper.sort();
        PIP_Inspection_Item__c latestInspectionItem = inspectionItemWrapper[AppConstants.ZERO_INDEX].inspectionItem;

        return latestInspectionItem;
    }

    /**
    * @description Increment Failed Inspection Count for PIP Item where PIP Inspection Item was created/updated and
    * marked as Incomplete and close date > pip item due date
    *
    * @param pipItem Parent pip item record of the pip inspection item
    * @param oldMap Map of old values of PIP Inspection Item
    * @param inspectionItemsForPIP List of new PIP Inspection items
   */
    private void setFailedInspectionCountPIPItem(TASKRAY__Project_Task__c pipItem,
            List<PIP_Inspection_Item__c> inspectionItemsForPIP, Map<Id, PIP_Inspection_Item__c> oldMap){
        for(PIP_Inspection_Item__c pii : inspectionItemsForPIP){
            if((oldMap == null
                    || (oldMap != null
                    && oldMap.get(pii.Id).LRA_Inspection_Results__c != pii.LRA_Inspection_Results__c))
                    && pii.LRA_Inspection_Results__c == INSPECTION_RESULT_INCOMPLETE
                    && pii.CreatedDate > pipItem.PI_Item_Due_Date__c ){
                if(pipItem.Failed_Inspection_Count__c == null){
                    pipItem.Failed_Inspection_Count__c = 1;
                }
                else{
                    pipItem.Failed_Inspection_Count__c += 1;
                }
            }
        }
    }

}