public with sharing class EmailTemplateDA {

	public static EmailTemplate getEmailTemplateByDeveloperName(String developerName) {
		return [SELECT  Id,
						DeveloperName
				FROM EmailTemplate
				WHERE DeveloperName = :developerName
				LIMIT 2];
	}

}