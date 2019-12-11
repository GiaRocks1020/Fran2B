/**
    * @description Batch job to copy all history tracking records of objects listed in the History_Tracking_Objects record
    * 				of Static Value custom metadata and Fields listed in the History Tracking Fields custom Metadata for today. 
    *
    * @author Madan Morusu
    * @date 2019-10-06
    */
global class HistoryTrackerBackupBatch implements Database.Batchable<sObject>,Database.Stateful{
    public String currentObjectName; 
    String query;
    Set<String> FieldNames;
    Final List<String> Objects;
    global HistoryTrackerBackupBatch() {
        FieldNames = new Set<String>();
	    Objects = new List<String>();
        for(History_Tracker_Fields__mdt HTF: [Select Fields__c, Object_Name__c from History_Tracker_Fields__mdt ]){
            Objects.add(HTF.Object_Name__c);
        }
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String ParentId = '';
        if(currentObjectName == null || currentObjectName == ''){
            currentObjectName = Objects[0];
        }
        if(!currentObjectName.contains('__'))
            ParentId = currentObjectName.replace('History', 'Id');
        else
            ParentId = 'ParentId';
		FieldNames = HistoryTracker_Util.getFieldstoTrackByObject(currentObjectName);
		query = 'Select id, NewValue, Oldvalue,  CreatedDate, CreatedById,Field,'+ParentId+' from '+currentObjectName+ ' Where CreatedDate = Today';        
        System.debug(query);
        return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug(fieldNames+''+currentObjectName);
    	List<History_Tracker__c> listHist = HistoryTracker_Util.initHistoryTrackerRecords(scope,FieldNames, currentObjectName);
		upsert listHist History_Record_Id__c;
        System.debug(listHist);
    }
	
	global void finish(Database.BatchableContext BC) {
        integer indexofObj = Objects.indexof(currentObjectName);
        System.debug(indexOfObj);            
        if(Objects.size() > indexofObj+1){
        	System.debug(indexOfObj);            
            indexofObj = indexofObj+1;
            HistoryTrackerBackupBatch nextBatch = new HistoryTrackerBackupBatch();
            nextBatch.currentObjectName = Objects[indexofObj];
            database.executeBatch(nextBatch); 
        }
        else
        {
            System.debug('All History Records Backedup.');
        }
	}
	
}