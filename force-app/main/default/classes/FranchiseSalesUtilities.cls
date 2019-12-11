public class FranchiseSalesUtilities {
   /**********************************************************************************************************
    Method to dynamically retrieve the Sobject field information
    ***********************************************************************************************************/
    public static set<String> getSobjectFields(String sObjectName) {
	    	set<String> fieldInfo = new set<String>();
	    	if(!String.isEmpty(sObjectName)) {
	    		  map<String, Schema.SObjectType> allObjects = Schema.getGlobalDescribe();
	            // describe the sobject in context
	            Schema.SObjectType currentObj = allObjects.get(sObjectName);
	            if(currentObj != Null) {
	                Schema.DescribeSobjectResult sobjDescribe = currentObj.getDescribe();
	                map<String, Schema.SObjectField> objInfo = sobjDescribe.fields.getMap();
	                for(Schema.SObjectField fld : sobjDescribe.fields.getMap().Values()) {
	                	   if(fld.getDescribe().isUpdateable()) {
	                	   		fieldInfo.add(fld.getDescribe().getName());
	                	   }
	                }
	    		  
	    			}
	    	}
	    	return fieldInfo;
	    
    }  
    /***************************************************************************************
    Method to get the Sobject name based on the id
    ****************************************************************************************/
    public static String getSobjectName(ID recId) {
        String objName;
        if(!String.isEmpty(recId)) {
            Schema.SObjectType objType = recId.getSObjectType();
            objName = objType.getDescribe().getName();
        }
        return objName;
    }

    /***************************************************************************************
    Method to get the RecordTypeId based on object and Name
    ****************************************************************************************/
    public static Id getRecordTypeById(sObject obj, String recordTypeName){
        	Schema.DescribeSObjectResult R = Contract.SObjectType.getDescribe();
			List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();

            obj.getSObjectType().getDescribe();
			
            return obj.getSObjectType().getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }

    /***************************************************************************************
    Returns a wrapper class that contains label and value picklist info
    ****************************************************************************************/   
    public static List<Picklist> getPicklistValues(sObject objObject, string fld){
        List < Picklist > allOpts = new List < Picklist > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(new Picklist(a));
        }
        return allOpts;       
    }
    
    public class Picklist {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public Picklist(Schema.PicklistEntry ple){
            label = ple.getLabel();
            value = ple.getValue();
        }
    }
}