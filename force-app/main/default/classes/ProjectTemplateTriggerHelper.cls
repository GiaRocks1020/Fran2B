/**
 * @description Helper class for PIP Template Record Type
 *
 * @author pradnya.desai
 * @date 11/4/19.
 */

public with sharing class ProjectTemplateTriggerHelper {

    /**
	 * @description This method will check and throw an error saying if two PIP templates from being created
	 * that are Active with the Same Brand.
	 *
	 * @param newPIPTemplateItems - New values for PIP Template record type
	 * @param oldPIPTemplateMapById - Old values for PIP Template record type
	 * @return void
	 */
    public void validateDuplicateBrand(List<TASKRAY__Project__c> newPIPTemplates, Map<Id, TASKRAY__Project__c>
            oldPIPTemplateMapById){

        List<TASKRAY__Project__c> pipTemplatesToValidate = new List<TASKRAY__Project__c>();
        List<Id> pipTemplateIdsToValidate = new List<Id>();

        for(TASKRAY__Project__c newPIPTemplate : newPIPTemplates){
            if(oldPIPTemplateMapById == null){
                pipTemplatesToValidate.add(newPIPTemplate);
                pipTemplateIdsToValidate.add(newPIPTemplate.Id);
            }else{
                TASKRAY__Project__c oldPIPTemplate = oldPIPTemplateMapById.get(newPIPTemplate.Id);
                if(oldPIPTemplate != null){
                    if((newPIPTemplate.Taskray__trTemplate__c != oldPIPTemplate.Taskray__trTemplate__c ||
                            newPIPTemplate.Brand__c != oldPIPTemplate.Brand__c ||
                            newPIPTemplate.Active__c != oldPIPTemplate.Active__c ||
                            newPIPTemplate.Name != oldPIPTemplate.Name)){
                        pipTemplatesToValidate.add(newPIPTemplate);
                        pipTemplateIdsToValidate.add(newPIPTemplate.Id);
                    }
                }

            }
        }
        if(pipTemplatesToValidate.size() > 0) {
            Map<String, List<Id>> projectMapByBrand = populateProjectMapByBrand(pipTemplateIdsToValidate);
            checkDuplicateBrand(pipTemplatesToValidate, projectMapByBrand);
        }
    }

    /**
	 * @description This method will check and throw an error saying if two Opening templates from being created
	 * that are Active with the Same Brand and Project Type.
	 *
	 * @param newPIPTemplateItems - New values for PIP Template record type
	 * @param oldPIPTemplateMapById - Old values for PIP Template record type
	 * @return void
	 */
    public void validateDuplicateBrandProjectType(List<TASKRAY__Project__c> newOpeningTemplates, Map<Id, TASKRAY__Project__c>
            oldProjectMapById){

        List<TASKRAY__Project__c> openingTemplatesToValidate = new List<TASKRAY__Project__c>();
        List<Id> openingTemplateIdsToValidate = new List<Id>();

        for(TASKRAY__Project__c newOpeningTemplate : newOpeningTemplates){
            if(oldProjectMapById == null){
                openingTemplatesToValidate.add(newOpeningTemplate);
                openingTemplateIdsToValidate.add(newOpeningTemplate.Id);
            }else{
                TASKRAY__Project__c oldPIPTemplate = oldProjectMapById.get(newOpeningTemplate.Id);
                if(oldPIPTemplate != null){
                    if((newOpeningTemplate.Taskray__trTemplate__c != oldPIPTemplate.Taskray__trTemplate__c ||
                            newOpeningTemplate.Brand__c != oldPIPTemplate.Brand__c ||
                            newOpeningTemplate.Project_Type__c != oldPIPTemplate.Project_Type__c ||
                            newOpeningTemplate.Active__c != oldPIPTemplate.Active__c ||
                            newOpeningTemplate.Name != oldPIPTemplate.Name)){
                        openingTemplatesToValidate.add(newOpeningTemplate);
                        openingTemplateIdsToValidate.add(newOpeningTemplate.Id);
                    }
                }

            }
        }
        if(openingTemplatesToValidate.size() > 0) {
            Map<String, List<Id>> projectMapByBrandProjectType = populateMapByBrandProject(openingTemplateIdsToValidate);
            checkDuplicateBrandProjectType(openingTemplatesToValidate, projectMapByBrandProjectType);
        }
    }

    /**
	 * @description This method will check and throw an error saying if two PIP templates from being created
	 * that are Active with the Same Brand.
	 *
	 * @param newPIPTemplateItems - New values for PIP Template record type
	 * @param oldPIPTemplateMapById - Old values for PIP Template record type
	 * @return void
	 */
    public void checkDuplicateBrand(List<TASKRAY__Project__c> pipTemplatesToValidate,Map<String, List<Id>> projectMapByBrand){

        for(TASKRAY__Project__c newPIPTemplate : pipTemplatesToValidate){
            if(newPIPTemplate.Active__c && newPIPTemplate.TASKRAY__trTemplate__c &&
                    newPIPTemplate.Brand__c != null && projectMapByBrand.containsKey(newPIPTemplate.Brand__c)){

                List<Id> pipTemplateListForBrand = projectMapByBrand.get(newPIPTemplate.Brand__c);
                if(pipTemplateListForBrand != null &&  pipTemplateListForBrand.size()>0) {
                    throw new DmlException('There is already a PIP Template for this Brand. Please deactivate the existing one,' +
                            ' before creating a new template.');
                }
            }
        }
    }

    /**
	 * @description This method will check and throw an error saying if two Opening templates from being created
	 * that are Active with the Same Brand and Project
	 *
	 * @param openingTemplatesToValidate - New values for PIP Template record type
	 * @param idMapByBrandProjectType - Old values for PIP Template record type
	 * @return void
	 */
    public void checkDuplicateBrandProjectType(List<TASKRAY__Project__c> openingTemplatesToValidate,
                Map<String, List<Id>> idMapByBrandProjectType){

        for(TASKRAY__Project__c newOpeningTemplate : openingTemplatesToValidate){
            if(newOpeningTemplate.Active__c && newOpeningTemplate.TASKRAY__trTemplate__c &&
                    newOpeningTemplate.Brand__c != null && newOpeningTemplate.Project_Type__c != null &&
                    idMapByBrandProjectType.containsKey(newOpeningTemplate.Brand__c+newOpeningTemplate.Project_Type__c)){

                List<Id> openingTemplateListForBrand = idMapByBrandProjectType.get(newOpeningTemplate.Brand__c+newOpeningTemplate.Project_Type__c);
                if(openingTemplateListForBrand != null &&  openingTemplateListForBrand.size()>0) {
                    throw new DmlException('There is already an Opening Template for this Brand and Project Type. ' +
                            'Please deactivate the existing one, before creating a new template.');
                }
            }
        }
    }

    /**
	 * @description This method will populate Project Map By Brand
	 *
	 * @return  Map<String, List<Id>>
	 */
    private Map<String, List<Id>> populateProjectMapByBrand(List<Id> newPIPTemplateIds){
        List<TASKRAY__Project__c> currentPIPTemplates = [Select Id, Brand__c, Active__c from TASKRAY__Project__c where
        TASKRAY__trTemplate__c=true and Active__c=true
        And RecordType.DeveloperName =: AppConstants.TASKRAY_PROJECT_RECORDTYPE_PIP_TEMPLATE
        And Id Not In :newPIPTemplateIds ];

        Map<String, List<Id>> projectMapByBrand = new Map<String, List<Id>>();
        for(TASKRAY__Project__c pipTemplate: currentPIPTemplates) {
            List<Id> pipTemplateListForBrand = null;
            if (pipTemplate.Brand__c != null) {
                if(projectMapByBrand.containsKey(pipTemplate.Brand__c)) {
                    pipTemplateListForBrand = projectMapByBrand.get(pipTemplate.Brand__c);
                }else{
                    pipTemplateListForBrand = new List<Id>();
                }
                pipTemplateListForBrand.add(pipTemplate.Id);
                projectMapByBrand.put(pipTemplate.Brand__c, pipTemplateListForBrand);
            }
        }
        return projectMapByBrand;
    }

    /**
	 * @description This method will populate Map By Brand and Project Type for Opening Template
	 *
	 * @return  Map<String, List<Id>>
	 */
    private Map<String, List<Id>> populateMapByBrandProject(List<Id> newOpeningTemplateIds){
        List<TASKRAY__Project__c> currentOpeningTemplates = [Select Id, Brand__c, Active__c, Project_Type__c
            from TASKRAY__Project__c where TASKRAY__trTemplate__c=true and Active__c=true
            And RecordType.DeveloperName =: AppConstants.TASKRAY_PROJECT_RECORDTYPE_OPENING_TEMPLATE
            And Id Not In :newOpeningTemplateIds ];

        Map<String, List<Id>> idMapByBrandProjectType = new Map<String, List<Id>>();
        for(TASKRAY__Project__c openingTemplate: currentOpeningTemplates) {
            List<Id> openingTemplateListForBrandProject = null;
            if (openingTemplate.Brand__c != null && openingTemplate.Project_Type__c != null) {
                String brandProjectTypeKey = openingTemplate.Brand__c + openingTemplate.Project_Type__c;
                if(idMapByBrandProjectType.containsKey(brandProjectTypeKey)) {
                    openingTemplateListForBrandProject = idMapByBrandProjectType.get(brandProjectTypeKey);
                }else{
                    openingTemplateListForBrandProject = new List<Id>();
                }
                openingTemplateListForBrandProject.add(openingTemplate.Id);
                idMapByBrandProjectType.put(brandProjectTypeKey, openingTemplateListForBrandProject);
            }
        }
        return idMapByBrandProjectType;
    }

}