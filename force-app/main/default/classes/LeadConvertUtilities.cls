public class LeadConvertUtilities {
	/*************************************************************************************
	Wrapper class with Match percentage for an Sobject Record
	**************************************************************************************/
	public class SobjectMatchScore {
		public list<Sobject> sObjectRecords;
		public Integer matchScore;
		// constructor
		private SobjectMatchScore(list<Sobject> recs,Integer matchScore) {
			sObjectRecords = new list<Sobject>();
			sObjectRecords.addAll(recs);
			this.matchScore = matchScore;
		}
	}
   /***************************************************************************************
    Method to sort based on the match weightage score
    ****************************************************************************************/
    public static list<SobjectMatchScore> sortRecordsBasedonMatchScore(list<Sobject> queryResults, Lead leadRec) {
	   list<SobjectMatchScore> sortedRecords = new list<SobjectMatchScore>();
    	   map<Integer,list<Sobject>> matchScore = getMatchPercentInfo(queryResults,leadRec);
	   list<Integer> matchScoreKeys = new list<Integer>();
    	   matchScoreKeys.addAll(matchScore.keyset());
    	   // sort match score keys
    	   matchScoreKeys.sort();
	   // display the sorted match score in descending order
	   for(integer i=matchScoreKeys.size()-1; i >= 0; i--) {
			SobjectMatchScore rec = new SobjectMatchScore(matchScore.get(matchScoreKeys[i]),matchScoreKeys[i]);
    	   		sortedRecords.add(rec);
	   }
	   return sortedRecords;
    }
    
    /***************************************************************************************
    Method to return the match weightage score
    ****************************************************************************************/
    private static integer getMatchPercentage(map<String,LeadConvertMatchWeightage__mdt> fieldWeightageMap,Sobject rec,Lead leadRec) {
    	   integer matchScore = 0;
    	   integer fuzzyMatchFieldCount = 0; // number of fields from metadata designed for fuzzy match
    	   integer fuzzyMatchScore = 0; // represents the number of fields that matched the fuzzy logic
    	   integer fuzzyMatchWeight = 0;
    	   final integer MAX_MATCH_SCORE = 100; // percentage cannot be more than 100%
    	   
    	   if(rec != NULL && leadRec != NULL && !fieldWeightageMap.isEmpty()) {
	    	   	 // loop over the fieldweightageMap
	    	   	 for(String fld : fieldWeightageMap.keySet()) {
	    	   	 	LeadConvertMatchWeightage__mdt metadataInfo = fieldWeightageMap.get(fld);
	    	   	 	if(metadataInfo.Matched_Lead_Field_API_Name__c != Null) {
	    	   	 		if(!metadataInfo.Is_Exact_Match__c)
	    	   	 			fuzzyMatchFieldCount++;
	    	   	 		// there could be multiple lead fields that can be matched with the given contact field. Multiple fields are separated by a ;
	    	   	 		list<String> leadFields = metadataInfo.Matched_Lead_Field_API_Name__c.split(';');
	    	   	 		Integer matchWt = Integer.valueOf(metadataInfo.Match_Score__c);
	    	   	 		boolean matchedExactly = false;
	    	   	 		boolean partiallyMatched = false;
	    	   	 		for(String leadFld : leadFields) {
	    	   	 			if(leadRec.get(leadFld) != Null && rec.get(fld) != Null) {
	    	   	 	 			// check if the field is an exact match
		    	   	 		 	if(leadRec.get(leadFld) == rec.get(fld)) {
						 		matchedExactly = true;
						 		break;
				    	   	 	}
			    	   	 		else if(!metadataInfo.Is_Exact_Match__c && String.valueOf(rec.get(fld)).contains(String.valueOf(leadRec.get(leadFld)))) {
		    	   	 				partiallyMatched = true;
								break;
				    	   		} // end of else
	    	   	 			} // end of if
	    	   	 		} // end of inner for loop
	    	   	 		if(matchedExactly) {
	    	   	 			matchScore += matchWt;
	    	   	 		}
	    	   	 		// check for Partially matched field info
	    	   	 	    if(partiallyMatched && !metadataInfo.Is_Exact_Match__c) {
			 			fuzzyMatchScore++;
	    	   	 			fuzzyMatchWeight = matchWt;
			 		}	
	    	   	 	} // end of if
    	   	 	 } // end of outer for loop
    	   } // end of if
    	   if(fuzzyMatchScore == fuzzyMatchFieldCount) // add the fuzzy match weight to the match score only if the counts match
    	   		matchScore += fuzzyMatchWeight;
    	   if(matchScore > MAX_MATCH_SCORE) // if the match score is greater than 100 then assign the match score as 100. This is an edge case scenario
    	   		matchScore = MAX_MATCH_SCORE;		
    	  
    	   return matchScore;
    }
    /***************************************************************************************
    Method to retrieve the appropriate metadata to be passed to get Match percentage
    ****************************************************************************************/
    private static map<Integer,list<Sobject>> getMatchPercentInfo(list<Sobject> queryResults, Lead leadRec) {
    	  map<Integer,list<Sobject>> matchPercent = new map<Integer,list<Sobject>>();
    	  map<String,LeadConvertMatchWeightage__mdt> metaDataFieldWeightageMap = new map<String,LeadConvertMatchWeightage__mdt>();
    	  Integer minScore = 50;
    	  final String ID_FIELD = 'Id';
    	  
    	  if(leadRec != NULL && !queryResults.isEmpty()) {
    	  	// get the SObject info based on the query result
    	  	String sobjectName = FranchiseSalesUtilities.getSobjectName(queryResults[0].Id);
    	  	// get the metadata info based on the sobject
    	  	list<LeadConvertMatchWeightage__mdt> matchWeightageMetadata = CustomMetadataDA.getMatchWeightageInfo(sobjectName);
    	  	if(!matchWeightageMetadata.isEmpty()) {
    	  		// populate the collections based on the metadata info
    	  		for(LeadConvertMatchWeightage__mdt rec : matchWeightageMetadata) {
    	  			metaDataFieldWeightageMap.put(rec.Match_Field_API_Name__c,rec);
    	  		}
    	  		//loop over the query results to get the match percentage
    	  		for(Sobject obj : queryResults) {
    	  			integer matchScore = getMatchPercentage(metaDataFieldWeightageMap,obj,leadRec);
    	  			// add only the records whose match score is greater than some score 
    	  			String minScoreNeeded = Label.LeadConvertMinMatchScore;
    	  			if(!String.isEmpty(minScoreNeeded)) {
    	  				minScore = Integer.valueOf(minScoreNeeded);
    	  			}
    	  			if(matchScore >= minScore) {
    	  				if(matchPercent.get(matchScore) != Null)
    	  					matchPercent.get(matchScore).add(obj); 
    	  				else {
    	  					list<Sobject> temp = new list<Sobject>();
    	  					temp.add(obj);
    	  					matchPercent.put(matchScore,temp);
    	  				}	
    	  			}
    	  		}
    	  	}
    	  }
    	  return matchPercent;
    }
    /***************************************************************************************
    Method to build metadata query based on a field 
    ****************************************************************************************/
    public static set<String> getQueryAttributes(String mdtType) {
    	   set<String> sObjQueryAttribs = new set<String>();
    	   if(!String.isEmpty(mdtType)) {
	   	  // build a dynamic query to get the metadata info
    	 	String mdtQuery = 'SELECT ' + Label.Custom_Metadata_Field_to_Reference_Sobj_Field + ' FROM ' + mdtType;
    	 	for(Sobject obj : database.query(mdtQuery)) {
    	 		if(obj.get(Label.Custom_Metadata_Field_to_Reference_Sobj_Field) != Null) {
    	 			String fld = String.valueOf(obj.get(Label.Custom_Metadata_Field_to_Reference_Sobj_Field));
	    	 		sObjQueryAttribs.add(fld);
    	 		}
    	 	}
    	   }
    	   return sObjQueryAttribs;
    }
    
    /***************************************************************************************
    Method to dynamically build the query based on the Sobject 
    ****************************************************************************************/
    public static string getSobjectQuery(string sObjectName, Lead leadRec) {
    	 String query;
    	 String displayFieldMetaData;
    	 String filterConditionMetaData;
    	 if(!String.isEmpty(sObjectName) && leadRec != NULL) {
    	 	 // query the metadata accordingly
	    	 for(LeadConvert_MetadataMappings__mdt metadataInfo : [SELECT Mapped_Metadata_API_Name__c,Represents_Display_Metadata__c,SObject_API_Name__c FROM LeadConvert_MetadataMappings__mdt WHERE SObject_API_Name__c = :sObjectName]) {
	    	     if(metadataInfo.Represents_Display_Metadata__c) 
	    	     	displayFieldMetaData = metadataInfo.Mapped_Metadata_API_Name__c; 
	    	     else
	    	     	filterConditionMetaData = metadataInfo.Mapped_Metadata_API_Name__c; 
	    	 }
	    	 if(!String.isEmpty(displayFieldMetaData) && !String.isEmpty(filterConditionMetaData)) {
	    	 	// build a dynamic query based on the metadata info
	    	 	for(String fld : getQueryAttributes(displayFieldMetaData)) {
    	 	 		if(String.isEmpty(query)) 
	    	 			query = fld;
	    	 		else
	    	 		    query = query + ',' + fld;	
	    	 	}
	    	    // prefix the select statement accordingly
	    	    if(!String.isEmpty(query))	{
	    	    	  // query the filter criteria information
	    	  	  String mdtQuery = 'SELECT Field_API_Name__c,Matched_Lead_Field_API_Name__c,Needs_Exact_Match__c FROM ' + filterConditionMetaData;
	    	  	  String filters;
	    	  	  for(Sobject obj : database.query(mdtQuery)) {
	    	  	  	 String fld = String.valueOf(obj.get(Label.Custom_Metadata_Field_to_Reference_Sobj_Field));
	    	  	  	 String leadFld = String.valueOf(obj.get(Label.Matched_Lead_Field_API_Name_For_Lead_Convert));
	    	  	  	 Boolean needsExactMatch = Boolean.valueOf(obj.get(Label.Needs_Exact_Match_Field_API_Name_For_Lead_Convert));
	    	  	  	 if(leadRec.get(leadFld) != Null) {
	    	  	  	 	String exactFilter = fld + ' = \'' + leadRec.get(leadFld) + '\'';
	    	  	  	 	String fuzzyFilter = fld + ' LIKE \'%' + leadRec.get(leadFld) + '%\'';
	    	  	  	 	 // add the filter accordingly
	    	  	  	 	if(needsExactMatch) 
	    	  	  	 		filters = String.isEmpty(filters) ? exactFilter : filters + ' OR ' + exactFilter;
	    	  	  	 	else
	    	  	  	 	    filters = String.isEmpty(filters) ? fuzzyFilter : filters + ' OR ' + fuzzyFilter;
		    	  	 
	    	  	      }
	    	  	  }
	    	  	  if(!String.isEmpty(filters))
	    	  	  	query = 'SELECT ' + query + ' FROM ' + sObjectName + ' WHERE ' + filters + ' LIMIT ' + Limits.getLimitQueryRows();
	    	    }
	    	 }
	  }
    	 
    		return query;
    }

    /***************************************************************************************
    Method to dynamically mapLeadFieldsFromMetadata
    ****************************************************************************************/
	public static SObject mapLeadFieldsFromMetaData(SObject obj , Lead l, String sObjectName){
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get(FranchiseSalesUtilities.getSobjectName(l.Id));
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

		for(Lead_Convert_Conversion_Mapping__mdt metadata : CustomMetadataDA.getLeadConvertConversionMappingBySObject(sobjectName)){
			try{
				List<String> fields = new List<String>();
				String concatinatedString = '';
				Boolean needsConcatinated = false;

				if(metadata.Lead_Field_API_Name__c != null){

					if(metadata.Lead_Field_API_Name__c.contains(';')){
						fields = metadata.Lead_Field_API_Name__c.split(';');
						needsConcatinated = true;
					}
				}

				if(needsConcatinated){
					for(String field : fields){
						Object value = getValue(field, fieldMap, obj, l,metadata.Use_Picklist_Label__c);
						if(value != null){
							concatinatedString +=  value + '-';
						}
					}
					if(!String.isEmpty(concatinatedString)){
						concatinatedString = concatinatedString.removeEnd('-');
						obj.put(metadata.SObject_Field_API_Name__c, concatinatedString);							
					}
				}
				else{
					if(l.get(metadata.Lead_Field_API_Name__c) != null){
						Object value = getValue(metadata.Lead_Field_API_Name__c, fieldMap, obj, l, metadata.Use_Picklist_Label__c);
						if(value != null){
							obj.put(metadata.SObject_Field_API_Name__c, value);
						}
					}
				}
			}
			catch(Exception e){
				System.debug(e.getMessage());
			}			
		}
		System.debug('Object ' + obj);

		return obj;

	}

    /***************************************************************************************
    Method to get correct value for lead mapping
    ****************************************************************************************/
	public static Object getValue(String apiName, Map<String, Schema.SObjectField> fieldMap, SObject obj, Lead l, Boolean useLabel){
		if(fieldMap.containsKey(apiName)){
			if(fieldMap.get(apiName).getDescribe().getType() == Schema.DisplayType.PickList && useLabel){
				for(Schema.PicklistEntry pe : fieldMap.get(apiName).getDescribe().getPickListValues()){
					if(l.get(apiName) == pe.getValue()){
						return pe.getLabel();
					}
				}
			}
		}

		return l.get(apiName);
	}

    /***************************************************************************************
    Method to get recordtype based on Lead Convert Record Type Metadata
    ****************************************************************************************/
	public static Id getRecordTypeIdFromLead(String leadValue, sObject obj, String sObjectName){
		String defaultLabel = '';
		for(Lead_Convert_RecordType_Mapping__mdt metadata : CustomMetadataDA.getLeadConvertRecordTypeMappingBySObject(sObjectName)){
			if(metadata.Lead_Value__c == 'Default'){
				defaultLabel = metadata.Record_Type_Label__c;
			}
			else if(leadValue == metadata.Lead_Value__c){
				return FranchiseSalesUtilities.getRecordTypeById(obj, metadata.Record_Type_Label__c);
			}
		}
		return FranchiseSalesUtilities.getRecordTypeById(obj, defaultLabel);
	}
}