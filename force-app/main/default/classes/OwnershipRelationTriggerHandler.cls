/*
 * @Author : Jagan Gorre
 * @Desc : Logic to insert custom object records or publish platform events whenever ownership relation record is created or updated. 
 * Refer CustomerTriggerHandler class for list of fields populated in platform event object
 * 
*/
public with sharing class OwnershipRelationTriggerHandler {
    @TestVisible private static List<Contract_Changes__e> insLstPlatEve = new List<Contract_Changes__e>();
    @TestVisible private static List<Contract_Changes_for_FMS__c> insLstCustomObj = new List<Contract_Changes_for_FMS__c>();
    public static void createPlatformEventOrInsertCustomObjectRecords(List<Ownership_Relation__c> triggerNew,Map<Id,Ownership_Relation__c> triggerOldMap){
        Boolean proceedNext = false;
        insLstPlatEve.clear();
        insLstCustomObj.clear();
        List<Ownership_Relation__c> finalList = new List<Ownership_Relation__c>();
        //Add records to finalList
        if(triggerOldMap == null){
            finalList.addAll(triggerNew);
        }
        else{
            for(Ownership_Relation__c ownrRel:triggerNew){
                //Add logic here if we have to check for specific field changes before proceeding
                finalList.add(ownrRel);
            }
        }
        if(finalList.size() > 0)
            proceedNext = true;
        if(proceedNext){
            /* Gather all the required data to create flat record list
             * We need three objects to frame the list
             * 1) Customer__c record.
             * 2) Contract__c record and
             * 3) Ownership_Relation__c record ( contains Account information as well).
			*/
            Set<Id> ownrGrpIds = new Set<Id>();
            Set<Id> ownrRelIds = new Set<Id>();
            Set<Id> contrIds = new Set<Id>();
            Map<Id,Ownership_Relation__c> grpIdRelMap = new Map<Id,Ownership_Relation__c>();
            Map<Id,Contract__c> contrMap = new Map<Id,Contract__c>();
            List<Customer__c> customerList = new List<Customer__c>();
            for(Ownership_Relation__c ownrRel:finalList){
                //collect record ids to list to query additional details from Ownership_Relation__c
                ownrRelIds.add(ownrRel.Id);
                //collect ownershipgroup ids to query customer data
                if(ownrRel.OwnershipGroupId__c != null){
					ownrGrpIds.add(ownrRel.OwnershipGroupId__c);
                }
            }
            //Get Contract details
            if(!ownrRelIds.isEmpty() && !ownrGrpIds.isEmpty()){
                Boolean contractExist = false;
                //Query the customers list
                customerList = CustomerDA.getCustomersByOwnershipGroupIds(ownrGrpIds);
                if(customerList != null && !customerList.isEmpty()){
                    //Get the contract ids from customer data
                    for(Customer__c cust:customerList){
                        //Add logic here to filter out contracts
                        if(cust.Contract__c != null)
                            contrIds.add(cust.Contract__c);
                    }
                    //Query the Contract Details and create map with contract id as key and Contract__c record as value
                    if(!contrIds.isEmpty()){
                        contractExist = true;
                        for(Contract__c contr: ContractDA.getContractsByIds(contrIds)){
                            contrMap.put(contr.id,contr);
                        }
                    }
                    //Query Ownership_Relation__c and create a map with OwnershipGroupId__c as key and Ownership_Relation__c record as value
                    for(Ownership_Relation__c ownrRel:OwnershipRelationDA.getOwnershipRelationsByIds(ownrRelIds)){
                    	grpIdRelMap.put(ownrRel.OwnershipGroupId__c,ownrRel);
                    }
                    //Proceed only when contract exist for the customer
                	if(contractExist){
                        //Switch to determine between platform event or custom object
                        Boolean platfromEventSwitch = Metadata_Control__c.getInstance().Switch_to_Platf_Events_Contract_Changes__c ;
                        //Final loop on Customers to create flat list
                        for(Customer__c cust:customerList){
                            //Get the Contract__c record from previously stored map
                            Contract__c contr = contrMap.get(cust.Contract__c);
                            //Ge the Ownership_Relation__c from previously stored map
                            Ownership_Relation__c ownrRel = grpIdRelMap.get(cust.Ownership_Group__c);
                            
                            /* Get a new record from PlatformEventsDA or ContractChangesforFMSDA based on cusom settings
                             * If Switch_to_Platf_Events_Contract_Changes__c is checked in Metadata_Control__c Custom settings,
                             * then create platform event list and publish it
                             * else create Contract_Changes_for_FMS__c custom object list and insert it.
                            */
                            if(platfromEventSwitch)
                            	insLstPlatEve.add(PlatformEventsDA.getNewContractChangesEventRecord(ownrRel,contr,cust));
                            else
                                insLstCustomObj.add(ContractChangesforFMSDA.getNewContractChangesforFMSRecord(ownrRel,contr,cust));
                        }
                        if(insLstPlatEve!=null && insLstPlatEve.size()>0)
                           PlatformEventsDA.publishPlatformEventList(insLstPlatEve);
                        else if(insLstCustomObj!=null && insLstCustomObj.size()>0)
                           ContractChangesforFMSDA.insertListToCustomObject(insLstCustomObj);
                    }
                }
            }
        }
	}
}