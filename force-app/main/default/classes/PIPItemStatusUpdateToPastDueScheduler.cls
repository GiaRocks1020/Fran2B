/**
 * @description Scheduler class for PIPItemStatusUpdateToPastDueBatch
 *
 * @author Sugu Chugh
 * @date 2019-09-13
 */

global class PIPItemStatusUpdateToPastDueScheduler implements Schedulable{
    global void execute(SchedulableContext SC){
        PIPItemStatusUpdateToPastDueBatch PIPItemStatusUpdateBatch = new PIPItemStatusUpdateToPastDueBatch();
        Database.executeBatch(PIPItemStatusUpdateBatch);
    }
}