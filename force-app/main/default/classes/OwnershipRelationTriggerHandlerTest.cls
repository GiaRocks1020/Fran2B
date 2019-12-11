@isTest
public class OwnershipRelationTriggerHandlerTest {
    
    static TestMethod void createPlatformEventOrInsertCustomObjectRecords_shouldInsertCustomObjectRecords_OnInsert(){
        Account acc = TestUtil.createAccount('Test Acc');
        insert acc;
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
        Contract__c contr2 = new Contract__c(
            Name ='Test Contr2',
            Application_Type__c ='NEWC',
            Contract_ID__c ='T121a',
            Contract_Status__c ='EXEC',
            Effective_Contract_Flag__c = true,
            Property__c = prop.id,
            Legal_Sec_Name__c = 'TESTla',
            Product__c = prod.id,
            Brand__c = brnd.id
        );
        insert contr2;
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
        Customer__c cust2 = new Customer__c(
                Contract__c = contr.id,
                Legacy_ID__c = 'TE23a',
                End_Date__c = system.today()+100,
                Ownership_Group__c = og.id,
                Property__c = prop.id,
                Start_Date__c = system.today(),
                Status__c = 'A'
        );
        insert cust2;
        Test.startTest();
        	Ownership_Relation__c orel = new Ownership_Relation__c(
                Start_Date__c = system.today(),
                End_Date__c = system.today()+100,
                Account__c = acc.id,
                OwnershipGroupId__c = og.id,
                Ownership_Percentage__c = 10.2,
                Relationship_Type__c ='Ownership'
            );
            insert orel;
           
        Test.stopTest();
        List<Contract_Changes_for_FMS__c> lstCFMS = new List<Contract_Changes_for_FMS__c>();
        lstCFMS = [select id,Account_SFID__c,Ownership_Relation_SFID__c,Ownership_Group_SFID__c,Contract_SFID__c,Customer_SFID__c,
                   Contract_ID__c,Account_Name__c,Start_Date_Customer__c,End_Date_Customer__c,Start_Date_Ownership_Relation__c,End_Date_Ownership_Relation__c,
                   Ownership_Percentage__c from Contract_Changes_for_FMS__c];
        
        system.assertEquals(2, lstCFMS.size(), 'There should be 2 elements in the list');
        system.assertEquals(0, CustomerTriggerHandler.insLstPlatEve.size(), 'There should not be any items in the platform events list');
        for(Contract_Changes_for_FMS__c cce : lstCFMS){
            System.assert(cce.Account_SFID__c == acc.id);
            System.assert(cce.Ownership_Relation_SFID__c == orel.id);
            System.assert(cce.Ownership_Group_SFID__c == og.id);
            System.assert(cce.Contract_SFID__c == contr.id || cce.Contract_SFID__c == contr2.id);
            System.assert(cce.Customer_SFID__c == cust.id || cce.Customer_SFID__c == cust2.id);
            System.assert(cce.Contract_ID__c == contr.Contract_ID__c || cce.Contract_ID__c == contr2.Contract_ID__c);
            System.assert(cce.Account_Name__c == acc.name);
            System.assert(cce.Start_Date_Customer__c == cust.Start_Date__c || cce.Start_Date_Customer__c == cust2.Start_Date__c);
            System.assert(cce.End_Date_Customer__c == cust.End_Date__c || cce.End_Date_Customer__c == cust2.End_Date__c);
            System.assert(cce.Start_Date_Ownership_Relation__c == orel.Start_Date__c);
            System.assert(cce.End_Date_Ownership_Relation__c == orel.End_Date__c);
            System.assert(cce.Ownership_Percentage__c == orel.Ownership_Percentage__c);
        }
    }
    
