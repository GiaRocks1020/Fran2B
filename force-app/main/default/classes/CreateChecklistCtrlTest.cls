@isTest
public with sharing class CreateChecklistCtrlTest {
     static TestMethod void testGetChecklistItems(){
         
        //Create Test Data
        PIP_Checklist__c pipC = TestDataFactory.createPIPChecklist(true);
        TestDataFactory.createPIPChecklistLibraryItems(true);
        TestDataFactory.createPIPChecklistLibraryItems(true);
        String wrapperString1 = CreateChecklistCtrl.getChecklistItems(pipC.id);
        List<CreateChecklistCtrl.CreateCheckListWrapper> listCtrl = (List<CreateChecklistCtrl.CreateCheckListWrapper>)System.JSON.deSerialize(wrapperString1,List<CreateChecklistCtrl.CreateCheckListWrapper>.class);
        System.assert(listCtrl.size()> 0, 'Checklist Item Wrapper not created.');

        CreateChecklistCtrl.saveChecklistItems(wrapperString1);
        List<PIP_Checklist_Item__c> pipCI = new List<PIP_Checklist_Item__c>();
        pipCI = [Select id from PIP_Checklist_Item__c Where PIP_Checklist__c =: pipC.id];
        System.assert(pipCI.size()>0,'Checklist Items not inserted on Save.');
        
        String wrapperString2 = CreateChecklistCtrl.getChecklistItems(pipC.id);
        List<CreateChecklistCtrl.CreateCheckListWrapper> listCtrl2 = (List<CreateChecklistCtrl.CreateCheckListWrapper>)System.JSON.deSerialize(wrapperString2,List<CreateChecklistCtrl.CreateCheckListWrapper>.class);
        for(CreateChecklistCtrl.CreateCheckListWrapper ci : listCtrl2){
            for(CreateChecklistCtrl.CheckListItemWrapper cii: ci.checklistItems){
                System.assert(cii.PIPCI.id != null, 'PIP Checklist Items prepared from Library Items instead of Query.');
                cii.pipCI.Notes__c = 'TEST';
                cii.pipCI.Improvement__c = 'Repair';
                cii.pipCI.Acceptable__c = 'Yes';
                cii.pipCI.Measurement__c = 'Test';
                cii.pipCI.Type__c = 'BES';
            }
        }
        String wrapperString3 = JSON.Serialize(listCtrl2);
        CreateChecklistCtrl.saveChecklistItems(wrapperString3);
        CreateChecklistCtrl.getChecklistItems(pipC.Id);
    
     }
}