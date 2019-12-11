public with sharing class ContractChangesforFMSDA {
    
	public static Contract_Changes_for_FMS__c getNewContractChangesforFMSRecord(Ownership_Relation__c ownrRel,Contract__c contr, Customer__c cust){
        return new Contract_Changes_for_FMS__c(
        			Name__c = contr.Contract_ID__c+' - '+ownrRel.Account__r.Name,
                    Contract_SFID__c = contr.Id,
                    Customer_SFID__c = cust.Id,
                    Ownership_Group_SFID__c = ownrRel.OwnershipGroupId__c,
                    Ownership_Relation_SFID__c = ownrRel.Id,
                    Account_SFID__c = ownrRel.Account__c,
                    Contract_ID__c = contr.Contract_ID__c,
                    Account_Name__c = ownrRel.Account__r.Name,
                    Account_Legacy_ID__c = ownrRel.Account__r.Legacy_ID__c,
                    Account_Structure__c = ownrRel.Account__r.Account_Structure__c,
                    Business_Phone__c = ownrRel.Account__r.Phone,
                    Date_Formed__c = ownrRel.Account__r.Date_Formed__c,
                    State_Formed__c = ownrRel.Account__r.State_Formed__c,
                    Email__c = ownrRel.Account__r.Email__c,
                    Billing_Street__c = ownrRel.Account__r.BillingStreet,
                    Billing_City__c = ownrRel.Account__r.BillingCity,
            		Billing_State__c = ownrRel.Account__r.BillingState,
                    Billing_Country__c = ownrRel.Account__r.BillingCountry,
                    Start_Date_Customer__c = cust.Start_Date__c,
                    End_Date_Customer__c = cust.End_Date__c,
                    Ownership_Percentage__c = ownrRel.Ownership_Percentage__c,
                    Start_Date_Ownership_Relation__c = ownrRel.Start_Date__c,
                    End_Date_Ownership_Relation__c = ownrRel.End_Date__c
                 );
    }
    public static void insertListToCustomObject(List<Contract_Changes_for_FMS__c> lstCustObj){
        insert lstCustObj;
    }
    
}