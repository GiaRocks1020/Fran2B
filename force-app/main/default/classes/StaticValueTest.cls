/**
 * @description Test class for StaticValue class.
 *
 * @author Zach French
 * @date 2019-05-30
 */
@IsTest
private class StaticValueTest {

	private static final String TEST_CLASS_VALUE = 'TEST_CLASS_VALUE';
	private static final String STRING_VALUE = 'TEST';

	/**
	 * @description Used to validate a positive test case scenario for StaticValue.getStaticValueText with a single
	 * string value
	 *
	 * @return void
	 */
	@IsTest
	static void testGetStaticValueTextWithStringPositive() {
		List<Static_Value__mdt> staticValues = new List<Static_Value__mdt>{
			new Static_Value__mdt(
				DeveloperName = STRING_VALUE,
				MasterLabel = STRING_VALUE,
				Text_Value__c = STRING_VALUE,
				Text_Area_Long_Value__c = '',
				Description__c = 'This is a test static value.'
			)
		};
		StaticValue.staticValues = staticValues;
		System.assertEquals(STRING_VALUE, StaticValue.getStaticValueText(TEST_CLASS_VALUE));
	}

	/**
	 * @description Used to validate a negative test case scenario for StaticValue.getStaticValueText with a single
	 * string value
	 *
	 * @return void
	 */
	@IsTest
	static void testGetStaticValueTextWithStringNegative() {
		System.assertEquals('', StaticValue.getStaticValueText(TEST_CLASS_VALUE));
	}

	/**
	 * @description Used to validate a positive test case scenario for StaticValue.getStaticValueText with a list of
	 * string values
	 *
	 * @return void
	 */
	@IsTest
	static void testGetStaticValueTextWithListOfStringPositive() {
		List<Static_Value__mdt> staticValues = new List<Static_Value__mdt>{
			new Static_Value__mdt(
				DeveloperName = STRING_VALUE,
				MasterLabel = STRING_VALUE,
				Text_Value__c = STRING_VALUE,
				Text_Area_Long_Value__c = '',
				Description__c = 'This is a test static value.'
			)
		};

		StaticValue.staticValues = staticValues;

		List<String> developerNames = new List<String>{TEST_CLASS_VALUE};

		Map<String, Static_Value__mdt> metadataByDeveloperName = StaticValue.getStaticValueText(developerNames);
		System.assertEquals(true, metadataByDeveloperName.containsKey(STRING_VALUE));
		System.assertEquals(STRING_VALUE, metadataByDeveloperName.get(STRING_VALUE).Text_Value__c);
	}

	/**
	 * @description Used to validate a negative test case scenario for StaticValue.getStaticValueText with a list of
	 * string values
	 *
	 * @return void
	 */
	@IsTest
	static void testGetStaticValueTextWithListOfStringNegative() {

		List<String> developerNames = new List<String>{TEST_CLASS_VALUE};

		Map<String, Static_Value__mdt> metadataByDeveloperName = StaticValue.getStaticValueText(developerNames);
		System.assertEquals(false, metadataByDeveloperName.containsKey(STRING_VALUE));
	}

	/**
	 * @description Used to validate a positive test case scenario for StaticValue.getStaticValueTextAreaLong with a
	 * single string value
	 *
	 * @return void
	 */
	@IsTest
	static void testGetStaticValueTextAreaLongWithStringPositive() {
		List<Static_Value__mdt> staticValues = new List<Static_Value__mdt>{
			new Static_Value__mdt(
				DeveloperName = STRING_VALUE,
				MasterLabel = STRING_VALUE,
				Text_Value__c = '',
				Text_Area_Long_Value__c = STRING_VALUE,
				Description__c = 'This is a test static value.'
			)
		};

		StaticValue.staticValues = staticValues;

		System.assertEquals(STRING_VALUE, StaticValue.getStaticValueTextAreaLong(STRING_VALUE));
	}

	/**
	 * @description Used to validate a negative test case scenario for StaticValue.getStaticValueTextAreaLong with a
	 * single string value
	 *
	 * @return void
	 */
	@IsTest
	static void testGetStaticValueTextAreaLongWithStringNegative() {
		System.assertEquals('', StaticValue.getStaticValueTextAreaLong(TEST_CLASS_VALUE));
	}

	/**
	 * @description Used to validate a positive test case scenario for StaticValue.getStaticValueTextAreaLong with a
	 * list of string values
	 *
	 * @return void
	 */
	@IsTest
	static void testGetStaticValueTextAreaLongWithListOfStringPositive() {
		List<Static_Value__mdt> staticValues = new List<Static_Value__mdt>{
			new Static_Value__mdt(
				DeveloperName = STRING_VALUE,
				MasterLabel = STRING_VALUE,
				Text_Value__c = STRING_VALUE,
				Text_Area_Long_Value__c = '',
				Description__c = 'This is a test static value.'
			)
		};

		StaticValue.staticValues = staticValues;

		List<String> developerNames = new List<String>{TEST_CLASS_VALUE};

		Map<String, Static_Value__mdt> metadataByDeveloperName = StaticValue.getStaticValueTextAreaLong(developerNames);
		System.assertEquals(true, metadataByDeveloperName.containsKey(STRING_VALUE));
		System.assertEquals(STRING_VALUE, metadataByDeveloperName.get(STRING_VALUE).Text_Value__c);
	}

	/**
	 * @description Used to validate a negative test case scenario for StaticValue.getStaticValueTextAreaLong with a
	 * list of string values
	 *
	 * @return void
	 */
	@IsTest
	static void testGetStaticValueTextAreaLongWithListOfStringNegative() {
		List<String> developerNames = new List<String>{TEST_CLASS_VALUE};

		Map<String, Static_Value__mdt> metadataByDeveloperName = StaticValue.getStaticValueTextAreaLong(developerNames);
		System.assertEquals(false, metadataByDeveloperName.containsKey(STRING_VALUE));
	}

}