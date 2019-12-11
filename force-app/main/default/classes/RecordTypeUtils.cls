/**
 * Created by pradnya.desai on 10/29/19.
 */

public with sharing class RecordTypeUtils {

    /**
     * @description This method will check if input record is PIP record or not.
     *
     * @param recordTypeId - Input Record Type id
     * @return Boolean
     */
    public static boolean isPIPItemRecordType(Id recordTypeId){
        boolean isPIPItemRecordType = false;
        if(AppConstants.taskrayTaskRecordTypeMap != null
                && AppConstants.taskrayTaskRecordTypeMap.get(recordTypeId) != null
                && (AppConstants.taskrayTaskRecordTypeMap.get(recordTypeId)).getDeveloperName()
                == AppConstants.TASKRAY_TASK_RECORDTYPE_PIP_ITEM){
            isPIPItemRecordType = true;
        }
        return isPIPItemRecordType;
    }

    /**
     * @description This method will check if input record is Milestone or not.
     *
     * @param recordTypeId - Input Record Type id
     * @return Boolean
     */
    public static boolean isMileStoneRecordType(Id recordTypeId){
        boolean isMilestoneRecordType = false;
        if(AppConstants.taskrayTaskRecordTypeMap != null
                && AppConstants.taskrayTaskRecordTypeMap.get(recordTypeId) != null
                && (AppConstants.taskrayTaskRecordTypeMap.get(recordTypeId)).getDeveloperName()
                == AppConstants.TASKRAY_TASK_RECORDTYPE_MILESTONE){
            isMilestoneRecordType = true;
        }
        return isMilestoneRecordType;
    }

    /**
     * @description This method will check if input record is PIP record or not.
     *
     * @param recordTypeId - Input Record Type id
     * @return Boolean
     */
    public static boolean isPIPRecordType(Id recordTypeId){
        boolean isPIPRecordType = false;
        if(AppConstants.taskrayProjectRecordTypeMap != null
                && AppConstants.taskrayProjectRecordTypeMap.get(recordTypeId) != null
                && (AppConstants.taskrayProjectRecordTypeMap.get(recordTypeId)).getDeveloperName()
                == AppConstants.TASKRAY_PROJECT_RECORDTYPE_PIP){
            isPIPRecordType = true;
        }
        return isPIPRecordType;
    }

    /**
     * @description This method will check if input record is PIP Template record or not.
     *
     * @param recordTypeId - Input Record Type id
     * @return Boolean
     */
    public static boolean isPIPTemplateRecordType(Id recordTypeId){
        boolean isPIPTemplateRecordType = false;
        if(AppConstants.taskrayProjectRecordTypeMap != null
                && AppConstants.taskrayProjectRecordTypeMap.get(recordTypeId) != null
                && (AppConstants.taskrayProjectRecordTypeMap.get(recordTypeId)).getDeveloperName()
                == AppConstants.TASKRAY_PROJECT_RECORDTYPE_PIP_TEMPLATE){
            isPIPTemplateRecordType = true;
        }
        return isPIPTemplateRecordType;
    }

    /**
     * @description This method will check if input record is Opening Template record or not.
     *
     * @param recordTypeId - Input Record Type id
     * @return Boolean
     */
    public static boolean isOpeningTemplateRecordType(Id recordTypeId){
        boolean isPIPTemplateRecordType = false;
        if(AppConstants.taskrayProjectRecordTypeMap != null
                && AppConstants.taskrayProjectRecordTypeMap.get(recordTypeId) != null
                && (AppConstants.taskrayProjectRecordTypeMap.get(recordTypeId)).getDeveloperName()
                == AppConstants.TASKRAY_PROJECT_RECORDTYPE_OPENING_TEMPLATE){
            isPIPTemplateRecordType = true;
        }
        return isPIPTemplateRecordType;
    }

    /**
     * @description This method will check if input record is Opening record or not.
     *
     * @param recordTypeId - Input Record Type id
     * @return Boolean
     */
    public static boolean isOpeningRecordType(Id recordTypeId){
        boolean isOpeningRecordType = false;
        if(AppConstants.taskrayProjectRecordTypeMap != null
                && AppConstants.taskrayProjectRecordTypeMap.get(recordTypeId) != null
                && (AppConstants.taskrayProjectRecordTypeMap.get(recordTypeId)).getDeveloperName()
                == AppConstants.TASKRAY_PROJECT_RECORDTYPE_OPENING){
            isOpeningRecordType = true;
        }
        return isOpeningRecordType;
    }

    /**
     * @description This method will RecordType Name for input record type Id and Object Name
     *
     * @param recordTypeId - Input Record Type id
     * @param sObjectName - sObject Name
     * @return Boolean
     */
    public static String getRecordTypeNameForId(Id recordTypeId, String sObjectName){
        String recordTypeName = '';
        Map<ID, Schema.RecordTypeInfo> recordTypeIdDetails = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosById();

        if(recordTypeIdDetails != null
                && recordTypeIdDetails.get(recordTypeId) != null){
            recordTypeName = (recordTypeIdDetails.get(recordTypeId)).getDeveloperName() ;
        }
        return recordTypeName;
    }

}