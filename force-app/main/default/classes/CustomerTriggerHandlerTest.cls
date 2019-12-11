@isTest
public class CustomerTriggerHandlerTest {
    
    static TestMethod void createPlatformEventOrInsertCustomObjectRecords_shouldInsertContractChangesforFMSOnInsert(){
        
        Account acc = TestUtil.createAccount('Test Acc');
        insert acc;
        Account acc2 = TestUtil.createAccount('Test Acc2');
        insert acc2;
        Property__c prop = TestUtil.createProperty('Test add', 'McLean', 'US-VA', 'US', '22101');
        insert prop;
        Property_Code_Metadata__c propMet = TestUtil.createPropertyCodeMetadata('TestCodeM','VA', 'US');
        insert propMet;
        Ownership_Group__c og = new Ownership_Group__c ();
        insert og;
        Brand__c brnd = new Brand__c(
        	Name='Test Brand',
         	External_ID__c ='TQEQ2',
            Brand_Code__c ='BRASDF',
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100,
            Status__c ='Active'
        );
        insert brnd;
        Product__c prod = new Product__c(
        	Name = 'Test prod',
            Brand__c = brnd.id,
            External_ID__c ='PR23',
            Status__c ='Active',
            Product_Code__c='PR2QE',
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100
        );
        insert prod;
        Contract__c contr = new Contract__c(
        	Name ='Test Contr',
        	Application_Type__c ='NEWC',
        	Contract_ID__c ='T121',
        	Contract_Status__c ='EXEC',
            Effective_Contract_Flag__c = true,
            Property__c = prop.id,
            Legal_Sec_Name__c = 'TESTl',
            Product__c = prod.id,
            Brand__c = brnd.id
        );
        insert contr;
        Ownership_Relation__c orel = new Ownership_Relation__c(
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100,
            Account__c = acc.id,
            OwnershipGroupId__c = og.id,
            Ownership_Percentage__c = 10.2,
            Relationship_Type__c ='Ownership'
        );
        insert orel;
        Ownership_Relation__c orel2 = new Ownership_Relation__c(
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100,
            Account__c = acc2.id,
            OwnershipGroupId__c = og.id,
            Ownership_Percentage__c = 10.2,
            Relationship_Type__c ='Ownership'
        );
        insert orel2;
        Test.startTest();
        	Customer__c cust = new Customer__c(
                Contract__c = contr.id,
                Legacy_ID__c = 'TE23',
                End_Date__c = system.today()+100,
                Ownership_Group__c = og.id,
                Property__c = prop.id,
                Start_Date__c = system.today(),
                Status__c = 'A'
            );
            insert cust;
        Test.stopTest();
        List<Contract_Changes_for_FMS__c> lstCFMS = new List<Contract_Changes_for_FMS__c>();
        lstCFMS = [select id,Account_SFID__c,Ownership_Relation_SFID__c,Ownership_Group_SFID__c,Contract_SFID__c,Customer_SFID__c,
                   Contract_ID__c,Account_Name__c,Start_Date_Customer__c,End_Date_Customer__c,Start_Date_Ownership_Relation__c,End_Date_Ownership_Relation__c,
                   Ownership_Percentage__c from Contract_Changes_for_FMS__c];
        
        system.assertEquals(2, lstCFMS.size(), 'There should be two elements in the list');
        system.assertEquals(0, CustomerTriggerHandler.insLstPlatEve.size(), 'There should not be any items in the platform events list');
        for(Contract_Changes_for_FMS__c cce : lstCFMS){
            System.assert(cce.Account_SFID__c == acc.id || cce.Account_SFID__c == acc2.id);
            System.assert(cce.Ownership_Relation_SFID__c == orel.id || cce.Ownership_Relation_SFID__c == orel2.id);
            System.assert(cce.Ownership_Group_SFID__c == og.id);
            System.assert(cce.Contract_SFID__c == contr.id);
            System.assert(cce.Customer_SFID__c == cust.id);
            System.assert(cce.Contract_ID__c == contr.Contract_ID__c);
            System.assert(cce.Account_Name__c == acc.name || cce.Account_Name__c == acc2.name);
            System.assert(cce.Start_Date_Customer__c == cust.Start_Date__c);
            System.assert(cce.End_Date_Customer__c == cust.End_Date__c);
            System.assert(cce.Start_Date_Ownership_Relation__c == orel.Start_Date__c);
            System.assert(cce.End_Date_Ownership_Relation__c == orel.End_Date__c);
            System.assert(cce.Ownership_Percentage__c == orel.Ownership_Percentage__c);
        }
    }
    
