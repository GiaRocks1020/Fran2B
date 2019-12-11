public class ApplicationHotelInfoController {


	@AuraEnabled
	public static Map<String,Private_Files__c> handleFirstTime(String appString){

		populateStartDate(appString);
		List<Private_Files__c> newPrivateFiles = createPrivateFiles(appString);
		newPrivateFiles = insertPrivateFiles(newPrivateFiles);
		Map<String,Private_Files__c> idToPrivateFile = createIdToPrivateFileMap(newPrivateFiles);
		return idToPrivateFile;
	}


	public static List<Private_Files__c> createPrivateFiles(String appString){
		Application__c app = (Application__c)JSON.deserialize(appString, Application__c.class);
		List<String> uploadedLocations = new List<String>{
			'Entity_Document__c',
			'ADA_Certificate__c',
			'Lease_Agreement__c',
			'Deed__c',
			'PA_or_LOI__c',
			'Additional_Document__c',
			'Insurance_Certificate__c'
		};
		List<Private_Files__c> newPrivateFiles  = new List<Private_Files__c>();
		for(String location: uploadedLocations){
			newPrivateFiles.add(new Private_Files__c(
				Uploaded_Location__c = location,
				Application__c = app.id
				));
		}
		return newPrivateFiles;

	}

	public static Map<String,Private_Files__c> createIdToPrivateFileMap(List<Private_Files__c> privateFiles){
		Map<String,Private_Files__c> idToPrivateFile = new Map<String,Private_Files__c>();

		for(Private_Files__c file: privateFiles){
			idToPrivateFile.put(file.Uploaded_Location__c, file);
		}
		return idToPrivateFile;

	}

	@AuraEnabled
	public static Map<String,Private_Files__c> getPrivateFiles(String appString){
		Application__c app = (Application__c)JSON.deserialize(appString, Application__c.class);

		List<Private_Files__c> privateFiles = [
			SELECT Id, Uploaded_Location__c, Application__c
			FROM Private_Files__c
			WHERE Application__c =: app.Id];

		Map<String,Private_Files__c> idToPrivateFile = createIdToPrivateFileMap(privateFiles);
		return idToPrivateFile;
	}

	public static List<Private_Files__c> insertPrivateFiles(List<Private_Files__c> privateFiles){
		insert privateFiles;
		return privateFiles;
	}

    public static void populateStartDate (String appString){
        Application__c app = (Application__c)JSON.deserialize(appString, Application__c.class);
        app.Application_Start_Date__c = Date.Today();
        
        update app;
    }
}