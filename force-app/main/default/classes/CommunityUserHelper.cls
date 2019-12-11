public class CommunityUserHelper {


    /***************************************************************************************
    Method that creates new Community User Data
    ****************************************************************************************/
    public static User getNewCommunityUser(Contact con, Id profileId){
        //Nickname logic
        String base = con.Email.substringBefore('@');
        String randNumber = String.valueOf(Math.random());
        randNumber = randNumber.removeStart('0');
        String nickname = base + randNumber;
        if(nickname.length() > 40){
            nickname = nickname.mid(0,40);
        }
        //Last Name logic
        String lastName = con.LastName;

        if(con.LastName.length() + 1 > 7){
            lastName = con.LastName.substring(0,7);
        }

        return new User(
            ProfileId = profileId,
            ContactId = con.Id,
            FirstName = con.FirstName,
            LastName = con.LastName,
            Username = con.Email + '.franchisedevelopment',
            Email = con.Email,
            CommunityNickname = nickname,// before @ on email + random number 
            Alias = con.FirstName.substring(0,1) + lastName,
            TimeZoneSidKey = 'America/Phoenix', //required
            LocaleSidKey = 'en_US', //required
            EmailEncodingKey = 'ISO-8859-1', //required
            LanguageLocaleKey = 'en_US' //required 
        );
    }
}