    static TestMethod void createPlatformEventOrInsertCustomObjectRecords_shouldInsertContractChangesforFMSOnUpdate(){
        Account acc = TestUtil.createAccount('Test Acc');
        insert acc;
        Account acc2 = TestUtil.createAccount('Test Acc2');
        insert acc2;
        Property__c prop = TestUtil.createProperty('Test add', 'McLean', 'US-VA', 'US', '22101');
        insert prop;
        Property_Code_Metadata__c propMet = TestUtil.createPropertyCodeMetadata('TestCodeM','VA', 'US');
        insert propMet;
        Ownership_Group__c og = new Ownership_Group__c ();
        insert og;
        Brand__c brnd = new Brand__c(
        	Name='Test Brand',
         	External_ID__c ='TQEQ2',
            Brand_Code__c ='BRASDF',
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100,
            Status__c ='Active'
        );
        insert brnd;
        Product__c prod = new Product__c(
        	Name = 'Test prod',
            Brand__c = brnd.id,
            External_ID__c ='PR23',
            Status__c ='Active',
            Product_Code__c='PR2QE',
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100
        );
        insert prod;
        Contract__c contr = new Contract__c(
        	Name ='Test Contr',
        	Application_Type__c ='NEWC',
        	Contract_ID__c ='T121',
        	Contract_Status__c ='EXEC',
            Effective_Contract_Flag__c = true,
            Property__c = prop.id,
            Legal_Sec_Name__c = 'TESTl',
            Product__c = prod.id,
            Brand__c = brnd.id
        );
        insert contr;
        Ownership_Relation__c orel = new Ownership_Relation__c(
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100,
            Account__c = acc.id,
            OwnershipGroupId__c = og.id,
            Ownership_Percentage__c = 10.2,
            Relationship_Type__c ='Ownership'
        );
        insert orel;
        Ownership_Relation__c orel2 = new Ownership_Relation__c(
            Start_Date__c = system.today()+2,
            End_Date__c = system.today()+101,
            Account__c = acc2.id,
            OwnershipGroupId__c = og.id,
            Ownership_Percentage__c = 11.2,
            Relationship_Type__c ='Ownership'
        );
        insert orel2;
        Customer__c cust = new Customer__c(
                Contract__c = contr.id,
                Legacy_ID__c = 'TE23',
                End_Date__c = system.today()+100,
                Ownership_Group__c = og.id,
                Property__c = prop.id,
                Start_Date__c = system.today(),
                Status__c = 'A'
            );
        insert cust;
        Test.startTest();
        	update cust;
        Test.stopTest();
        List<Contract_Changes_for_FMS__c> lstCFMS = new List<Contract_Changes_for_FMS__c>();
        lstCFMS = [select id,Account_SFID__c,Ownership_Relation_SFID__c,Ownership_Group_SFID__c,Contract_SFID__c,Customer_SFID__c,
                   Contract_ID__c,Account_Name__c,Start_Date_Customer__c,End_Date_Customer__c,Start_Date_Ownership_Relation__c,End_Date_Ownership_Relation__c,
                   Ownership_Percentage__c from Contract_Changes_for_FMS__c];
        system.assertEquals(4, lstCFMS.size(), 'There should be 4 records in Contract_Changes_for_FMS__c,2 for insert, 2 for update');
        system.assertEquals(0, CustomerTriggerHandler.insLstPlatEve.size(), 'There should not be any items in the platform events list');
        
        for(Contract_Changes_for_FMS__c cce : lstCFMS){
            System.assert(cce.Account_SFID__c == acc.id || cce.Account_SFID__c == acc2.id);
            System.assert(cce.Ownership_Relation_SFID__c == orel.id || cce.Ownership_Relation_SFID__c == orel2.id);
            System.assert(cce.Ownership_Group_SFID__c == og.id);
            System.assert(cce.Contract_SFID__c == contr.id);
            System.assert(cce.Customer_SFID__c == cust.id);
            System.assert(cce.Contract_ID__c == contr.Contract_ID__c);
            System.assert(cce.Account_Name__c == acc.name || cce.Account_Name__c == acc2.name);
            System.assert(cce.Start_Date_Customer__c == cust.Start_Date__c);
            System.assert(cce.End_Date_Customer__c == cust.End_Date__c);
            System.assert(cce.Start_Date_Ownership_Relation__c == orel.Start_Date__c || cce.Start_Date_Ownership_Relation__c == orel2.Start_Date__c);
            System.assert(cce.End_Date_Ownership_Relation__c == orel.End_Date__c || cce.End_Date_Ownership_Relation__c == orel2.End_Date__c);
            System.assert(cce.Ownership_Percentage__c == orel.Ownership_Percentage__c || cce.Ownership_Percentage__c == orel2.Ownership_Percentage__c);
        }
    }
    
