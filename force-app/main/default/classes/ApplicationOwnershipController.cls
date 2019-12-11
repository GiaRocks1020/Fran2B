public with sharing class ApplicationOwnershipController {
    private static final String OWNER = 'Owner';



    @AuraEnabled
    public static String handleDataInit(Id appId, String ownerId){
        if(String.isEmpty(ownerId)){
            return handleNewOwner(appId);
        }
        else{
            return handleEditOwner(ownerId);
        }
    }


    public static String handleNewOwner(Id appId){

        Applicant__c newOwner = createOwner(appId);
        insertApplicant(newOwner);

        List<Private_Files__c> newPrivateFiles = createPrivateFiles(newOwner);
        newPrivateFiles = insertPrivateFiles(newPrivateFiles);

        Map<String,Private_Files__c> idToPrivateFile = createIdToPrivateFileMap(newPrivateFiles);

        OwnershipEnvelope envelope = new OwnershipEnvelope(newOwner,idToPrivateFile);
        return JSON.serialize(envelope);
    }

    public static String handleEditOwner(Id ownerId){
        Applicant__c newOwner = new Applicant__c(Id = ownerId);
        List<Private_Files__c> privateFiles = getPrivateFilesByApplicant(ownerId);

        if(privateFiles.size() == 0){
            privateFiles = createPrivateFiles(newOwner);
            privateFiles = insertPrivateFiles(privateFiles);
        }
        Map<String,Private_Files__c> idToPrivateFile = createIdToPrivateFileMap(privateFiles);
        OwnershipEnvelope envelope = new OwnershipEnvelope(newOwner,idToPrivateFile);
        return JSON.serialize(envelope);


    }

    
    public static Applicant__c createOwner(Id appId){
        Applicant__c newOwner = new Applicant__c(
            Are_you_Owner_or_Designated_Rep__c = OWNER,
            Application__c = appId
        );

        return newOwner;
    }

    public static Applicant__c insertApplicant(Applicant__c applicant){
        insert applicant;
        return applicant;
    }


    public static List<Private_Files__c> createPrivateFiles(Applicant__c applicant){
        List<String> uploadedLocations = new List<String>{
            'Personal_Financial_Statement__c',
            'Owner_Resume__c'
        };

        List<Private_Files__c> newPrivateFiles  = new List<Private_Files__c>();
        for(String location: uploadedLocations){
            newPrivateFiles.add(new Private_Files__c(
                Uploaded_Location__c = location,
                Applicant__c = applicant.id
                ));
        }
        return newPrivateFiles;

    }

    public static List<Private_Files__c> getPrivateFilesByApplicant(Id applicantId){
        return[
        SELECT Id, Uploaded_Location__c, Applicant__c
        FROM Private_Files__c
        WHERE Applicant__c =:applicantId
        ];

    }

    public static List<Private_Files__c> insertPrivateFiles(List<Private_Files__c> privateFiles){
        insert privateFiles;
        return privateFiles;
    }

    public static Map<String,Private_Files__c> createIdToPrivateFileMap(List<Private_Files__c> privateFiles){
        Map<String,Private_Files__c> idToPrivateFile = new Map<String,Private_Files__c>();

        for(Private_Files__c file: privateFiles){
            idToPrivateFile.put(file.Uploaded_Location__c, file);
        }
        return idToPrivateFile;

    }

     public class OwnershipEnvelope{
        public Applicant__c owner {get; set;}
        public Map<String,Private_Files__c> idToPrivateFile {get;set;}

        public OwnershipEnvelope(Applicant__c owner, Map<String,Private_Files__c> idToPrivateFile) {
            this.owner = owner;
            this.idToPrivateFile = idToPrivateFile;
        
        }
    }

    @AuraEnabled
    public static void updateFinancialStatement(Id ownerId){
        update new Applicant__c(Id = ownerId, Personal_Financial_Statement__c = true, Section__c ='');
    }

    @AuraEnabled
    public static void updateOwnerResume(Id ownerId){
        update new Applicant__c(Id = ownerId, Owner_Resume__c = true, Section__c ='');
    }
}