    static TestMethod void createPlatformEventOrInsertCustomObjectRecords_shouldInsertCustomObjectRecords_OnUpdate(){
        Account acc = TestUtil.createAccount('Test Acc');
        insert acc;
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
        Contract__c contr2 = new Contract__c(
            Name ='Test Contr2',
            Application_Type__c ='NEWC',
            Contract_ID__c ='T121a',
            Contract_Status__c ='EXEC',
            Effective_Contract_Flag__c = true,
            Property__c = prop.id,
            Legal_Sec_Name__c = 'TESTla',
            Product__c = prod.id,
            Brand__c = brnd.id
        );
        insert contr2;
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
        Customer__c cust2 = new Customer__c(
                Contract__c = contr.id,
                Legacy_ID__c = 'TE23a',
                End_Date__c = system.today()+110,
                Ownership_Group__c = og.id,
                Property__c = prop.id,
                Start_Date__c = system.today()+2,
                Status__c = 'A'
        );
        insert cust2;
        Ownership_Relation__c orel = new Ownership_Relation__c(
                Start_Date__c = system.today(),
                End_Date__c = system.today()+100,
                Account__c = acc.id,
                OwnershipGroupId__c = og.id,
                Ownership_Percentage__c = 10.2,
                Relationship_Type__c ='Ownership'
            );
        insert orel;
        Test.startTest();
        	update orel;
        Test.stopTest();
        List<Contract_Changes_for_FMS__c> lstCFMS = new List<Contract_Changes_for_FMS__c>();
        lstCFMS = [select id,Account_SFID__c,Ownership_Relation_SFID__c,Ownership_Group_SFID__c,Contract_SFID__c,Customer_SFID__c,
                   Contract_ID__c,Account_Name__c,Start_Date_Customer__c,End_Date_Customer__c,Start_Date_Ownership_Relation__c,End_Date_Ownership_Relation__c,
                   Ownership_Percentage__c from Contract_Changes_for_FMS__c];
        system.assertEquals(4, lstCFMS.size(), 'There should be 4 records in Contract_Changes_for_FMS__c object,2 for insert, 2 for update');
        system.assertEquals(0, CustomerTriggerHandler.insLstPlatEve.size(), 'There should not be any items in the platform events list');
        for(Contract_Changes_for_FMS__c cce : lstCFMS){
            System.assert(cce.Account_SFID__c == acc.id);
            System.assert(cce.Ownership_Relation_SFID__c == orel.id);
            System.assert(cce.Ownership_Group_SFID__c == og.id);
            System.assert(cce.Contract_SFID__c == contr.id || cce.Contract_SFID__c == contr2.id);
            System.assert(cce.Customer_SFID__c == cust.id || cce.Customer_SFID__c == cust2.id);
            System.assert(cce.Contract_ID__c == contr.Contract_ID__c || cce.Contract_ID__c == contr2.Contract_ID__c);
            System.assert(cce.Account_Name__c == acc.name);
            System.assert(cce.Start_Date_Customer__c == cust.Start_Date__c || cce.Start_Date_Customer__c == cust2.Start_Date__c);
            System.assert(cce.End_Date_Customer__c == cust.End_Date__c || cce.End_Date_Customer__c == cust2.End_Date__c);
            System.assert(cce.Start_Date_Ownership_Relation__c == orel.Start_Date__c);
            System.assert(cce.End_Date_Ownership_Relation__c == orel.End_Date__c);
            System.assert(cce.Ownership_Percentage__c == orel.Ownership_Percentage__c);
        }
    }
    
    static TestMethod void createPlatformEventOrInsertCustomObjectRecords_shouldPublishPlatformEvents_OnInsert(){
        Account acc = TestUtil.createAccount('Test Acc');
        insert acc;
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
        Contract__c contr2 = new Contract__c(
            Name ='Test Contr2',
            Application_Type__c ='NEWC',
            Contract_ID__c ='T121a',
            Contract_Status__c ='EXEC',
            Effective_Contract_Flag__c = true,
            Property__c = prop.id,
            Legal_Sec_Name__c = 'TESTla',
            Product__c = prod.id,
            Brand__c = brnd.id
        );
        insert contr2;
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
        Customer__c cust2 = new Customer__c(
                Contract__c = contr.id,
                Legacy_ID__c = 'TE23a',
                End_Date__c = system.today()+100,
                Ownership_Group__c = og.id,
                Property__c = prop.id,
                Start_Date__c = system.today(),
                Status__c = 'A'
        );
        insert cust2;
        Test.startTest();
        	insert new Metadata_Control__c (SetupOwnerId=UserInfo.getOrganizationId(), Switch_to_Platf_Events_Contract_Changes__c = true);
            Ownership_Relation__c orel = new Ownership_Relation__c(
                Start_Date__c = system.today(),
                End_Date__c = system.today()+100,
                Account__c = acc.id,
                OwnershipGroupId__c = og.id,
                Ownership_Percentage__c = 10.2,
                Relationship_Type__c ='Ownership'
            );
            insert orel;
           
        Test.stopTest();
        system.assertEquals(2, OwnershipRelationTriggerHandler.insLstPlatEve.size(), 'There should be two elements in the platform event list');
        List<Contract_Changes_for_FMS__c> lstCFMS = new List<Contract_Changes_for_FMS__c>();
        lstCFMS = [select id,Account_SFID__c,Ownership_Relation_SFID__c,Ownership_Group_SFID__c,Contract_SFID__c,Customer_SFID__c,
                   Contract_ID__c,Account_Name__c,Start_Date_Customer__c,End_Date_Customer__c,Start_Date_Ownership_Relation__c,End_Date_Ownership_Relation__c,
                   Ownership_Percentage__c from Contract_Changes_for_FMS__c];
        system.assertEquals(0, lstCFMS.size(), 'There should not be any records inserted in Contract_Changes_for_FMS__c');
        
        for(Contract_Changes__e cce : OwnershipRelationTriggerHandler.insLstPlatEve){
            System.assert(cce.Account_SFID__c == acc.id);
            System.assert(cce.Ownership_Relation_SFID__c == orel.id);
            System.assert(cce.Ownership_Group_SFID__c == og.id);
            System.assert(cce.Contract_SFID__c == contr.id || cce.Contract_SFID__c == contr2.id);
            System.assert(cce.Customer_SFID__c == cust.id || cce.Customer_SFID__c == cust2.id);
            System.assert(cce.Contract_ID__c == contr.Contract_ID__c || cce.Contract_ID__c == contr2.Contract_ID__c);
            System.assert(cce.Account_Name__c == acc.name);
            System.assert(cce.Start_Date_Customer__c == cust.Start_Date__c || cce.Start_Date_Customer__c == cust2.Start_Date__c);
            System.assert(cce.End_Date_Customer__c == cust.End_Date__c || cce.End_Date_Customer__c == cust2.End_Date__c);
            System.assert(cce.Start_Date_Ownership_Relation__c == orel.Start_Date__c);
            System.assert(cce.End_Date_Ownership_Relation__c == orel.End_Date__c);
            System.assert(cce.Ownership_Percentage__c == orel.Ownership_Percentage__c);
        }
    }
    
