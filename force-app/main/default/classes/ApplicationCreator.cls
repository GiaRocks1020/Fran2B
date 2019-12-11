public without sharing class ApplicationCreator {
    public static final String CHOICE_COMMUNITY_PROFILE = 'Choice Community User';
    private static final String APP_EXPECTED_STAGE = 'App Expected';
    @TestVisible private static final String DEAL_WORKING_STAGE = 'Deal Working';

    /***************************************************************************************
    Returns A list of Deals that have been flagged to create Applications
    ****************************************************************************************/
    public static List<Opportunity> getOpportunitiesThatNeedApplications(List<Opportunity> newOppList, Map<Id,Opportunity> oldOppMap){
            List<Opportunity> oppsToReturn = new List<Opportunity>();
            for(Opportunity opp : newOppList){
                Opportunity oldOpp = oldOppMap.get(opp.Id);

                if(opp.Send_Application__c == true && opp.Send_Application__c != oldOpp.Send_Application__c){
                    oppsToReturn.add(opp);
                }
            }

        return oppsToReturn;
    }

    /***************************************************************************************
    Handles setup of data for Application creation
    ****************************************************************************************/
    public static void createApplicationData(List<Opportunity> opps){
        Profile pf = [Select Id, Name from Profile where name = :CHOICE_COMMUNITY_PROFILE limit 1];
        List<Id> contactIdsOnOpps = new List<Id>();

        for(Opportunity opp: opps){
            contactIdsOnOpps.add(opp.Applicant__c);
            updateStageToAppExpected(opp);
        }

        Map<Id, Contact> contactIdToContact = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE Id IN :contactIdsOnOpps]);

        Map<Id, User> portalUsersMap = new Map<Id, User>([SELECT FirstName, LastName, Email, ContactId, IsActive 
                                    FROM User WHERE ContactId IN :contactIdsOnOpps
                                    AND ProfileId = :pf.Id]);

        Map<Id, User> contactIdToPortalUserMap = getContactIdToPortalUserMap(portalUsersMap.values());

        List<User> newPortalUsersToInsert = new List<User>();

        for(Opportunity opp : opps){
            //if contact does not have a portal user, create a new one
            if(!contactIdToPortalUserMap.containsKey(opp.Applicant__c)){
                if(contactIdToContact.containsKey(opp.Applicant__c)){
                    Contact c = contactIdToContact.get(opp.Applicant__c);
                    newPortalUsersToInsert.add(CommunityUserHelper.getNewCommunityUser(c, pf.Id));
                }
            }
        }

        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        dlo.optAllOrNone = true;

        Database.insert(newPortalUsersToInsert, dlo);

        if(portalUsersMap.size() > 0){
            makeUsersActive(portalUsersMap.keySet());
        }

        contactIdToPortalUserMap.putAll(getContactIdToPortalUserMap(newPortalUsersToInsert));

        insertApplications(opps, contactIdToPortalUserMap);
    }

    /***************************************************************************************
    Method to update stage from 'Deal Working' to 'App Expected'
    ****************************************************************************************/
    public static void updateStageToAppExpected(Opportunity opp){
        if(opp.StageName == DEAL_WORKING_STAGE){
            opp.StageName = APP_EXPECTED_STAGE;
        }   
    }

    /***************************************************************************************
    Method to update inactive users to active. Future method to prevent Mixed DML Errors
    ****************************************************************************************/
    @Future
    public static void makeUsersActive(Set<Id> userIds){

        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        dlo.optAllOrNone = true;

        List<User> users = new List<User>([SELECT Id, isActive FROM User WHERE Id IN :userIds]);

        for(User u :users){
            if(u.isActive == false){
                u.isActive = true;
            }
        }

        Database.update(users, dlo);
    }

    /***************************************************************************************
    Method that inserts applications into the database
    ****************************************************************************************/
    public static void insertApplications(List<Opportunity> opps, Map<Id, User> contactIdToPortalUserMap){
        List<Application__c> applicationsToInsert = new List<Application__c>();
        //for each opp, create an application with the correct portal user;
        for(Opportunity opp: opps){
            if(opp.Applicant__c != null){
                Application__c app = new Application__c(
                    Deal__c = opp.Id,
                    OwnerId  = contactIdToPortalUserMap.get(opp.Applicant__c).Id
                );

                applicationsToInsert.add(app);
            }
        }
        try{
            insert applicationsToInsert;
        }
        catch(Exception e){
            applicationsToInsert.get(0).addError(e.getMessage());
        }
    }

    /***************************************************************************************
    Method returns a Map of users where the key is the Contact Id
    ****************************************************************************************/
    public static Map<Id, User> getContactIdToPortalUserMap(List<User> users){
        Map<Id, User> contactIdToPortalUserMap = new Map<Id, User>();

        for(User u : users){
            contactIdToPortalUserMap.put(u.ContactId, u);
        }

        return contactIdToPortalUserMap;
    }


}