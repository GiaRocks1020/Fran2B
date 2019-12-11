public class HistoryTrackerBackupSchedule implements Schedulable  {
   	public void execute(SchedulableContext sc) {
    	HistoryTrackerBackupBatch historyBatch = new HistoryTrackerBackupBatch();
		database.executeBatch(historyBatch);
	}
}