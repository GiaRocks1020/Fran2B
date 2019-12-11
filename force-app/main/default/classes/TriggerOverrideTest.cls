/** 
 * @description Test Class for Trigger Override which is included within Trigger framework.
 *
 * @author Zach French
 * @date 2019-12-12
 */
@isTest
public inherited sharing class TriggerOverrideTest {

    static User user;
    static Profile sysAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    public static string sysAdminUsername = 'testuserdeployment2a@slalom.com';

    @TestSetup
    static void dataSetup() {
        user = new User(
            Alias = 'tuser',
            Email='testuser@slalom.com',
            EmailEncodingKey='UTF-8',
            FirstName = 'Test',
            LastName='User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = sysAdmin.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=sysAdminUsername
        );
        insert user;
    }

    static testMethod void overrideAllTest() {
        user = [SELECT Id FROM User WHERE username = :sysAdminUsername LIMIT 1];
        Trigger_Override__c profileOverride = new Trigger_Override__c();
        profileOverride.Enabled__c = true;
        profileOverride.SetupOwnerId = sysAdmin.Id;
        insert profileOverride;

        Trigger_Override__c profileOverride2 = Trigger_Override__c.getInstance(UserInfo.getProfileId());

        Trigger_Override__c userOverride = new Trigger_Override__c();
        userOverride.Enabled__c = true;
        userOverride.Deactivate_All_Triggers__c = true;
        userOverride.SetupOwnerId = user.Id;
        insert userOverride;

        System.runAs(user){
            System.assertEquals(true, TriggerOverride.bypassTrigger(Account.SObjectType));
        }
    }

    static testMethod void overrideNoneTest() {
        user = [SELECT Id FROM User WHERE username = :sysAdminUsername LIMIT 1];
        Trigger_Override__c profileOverride = new Trigger_Override__c();
        profileOverride.Enabled__c = true;
        profileOverride.Deactivate_All_Triggers__c = false;
        profileOverride.SetupOwnerId = sysAdmin.Id;
        insert profileOverride;

        Trigger_Override__c userOverride = new Trigger_Override__c();
        userOverride.Enabled__c = true;
        userOverride.Deactivate_All_Triggers__c = false;
        userOverride.SetupOwnerId = user.Id;
        insert userOverride;

        System.runAs(user){
            System.assertEquals(false,TriggerOverride.bypassTrigger(Account.SObjectType));
        }
    }

    static testMethod void overrideSpecificTest() {
        user = [SELECT Id FROM User WHERE username = :sysAdminUsername LIMIT 1];
        Trigger_Override__c profileOverride = new Trigger_Override__c();
        profileOverride.Enabled__c = true;
        profileOverride.Deactivate_All_Triggers__c = false;
        profileOverride.SetupOwnerId = sysAdmin.Id;
        insert profileOverride;

        Trigger_Override__c userOverride = new Trigger_Override__c();
        userOverride.Enabled__c = true;
        userOverride.Deactivate_All_Triggers__c = false;
        userOverride.SetupOwnerId = user.Id;
        insert userOverride;

        List<Trigger_Override_Object__mdt> triggerOverrideObjectList = new List<Trigger_Override_Object__mdt>
        {CustomMetadataService.getTriggerOverrideObjectRecord('Account',false)};

        System.runAs(user){
            System.assert(TriggerOverride.bypassTrigger(Account.SObjectType, triggerOverrideObjectList));
            System.assert(!TriggerOverride.bypassTrigger(Lead.SObjectType, triggerOverrideObjectList));
        }
    }

    static testMethod void overridedisabledTest() {
        user = [SELECT Id FROM User WHERE username = :sysAdminUsername LIMIT 1];
        Trigger_Override__c profileOverride = new Trigger_Override__c();
        profileOverride.Enabled__c = true;
        profileOverride.Deactivate_All_Triggers__c = false;
        profileOverride.SetupOwnerId = sysAdmin.Id;
        insert profileOverride;

        Trigger_Override__c userOverride = new Trigger_Override__c();
        userOverride.Enabled__c = false;
        userOverride.Deactivate_All_Triggers__c = false;
        userOverride.SetupOwnerId = user.Id;
        insert userOverride;

        System.runAs(user){
            System.assert(!TriggerOverride.bypassTrigger(Account.SObjectType));
        }
    }

    static testMethod void throwErrorTest() {
        user = [SELECT Id FROM User WHERE username = :sysAdminUsername LIMIT 1];
        Trigger_Override__c profileOverride = new Trigger_Override__c();
        profileOverride.Enabled__c = true;
        profileOverride.Deactivate_All_Triggers__c = false;
        profileOverride.SetupOwnerId = sysAdmin.Id;
        insert profileOverride;

        Trigger_Override__c userOverride = new Trigger_Override__c();
        userOverride.Enabled__c = true;
        userOverride.Deactivate_All_Triggers__c = false;
        userOverride.SetupOwnerId = user.Id;
        insert userOverride;

        TriggerOverride.testClassCatchError = true;

        System.runAs(user){
            System.assertEquals(false, TriggerOverride.bypassTrigger(Account.SObjectType));
        }
    }

}