/**
 * @description TriggerHandler for Files Object
 *
 * @author Sugandha Chugh
 * @date 2019-08-21
 */

public inherited sharing class ContentDocumentLinkTriggerHandler extends TriggerBase{

// Trigger Variables
    public static Boolean bypassTrigger = false;

// Constructor
    public ContentDocumentLinkTriggerHandler() {
        setBypassTrigger(bypassTrigger);
    }

// After Insert execution context
    public override void afterInsert(){
        List<ContentDocumentLink> lstCntLinks = (List<ContentDocumentLink>)Trigger.new;
        updateFileNameCheckDuplicate(lstCntLinks);
    }

    public void updateFileNameCheckDuplicate(List<ContentDocumentLink> lstCntLinks){
        String strObjPrefix;
        Set<Id> setCntDocIds = new Set<Id>();
        Set<Id> setPIPIds = new Set<Id>();
        Map<Id, TASKRAY__Project__c> mapPIPs;

        for(ContentDocumentLink clIterator : lstCntLinks) {
            strObjPrefix = String.valueOf(clIterator.LinkedEntityId).substring(0, 3);
            if(strObjPrefix == TaskRay__Project__c.SObjectType.getDescribe().getKeyPrefix()) {
                setCntDocIds.add(clIterator.ContentDocumentId);
                setPIPIds.add(clIterator.LinkedEntityId);
            }
        }

        if(!setCntDocIds.isEmpty() && !setPIPIds.isEmpty()) {
            mapPIPs = new Map<Id, TASKRAY__Project__c>([SELECT Id, Name, Property_Code__c, Brand__r.Name,
                    Product__r.Name, City__c FROM TASKRAY__Project__c WHERE Id IN :setPIPIds]);
        }

        // Get content document object for current set of files
        Map<Id, ContentDocument> mapContentDocuments = new Map<Id, ContentDocument>(
        [SELECT Id, Title, FileExtension FROM ContentDocument WHERE Id IN :setCntDocIds]);

        // Retrieve all the existing attachments associated with the parent records
        Map<Id, Set<String>> mapParentIdFilenames = new Map<Id, Set<String>>();
        if(!setPIPIds.isEmpty() || !setCntDocIds.isEmpty()) {
            for (ContentDocumentLink cdlIterator : [
                    SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title,
                            ContentDocument.FileExtension
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :setPIPIds AND Id NOT IN :setCntDocIds]) {
                if (!mapParentIdFilenames.containsKey(cdlIterator.LinkedEntityId)) {
                    mapParentIdFilenames.put(cdlIterator.LinkedEntityId, new Set<String>());
                }
                mapParentIdFilenames.get(cdlIterator.LinkedEntityId).add(cdlIterator.ContentDocument.Title
                        + (String.isBlank(cdlIterator.ContentDocument.FileExtension) ? '' : '.' + cdlIterator.ContentDocument.FileExtension));
            }
        }

        TASKRAY__Project__c objPIP;
        List<ContentDocument> lstCntDocsToUpdate = new List<ContentDocument>();

        for(ContentDocumentLink cdlIterator : lstCntLinks) {
            ContentDocument objCntDoc = mapContentDocuments.get(cdlIterator.ContentDocumentId);
            String strFilename = '';
            if(mapPIPs != null && mapPIPs.containsKey(cdlIterator.LinkedEntityId)) {
                objPIP = mapPIPs.get(cdlIterator.LinkedEntityId);
                strFilename = (String.isBlank(objPIP.Property_Code__c) ? '' : objPIP.Property_Code__c)
                        + ', '
                        + (String.isBlank(objPIP.Brand__r.Name) ? '' : objPIP.Brand__r.Name)
                        + ', '
                        + (String.isBlank(objPIP.Product__r.Name) ? '' : objPIP.Product__r.Name)
                        + ', '
                        + (String.isBlank(objPIP.City__c) ? '' : objPIP.City__c)
                        + ', '
                        + objCntDoc.Title
                        + '.'
                        + objCntDoc.FileExtension;
            }

            if(!String.isBlank(strFilename)) {
                Set<String> setExistingFilenames = mapParentIdFilenames.get(cdlIterator.LinkedEntityId);
                if (setExistingFilenames != null && setExistingFilenames.contains(strFilename
                        + (String.isBlank(objCntDoc.FileExtension) ? '' : '.' + objCntDoc.FileExtension))) {
                    //Commenting next line as SF currently has a bug for nt displaying error in lightning for files.
                    //cdlIterator.addError('Attaching duplicate file, please choose different file.');

                    //attach Date/Time for duplicate file
                    try {
                        String strNewFileName = strFilename.substring(0, strFilename.lastIndexOf('.'))
                                + ' -Copy '
                                + Datetime.now().format('MM-dd-YYYY HH:mm:ss')
                                + '.'
                                + objCntDoc.FileExtension;
                        objCntDoc.Title = strNewFileName;
                    }catch(Exception ex){
                        System.debug('Exception occurred in ContentDocumentLinkTriggerHandler while renaming File. Error: '+ex.getMessage());
                    }
                }
                else {
                    objCntDoc.Title = strFilename;
                }
                    lstCntDocsToUpdate.add(objCntDoc);
            }
        }

        if(!lstCntDocsToUpdate.isEmpty()) {
            try {
                update lstCntDocsToUpdate;
            }catch(Exception ex){
                System.debug('Exception occurred in ContentDocumentLinkTriggerHandler. Error: '+ex.getMessage());
            }
        }
    }
}