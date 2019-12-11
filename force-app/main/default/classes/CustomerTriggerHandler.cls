/*
 * @Author : Jagan Gorre
 * @Desc : Logic to insert custom object records or publish platform events whenever customer record is created or updated. Below are 
 * the list of fields and their descriptions that are part of Platform Event object
 * 
 * Name__c : Name (as Contract_ID__c & " - " & Account_Name__c) 
 * Contract_SFID__c : Contract record salesforce Id identified on the associated Customer record
 * Customer_SFID__c : Customer record Salesforce Id
 * Ownership_Group_SFID__c : Ownership Group SFID
 * Ownership_Relation_SFID__c : Ownership Relation SFID
 * Account_SFID__c : Account SFID on the Account associated to the Ownership Relationship record
 * Contract_ID__c : Contract ID (e.g., 0000012345) from the Contract
 * Account_Name__c : Account Name from the Account
 * Account_Legacy_ID__c : Account Legacy ID (FMS GUID)
 * Account_Structure__c : Account Structure picklist API value from the Account
 * Business_Phone__c : Business Phone from the Account
 * Date_Formed__c : Date Formed from the Account
 * State_Formed__c : State Formed picklist API Value from the Account
 * Email__c : Email Address from the Account
 * Billing_Street__c : Billing Address Street from the Account
 * Billing_City__c : Billing Address Street from the Account
 * Billing_State__c : Billing Address State API Name from the Account
 * Billing_Country__c : Billing Address Country API Name from the Account
 * Start_Date_Customer__c : Start Date from the Customer
 * End_Date_Customer__c : End Date from the Customer
 * Ownership_Percentage__c : Ownership Percent from Ownership Relation
 * Start_Date_Ownership_Relation__c : Start Date from Ownership Relation
 * End_Date_Ownership_Relation__c : End Date from Ownership Relation
*/
public with sharing class CustomerTriggerHandler {
    //List to add platform events to publish
    @TestVisible private static List<Contract_Changes__e> insLstPlatEve = new List<Contract_Changes__e>();
    //List to add Contract_Changes_for_FMS__c records to insert
    @TestVisible private static List<Contract_Changes_for_FMS__c> insLstCustomObj = new List<Contract_Changes_for_FMS__c>();
    public static void createPlatformEventOrInsertCustomObjectRecords(List<Customer__c > triggerNew,Map<Id,Customer__c > triggerOldMap){
        Boolean proceedNext = false;
        insLstPlatEve.clear();
        insLstCustomObj.clear();
        List<Customer__c> finalList = new List<Customer__c>();
        //Add records to finalList
        if(triggerOldMap == null){
            finalList.addAll(triggerNew);
        }
        else{
            for(Customer__c  cust:triggerNew){
                //Add logic here if we have to check for specific field changes before proceeding
                finalList.add(cust);
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
            
            Map<Id,Customer__c> ownrGrpMap = new Map<Id,Customer__c>();
            Map<Id,Id> contrIdMap = new Map<Id,Id>();
            Map<Id,Contract__c> contrObjMap = new Map<Id,Contract__c>();
            for(Customer__c cust:finalList){
                if(cust.Contract__c != null && cust.Ownership_Group__c!=null ){
                    //Create a map with Contract sf id as key and customer id as value
                    contrIdMap.put(cust.Contract__c,cust.id);
                    //Create a map with ownership grou sf id as key and customer record as value
                    ownrGrpMap.put(cust.Ownership_Group__c,cust);
                }
            }
            //Get Contract details
            if(contrIdMap!=null && !contrIdMap.isEmpty()){
                //Query the contract details using the keyset of contrIdMap which are contract sf ids
                List<Contract__c> contractList = ContractDA.getContractsByIds(contrIdMap.keySet());
                if(contractList!=null && contractList.size()>0){
                    for(Contract__c contr:contractList){
                        if(contrIdMap.containsKey(contr.Id)){
                            //using the queried list, create a map with customer id as key and contract record as value
                            contrObjMap.put(contrIdMap.get(contr.Id),contr);
                        }
                    }
                }
            }
            if(ownrGrpMap!=null && !ownrGrpMap.isEmpty()){
                //Switch to determine between platform event or custom object
                Boolean platfromEventSwitch = Metadata_Control__c.getInstance().Switch_to_Platf_Events_Contract_Changes__c ;
                //Query ownership relations from Ownership Group ids in Customer__c object
                List<Ownership_Relation__c> allOwnerRelations = OwnershipRelationDA.getOwnershipRelationsByOwnershipGroupIds(ownrGrpMap.keySet());
                if(allOwnerRelations != null && allOwnerRelations.size()>0){
                    //Final loop on Ownership relations to create flat list
                    for(Ownership_Relation__c ownrRel:allOwnerRelations){
                        //Get customer record from previous map using the OwnershipGroupId__c in Ownership_Relation__c
                        Customer__c cust = ownrGrpMap.get(ownrRel.OwnershipGroupId__c);
                        //Get Contract record from previous map using the customer id
                        Contract__c contr = contrObjMap.get(cust.Id);
                        if(contr != null){
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
                	}//end of loop
                }
            }
            if(insLstPlatEve!=null && insLstPlatEve.size()>0)
                PlatformEventsDA.publishPlatformEventList(insLstPlatEve);
            else if(insLstCustomObj!=null && insLstCustomObj.size()>0)
                ContractChangesforFMSDA.insertListToCustomObject(insLstCustomObj);
        }
	}
}