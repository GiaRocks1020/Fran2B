//* 
//Contract__c trigger
//Date: Oct 23 2018
//Author: Hemanth Gottipati hemanth.gottipati@choicehotels.com
//After the integration user updates a contract to be the true effective contract,
//then all other contracts related to the same property need to not be the effective contracts (set to false)
//*

trigger ContractTrigger on Contract__c (before insert, before update, before delete, after insert, after
    update, after delete, after undelete) {
    ContractTriggerHandler handler = new ContractTriggerHandler();
}