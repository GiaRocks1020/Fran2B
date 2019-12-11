@isTest
public class HistoryTracker_Test {
    @TestSetup
    static void testDataSetup(){
	 TaskRay__Project__c prj = TestDataFactory.createPIP(true); 
     prj.TASKRAY__trStatus__c = 'Requested';
     prj.Sub_Status__c = 'Pending Approval';
     update prj;
    }
     static TestMethod void testcreateHistoryTrackerRecords(){
        TaskRay__Project__c prj = [Select id from TaskRay__Project__c limit 1]; 
        Test.startTest();
     	update prj;
        Test.stopTest(); 
        List<History_Tracker__c> listHistRec = [Select id from History_Tracker__c where parentId__c =: prj.id];
        System.assert(listHistRec.size()>0,'History Records are not created.');
     }
    static TestMethod void testCreateFromHistoryRecs(){
	 	TaskRay__Project__c prj = TestDataFactory.createPIP(true); 
        prj.Sub_Status__c = '';
        Insert new TaskRay__Project__History(parentid=prj.id,field='Sub_Status__c');   
		HistoryTrackerBackupBatch historyBatch = new HistoryTrackerBackupBatch();
    	database.executeBatch(historyBatch);        
        Test.startTest();
     	update prj;
        Test.stopTest(); 
        System.debug([Select id, NewValue, Oldvalue,  CreatedDate, CreatedById,Field,ParentId from TASKRAY__Project__History Where CreatedDate = Today]);
        
        List<History_Tracker__c> listHistRec = [Select id from History_Tracker__c where parentId__c =: prj.id];
        System.assert(listHistRec.size()>0,'History Records are not created.');
     }
    static TestMethod void testHistorySchedule(){
	 	TaskRay__Project__c prj = TestDataFactory.createPIP(true); 
        prj.Sub_Status__c = '';
        Insert new TaskRay__Project__History(parentid=prj.id,field='Sub_Status__c');           
        Test.startTest();
        //Job runs ar 5AM every Day
        String sch = '0 0 5 ? * * *';
		  String jobID = system.schedule('History Schedule Job', sch, new HistoryTrackerBackupSchedule());
        System.assert(jobID != null, 'Unable to schedule History Tacker Backup Schedule Job.');
        Test.stopTest(); 
     }
    
}