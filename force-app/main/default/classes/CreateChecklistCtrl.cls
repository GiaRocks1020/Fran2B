public with sharing class CreateChecklistCtrl {
    public CreateChecklistCtrl() {

    }

    /**
    * @description Wrapper list for displaying the line items on the component. 
    *
    * @author Madan Morusu
    * @date 2019-09-27
    * @param checkListId - Checklist Record Id. 
    * @return String
    */
    @AuraEnabled
    public static string getCheckListItems(String checkListId){
        if(checkListId != null && checkListId != ''){
            List<createCheckListWrapper> wrapperList = new List<createCheckListWrapper>();
            List<PIP_Checklist__c> checkList = new List<PIP_Checklist__c>();
            List<PIP_Checklist_Item__c> checkListItems = new List<PIP_Checklist_Item__c>();
        
            checkList = [Select id, Brand__c from PIP_Checklist__c where Id =: checkListId];

            if(checkList.size() > 0 ){
                checkListItems = [Select id, Question__c, Number_of_Photos__c, PIP_Checklist__c, Notes__c, Measurement__c, Improvement__c, Acceptable__c, Category__c, Type__c 
                                    from PIP_Checklist_Item__c where PIP_Checklist__c =: checkList[0].id Order By Category__c ASC, Order__c ASC];
                Map<String, List<CheckListItemWrapper>> mapCheckList = new Map<String, List<CheckListItemWrapper>>();
                Map<String, integer> mapCatCount = new Map<String, integer>();

                if(checkListItems.size()>0){
                    createCheckListWrapper wrapper = new createCheckListWrapper();
                    for(PIP_Checklist_Item__c pipCLI : checkListItems){
                        boolean completePIPCLI = pipCLI.Notes__c != null && 
                                                    pipCLI.Improvement__c != null &&
                                                        pipCLI.Acceptable__c != Null &&
                                                            pipCLI.Measurement__c != null &&
                                                                pipCLI.Type__c != null;

                        if(mapCheckList.get(pipCLI.Category__c) != null){
                            List<CheckListItemWrapper> temppipCLI = mapCheckList.get(pipCLI.Category__c);
                            temppipCLI.add(new CheckListItemWrapper(pipCLI));
                            mapCheckList.put(pipCLI.Category__c, temppipCLI);
                            integer tempCount =  mapCatCount.get(pipCLI.Category__c);
                            mapCatCount.put(pipCLI.Category__c,tempCount+(completePIPCLI?1:0));
                        }
                        else {
                            mapCheckList.put(pipCLI.Category__c, new List<CheckListItemWrapper>{new CheckListItemWrapper(pipCLI)});
                            mapCatCount.put(pipCLI.Category__c,completePIPCLI?1:0);
                        }
                    }
                  
                    
                }
                else{
                    string soqlString = 'Select id, Active__c, Name, Brand__c, Category__c, Minimum_Number_of_Photos__c,Order__c, Question__c From PIP_Checklist_Library_Item__c Where Active__c = true and Brand__c INCLUDES (\''+checkList[0].Brand__c+'\') Order By Category__c ASC, Order__c Asc';
                    List<PIP_Checklist_Library_Item__c> pipCLIlist = new List<PIP_Checklist_Library_Item__c>();
                    pipCLIList = database.query(soqlString);
                    for(PIP_Checklist_Library_Item__c pipCLI :  pipCLIList)
                    {
                        createCheckListWrapper wrapper = new createCheckListWrapper();
                        PIP_Checklist_Item__c pipCI = new PIP_Checklist_Item__c();
                        pipCI.Name = pipCLI.Name;
                        pipCI.Number_of_Photos__c = pipCLI.Minimum_Number_of_Photos__c;
                        pipCI.Order__c = pipCLI.Order__c;
                        pipCI.Question__c = pipCLI.Question__c;
                        pipCI.Category__c = pipCLI.Category__c;
                        PIPci.PIP_Checklist__c = checkListId;
                            if(mapCheckList.get(pipCI.Category__c) != null){
                                List<CheckListItemWrapper> temppipCI = mapCheckList.get(pipCI.Category__c);
                                temppipCI.add(new CheckListItemWrapper(pipCI));
                                mapCheckList.put(pipCI.Category__c, temppipCI);
                            }
                            else {
                                mapCheckList.put(pipCI.Category__c, new List<CheckListItemWrapper>{new CheckListItemWrapper(pipCI)});
                            }

                    }
                }
                for(String key: mapCheckList.keySet()){
                        CreateCheckListWrapper tempWrapper = new CreateCheckListWrapper();
                        integer catCount = 0;
                        if(!(mapCatCount.isEmpty())){
                            catCount = mapCatCount.get(key);
                        }
                        tempWrapper.checklistType = key;
                        tempWrapper.checkListItems = mapCheckList.get(key);
                        tempWrapper.categoryStatus = '('+catCount+'/'+tempWrapper.checkListItems.size()+')';
                        wrapperList.add(tempWrapper);
                    }
            }
            return JSON.serialize(wrapperList);
        }
        return null;
    }
    public class CreateCheckListWrapper{
        public String checklistType;
        public String categoryStatus;
        public List<CheckListItemWrapper> checklistItems = new List<CheckListItemWrapper>();
        public createCheckListWrapper(){
            
        }
    }
    public class CheckListItemWrapper{
        public PIP_Checklist_Item__c pipCI;
        public integer categoryIndex;
        public integer libraryIndex;
        public CheckListItemWrapper(PIP_Checklist_Item__c pipCI){
            this.pipCI = pipCI;
        }
    }
    @AuraEnabled
    public static void saveChecklistItems(String WrapperString){
       try{
        List<CreateCheckListWrapper> wrapperList = new List<CreateCheckListWrapper>();
        wrapperList = (List<CreateCheckListWrapper>)System.JSON.deserialize(wrapperString, LIST<CreateCheckListWrapper>.class);
        List<PIP_Checklist_Item__c> pipCIlist = new List<PIP_Checklist_Item__c>();
        for(CreateCheckListWrapper clw : wrapperList){
            for(CheckListItemWrapper cliw : clw.checkListItems)
                pipCIlist.add(cliw.pipCI);
        }
        upsert pipCIlist;
        }
        Catch(exception ex){
            throw new AuraHandledException('An Error Occured : '+ ex.getMessage());
        }
    }
}