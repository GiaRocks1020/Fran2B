global class ApplicationDeactivateUserBatch implements Database.Batchable<sObject> {
	
	private static final String COMMUNITY_USER = 'Choice Community User';
	private static final String IN_PROGRESS = 'In Progress';


	global ApplicationDeactivateUserBatch() {
		
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
        if(Test.isRunningTest()){
            return Database.getQueryLocator([
                SELECT ID, Name,IsActive
                FROM USER 
                WHERE Profile.Name=:COMMUNITY_USER
                AND IsActive = true
                AND Id NOT IN (SELECT OwnerID FROM Application__c WHERE Status__c=: IN_PROGRESS) limit 1
            ]);
        } else{
            return Database.getQueryLocator([
			SELECT ID, Name,IsActive
			FROM USER 
			WHERE Profile.Name=:COMMUNITY_USER
			AND IsActive = true
			AND Id NOT IN (SELECT OwnerID FROM Application__c WHERE Status__c=: IN_PROGRESS)
			]);
        }
	}

	global void execute(Database.BatchableContext BC, List<User> scope){
		for (User u: scope){
			u.isActive =false;
		}
		update scope;
	}

	global void finish(Database.BatchableContext BC) {
		
	}
}