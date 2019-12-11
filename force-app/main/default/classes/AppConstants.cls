/**
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
public class AppConstants {

    public static final String QUALIFIED_API_NAME_ATTRIBUTE = 'QualifiedApiName';
    public static final String FULL_NAME_ATTRIBUTE = 'FullName';
    public static final String LABEL_ATTRIBUTE = 'Label';
    public static final String DEV_NAME_ATTRIBUTE = 'DeveloperName';
    public static final String DESC_ATTRIBUTE = 'Description';
    public static final String MDT_SUFFIX = '__mdt';
    
    public static final String CS_NAME_ATTRIBUTE = 'Name';
    public static final String SELECT_STRING = 'Select type';
    
    public static final String HEADER_MISSING_DEVNAME_AND_LABEL = 'Header must contain atleast one of these two fields - '+ DEV_NAME_ATTRIBUTE + ', ' + LABEL_ATTRIBUTE +'.';

    // Do not change value for ERROR_UNAUTHORIZED_ENDPOINT
 	public static final String ERROR_UNAUTHORIZED_ENDPOINT	= 'Unauthorized endpoint, please check Setup';

    public static final String COST_UNIT_PER_BUILDING = 'Per Building';
    public static final String COST_UNIT_PER_ROOM = 'Per Room';
    public static final Integer PER_BUILDING_QUANTITY = 1;

    public static final Integer ZERO_INDEX = 0;
    public static final String TASKRAY_PROJECT_RECORDTYPE_PIP = StaticValue.getStaticValueText
            ('TASKRAY_Project_RECORD_TYPE_PIP');
    public static final String TASKRAY_PROJECT_RECORDTYPE_PIP_TEMPLATE = StaticValue.getStaticValueText
            ('TASKRAY_Project_RECORD_TYPE_PIP_Template');
    public static final String TASKRAY_PROJECT_RECORDTYPE_OPENING_TEMPLATE = StaticValue.getStaticValueText
            ('TASKRAY_Project_RECTYPE_Opening_Template');
    public static final String TASKRAY_PROJECT_RECORDTYPE_OPENING = StaticValue.getStaticValueText
            ('TASKRAY_Project_RECORD_TYPE_Opening');
    public static final String TASKRAY_TASK_RECORDTYPE_PIP_ITEM = StaticValue.getStaticValueText
            ('TASKRAY_Task_RECORD_TYPE_PIP_Item');
    public static final String TASKRAY_TASK_RECORDTYPE_MILESTONE = StaticValue.getStaticValueText
            ('TASKRAY_Task_RECORD_TYPE_Milestone');

    public static final Map<ID, Schema.RecordTypeInfo> taskrayProjectRecordTypeMap =
            Schema.SObjectType.TASKRAY__Project__c.getRecordTypeInfosById();

    public static final Map<ID, Schema.RecordTypeInfo> taskrayTaskRecordTypeMap =
            Schema.SObjectType.TASKRAY__Project_Task__c.getRecordTypeInfosById();
            
}