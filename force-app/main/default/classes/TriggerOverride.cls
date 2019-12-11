/**
 * @description: Used to override triggers and disable as needed. Trigger override functionality
 * should be added to all new and existing triggers.
 *
 * @author: Zach French
 * @date: 11/20/2018
 */

public class TriggerOverride {

    // Used to contain trigger names which should be disabled
    private static Set<String> disabledTriggerNames;
    @testVisible private static Boolean testClassCatchError = false;

    /**
     * @description: Used to determine if a trigger will execute
     *
     * @param: sObjectTypeValue - Specifies the Object Type (e.g., account)
     * @param: triggerOverrideObjects - List of Trigger_Override_Object__mdt for test classes
     * @return: Boolean value returned which determines if trigger will execute. If trigger contains 'all' or
     * specific trigger name in disabled trigger it will return false and trigger will not execute. If true, trigger
     * will continue to execute.
     **/
    public static Boolean bypassTrigger(SObjectType sObjectTypeValue) {
        return bypassTriggerLogic(sObjectTypeValue, new list<Trigger_Override_Object__mdt>());
    }

    public static Boolean bypassTrigger(SObjectType sObjectTypeValue, List<Trigger_Override_Object__mdt>
        triggerOverrideObjects) {
        return bypassTriggerLogic(sObjectTypeValue, triggerOverrideObjects);
    }

    private static Boolean bypassTriggerLogic(SObjectType sObjectTypeValue, List<Trigger_Override_Object__mdt>
        triggerOverrideObjects) {
        try{
            if(disabledTriggerNames == null){
                setOverrideSettings(triggerOverrideObjects);
            }

            // Used to enter catch clause
            if(testClassCatchError){
                TypeException e = new TypeException();
                e.setMessage('Test Class Error Message');
                throw e;
            }

            // @return TRUE, stops execution of trigger.
            // @return FALSE, allow execution of trigger.
            return !( !disabledTriggerNames.contains('all') && !disabledTriggerNames.contains(String.valueOf
                (sObjectTypeValue).toLowerCase()) );

        } catch(Exception e) { system.debug('Error: ' + e + ' - lineNumber: ' +e.getLineNumber() + ' - Cause:' + e
            .getCause()); }

        // Trigger will execute if line is reached
        return false;
    }

    /**
     * @description: Used to check TriggerOverride custom settings and determines whether a trigger is overridden
     *
     * @param: triggerOverrideObjects - List of Trigger_Override_Object__mdt for test classes
     * @return: N/A
     **/
    private static void setOverrideSettings(List<Trigger_Override_Object__mdt> triggerOverrideObjects) {
        disabledTriggerNames = new Set<String>();

        // Obtain profile and user override records, if available
        Trigger_Override__c profileOverride = Trigger_Override__c.getInstance(UserInfo.getProfileId());
        Trigger_Override__c userOverride = Trigger_Override__c.getInstance(UserInfo.getUserId());

        Boolean profileOverrideEnabled = profileOverride != null && profileOverride.Id != null && profileOverride
            .Enabled__c ? true : false;
        Boolean userOverrideEnabled = userOverride != null && userOverride.Id != null && userOverride.Enabled__c ?
            true : false;

        if(profileOverrideEnabled || userOverrideEnabled) {

            // User setting will supercede profile setting, default value: false
            Boolean deactivateAllTriggers = userOverrideEnabled && userOverride.Enabled__c ? userOverride
                .Deactivate_All_Triggers__c : profileOverrideEnabled && profileOverride.Enabled__c ? profileOverride
                .Deactivate_All_Triggers__c : false;

            if(deactivateAllTriggers){
                disabledTriggerNames.add('all');
            } else {
                List<Trigger_Override_Object__mdt> triggerOverrideObjectRecords = Test.isRunningTest() ?
                    triggerOverrideObjects : [SELECT ID, MasterLabel, Active__c FROM Trigger_Override_Object__mdt];

                if(triggerOverrideObjectRecords.size() > 0 && !triggerOverrideObjectRecords.isEmpty()) {

                    for(Trigger_Override_Object__mdt triggerOverrideObject : triggerOverrideObjectRecords) {

                        if(!triggerOverrideObject.Active__c) {
                            disabledTriggerNames.add(String.valueOf(triggerOverrideObject.MasterLabel).toLowerCase());
                        }
                    }
                }
            }
        }
    }

}