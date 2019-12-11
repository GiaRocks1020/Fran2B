public class ApplicationFileDisplayController {
	private static final String NOT_FOUND = 'NOTFOUND';
    private static final String ATTACHMENT = 'doctype:attachment';
    private static final String FINANCIAL_STATEMENT = 'Personal_Financial_Statement__c';
    private static final String RESUME = 'Owner_Resume__c';
    private static final String ADDITIONAL_DOCUMENTS = 'Additional Documents';
        
    
    @AuraEnabled
    public static List<UploadWrapper> getFileUploads(Id appId){
         System.debug('ID: ' + appId);
        List<Id> applicantIds = new List<Id>();
        List<UploadWrapper> wrapper = new List<UploadWrapper>();

        List<Applicant__c> applicants = retrieveApplicantsById(appId);

        for(Applicant__c applicant : applicants){
            applicantIds.add(applicant.Id);
        }
        List<Private_Files__c> privateFiles = getPrivateFilesByAppOrApplicant(appId, applicantIds);
        System.debug('PRIVATE FILES: ' + privateFiles);
        Map<String,String> idToPrivateFiles = createIdToPrivateFileMap(privateFiles);
        List<Id> pfIds = extractPrivateFileIds(privateFiles);
        System.debug('pfids= ' +  pfIds);

        List<ContentDocumentLink> uploads = retrieveAttachments(pfIds);

        Set<String> fileTypes = extractFileTypes(uploads);
        List<File_Icon_Mapping__mdt> mappingList = getFieldMapping(fileTypes);
        Map<String,String>  iconMap = createTypeToIconMap(mappingList);

        for(ContentDocumentLink upload : uploads){
            String fileType = NOT_FOUND;

            String uploadedLocation = idToPrivateFiles.get(upload.LinkedEntityId);
            if(iconMap.containsKey(upload.ContentDocument.FileType)){
                fileType = upload.ContentDocument.FileType;
            }   
            fileType = iconMap.get(fileType);

            wrapper.add(new UploadWrapper(upload,fileType,upload.ContentDocumentId,uploadedLocation));
        }
        return wrapper;
    }


    @AuraEnabled
    public static String  handleDeletionProcess(Id documentId,String section, Id parentId){
        //parent id = new obj.
        ContentDocument document = new ContentDocument(Id = documentId);
        deleteFile(document);
        Private_Files__c privateFile = getPrivateFileById(parentId);
        Id idOfFileToUpdate = determineIdToUpdate(section,privateFile);
        List<ContentDocumentLink> links = retrieveAttachments(new List<Id>{parentId});

        Boolean shouldUpdateUI;
        Id applicantId;
        if(links.size() == 0){
            determineRecordToUpdate(section,idOfFileToUpdate);
            shouldUpdateUI = true;
        }else{
            shouldUpdateUI = false;
        }


        
        return JSON.serialize(new DeleteWrapper(shouldUpdateUI,idOfFileToUpdate));
    }



    public static Map<String,String> createIdToPrivateFileMap ( List<Private_Files__c> privateFiles){
        Map<String,String> idToPrivateFiles =  new map<String,String>();
        for(Private_Files__c file: privateFiles){
            idToPrivateFiles.put(file.id, file.Uploaded_location__c);
        }
        return idToPrivateFiles;
    }




    public static Map<String,String> createTypeToIconMap(List<File_Icon_Mapping__mdt> mappingList){
        Map<String,String> iconMap = new Map<String,String>();
        for(Integer x = 0; x<mappingList.size(); x++){
            if(!iconMap.containsKey(mappingList[x].Extension__c)){
                iconMap.put(mappingList[x].Extension__c, mappingList[x].Icon__c);
            }
        }
        iconMap.put(NOT_FOUND,ATTACHMENT);
        return iconMap;
    }

    public static Set<String> extractFileTypes(List<ContentDocumentLink> cdl){
        Set<String> fileTypes = new Set<String>();
        for(Integer x = 0; x< cdl.size(); x++){
            fileTypes.add(cdl[x].ContentDocument.FileType);
        }
        return fileTypes;

    }


     public static List<Id> extractPrivateFileIds (List<Private_Files__c> privateFiles){
        List<Id> pfIds = new List<Id>();
        for(Private_Files__c pf: privateFiles){
            pfIds.add(pf.Id);
        }
        return pfIds;
    }


  


    public static id determineIdToUpdate(String section, Private_Files__c privateFile){
        Id idOfFileToUpdate;
         if(section == privateFile.Uploaded_location__c){
            if(privateFile.Application__c != null){
                idOfFileToUpdate = privateFile.Application__c;  
            }else if(privateFile.Applicant__c != null){
                idOfFileToUpdate = privateFile.Applicant__c;
            }
        }
        return idOfFileToUpdate;
    }

    public static void determineRecordToUpdate(String section, Id idOfFileToUpdate){
        if(section !='' && section != ADDITIONAL_DOCUMENTS ){
            if(section == RESUME || section == FINANCIAL_STATEMENT){
                Applicant__c applicant = setApplicantCheckbox(section,idOfFileToUpdate);
                updateApplicant(applicant);
            }else{
                Application__c application = setApplicationCheckbox(section,idOfFileToUpdate);
                updateApplication(application);                  
            }
        }
    }


    public static Applicant__c setApplicantCheckbox(String section, Id parentId){
        Applicant__c applicant = new Applicant__c(Id = parentId, Section__c = '');
        String returnValue = (String)applicant.put(section,false);
        return applicant;
    }


    public static Application__c setApplicationCheckbox(String section, Id parentId){
        Application__c application = new Application__c(Id = parentId,Section__c = '');
        return application;
    }


    public static void updateApplication(Application__c application){
        update application;
    }

    public static void updateApplicant(Applicant__c applicant){
        update applicant;
    }

    public static void deleteFile(ContentDocument document){
        delete document;
    }



    public static List<File_Icon_Mapping__mdt> getFieldMapping(Set<String> extensions){
        return[SELECT Id, Icon__c,Extension__c
                FROM File_Icon_Mapping__mdt
                WHERE Extension__c IN :extensions];
    }


    public static List<Applicant__c> retrieveApplicantsById(Id appId){
                return [SELECT Id 
                FROM Applicant__c 
                WHERE Application__c = :appId];

    }


    public static List<Private_Files__c> getPrivateFilesByAppOrApplicant(Id appId, List<Id> applicantIds){
        return[SELECT Id,Uploaded_location__c, Application__c, Applicant__c
            FROM Private_Files__c
            WHERE Application__c =:appId OR
            Applicant__c IN: applicantIds];
    }

    public static Private_Files__c getPrivateFileById(Id privateFileId){
        return[SELECT Id,Uploaded_location__c, Application__c, Applicant__c
            FROM Private_Files__c
            WHERE Id =:privateFileId 
            LIMIT 1];
    }



    public static List<ContentDocumentLink> retrieveAttachments(List<Id> ids){
        if(ids.size() == 0){
            return new List<ContentDocumentLink>();
        }
        return [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.Owner.Name,
         ContentDocument.LastModifiedDate ,ContentDocument.LatestPublishedVersionId,
        ContentDocument.FileType,LinkedEntityId
        FROM ContentDocumentLink 
        WHERE LinkedEntityId IN :ids];

    }



    public class DeleteWrapper{
        @AuraEnabled public Boolean updateUI;
        @AuraEnabled public Id applicantId;

        DeleteWrapper(Boolean updateUI,Id applicantId){
            this.updateUI = updateUI;
            this.applicantId = applicantId;
        }
    }




    public class UploadWrapper{
        
        @AuraEnabled public String name;
        @AuraEnabled public String fileIcon;
        @AuraEnabled public Id contentDocumentId;
        @AuraEnabled public ContentDocumentLink link;
        @AuraEnabled public String section;
        UploadWrapper(ContentDocumentLink link, String fileIcon, Id contentDocumentId,
             String section){
            this.link = link;
            this.name = link.ContentDocument.Title;
            this.fileIcon = fileIcon;
            this.contentDocumentId = contentDocumentId;
            this.section = section;
        }
    }
}