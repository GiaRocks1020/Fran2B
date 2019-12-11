public with sharing class ApplicationOwnersController {
    private static final String OWNER = 'Owner';

    @AuraEnabled
    public static List<Applicant__c> getApplicantsRelatedToApp(Id appId){

        String fieldsToQuery = 'Id, Name, ';

        for(String field : FranchiseSalesUtilities.getSobjectFields('Applicant__c')){
             fieldsToQuery += field + ', ';
        }

        fieldsToQuery = fieldsToQuery.removeEnd(', ');

        String queryString = 'SELECT ' + fieldsToQuery + ' FROM Applicant__c ' + 
                    'WHERE Application__c = \'' + appId + '\' ' +
                    'AND (Are_you_Owner_or_Designated_Rep__c = \'' + OWNER + '\' ' +
                    'OR Is_the_Desig_Rep_also_one_of_the_Owners__c = True)';

    List<Applicant__c> applicantsOnApp = Database.query(queryString);

        return returnCleanedUpApplicants(applicantsOnApp);
    }

    @AuraEnabled
    public static void deleteOwner(Applicant__c owner){

        delete owner;
    }


    public static List<Private_Files__c> getPrivateFilesByApplicant(List<id> applicantIds){
        return[SELECT Id
        FROM Private_Files__c
        WHERE Applicant__c IN:applicantIds];
    }

    public static void deletePrivateFiles(List<Private_Files__c> privateFiles){
        delete privateFiles;
    }

    private static List<Applicant__c> returnCleanedUpApplicants(List<Applicant__c> applicants){
        List<Applicant__c> applicantsToRemove = new List<Applicant__c>();
        List<Applicant__c> cleanedUpApplicants = new List<Applicant__c>();
        List<Id> applicantsToDeleteIds = new List<Id>();
        for(Applicant__c applicant : applicants){
            if(String.isEmpty(applicant.First_Name__c) && String.isEmpty(applicant.Last_Name__c)){
                applicantsToRemove.add(applicant);
                applicantsToDeleteIds.add(applicant.Id);
            }
            else{
                cleanedUpApplicants.add(applicant);
            }
        }
        List<Private_Files__c> privateFilesToDelete = getPrivateFilesByApplicant(applicantsToDeleteIds);
        if(privateFilesToDelete.size() > 0){
            deletePrivateFiles(privateFilesToDelete);
        }
        



        try{
            delete applicantsToRemove;
        }
        catch(Exception e){
            return applicants;
        }

        return cleanedUpApplicants;

    }
}