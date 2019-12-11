public without sharing class PopulateCustomApprover {

	/**********************************************************************************
    	DESCRIPTION:
    		Method to identify Opportunity records that need CustomApprover__c updated.
    	INPUTS:
    		List<Opportunity>
    	RETURNS
    		List<Opportunity>
    **********************************************************************************/	
	public static List<Opportunity> getOpportunitiesThatNeedCustomApproverUpdated(List<Opportunity> opps, Map<Id,Opportunity> oldMap) {
		List<Opportunity> recs = new List<Opportunity>();

        for(Opportunity opp : opps){
            Opportunity oldOpp = oldMap.get(opp.Id);
            if(opp.StageName != oldOpp.StageName && opp.StageName == System.Label.Opportunity_Status_for_Populating_Custom_Approver){
                recs.add(opp);
            }
        }

		return recs;
	}

	/**********************************************************************************
    	DESCRIPTION:
    		Returns a list of Property Ids Based on Opportunities
    	INPUTS:
    		List<Opportunity>
    	RETURNS
    		List<Id>
    **********************************************************************************/	
	public static Set<Id> getPropertyIdsFromOpps(List<Opportunity> opps) {
		Set<Id> propIds = new Set<Id>();
        for(Opportunity opp : opps){
            if(opp.Property__c != null){
                propIds.add(opp.Property__c);
            }
        }

		return propIds;
	}

	/**********************************************************************************
    	DESCRIPTION:
    		Method to update Opportunity records that need CustomApprover__c updated.
    	INPUTS:
    		List<Opportunity>
    **********************************************************************************/	    
    public static void UpdateOppCustomApprover(List<Opportunity> opps, Set<Id> propertyIds){
        if(!propertyIds.isEmpty()){
            Set<String> brands = new Set<String>();
            Set<String> states = new Set<String>();
            Set<String> countries = new Set<String>();

            Map<Id, Property__c> propertyMap = new Map<Id, Property__c>(PropertyDA.getPropertiesBasedOnIds(propertyIds));
            for(Opportunity opp : opps){
                if(propertyMap.containsKey(opp.Property__c)){
                    Property__c prop = propertyMap.get(opp.Property__c);

                    brands.add(opp.Brand__c);
                    states.add(prop.State_Province__c);      
                    countries.add(prop.Country__c);    
                }
            }
            List<Approver__c> approvers = ApproverDA.getRecordsThatContainBrandsStatesAndCountries(brands, states, countries);
            Map<String, Id> brandStateCountryKeyToOwnerIdMap = createBrandStateCountryKeyToOwnerIdMap(approvers);

            for(Opportunity opp :opps){
                if(propertyMap.containsKey(opp.Property__c)){
                    Property__c prop = propertyMap.get(opp.Property__c);

                    if(brandStateCountryKeyToOwnerIdMap.containsKey(opp.Brand__c + '|' +  prop.State_Province__c + '|' + prop.Country__c)){
                        opp.CustomApprover__c = brandStateCountryKeyToOwnerIdMap.get(opp.Brand__c + '|' +  prop.State_Province__c + '|' + prop.Country__c);
                    }
                }
            }
        }
    }

	/**********************************************************************************
    	DESCRIPTION:
    		Method that creates map needed to get OwnerId
    	INPUTS:
    		List<Approver__c>
    **********************************************************************************/	  
    public static Map<String, Id> createBrandStateCountryKeyToOwnerIdMap(List<Approver__c> approvers){
        Map<String, Id> brandStateCountryKeyToOwnerIdMap = new Map<String, Id>();

        for(Approver__c approver : approvers){
            brandStateCountryKeyToOwnerIdMap.put(approver.Brand__c + '|' +  approver.State__c + '|' + approver.Country__c, approver.OwnerId);
        }

        return brandStateCountryKeyToOwnerIdMap;
    }
}