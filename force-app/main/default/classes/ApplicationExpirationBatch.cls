global class ApplicationExpirationBatch implements Database.Batchable<sObject> {
	private static final String EXPIRED = 'Expired';
	private static final String IN_PROGRESS = 'In Progress';
	private static Date cutOffDate = Date.Today().addDays(-14);
	
	String query = 'SELECT Id FROM Application__c WHERE (Status__c =  '  + '\''  + IN_PROGRESS  + '\')' +
	  ' AND Application_Start_Date__c  <= ' + String.valueOf(Date.Today().addDays(-14));


		

	
	global ApplicationExpirationBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT Id 
			FROM Application__c 
			WHERE (Status__c =:IN_PROGRESS) 
			AND (Application_Start_Date__c  <=:cutOffDate  )
			]);
	}

   	global void execute(Database.BatchableContext BC, List<Application__c> scope) {
		for(Application__c app: scope){
			app.Status__c =EXPIRED;
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
        if(!Test.isRunningTest()){
			Database.executeBatch(new  ApplicationDeactivateUserBatch());
        }

	}
	
}