/**
    * @description Utility class for history Tracker Object. 
    *
    * @author Madan Morusu
    * @date 2019-10-06
    */
public without Sharing class HistoryTracker_Util{
    /**
    * @description Method that creates and inserts history tracking records for the objects created.  
    *
    * @author Madan Morusu
    * @date 2019-10-06
    * @param oldsObjectMap - Old records map 
    * @param newsObjectMap - New records map 
    * @param ObjectName - Name of the object.   
    */
    public static void createHistoryTrackerRecords(Map<Id, SObject> oldsObjectMap, Map<Id, SObject> newsObjectMap, String ObjectName){
        List<History_Tracker__c> listHistoryRecords = new List<History_Tracker__c>();       
        Set<String> fieldNames = getFieldsNotFieldTrackedByObject(ObjectName);
        For(String key : oldsObjectMap.keyset()){
            listHistoryRecords.addall(initHistoryTrackerRecords(newsObjectMap.get(key),oldsObjectMap.get(key),fieldNames));
        }
        if(listHistoryRecords.size()>0)
            insert listHistoryRecords;       
    }
    /**
    * @description Async Method that creates and inserts history tracking records for the objects created.  
    *
    * @author Madan Morusu
    * @date 2019-10-06
    * @param oldsObjectMap - Old records map JSON String
    * @param newsObjectMap - New records map JSON String
    * @param ObjectName - Name of the object.   
    */
    @future 
    public static void createHistoryTrackerRecords(String OldMap, String newMap, String ObjectName){
        Map<Id, sObject> oldsObjectMap = new Map<Id, sObject>();
        Map<Id, sObject> newsObjectMap = new Map<Id, sObject>();
        oldsObjectMap = (Map<Id, sObject>)JSON.deserialize(oldMap, Map<Id, sObject>.class);
        newsObjectMap = (Map<Id, sObject>)JSON.deserialize(newMap, Map<Id, sObject>.class);        
        createHistoryTrackerRecords(oldsObjectMap,newsObjectMap,ObjectName);        
    }
    /**
    * @description Method that initializes and returns  history tracking records for the record passes.  
    *
    * @author Madan Morusu
    * @date 2019-10-06
    * @param newRec - sObject of new Rec
    * @param oldRec - sObject of old Rec
    * @param Fields - Set of fields to be checked for tracking.   
    */
    public static list<History_Tracker__c> initHistoryTrackerRecords(SObject newRec, SObject oldRec, Set<String> FieldNames){
        //Loop thru the list to create the fields. 
        List<History_Tracker__c> listHistoryRecords = new List<History_Tracker__c>();
        for(String fieldName : fieldNames){
                if(oldRec.get(fieldName) != newRec.get(fieldName)){
                    History_Tracker__c tempHT = new History_Tracker__c();
                    tempHT.New_Value__c = newRec.get(fieldName) != null?String.ValueOf(newRec.get(fieldName)):null;
                    tempHT.Old_Value__c = oldRec.get(fieldName) != null?String.valueOf(oldRec.get(fieldName)):null;
                    tempHT.Field_Modified_Date__c = System.now();
                    TempHT.Field_Label__c = FieldAPINameMap.get(fieldName);
                    tempHT.Field_Modified_By__c = System.UserInfo.getUserId();
                    tempHT.ParentId__c = newRec.get('Id')!=null?(String)newRec.get('Id'):null;
                    if(tempHT.parentId__c != null)
                    {
                        id parentID = tempHT.ParentId__c;
                        if(parentID.getSObjectType().getDescribe().getName() == 'TaskRay__Project__c'){
                            tempHT.TaskRay_Project__c = ParentId;
                        }
                        else if(parentID.getSObjectType().getDescribe().getName() == 'TaskRay__Project_Task__c'){
                            tempHT.TaskRay_Task__c = ParentId;
                        }
                    }
                    listHistoryRecords.add(tempHT);
                }
            }
        return listHistoryRecords;
    }
    /**
    * @description Method that initializes and returns  history tracking records for the record passes.  
    *
    * @author Madan Morusu
    * @date 2019-10-06
    * @param historyRecs - List of History Records to be copied from
    * @param fields - Fields to be tracked
    * @param currentObjectName - Name of the Object tracked.   
    */
    public static list<History_Tracker__c> initHistoryTrackerRecords(List<sObject> historyRecs, Set<String> fields, String currentObjectName){
        //Loop thru the list to create the fields. 
        List<History_Tracker__c> listHistoryRecords = new List<History_Tracker__c>();
        String ParentIdLabel = 'ParentID';
        string tempObjName;
        if(currentObjectName.contains('__History'))
            tempObjName = currentObjectName.replace('__History','__c');
        else if (currentObjectName.contains('History'))
            tempObjName = currentObjectName.replace('History','');
        FieldAPINameMap = new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(tempObjName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for(String Field : fields){
            System.debug(Field);
            if(field!='' && field != null)
            	FieldAPINameMap.put(field,fieldMap.get(field).getDescribe().getLabel());//It provides to get the object fields label.
        }
        for(sObject s : historyRecs){
            if(fields.contains(String.valueOf(s.get('Field')))){
                History_Tracker__c h = new History_Tracker__c();
                h.New_Value__c = s.get('NewValue') != null ? String.ValueOf(s.get('NewValue')):null;
                h.Old_Value__c = s.get('OldValue') != null ? String.valueOf(s.get('OldValue')):null;
                System.debug('field'+s.get('Field'));
                h.Field_Label__c = s.get('Field') != null ? FieldAPINameMap.get(String.valueOf(s.get('field'))):null;
                h.History_Record_Id__c = s.get('Field') != null ? String.valueOf(s.get('Id')):null;
                if(!currentObjectName.contains('__'))
                    ParentIdLabel = currentObjectName.replace('History', 'Id');
                System.debug(ParentIdLabel);
                h.ParentId__c = String.valueOf(s.get(ParentIdLabel));
                Id parentID = h.ParentId__c;
                if(parentID.getSObjectType().getDescribe().getName() == 'TaskRay__Project__c'){
                    h.TaskRay_Project__c = h.parentId__c;
                }
                else if(parentID.getSObjectType().getDescribe().getName() == 'TaskRay__Project_Task__c'){
                    h.TaskRay_Task__c = h.parentId__c;
                }
                h.Field_Modified_By__c = String.valueOf(s.get('CreatedByID'));
                h.Field_Modified_Date__c = (DateTime)(s.get('CreatedDate'));
                listHistoryRecords.add(h);
            }
        }
        return listHistoryRecords;
    }
    /**
    * @description Method returns fields that have fieldTracking enabled for any given object.  
    *
    * @author Madan Morusu
    * @date 2019-10-06
    * @param ObjectName - Name of the Object.
    * @return - Set of Fields to be Tracked.    
    */
    public static Set<String> getFieldstoTrackByObject(String  ObjectName){
        Set<String> FieldNames = new Set<String>();
        System.debug('ObjectName'+ObjectName);
        for(History_Tracker_Fields__mdt HTF: [Select Fields__c, Object_Name__c from History_Tracker_Fields__mdt where Object_Name__c =: ObjectName]){
            List<String> fields = HTF.Fields__c.split(',');            
            FieldNames.addall(fields);
        }
        string tempObjName;
        if(ObjectName.contains('__History'))
            tempObjName = ObjectName.replace('__History','__c');
        else if (ObjectName.contains('History'))
            tempObjName = ObjectName.replace('History','');
        FieldAPINameMap = new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(tempObjName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for(String Field : FieldNames){
            System.debug(Field);
            if(field!='' && field != null)
            	FieldAPINameMap.put(field,fieldMap.get(field).getDescribe().getLabel());//It provides to get the object fields label.
        }
        
        return FieldNames;
        
    }
    
    public static Map<String,String> FieldAPINameMap; 
    /**
    * @description Method returns fields that do not have fieldTracking enabled for given object.  
    *
    * @author Madan Morusu
    * @date 2019-10-06
    * @param ObjectName - Name of the Object.
    * @return - Set of Fields to be Tracked.    
    */
    public static Set<String> getFieldsNotFieldTrackedByObject(String ObjectName){
        string tempObjName;
        if(ObjectName.contains('__History'))
            tempObjName = ObjectName.replace('__History','__c');
        else if (ObjectName.contains('History'))
            tempObjName = ObjectName.replace('History','');
        System.debug('ObjectName'+ObjectName);
        Set<String> FieldNames = getFieldstoTrackByObject(ObjectName);
        for(FieldDefinition fd : [SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName =: tempObjName AND IsFieldHistoryTracked = true]){
            if(FieldNames.contains(fd.QualifiedAPIName)){
                FieldNames.remove(fd.QualifiedAPIName);
            }
        }
        return FieldNames;
    }
    
    
}