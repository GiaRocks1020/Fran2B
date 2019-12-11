/**
 * @description Utility class to return to calculate business days after a particular date. Additional methods can be
 * added later if necessary.
 *
 * @author Zach French
 * @date 2019-08-02
 */
public class BusinessDaysUtility {

	private static final String PIP_RULE_TARGET_FIELD_TARGET_COMPLETION_DATE = 'Target_Completion_Date__c';
	private static final String PIP_RULE_TYPE_SLA = 'SLA';

	/**
	 * @description Used to the set the Target Assignment Date field for a PIP based upon SLA rules defined in the
	 * PIP_SLA_Rules__c object.
	 *
	 * @param projects - List of projects
	 * @return List<TASKRAY__Project__c>
	 */
	@InvocableMethod(label='Set PIP Target Assignment Date' description='Sets the Target Assingment Date')
	public static List<TASKRAY__Project__c> setPIPTargetAssignmentDate(List<TASKRAY__Project__c> projects) {

		Map<Date, Id> holidayIdByDate = getHolidayIdByActivityDate();
		Map<String, PIP_SLA_Rule__c> pipSLARuleByPIPTypePIPMethod = getPIPSLARuleByPIPTypePIPMethod(PIP_RULE_TYPE_SLA,
			PIP_RULE_TARGET_FIELD_TARGET_COMPLETION_DATE);

		for(TASKRAY__Project__c project : projects) {
			Integer numberOfBusinessDays = 0;

			String projectPIPTypePIPMethod = project.PIP_Type__c + project.PIP_Method__c;
			if(pipSLARuleByPIPTypePIPMethod.containsKey(projectPIPTypePIPMethod)) {
				numberOfBusinessDays = Integer.valueOf(pipSLARuleByPIPTypePIPMethod.get(projectPIPTypePIPMethod)
					.days__c);
			}

			Date targetAssignmentDate = addBusinessDays(project.PIP_Assignment_Date__c, numberOfBusinessDays);
			Integer count = 0;

			while(holidayIdByDate.containsKey(targetAssignmentDate) && count < 10) {
				targetAssignmentDate = addBusinessDays(targetAssignmentDate, 1);
				count++;
			}
			project.Target_Completion_Date__c = targetAssignmentDate;
		}
		return projects;
	}

	/**
	 * @description Used to determine if the specified date is a weekend day
	 *
	 * @param dateValue - Date value
	 * @return Boolean
	 */
	public static Boolean IsWeekendDay(Date dateValue){
		Boolean weekendDay = false;
		// Start date for week based on dateValue
		Date startOfWeek   = dateValue.toStartOfWeek();
		Integer dayOfWeek  = dateValue.day() - startOfWeek.day();

		// Check start of week is the month before the current month
		if (dayOfWeek < 0) {
			Integer monthDays = date.daysInMonth(startOfWeek.year(), startOfWeek.month());
			dayOfWeek = monthDays + dayOfWeek;
		}

		// User locale used to determine is weekend day
		if (UserInfo.getLocale() == 'en_US') {
			weekendDay = dayOfWeek == 0 || dayOfWeek == 6 ? true : false; // Sunday & Saturday (US)
		} else {
			weekendDay = dayOfWeek == 5 || dayOfWeek == 6 ? true : false; // Sunday & Saturday (EU)
		}

		return weekendDay;
	}

	/**
	 * @description Used to add business days to a date field.
	 *
	 * @param startDate - Start Date
	 * @param businessDaysToAdd - Number of business days to be added
	 *
	 * @return Date
	 */
	public static Date addBusinessDays(Date startDate, Integer businessDaysToAdd){
		//Add or decrease in businessDaysToAdd days
		Date finalDate = startDate;
		Integer direction = businessDaysToAdd < 0 ? -1 : 1;

		while(businessDaysToAdd != 0 && finalDate != null) {
			finalDate = finalDate.AddDays(direction);
			if (!isWeekendDay(finalDate)) {
				businessDaysToAdd -= direction;
			}
		}

		return finalDate;
	}

	/**
	 * @description Used to return a map of holidays as configured in the Holiday objecct.
	 *
	 * @return Map<Date, Id>
	 */
	public static Map<Date, Id> getHolidayIdByActivityDate() {
		Map<Date, Id> holidayIdByDate = new Map<Date, Id>();
		List<Holiday> holidays = [
			SELECT ID, ActivityDate
			FROM Holiday];

		for(Holiday holiday : holidays) {
			holidayIdByDate.put(holiday.ActivityDate, holiday.Id);
		}

		return holidayIdByDate;
	}

	/**
	 * @description Used to create a map of PIP SLA rules with the key as a join between PIP Type + PIP Method
	 *
	 * @param ruleType - The type of rule that is configured, e.g., SLA
	 * @param ruleTargetField - The field that will be set by from the SLA Rule
	 *
	 * @return Map<String, PIP_SLA_Rule__c>
	 */
	public static Map<String, PIP_SLA_Rule__c> getPIPSLARuleByPIPTypePIPMethod(String ruleType, String
		ruleTargetField) {

		Map<String, PIP_SLA_Rule__c> PIPSLARuleByPIPTypePIPMethod = new Map<String, PIP_SLA_Rule__c>();

		for(PIP_SLA_Rule__c pipSLARule : [
			SELECT ID, Rule_Target_Field__c, Rule_Type__c, PIP_Type__c, PIP_Method__c, Days__c
			FROM PIP_SLA_Rule__c
			WHERE Rule_Type__c = :ruleType AND Rule_Target_Field__c = :ruleTargetField]) {

			PIPSLARuleByPIPTypePIPMethod.put(pipSLARule.PIP_Type__c+pipSLARule.PIP_Method__c, pipSLARule);
		}

		return PIPSLARuleByPIPTypePIPMethod;
	}
}