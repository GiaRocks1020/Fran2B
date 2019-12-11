/**
 * @description Test class for PIPItemStatusUpdateToPastDueScheduler
 *
 * @author Sugu Chugh
 * @date 2019-09-13
 */

@IsTest
private class PIPItemStatusUpdateToPastDueSchdlerTest {
    public static testMethod void testSchedule() {
        Test.startTest();
        PIPItemStatusUpdateToPastDueScheduler testScheduler = new PIPItemStatusUpdateToPastDueScheduler();
        String CRON_EXP = '0 0 0 15 3 ? *';
        String jobId = System.schedule('Test status Check', CRON_EXP, testScheduler);
        CronTrigger ct = [SELECT Id , CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(CRON_EXP,ct.CronExpression);
        Test.stopTest();
    }
}