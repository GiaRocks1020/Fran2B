/**
 * @description Controller for the PIPLineItemSelectionComp
 *
 * @author Madan Morusu
 * @date 2019-08-22
 */
public with sharing class PIPSelectionCompCtrl {
    public PIPSelectionCompCtrl() {

    }

    /**
    * @description Wrapper class for displaying the line items on the component. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */
    public class PIPLibraryItemWrapper{
        public boolean preSelected;
        public boolean isSelected;
        public PIP_Library_Item__c pipLibraryItem;
        public PIPLibraryItemWrapper(){
            preSelected = false;
            isSelected = false;
            pipLibraryItem = new PIP_Library_Item__c();

        }
    }
    /**
    * @description Wrapper list for displaying the line items on the component. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    * @param pipId - Pip Id to query the Library Items based on the Brand
    * @param sortField 
    * @param sortDirection
    * @return String
    */
    @AuraEnabled
    public static string getLibraryItemWrapperList(String pipId, string sortField, string sortDirection){
        List<String> selectedLibraryItemIds = New List<String>();
        List<PIP_Library_Item__c> pipLibraryItems = new List<PIP_Library_Item__c>();
        List<PIPLibraryItemWrapper> wrapperList = new List<PIPLibraryItemWrapper>();
        selectedLibraryItemIds = getSelectedLibraryItems(pipId);
        pipLibraryItems = getsortedPIPLibraryItemsByPIP(pipId,sortField,sortDirection);
        for(PIP_Library_Item__c pip : pipLibraryItems){
            PIPLibraryItemWrapper tempWrapper =new PIPLibraryItemWrapper();
            tempWrapper.pipLibraryItem = pip;
            if(selectedLibraryItemIds.size()>0)
                tempWrapper.preSelected = selectedLibraryItemIds.contains(pip.id);
            wrapperList.add(tempWrapper);
        }
        return System.JSON.Serialize(wrapperList);
    }
    /**
    * @description auraenabled method that returns the List of pre selected Library Line Items IDs for the PIP Id. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    * @param pipId - Pip Id to query the Library Items based on the Brand
    * @return List<String>
    */
    @AuraEnabled
    public static List<String> getSelectedLibraryItems(String pipId){
        List<String> pipLibraryItemIds = new List<String>();
        if(pipId != null){
            for(TaskRay__Project_Task__c prjTask : [Select id, PIP_Library_Item__c from TaskRay__Project_Task__c Where TaskRay__Project__c =: pipId]){
                pipLibraryItemIds.add(prjtask.PIP_Library_Item__c);
            }
        }
        if(pipLibraryItemIds != Null && pipLibraryItemIds.size()>0){
            return pipLibraryItemIds;
        }
        else {
            return pipLibraryItemIds;
        }
    }
    /**
    * @description auraenabled method that returns the List of PIP Library Line Items for the PIP Id pre sorted by Name in Asc order. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    * @param pipId - Pip Id to query the Library Items based on the Brand
    * @return List<PIP_Library_Item__c>    
    */
    @AuraEnabled
    public static List<PIP_Library_Item__c> getPIPLibraryItemsByPIP(String pipId){
        return getsortedPIPLibraryItemsByPIP(pipId, 'Name','ASC');
    }
    /**
    * @description auraenabled method that returns the List of PIP Library Line Items for the PIP Id sorted based on the parameters passed. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    * @param pipId - Pip Id to query the Library Items based on the Brand
    * @param sortField - Sort by Field
    * @param sortDirection - Sort by Direction
    * @return List<PIP_Library_Item__c>    
    */
    @AuraEnabled
    public static List<PIP_Library_Item__c> getsortedPIPLibraryItemsByPIP(String pipId,string sortField, string sortDirection){
        List<PIP_Library_Item__c> pipLibraryItems = new List<PIP_Library_Item__c>();
        if(PIPId != null){
            TaskRay__Project__c pip = new TaskRay__Project__c();
            pip = [Select id, Brand__c, Brand__r.Name from TaskRay__Project__c where id =: pipId];
            if(PIP != null && PIP.Brand__c != Null && PIP.Brand__r.Name != Null){
                String sortString = '';
                List<String> fields = sortField.split(',');
                for(Integer i=0; i < fields.size() ; i++){
                    sortString = sortString+ fields[i]+' '+sortDirection;
                    if(i+1 < fields.size())
                    sortString = sortString + ',';
                }
                String soqlQuery = 'Select id, Name, PI_Type__c, PI_Short_Name__c, Category__c, Program__c ,PI_Brands__c,PI_Design__c, PI_Description__c from PIP_Library_Item__c where Active__c = true and Brand__c INCLUDES (\''+PIP.Brand__r.Name+'\') Order By '+sortString;
                pipLibraryItems = Database.query(soqlQuery);
            }
        }
        if(pipLibraryItems != Null && pipLibraryItems.size()>0){
            return pipLibraryItems;
        }
        else {
            return null;
        }
    }
    /**
    * @description auraenabled method that creates Tasks based on the Library Items Passed. 
    
    * @author Madan Morusu
    * @date 2019-09-10
    * @param pipId - Pip Library Item Id
    * @param pipLibraryItems - Serialized PIP Library Item IDs.
    * @return string - PIP Id to returnt the UI to. 
    */
    @AuraEnabled
    public static string createPIPItems(String pipId, String pipLibraryItems){
        List<String> libraryItems = new List<String>();
        if(String.ISNOTBLANK(pipLibraryItems)){
            libraryItems=(List<String>)System.JSON.deserialize(pipLibraryItems,List<String>.Class);
        }
        if(libraryItems.size()>0){
            list<TaskRay__Project_Task__c> taskList = new List<TaskRay__Project_Task__c>();
            for(PIP_Library_Item__c libraryItem : [Select Id,
                    Active__c,
                    Category__c,
                    Name,
                    PI_Architecture__c,
                    PI_Brands__c,
                    PI_Design__c,
                    PI_Education__c,
                    PI_HGI__c,
                    PI_Incentive_Program__c,
                    PI_Maintenance__c,
                    PI_Procurement__c,
                    PI_QA__c,
                    PI_Signage__c,
                    PI_Verify__c,
                    PI_Description__c,
                    PI_Short_Name__c,
                    PI_Major_Minor__c,
                    PI_Type__c,
                    Program__c,
                    PI_Average_Cost__c,
                    PI_Cost_Units__c
            From PIP_Library_Item__c Where ID IN: libraryItems]){
                taskList.add(new TaskRay__Project_Task__c(
                        Name = libraryItem.Name,
                        TaskRay__Project__c = PIPId,
                        PIP_Library_Item__c = libraryItem.Id,
                        PI_Architecture__c = libraryItem.PI_Architecture__c,
                        PI_Brands__c = libraryItem.PI_Brands__c,
                        PI_Design__c = libraryItem.PI_Design__c,
                        PI_Education__c = libraryItem.PI_Education__c,
                        PI_HGI__c = libraryItem.PI_HGI__c,
                        PI_Incentive_Program__c = libraryItem.PI_Incentive_Program__c,
                        PI_Maintenance__c = libraryItem.PI_Maintenance__c,
                        PI_Procurement__c = libraryItem.PI_Procurement__c,
                        PI_QA__c = libraryItem.PI_QA__c,
                        PI_Signage__c = libraryItem.PI_Signage__c,
                        PI_Verify__c = libraryItem.PI_Verify__c,
                        TaskRay__Description__c = libraryItem.PI_Description__c,
                        PI_Short_Name__c = libraryItem.PI_Short_Name__c,
                        PI_Major_Minor__c = libraryItem.PI_Major_Minor__c,
                        PI_Type__c = libraryItem.PI_Type__c,
                        Active__c	= libraryItem.Active__c,
                        Category__c = libraryItem.Category__c,
                        Program__c = libraryItem.Program__c,
                        //PI_Item_Due_Date__c = System.Today().addMonths(12), -- CK - removed since business wants item due date blank
                        PI_Estimated_Cost_per_Cost_Unit__c = libraryItem.PI_Average_Cost__c,
                        PI_Cost_Units__c = libraryItem.PI_Cost_Units__c
                ));
            }
            if(taskList.size()>0){
                insert taskList;
            }
        }
        return pipId;
    }

    /**
    * @description Method that returns a serialized String of dependent picklist values. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    * @return String 
    */
    @AuraEnabled
    public static String getSubCategoryPickList(){
        return getDependentPicklistValues(PIP_Library_Item__c.Category__c,PIP_Library_Item__c.Program__c);
    }
    /**
    * @description Returns a serialized String of dependent picklist values. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    * @param theField - Dependent Field
    * @param ctrlField - Controlling Field
    * @return String 
    */
    public static String getDependentPicklistValues(Schema.SObjectField theField, Schema.SObjectField ctrlField) {
		// validFor property cannot be accessed via a method or a property,
		// so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
		List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
		List<PicklistEntryWrapper> depEntries =
				wrapPicklistEntries(theField.getDescribe().getPicklistValues());

		// Set up the return container - Map<ControllingValue, List<DependentValues>>
		Map<String, List<String>> objResults = new Map<String, List<String>>();
		List<String> controllingValues = new List<String>();
        List<dependentPicklistWrapper> depListWrp = new List<dependentPicklistWrapper>();
		for (Schema.PicklistEntry ple : contrEntries) {
			String label = ple.getLabel();
			objResults.put(label, new List<String>());
			controllingValues.add(label);
		}

		for (PicklistEntryWrapper plew : depEntries) {
			String label = plew.label;
			String validForBits = base64ToBits(plew.validFor);
			for (Integer i = 0; i < validForBits.length(); i++) {
				// For each bit, in order: if it's a 1, add this label to the dependent list for the corresponding controlling value
				String bit = validForBits.mid(i, 1);
				if (bit == '1') {
					objResults.get(controllingValues.get(i)).add(label);
				}
			}
		}
        for(String key: objResults.keySet()){
            depListWrp.add(new dependentPicklistWrapper(key,objResults.get(key)));
        }
		return JSON.serialize(depListWrp);
	}


	private static String decimalToBinary(Integer val) {
		String bits = '';
		while (val > 0) {
			Integer remainder = Math.mod(val, 2);
			val = Integer.valueOf(Math.floor(val / 2));
			bits = String.valueOf(remainder) + bits;
		}
		return bits;
	}

	private static String base64ToBits(String validFor) {
		if (String.isEmpty(validFor)) return '';

		String validForBits = '';

		for (Integer i = 0; i < validFor.length(); i++) {
			String thisChar = validFor.mid(i, 1);
			Integer val = base64Chars.indexOf(thisChar);
			String bits = decimalToBinary(val).leftPad(6, '0');
			validForBits += bits;
		}
		return validForBits;
	}


	private static final String base64Chars = '' +
			'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
			'abcdefghijklmnopqrstuvwxyz' +
			'0123456789+/';


	private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
		return (List<PicklistEntryWrapper>)
			JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
	}

    /**
    * @description wrapper fo the picklist entry. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */
	public class PicklistEntryWrapper {
		public String active {get; set;}
		public String defaultValue {get; set;}
		public String label {get; set;}
		public String value {get; set;}
		public String validFor {get; set;}
	}

    /**
    * @description wrapper for the dependent picklist structure returned back to c. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */
    public class dependentPicklistWrapper{
        public string controllingPicklist;
        public List<String> dependentPickList;
        public dependentPicklistWrapper(string controllingPicklist,List<String> dependentPickList){
            this.dependentPickList = dependentPickList;
            this.controllingPicklist = controllingPicklist;
        }
    }
}