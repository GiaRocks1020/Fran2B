public without sharing class PopulateDealTerms {
    public static final String FEE_TERM_TYPE = 'Fee';
    public static final String WAIVER_TERM_TYPE = 'Waiver';
    public static final String OUT_DATE_TERM_TYPE = 'Out Date';

	/**********************************************************************************
    	DESCRIPTION:
    		Method to identify Opportunity records that need Deal Terms updated.
    	INPUTS:
    		List<Opportunity>
            Map<Id,Opportunity>
    	RETURNS
    		List<Opportunity>
    **********************************************************************************/	
	public static List<Opportunity> getOpportunitiesThatNeedDealTermsUpdated(List<Opportunity> opps, Map<Id,Opportunity> oldMap) {
		List<Opportunity> recs = new List<Opportunity>();

        for(Opportunity opp : opps){
            Opportunity oldopp = null;
            
            if(oldMap.containsKey(opp.Id)){
                oldOpp = oldMap.get(opp.Id);
            }
            //If it is in the correct stage
            if(opp.StageName == System.Label.Opportunity_Status_for_Populating_Deal_Terms){
                //oldOpp == Null means it is a new opp
                if(oldOpp == null){
                    recs.add(opp);
                }
                else if(oldOpp.StageName != System.Label.Opportunity_Status_for_Populating_Deal_Terms){
                    recs.add(opp);
                }
            }
        }
		return recs;
	}

    public static void populateTerms(List<Opportunity> opps){
        List<Waivers__c> waiversToInsert = new List<Waivers__c>();
        List<Fees__c> feesToInsert = new List<Fees__c>();
        List<Out_Dates__c> outDatesToInsert = new List<Out_Dates__c>();
        Id waiverId = FranchiseSalesUtilities.getRecordTypeById(new Standard_Terms__c(), WAIVER_TERM_TYPE);
        Id feeId = FranchiseSalesUtilities.getRecordTypeById(new Standard_Terms__c(), FEE_TERM_TYPE);
        Id outDateId = FranchiseSalesUtilities.getRecordTypeById(new Standard_Terms__c(), OUT_DATE_TERM_TYPE);


        List<Standard_Terms__c> terms = getStandardTerms();

        for(Opportunity opp : opps){
            Set<String> optionsSet = returnOptionsStringSet(opp);

            for(Standard_Terms__c term : terms){

                if(term.Code__c == 'SUITE' && opp.Product__c == 'AS'){
                    waiversToInsert.add(new Waivers__c(
                        Standard_Term__c = term.Id,
                        Deal__c = opp.Id
                    ));
                }

                if(term.Brand__c == opp.Brand__c
                && term.RecordtypeId == waiverId
                ){
                    waiversToInsert.add(new Waivers__c(
                        Standard_Term__c = term.Id,
                        Deal__c = opp.Id
                        
                    ));
                }

                if(term.Brand__c == opp.Brand__c 
                && term.RecordtypeId == feeId
                ){
                    feesToInsert.add(new Fees__c(
                        Standard_Term__c = term.Id,
                        Deal__c = opp.Id
                    ));
                }

                if(term.Brand__c == opp.Brand__c 
                && term.RecordtypeId == outDateId
                ){
                    outDatesToInsert.add(new Out_Dates__c(
                        Standard_Term__c = term.Id,
                        Deal__c = opp.Id
                    ));
                }

                if(optionsSet.contains(term.Deal_Terms_to_Waiver__c)){
                     waiversToInsert.add(new Waivers__c(
                        Standard_Term__c = term.Id,
                        Deal__c = opp.Id
                    ));
                }
            }

        }
        if(waiversToInsert.size() > 0){
            insert waiversToInsert;
        }

        if(feesToInsert.size() > 0){
            insert feesToInsert;
        }

        if(outDatesToInsert.size() > 0){
            insert outDatesToInsert;
        }

    }

    public static List<Standard_Terms__c> getStandardTerms(){
        return [SELECT Id, RecordtypeId, Brand__c, Code__c, Deal_Terms_to_Waiver__c
        FROM Standard_Terms__c 
        WHERE Status__c = 'Active'];
    }

    public static Set<String> returnOptionsStringSet(Opportunity opp){
        Set<String> options = new Set<String>();

        if(opp.Liquidated_Damages_Discount__c != null){
            options.addAll(opp.Liquidated_Damages_Discount__c.split(';'));
        }
        if(opp.Other_Deal_Terms__c != null){
            options.addAll(opp.Other_Deal_Terms__c.split(';'));
        }

        return options;
    }
}