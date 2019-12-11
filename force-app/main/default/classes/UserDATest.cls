@isTest
public class UserDATest {
@testSetup
    static void setUpTestData(){
        User u = TestUtil.createUser('System Administrator', 'Tester');

        insert u;
    }

    @isTest
    static void getUsersFromEmployeeNumbers_givenEmployeeNumbers_shouldReturnRecords(){
        List<String> employeeNumberList = new List<String>();
        employeeNumberList.add('ABC123');
        List<User> users = new List<User>();
        Test.startTest();
            users = UserDA.getUsersFromEmployeeNumbers(employeeNumberList);
        Test.stopTest();

        System.assert(users.size() > 0, 'Records should have been returned');
    }

    @isTest
    private static void getUsersById_GivenUserIds_ShouldReturnUserRecords() {
        User user0 = TestUtil.createUser('System Administrator', 'User0', 'user0', 'user0@example.com', 'user0@example.com.test', 'user0');
        User user1 = TestUtil.createUser('System Administrator', 'User1', 'user1', 'user1@example.com', 'user1@example.com.test', 'user1');
        insert new List<User>{user0, user1};
        
        List<User> users = new List<User>();
        Test.startTest();
            users = UserDA.getUsersById(new List<Id>{user0.Id, user1.Id});
        Test.stopTest();

        List<String> userEmails = new List<String>();
        for (User u : users) {
            userEmails.add(u.Email);
        }

        System.assertEquals(2, users.size());
        System.assert(userEmails.contains('user0@example.com'));
        System.assert(userEmails.contains('user1@example.com'));

    }
}