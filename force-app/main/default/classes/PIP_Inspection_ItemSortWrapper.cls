/**
 *  @description Comparable class implementation for sorting Inspection Items by Last modified date
 *  @author Pradnya Desai
 *  @date 2019-09-16
 */


global class PIP_Inspection_ItemSortWrapper implements Comparable{

    public PIP_Inspection_Item__c inspectionItem;

    // Constructor
    public PIP_Inspection_ItemSortWrapper(PIP_Inspection_Item__c inspectionItem) {
        this.inspectionItem = inspectionItem;
    }

    // Compare PIP_Inspection_Item__c based on the Last Modified Date.
    global Integer compareTo(Object inputInspectionItem) {
        // Cast argument to PIP_Inspection_ItemSortWrapper
        PIP_Inspection_ItemSortWrapper compareToInspectionItem = (PIP_Inspection_ItemSortWrapper)inputInspectionItem;

        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;

        if (inspectionItem.LastModifiedDate < compareToInspectionItem.inspectionItem.LastModifiedDate) {
             // Set return value to a positive value.
            returnValue = 1;
        } else if (inspectionItem.LastModifiedDate > compareToInspectionItem.inspectionItem.LastModifiedDate) {
            // Set return value to a negative value.
            returnValue = -1;
        }

        return returnValue;
    }

}