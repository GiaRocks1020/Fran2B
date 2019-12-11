public class LeadRoutingHelper {
	
	/****************************************************************
    	DESCRIPTION:
    		Method to identify lead records that need routing.
    	INPUTS:
    		list<lead>
    	RETURNS
    		list<lead>
    ****************************************************************/	
	public static list<Lead> getLeadsThatNeedRouting(list<Lead> leads) {
		list<Lead> recs = new list<Lead>();
		if(!leads.isEmpty()) {
			set<String> leadSources = new set<String>();
			// get the metadata information
			for(Lead_Source_for_Routing__mdt leadSourceInfo : CustomMetadataDA.getLeadSourcesForRouting())
				leadSources.add(leadSourceInfo.label);
			if(!leadSources.isEmpty()) {
				for(Lead rec : leads) {
					if(!String.isEmpty(rec.LeadSource) && leadSources.contains(rec.LeadSource))
						recs.add(rec);
				}
			}	
		}
		return recs;
	}
	/****************************************************************
    	DESCRIPTION:
    		Method to identify lead recpords whose Brand of Interest and StateCode fields are updated
    	INPUTS:
    		map<Id,Sobject>newMap, map<Id,Sobject>oldMap
    	RETURNS
    		list<lead>
    ****************************************************************/	
	public static list<Lead> checkIfLeadStateOrBrandOfInterestHasChanged(List<Lead> leads, map<Id,Sobject>oldMap){
        list<Lead> updatedLeads = new list<Lead>();
        if(!leads.isEmpty() && !oldMap.isEmpty()) {
        		for(Lead rec : leads) {
        		    if(rec.Brand_of_Interest__c != oldMap.get(rec.Id).get(Label.Lead_Brand_Of_Interest_Field) || rec.StateCode != oldMap.get(rec.Id).get(Label.Lead_StateCode_Field)) {
        		    		updatedLeads.add(rec);
        		    }	
        		}
        }
        return updatedLeads;
    }
    /****************************************************************
    	DESCRIPTION:
    		Method to route leads based on BrandCode, StateCode and Country 
    	INPUTS:
    		list<Lead> leads
    	RETURNS
    		list<lead>
    ****************************************************************/	
	public static list<Lead> assignLeads(list<Lead> leads) {
		list<Lead> recs = new list<Lead>();
		if(!leads.isEmpty()) {
			// get the metadata information
			list<Brand_Ranking__mdt> brandRankings = CustomMetadataDA.getBrandRankings();
			map<String,String> userAssignmentMap = new map<String,String>();
			map<String,String> mappedUserId = new map<String,String>();
			map<String,String> queueAssignmentMap = new map<String,String>();
			map<String,String> mappedQueueId = new map<String,String>();
			map<String,String> brandCodeMap = new map<String,String>();
			if(!brandRankings.isEmpty()) {
				for(Brand_Ranking__mdt rank : brandRankings) {
					brandCodeMap.put(rank.Brand__c,rank.Brand_Code__c);
				}
				String devOpsQueueId;
				list<Group> devOpsQueue = QueueDA.getDefaultRoutingGroup();
				if(!devOpsQueue.isEmpty()) 
					devOpsQueueId = devOpsQueue[0].Id;
				// process the assignment mapping
				for(Lead_Assignment_Mapping__mdt assignment : CustomMetadataDA.getLeadAssignments()) {
					  if(!String.isEmpty(assignment.Brand_Code__c) && !String.isEmpty(assignment.State__c) && !String.isEmpty(assignment.Country__c))  {
					  	String key = assignment.Brand_Code__c + '-' + assignment.State__c + '-' + assignment.Country__c;
					  	if(assignment.Is_a_Queue__c) {
					  		if(!String.isEmpty(assignment.DFS_Name__c))
					  			queueAssignmentMap.put(key,assignment.DFS_Name__c);
					  	}
					  	else {
					  		if(!String.isEmpty(assignment.Employee_Number__c))
					  			userAssignmentMap.put(key,assignment.Employee_Number__c);
					  	}
					  }	
				}
				// get the employee ids based on employee numbers
				if(!userAssignmentMap.isEmpty()) {
					for(User rec : UserDA.getUsersFromEmployeeNumbers(userAssignmentMap.values()))
						mappedUserId.put(rec.EmployeeNumber,rec.Id);
				}
				// get the queue ids based on queue Names
				if(!queueAssignmentMap.isEmpty()) {
					for(Group grp : QueueDA.getQueuesBasedOnNames(queueAssignmentMap.values()))
						mappedQueueId.put(grp.Name,grp.Id);
				}
				// process the leads
				for(Lead temp : leads) {
					Lead rec = temp.clone(true);
					boolean assignToDevOps = false;
					try {
						if(!String.isEmpty(rec.Choice_Brand_of_Interest__c) || !String.isEmpty(rec.Brand_of_Interest__c)) {
							String country = Label.Routing_Default_Country;
							String brandCode;
							if(!String.isEmpty(rec.CountryCode)){
								country = rec.CountryCode;
							}
							brandCode = brandCodeMap.get(rec.Brand_of_Interest__c);	
							// get the lead assignment info
							if((!mappedUserId.isEmpty() || !mappedQueueId.isEmpty()) && !String.isEmpty(rec.StateCode)) {	  
								if(!String.isEmpty(brandCode)) {
										string leadKey = brandCode + '-' + rec.StateCode + '-' + country;
										if(userAssignmentMap.get(leadKey) != Null) {
											if(mappedUserId.get(userAssignmentMap.get(leadKey)) != Null)
												rec.OwnerId = mappedUserId.get(userAssignmentMap.get(leadKey));
											else
											assignToDevOps = true;
										}
										else if(queueAssignmentMap.get(leadKey) != Null) {
											if(mappedQueueId.get(queueAssignmentMap.get(leadKey)) != Null)
												rec.OwnerId = mappedQueueId.get(queueAssignmentMap.get(leadKey));
											else
											assignToDevOps = true;
										}
										else 
											assignToDevOps = true;
								}
								else
										assignToDevOps = true;
							}
							else {
								assignToDevOps = true;
							}									
						}
						else
							assignToDevOps = true;						
					}catch(Exception e) {
						system.debug('Exeption='+e.getMessage());
						assignToDevOps = true;
					}
					//assign to devops queue accordingly 
					if(assignToDevOps){
						if(!String.isEmpty(devOpsQueueId))
							rec.ownerId = devOpsQueueId;
					}
					recs.add(rec);
				}
			}
		}
		return recs;
	}

	public static void assignBrandOfInterestIfEmpty(List<Lead> leads){
		List<Brand_Ranking__mdt> brandRankings = CustomMetadataDA.getBrandRankings();
		for(Lead rec : leads){
			if(String.isEmpty(rec.Brand_of_Interest__c)){
				if(!String.isEmpty(rec.Choice_Brand_of_Interest__c)) {
					set<String> unInterestedBrands = new set<String>();
					if(!String.isEmpty(rec.Uninterested_Brands__c))
						unInterestedBrands.addAll(rec.Uninterested_Brands__c.split(';'));
					for(Brand_Ranking__mdt rank : brandRankings) {
						if(!String.isEmpty(rank.Brand__c)) {
							if(rec.Choice_Brand_of_Interest__c.contains(rank.Brand__c) && (unInterestedBrands.isEmpty() || !unInterestedBrands.contains(rank.Brand__c))) {
								rec.Brand_of_Interest__c = rank.Brand__c;
								if(rec.Uninterested_Brands__c == null){
									rec.Uninterested_Brands__c = '';
								}
								rec.Uninterested_Brands__c += ';' + rec.Brand_of_Interest__c;
								break;
							}
						}
					}
				}
			}
			else{
				Set<String> unInterestedBrands = new set<String>();
					if(!String.isEmpty(rec.Uninterested_Brands__c)){
						unInterestedBrands.addAll(rec.Uninterested_Brands__c.split(';'));
					}
					else{
						rec.Uninterested_Brands__c = '';
					}
					System.debug(unInterestedBrands);
					System.debug(rec.Brand_of_Interest__c);
					if(!unInterestedBrands.contains(rec.Brand_of_Interest__c)){
						rec.Uninterested_Brands__c += ';' + rec.Brand_of_Interest__c;
					}
					
			}
		}
	}
}