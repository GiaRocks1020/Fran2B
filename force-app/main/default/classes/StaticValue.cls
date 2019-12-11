/**
 * @description Used to retrieve static values for reference values required in code.
 *
 * @author Zach French
 * @date 2019-05-30
 */
public class StaticValue {
	@TestVisible
	private static List<Static_Value__mdt> staticValues = new List<Static_Value__mdt>();

	/**
	 * @description Used to return the text field associated with the custom metadata type. Using this field will not
	 * count towards apex governor limits.
	 *
	 * @param developerName Developer Name associated with the custom metadata type record.
	 * @return String
	 */
	public static String getStaticValueText(String developerName) {

		String textValue = '';

		List<Static_Value__mdt> currentStaticValues = new List<Static_Value__mdt>();

		currentStaticValues = (!staticValues.isEmpty()) ? staticValues : [
			SELECT Id, DeveloperName, Label, Language, MasterLabel, Text_Value__c
			FROM Static_Value__mdt
			WHERE DeveloperName = :developerName
			LIMIT 1];

		textValue = !currentStaticValues.isEmpty() & currentStaticValues.size() > 0 ? currentStaticValues[0]
			.Text_Value__c : '';

		return textValue;
	}

	/**
	 * @description Used to return the text field associated with the custom metadata type. Using this field will not
	 * count towards apex governor limits.
	 *
	 * @param developerNames List of Developer Name (String) associated with the custom metadata type record.
	 * @return Map<String, Static_Value__mdt>
	 */
	public static Map<String, Static_Value__mdt> getStaticValueText(List<String> developerNames) {

		Map<String, Static_Value__mdt> staticValueByDeveloperName = new Map<String, Static_Value__mdt>();

		for(Static_Value__mdt staticValue : (!staticValues.isEmpty()) ? staticValues : [
			SELECT Id, DeveloperName, Label, Language, MasterLabel, Text_Value__c
			FROM Static_Value__mdt
			WHERE DeveloperName = :developerNames]) {

			staticValueByDeveloperName.put(staticValue.DeveloperName, staticValue);
		}

		return staticValueByDeveloperName;
	}

	/**
	 * @description Used to return the Text Area Long field associated with the custom metadata type. This method
	 * should only be used if the necessary data cannot be stored in a text field. Using this query will count
	 * towards apex governor limits.
	 *
	 * @param developerName Developer Name associated with the custom metadata type record.
	 * @return String
	 */
	public static String getStaticValueTextAreaLong(String developerName) {

		String textAreaLongValue = '';

		List<Static_Value__mdt> currentStaticValues = new List<Static_Value__mdt>();

		currentStaticValues = (!staticValues.isEmpty()) ? staticValues : [
			SELECT Id, DeveloperName, Label, Language, MasterLabel, Text_Area_Long_Value__c, Text_Value__c
			FROM Static_Value__mdt
			WHERE DeveloperName = :developerName
			LIMIT 1];

		textAreaLongValue = !currentStaticValues.isEmpty() & currentStaticValues.size() > 0 ? currentStaticValues[0]
			.Text_Area_Long_Value__c : '';

		return textAreaLongValue;
	}

	/**
	 * @description Used to return the Text Area Long field associated with the custom metadata type. This method
	 * should only be used if the necessary data cannot be stored in a text field. Using this query will count
	 * towards apex governor limits.
	 *
	 * @param developerNames List of Developer Name (String) associated with the custom metadata type record.
	 * @return Map<String, Static_Value__mdt>
	 */
	public static Map<String, Static_Value__mdt> getStaticValueTextAreaLong(List<String> developerNames) {

		Map<String, Static_Value__mdt> staticValueByDeveloperName = new Map<String, Static_Value__mdt>();

		for(Static_Value__mdt staticValue : (!staticValues.isEmpty()) ? staticValues : [
			SELECT Id, DeveloperName, Label, Language, MasterLabel, Text_Area_Long_Value__c, Text_Value__c
			FROM Static_Value__mdt
			WHERE DeveloperName = :developerNames]) {

			staticValueByDeveloperName.put(staticValue.DeveloperName, staticValue);
		}

		return staticValueByDeveloperName;
	}
}