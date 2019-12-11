/** 
 * @description Mock class used to specify for the Trigger Override custom metadata type
 *
 * @author Zach French
 * @date 2019-12-12
 */
public class CustomMetadataService {

    /**
     * This method instantiates a custom metadata record of type Trigger_Override_Object__mdt
     * and sets the DeveloperName to objectAPIName
     * Note that the record is not inserted into the database,
     * and would not be found by a SOQL query.
     */
    public static Trigger_Override_Object__mdt getTriggerOverrideObjectRecord(String objectAPIName, Boolean active) {
        Trigger_Override_Object__mdt triggerOverrideRecord = new Trigger_Override_Object__mdt();
        triggerOverrideRecord.DeveloperName = objectAPIName;
        triggerOverrideRecord.MasterLabel = objectAPIName;
        triggerOverrideRecord.Active__c = active;
        return triggerOverrideRecord;
    }
}