    static TestMethod void createPlatformEventOrInsertCustomObjectRecords_shouldPublishPlatformEventsOnInsert(){
        
        Account acc = TestUtil.createAccount('Test Acc');
        insert acc;
        Account acc2 = TestUtil.createAccount('Test Acc2');
        insert acc2;
        Property__c prop = TestUtil.createProperty('Test add', 'McLean', 'US-VA', 'US', '22101');
        insert prop;
        Property_Code_Metadata__c propMet = TestUtil.createPropertyCodeMetadata('TestCodeM','VA', 'US');
        insert propMet;
        Ownership_Group__c og = new Ownership_Group__c ();
        insert og;
        Brand__c brnd = new Brand__c(
        	Name='Test Brand',
         	External_ID__c ='TQEQ2',
            Brand_Code__c ='BRASDF',
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100,
            Status__c ='Active'
        );
        insert brnd;
        Product__c prod = new Product__c(
        	Name = 'Test prod',
            Brand__c = brnd.id,
            External_ID__c ='PR23',
            Status__c ='Active',
            Product_Code__c='PR2QE',
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100
        );
        insert prod;
        Contract__c contr = new Contract__c(
        	Name ='Test Contr',
        	Application_Type__c ='NEWC',
        	Contract_ID__c ='T121',
        	Contract_Status__c ='EXEC',
            Effective_Contract_Flag__c = true,
            Property__c = prop.id,
            Legal_Sec_Name__c = 'TESTl',
            Product__c = prod.id,
            Brand__c = brnd.id
        );
        insert contr;
        Ownership_Relation__c orel = new Ownership_Relation__c(
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100,
            Account__c = acc.id,
            OwnershipGroupId__c = og.id,
            Ownership_Percentage__c = 10.2,
            Relationship_Type__c ='Ownership'
        );
        insert orel;
        Ownership_Relation__c orel2 = new Ownership_Relation__c(
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100,
            Account__c = acc2.id,
            OwnershipGroupId__c = og.id,
            Ownership_Percentage__c = 10.2,
            Relationship_Type__c ='Ownership'
        );
        insert orel2;
        Test.startTest();
        	insert new Metadata_Control__c (SetupOwnerId=UserInfo.getOrganizationId(), Switch_to_Platf_Events_Contract_Changes__c = true);
        	Customer__c cust = new Customer__c(
                Contract__c = contr.id,
                Legacy_ID__c = 'TE23',
                End_Date__c = system.today()+100,
                Ownership_Group__c = og.id,
                Property__c = prop.id,
                Start_Date__c = system.today(),
                Status__c = 'A'
            );
            insert cust;
        Test.stopTest();
        system.assertEquals(2, CustomerTriggerHandler.insLstPlatEve.size(), 'There should be two elements in the platform events list');
        List<Contract_Changes_for_FMS__c> lstCFMS = new List<Contract_Changes_for_FMS__c>();
        lstCFMS = [select id,Account_SFID__c,Ownership_Relation_SFID__c,Ownership_Group_SFID__c,Contract_SFID__c,Customer_SFID__c,
                   Contract_ID__c,Account_Name__c,Start_Date_Customer__c,End_Date_Customer__c,Start_Date_Ownership_Relation__c,End_Date_Ownership_Relation__c,
                   Ownership_Percentage__c from Contract_Changes_for_FMS__c];
        system.assertEquals(0, lstCFMS.size(), 'There should not be any records inserted in Contract_Changes_for_FMS__c');
        
        for(Contract_Changes__e cce : CustomerTriggerHandler.insLstPlatEve){
            System.assert(cce.Account_SFID__c == acc.id || cce.Account_SFID__c == acc2.id);
            System.assert(cce.Ownership_Relation_SFID__c == orel.id || cce.Ownership_Relation_SFID__c == orel2.id);
            System.assert(cce.Ownership_Group_SFID__c == og.id);
            System.assert(cce.Contract_SFID__c == contr.id);
            System.assert(cce.Customer_SFID__c == cust.id);
            System.assert(cce.Contract_ID__c == contr.Contract_ID__c);
            System.assert(cce.Account_Name__c == acc.name || cce.Account_Name__c == acc2.name);
            System.assert(cce.Start_Date_Customer__c == cust.Start_Date__c);
            System.assert(cce.End_Date_Customer__c == cust.End_Date__c);
            System.assert(cce.Start_Date_Ownership_Relation__c == orel.Start_Date__c);
            System.assert(cce.End_Date_Ownership_Relation__c == orel.End_Date__c);
            System.assert(cce.Ownership_Percentage__c == orel.Ownership_Percentage__c);
        }
    }
    
