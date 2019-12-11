public class ApplicationHelper {
    public static final String IN_PROGRESS_STATUS = 'In Progress';
    public static final String EXPIRED_STATUS = 'Expired';


	/**********************************************************************************
    	DESCRIPTION:
    		Method to identify Application records that need status renewed
    	INPUTS:
    		List<Application__c>
            Map<Id,Application__c>
    	RETURNS
    		List<Application__c>
    **********************************************************************************/	
    public static List<Application__c> getExpiredAppsWithStartDateRenewed(List<Application__c> apps, Map<Id, Application__c> oldAppsMap){
        List<Application__c> appsThatMatchCriteria = new List<Application__c>();

        //if status expired and start date changed to future
        for(Application__c app : apps){
            if(app.Status__c == EXPIRED_STATUS){
                Application__c oldApp = oldAppsMap.get(app.Id);
                if(app.Application_Start_Date__c != oldApp.Application_Start_Date__c){
                    if(app.Application_Start_Date__c >= Date.today()){
                        appsThatMatchCriteria.add(app);
                    }
                }
            }
        }
        
        return appsThatMatchCriteria;
    }

	/**********************************************************************************
    	DESCRIPTION:
    		Method to change application status to 'In Progress' and 
            activate inactive users.
    	INPUTS:
    		List<Applications> 		
    **********************************************************************************/	
    public static void changeStatusToInProgressAndActivateUsers(List<Application__c> apps){
        Set<Id> userIds = new Set<Id>();

        for(Application__c app :apps){
            app.Status__c = IN_PROGRESS_STATUS;
            userIds.add(app.OwnerId);
        }

        ApplicationCreator.makeUsersActive(userIds);
    }
}