    static TestMethod void createPlatformEventOrInsertCustomObjectRecords_shouldPublishPlatformEvents_OnUpdate(){
        Account acc = TestUtil.createAccount('Test Acc');
        insert acc;
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
        Contract__c contr2 = new Contract__c(
            Name ='Test Contr2',
            Application_Type__c ='NEWC',
            Contract_ID__c ='T121a',
            Contract_Status__c ='EXEC',
            Effective_Contract_Flag__c = true,
            Property__c = prop.id,
            Legal_Sec_Name__c = 'TESTla',
            Product__c = prod.id,
            Brand__c = brnd.id
        );
        insert contr2;
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
        Customer__c cust2 = new Customer__c(
                Contract__c = contr.id,
                Legacy_ID__c = 'TE23a',
                End_Date__c = system.today()+110,
                Ownership_Group__c = og.id,
                Property__c = prop.id,
                Start_Date__c = system.today()+2,
                Status__c = 'A'
        );
        insert cust2;
        insert new Metadata_Control__c (SetupOwnerId=UserInfo.getOrganizationId(), Switch_to_Platf_Events_Contract_Changes__c = true);
        Ownership_Relation__c orel = new Ownership_Relation__c(
                Start_Date__c = system.today(),
                End_Date__c = system.today()+100,
                Account__c = acc.id,
                OwnershipGroupId__c = og.id,
                Ownership_Percentage__c = 10.2,
                Relationship_Type__c ='Ownership'
        );
        insert orel;
        Test.startTest();
        	update orel;
        Test.stopTest();
        system.assertEquals(2, OwnershipRelationTriggerHandler.insLstPlatEve.size(), 'There should be 2 elements in the platform event list');
        List<Contract_Changes_for_FMS__c> lstCFMS = new List<Contract_Changes_for_FMS__c>();
        lstCFMS = [select id,Account_SFID__c,Ownership_Relation_SFID__c,Ownership_Group_SFID__c,Contract_SFID__c,Customer_SFID__c,
                   Contract_ID__c,Account_Name__c,Start_Date_Customer__c,End_Date_Customer__c,Start_Date_Ownership_Relation__c,End_Date_Ownership_Relation__c,
                   Ownership_Percentage__c from Contract_Changes_for_FMS__c];
        system.assertEquals(0, lstCFMS.size(), 'There should not be any records inserted in Contract_Changes_for_FMS__c');
        
        for(Contract_Changes__e cce : OwnershipRelationTriggerHandler.insLstPlatEve){
            System.assert(cce.Account_SFID__c == acc.id);
            System.assert(cce.Ownership_Relation_SFID__c == orel.id);
            System.assert(cce.Ownership_Group_SFID__c == og.id);
            System.assert(cce.Contract_SFID__c == contr.id || cce.Contract_SFID__c == contr2.id);
            System.assert(cce.Customer_SFID__c == cust.id || cce.Customer_SFID__c == cust2.id);
            System.assert(cce.Contract_ID__c == contr.Contract_ID__c || cce.Contract_ID__c == contr2.Contract_ID__c);
            System.assert(cce.Account_Name__c == acc.name);
            System.assert(cce.Start_Date_Customer__c == cust.Start_Date__c || cce.Start_Date_Customer__c == cust2.Start_Date__c);
            System.assert(cce.End_Date_Customer__c == cust.End_Date__c || cce.End_Date_Customer__c == cust2.End_Date__c);
            System.assert(cce.Start_Date_Ownership_Relation__c == orel.Start_Date__c);
            System.assert(cce.End_Date_Ownership_Relation__c == orel.End_Date__c);
            System.assert(cce.Ownership_Percentage__c == orel.Ownership_Percentage__c);
        }
    }
}