    static TestMethod void createPlatformEventOrInsertCustomObjectRecords_shouldPublishPlatformEventsOnUpdate(){
        Account acc = TestUtil.createAccount('Test Acc');
        insert acc;
        Account acc2 = TestUtil.createAccount('Test Acc2');
        insert acc2;
        Property__c prop = TestUtil.createProperty('Test add', 'McLean', 'US-VA', 'US', '22101');
        insert prop;
        Property_Code_Metadata__c propMet = TestUtil.createPropertyCodeMetadata('TestCodeM','VA', 'US');
        insert propMet;
        Ownership_Group__c og = new Ownership_Group__c ();
        insert og;
        Brand__c brnd = new Brand__c(
        	Name='Test Brand',
         	External_ID__c ='TQEQ2',
            Brand_Code__c ='BRASDF',
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100,
            Status__c ='Active'
        );
        insert brnd;
        Product__c prod = new Product__c(
        	Name = 'Test prod',
            Brand__c = brnd.id,
            External_ID__c ='PR23',
            Status__c ='Active',
            Product_Code__c='PR2QE',
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100
        );
        insert prod;
        Contract__c contr = new Contract__c(
        	Name ='Test Contr',
        	Application_Type__c ='NEWC',
        	Contract_ID__c ='T121',
        	Contract_Status__c ='EXEC',
            Effective_Contract_Flag__c = true,
            Property__c = prop.id,
            Legal_Sec_Name__c = 'TESTl',
            Product__c = prod.id,
            Brand__c = brnd.id
        );
        insert contr;
        Ownership_Relation__c orel = new Ownership_Relation__c(
            Start_Date__c = system.today(),
            End_Date__c = system.today()+100,
            Account__c = acc.id,
            OwnershipGroupId__c = og.id,
            Ownership_Percentage__c = 10.2,
            Relationship_Type__c ='Ownership'
        );
        insert orel;
        Ownership_Relation__c orel2 = new Ownership_Relation__c(
            Start_Date__c = system.today()+2,
            End_Date__c = system.today()+101,
            Account__c = acc2.id,
            OwnershipGroupId__c = og.id,
            Ownership_Percentage__c = 11.2,
            Relationship_Type__c ='Ownership'
        );
        insert orel2;
        insert new Metadata_Control__c (SetupOwnerId=UserInfo.getOrganizationId(), Switch_to_Platf_Events_Contract_Changes__c = true);
        Customer__c cust = new Customer__c(
                Contract__c = contr.id,
                Legacy_ID__c = 'TE23',
                End_Date__c = system.today()+100,
                Ownership_Group__c = og.id,
                Property__c = prop.id,
                Start_Date__c = system.today(),
                Status__c = 'A'
            );
        insert cust;
        Test.startTest();
        	update cust;
        Test.stopTest();
        system.assertEquals(2, CustomerTriggerHandler.insLstPlatEve.size(), 'There should be 2 elements in the list');
        List<Contract_Changes_for_FMS__c> lstCFMS = new List<Contract_Changes_for_FMS__c>();
        lstCFMS = [select id,Account_SFID__c,Ownership_Relation_SFID__c,Ownership_Group_SFID__c,Contract_SFID__c,Customer_SFID__c,
                   Contract_ID__c,Account_Name__c,Start_Date_Customer__c,End_Date_Customer__c,Start_Date_Ownership_Relation__c,End_Date_Ownership_Relation__c,
                   Ownership_Percentage__c from Contract_Changes_for_FMS__c];
        system.assertEquals(0, lstCFMS.size(), 'There should not be any records inserted in Contract_Changes_for_FMS__c');
        for(Contract_Changes__e cce : CustomerTriggerHandler.insLstPlatEve){
            System.assert(cce.Account_SFID__c == acc.id || cce.Account_SFID__c == acc2.id);
            System.assert(cce.Ownership_Relation_SFID__c == orel.id || cce.Ownership_Relation_SFID__c == orel2.id);
            System.assert(cce.Ownership_Group_SFID__c == og.id);
            System.assert(cce.Contract_SFID__c == contr.id);
            System.assert(cce.Customer_SFID__c == cust.id);
            System.assert(cce.Contract_ID__c == contr.Contract_ID__c);
            System.assert(cce.Account_Name__c == acc.name || cce.Account_Name__c == acc2.name);
            System.assert(cce.Start_Date_Customer__c == cust.Start_Date__c);
            System.assert(cce.End_Date_Customer__c == cust.End_Date__c);
            System.assert(cce.Start_Date_Ownership_Relation__c == orel.Start_Date__c || cce.Start_Date_Ownership_Relation__c == orel2.Start_Date__c);
            System.assert(cce.End_Date_Ownership_Relation__c == orel.End_Date__c || cce.End_Date_Ownership_Relation__c == orel2.End_Date__c);
            System.assert(cce.Ownership_Percentage__c == orel.Ownership_Percentage__c || cce.Ownership_Percentage__c == orel2.Ownership_Percentage__c);
        }
        //to cover the trigger executor
        delete cust;
        delete orel;
    }
}