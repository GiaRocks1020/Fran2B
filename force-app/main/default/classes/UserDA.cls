public without sharing class UserDA {
	public static List<User> getUsersFromEmployeeNumbers(List<String> employeeNumbers){
		if(!employeeNumbers.isEmpty()){
			return [SELECT Id,
					Name, 
					Email, 
					EmployeeNumber
					FROM User
					WHERE EmployeeNumber IN :employeeNumbers];
		}
		else{
			return new List<User>();
		}

	}

	public static List<User> getUsersById(List<Id> userIds) {
		return [SELECT Id,
				Name, 
				Email, 
				EmployeeNumber
				FROM User
				WHERE Id IN :userIds];
	}
}