public without sharing class ApplicationContainerController {
	private static final String IN_PROGRESS = 'In Progress';

	@AuraEnabled
	public static String getDataEnvelope(){
		List<Application__c> apps = getApplications();

		ApplicationEnvelope envelope = new ApplicationEnvelope(apps);
		return JSON.serialize(envelope);

	}


 	@AuraEnabled
    public static List<Application__c> getApplications(){
        String fieldsToQuery = 'Id, Name, ';

        for(String field : FranchiseSalesUtilities.getSobjectFields('Application__c')){
             fieldsToQuery += field + ', ';
        }
        fieldsToQuery += 'Application_Expires_in__c ';
        //fieldsToQuery = fieldsToQuery.removeEnd(', ');
        System.debug('query fields ' + fieldsToQuery);
        String whereClause = '';
        whereClause = ' WHERE (OwnerId = '  + '\''  + UserInfo.getUserId() + '\')' + ' AND (Status__c =  '  + '\''  + IN_PROGRESS  + '\')' ;
        return Database.query('SELECT ' + fieldsToQuery + ' FROM Application__c ' + whereClause +  ' ORDER BY Name');
        
    }


    public class ApplicationEnvelope{
		public List<Application__c> applications {get; set;}
		

		public ApplicationEnvelope(List<Application__c> applications) {
			this.applications = applications;
		
		}
	}


}