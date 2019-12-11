/**
 * @description TestDataFactory for Creating/Instantiating objects for all Test Classes
 *
 * @author Sugandha Chugh
 * @date 2019-08-25
 */

@IsTest
public class TestDataFactory {

    public static Profile ChoiceStandardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Choice Standard User'];
    public static Profile ADMIN_USER_PROFILE = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    public static PermissionSet PIPReadWritePermissionSet = [SELECT Id FROM PermissionSet WHERE Name =
        'PIP_Read_Write'];
    public static PermissionSet PIPWriterPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'PIP_Writer'];
    public static PermissionSet PIPManagerPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'PIP_Manager'];


    public static User instantiateBaseUser(){
        User usrTestUser =  new User();
        usrTestUser.FirstName = createRandomString(1).toUpperCase() + createRandomString(3);
        usrTestUser.LastName = createRandomString(1).toUpperCase() + createRandomString(7);
        usrTestUser = createAliasEmail(usrTestUser);
        usrTestUser.IsActive = true;
        usrTestUser.EmailEncodingKey = 'UTF-8';
        usrTestUser.LanguageLocaleKey = 'en_US';
        usrTestUser.LocaleSidKey = 'en_US';
        usrTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        return usrTestUser;
    }

    public static User getUserDetails(String firstName, String lastName, Id profileId){
        User usrTestUser =  new User();
        usrTestUser.FirstName = firstName;
        usrTestUser.LastName = lastName;
        usrTestUser = createAliasEmail(usrTestUser);
        usrTestUser.IsActive = true;
        usrTestUser.EmailEncodingKey = 'UTF-8';
        usrTestUser.LanguageLocaleKey = 'en_US';
        usrTestUser.LocaleSidKey = 'en_US';
        usrTestUser.ProfileId = profileId;
        usrTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        return usrTestUser;
    }

    /********************************** User PIP Writer ******************************/
    public static User createPIPWriterUser(){
        User PIPWriter = instantiateBaseUser();
        PIPWriter.ProfileId = ChoiceStandardUserProfile.Id;
        insert PIPWriter;

        System.runAs(new User(Id=UserInfo.getUserId())) {
            insert new PermissionSetAssignment(AssigneeId = PIPWriter.Id, PermissionSetId = PIPWriterPermissionSet.Id);
            insert new PermissionSetAssignment(AssigneeId = PIPWriter.Id, PermissionSetId = PIPReadWritePermissionSet
                .Id);
        }
        return PIPWriter;
    }

    // User PIP Manager
    public static User createPIPManagerUser(){
        User PIPManager= instantiateBaseUser();
        PIPManager.ProfileId = ChoiceStandardUserProfile.Id;
        insert PIPManager;

        System.runAs(new User(Id=UserInfo.getUserId())) {
            List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>{
                new PermissionSetAssignment(
                    AssigneeId = PIPManager.Id,
                    PermissionSetId = PIPManagerPermissionSet.Id
                ),
                new PermissionSetAssignment(
                    AssigneeId = PIPManager.Id,
                    PermissionSetId = PIPReadWritePermissionSet.Id
                )
            };
            insert permissionSetAssignments;
        }
        return PIPManager;
    }

    public static User createAdminUser() {
        User adminsUser = instantiateBaseUser();
        adminsUser.ProfileId = ADMIN_USER_PROFILE.Id;
        insert adminsUser;

        return adminsUser;
    }

	// Resource
	public static Resource__c createResource(Id userId) {
		Resource__c resource = new Resource__c(
			Name = 'Test Resource - Temp',
            Email__c = 'testemail@email.com',
			User__c = userId
		);
		insert resource;

		return resource;
	}

    /********************************** ACCOUNT **********************************/

    /********************************** CONTACT **********************************/

    /********************************** BRAND **********************************/

    /********************************** PRDOUCT **********************************/

    /********************************** PROPERTY **********************************/
    public static Property__c createProperty(Boolean isInsert){
        Property__c property = new Property__c(
            Name = 'AZ083 Tempe',
            DI_Indicator__c = 'D',
            Reporting_Location__c = 'D',
            Property_Code__c = 'AZ083',
	        GM_Name__c = 'Test GM',
	        Additional_GM_Email__c = 'additionalgm123@123.com',
	        Property_Fax__c = '000-111-2222',
	        Property_Phone__c = '000-222-3333'
        );

        if(isInsert) {
            insert property;
        }

        return property;
    }

    public static Property__c createVTProperty(Boolean isInsert){
        Property__c property = new Property__c(
                Name = 'VT019 Montpelier',
                Property_Code__c = 'VT019',
                State_Province__c = 'US-VT',
                Country__c = 'US'
        );

        if(isInsert) {
            insert property;
        }

        return property;
    }

    public static Product__c createProductRE(Boolean isInsert, String productName, Id brandId, String externalId){
        // Product
        Product__c product = new Product__c(
            Name = productName,
            Brand__c = brandId,
            Product_Code__c = 'RE',
            External_ID__c = externalId,
            Choice_Class_ID__c = 'R'
            );
        if(isInsert) {
            insert product;
        }

        return product;
    }

    /********************************** RESOURCE ********************************/
    public static Resource__c createResourceNoUser(Boolean isInsert) {
        Resource__c resource = new Resource__c(
                Name = 'Test Resource - Temp',
                Email__c = 'testemail@test.com',
                External_User_Name__c = 'Test User'
        );
        if(isInsert) {
            insert resource;
        }
        return resource;
    }

    /********************************** DEAL **********************************/
    public static Opportunity createDeal(Boolean isInsert){
        Opportunity deal = new Opportunity(
                Name = 'Test Deal',
                StageName = 'Deal Working',
                CloseDate = System.today().addYears(1)
        );

        if(isInsert) {
            insert deal;
        }

        return deal;
    }

    // Contract
    public static Contract__c createContract(Boolean isInsert){
        Contract__c contract = new Contract__c(
            Name = 'Test Contract',
            Contract_Status__c = 'Open'
        );

        if(isInsert) {
            insert contract;
        }

        return contract;
    }

    /********************************** PIP **********************************/
    public static TaskRay__Project__c createPIP(Boolean isInsert){
        TaskRay__Project__c PIP = new TaskRay__Project__c(
                Name = 'Test PIP',
                TASKRAY__trStatus__c = 'Active',
                Sub_Status__c = 'Executed'
        );
        if(isInsert){
            insert PIP;
        }
        return PIP;
    }

    /********************************** Brand **********************************/
    public static Brand__c createBrand(Boolean isInsert, String brandName){
        Brand__c brand = new Brand__c(
                Name=brandName,
                External_ID__c =brandName,
                Brand_Code__c =brandName,
                Start_Date__c = system.today(),
                End_Date__c = system.today()+100,
                Status__c ='Active'
        );
        if(isInsert){
            insert brand;
        }
        return brand;
    }

    /********************************** PIP Template**********************************/
    public static TaskRay__Project__c createPIPTemplate(Boolean isInsert, Id brand, Boolean isActive, Id recordTypeId,
            String name){
        TaskRay__Project__c PIP = new TaskRay__Project__c(
                Name = name,
                TASKRAY__trTemplate__c = true,
                Active__c = isActive,
                Brand__c = brand,
                recordTypeId = recordTypeId
        );
        if(isInsert){
            insert PIP;
        }
        return PIP;
    }

    /********************************** Opening Template**********************************/
    public static TaskRay__Project__c createOpeningTemplate(Boolean isInsert, Id brand, Boolean isActive, Id recordTypeId,
            String name, String projectType){
        TaskRay__Project__c PIP = new TaskRay__Project__c(
                Name = name,
                TASKRAY__trTemplate__c = true,
                Active__c = isActive,
                Brand__c = brand,
                Project_Type__c = projectType,
                recordTypeId = recordTypeId
        );
        if(isInsert){
            insert PIP;
        }
        return PIP;
    }

    /********************************** PIP Items **********************************/
    public static TASKRAY__Project_Task__c createPIPItem(Boolean isInsert){
        TASKRAY__Project_Task__c PIPItem = new TASKRAY__Project_Task__c(
                Name = 'Test PIP Item'
        );
        if(isInsert){
            insert PIPItem;
        }
        return PIPItem;
    }

    /********************************** PIP Inspection Items **********************************/
    public static PIP_Inspection_Item__c createPIPInspectionsForPIPItems(Boolean isInsert){
        PIP_Inspection_Item__c pipInspectionItem = new PIP_Inspection_Item__c(
                Name = 'Test PIP Inspection'
        );

        if(isInsert){
            insert pipInspectionItem;
        }
        return pipInspectionItem;
    }
    /********************************** PIP Library Items **********************************/
    public static PIP_Library_Item__c createPIPLibraryItem(Boolean isInsert){
        PIP_Library_Item__c pipLibraryItem = new PIP_Library_Item__c(
            Name = 'Test Library Item'
        );
        if(isInsert){
            insert pipLibraryItem;
        }
        return pipLibraryItem;
    }

    /********************************** CONTENT VERSION **********************************/
    public static ContentVersion createContentVersion(String strTitle,Boolean isInsert){
        ContentVersion contentVersionInsert = new ContentVersion(
                Title = strTitle,
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content Data'),
                IsMajorVersion = true
        );
        if(isInsert) {
            insert contentVersionInsert;
        }
        return contentVersionInsert;
    }

    /********************************** CONTENT DOCUMENT **********************************/
    public static ContentDocument createContentDocument(String strTitle,Boolean isInsert){
        ContentVersion contentVersionInsert = createContentVersion(strTitle,true);
        ContentVersion contentVersionSelect = [
            SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentVersionInsert.Id
            LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument
                                            WHERE LatestPublishedVersionId = :ContentVersionInsert.Id];
        return documents[0];
    }

    /**
     * Returns a random string based on the integer provided
     * @param len - length of the string to return
     * @return - the randomly generated string
     */
    public static String createRandomString(Integer len)
    {
        String strBase = 'abcdefghijklmnopqrstuvwxyz';
        String strReturn = '';
        for (Integer iCtr1 = 0; iCtr1 < len; iCtr1 ++)
        {
            Integer intStart = Math.round((Math.random()*25));
            strReturn= strReturn + strBase.substring(intStart,intStart+1);
        }
        return strReturn;
    }

    /**
     * Returns a random string based on the integer provided
     * @param len - length of the string to return
     * @return - the randomly generated string
     */
    private static User createAliasEmail(User usrTestUser)
    {
        if (usrTestUser.LastName.length()<7)
        {
            usrTestUser.Alias = usrTestUser.LastName.substring(0,usrTestUser.LastName.length());
        }
        else
        {
            usrTestUser.Alias = usrTestUser.LastName.substring(0,6);
        }
        usrTestUser.Email = usrTestUser.FirstName+usrTestUser.LastName+'@example.com';
        usrTestUser.Username = usrTestUser.Email;
        return usrTestUser;
    }
	
    public static PIP_Library_Item__c createPIPLibItemForCostUnit(String costUnit){
        PIP_Library_Item__c pipLibraryItem = new PIP_Library_Item__c();
        pipLibraryItem.PI_Cost_Units__c = costUnit;
        pipLibraryItem.PI_Average_Cost__c = 5;
        pipLibraryItem.Brand__c = 'Comfort';
        pipLibraryItem.PI_Type__c = 'BES';

        return pipLibraryItem;
    }

    public static List<PIP_Inspection__c> createPIPInspections(Integer numberOfItems, Id projectId
            , String externalIdPrefix, String statusReason){
        System.debug('PIPInspectionTriggerHelper createPIPInspections: ' + numberOfItems);

        List<PIP_Inspection__c> pipInspectionsList = new List<PIP_Inspection__c>();
        for(Integer i=0; i<numberOfItems; i++){
            PIP_Inspection__c pipInspection = new PIP_Inspection__c();
            pipInspection.Inspection_Notes__c = 'Notes';
            pipInspection.Inspection_Results__c = 'Result';
            pipInspection.Inspection_Type__c = 'Standard';
            pipInspection.Status_Reason__c = statusReason;
            pipInspection.LRA_AESI_ID__c = externalIdPrefix + i;
            pipInspection.PIP__c = projectId;

            pipInspectionsList.add(pipInspection);
        }
        return pipInspectionsList;

    }

    public static List<TASKRAY__Project_Task__c> createPIPItems(Boolean isInsert, Integer numberOfItems,
        Id pipProjectId, Id pipPerBuildingLibraryItemId, Id recordTypeId){
        List<TASKRAY__Project_Task__c> pipItemsList = new List<TASKRAY__Project_Task__c>();
        for(Integer i=0; i<numberOfItems; i++) {
            TASKRAY__Project_Task__c pipItem = new TASKRAY__Project_Task__c();
            pipItem.TASKRAY__Project__c = pipProjectId;
            pipItem.RecordTypeId = recordTypeId;
            pipItem.PIP_Library_Item__c = pipPerBuildingLibraryItemId;
            pipItemsList.add(pipItem);
        }

        if(isInsert){
            insert pipItemsList;
        }
        return pipItemsList;
    }
    
    public static PIP_Checklist_Library_Item__c createPIPChecklistLibraryItems(Boolean isInsert){
        PIP_Checklist_Library_Item__c pipCLI = new PIP_Checklist_Library_Item__c();
        pipCLI.Name = '1234';
        pipCLI.Active__c = true;
        pipCLI.Brand__c = 'Ascend';
        pipCLI.Category__c = 'EXTERIORS';
        pipCLI.Order__c = 1;
        pipCLI.Question__c = 'Question 1';
        if(isInsert)
            Insert PIPCLI;
        return PIPCLI;
    }
    
    public static PIP_Checklist__c createPIPChecklist(Boolean isInsert){
        PIP_Checklist__c pipC = new PIP_Checklist__c();
        pipC.Brand__c = 'Ascend';
        pipC.Breakfast_Room__c = 'Yes';
        pipC.Breakfast_Room_Dimensions__c = '20X20';
        pipC.Business_Center__c = 'Separate Room';
        pipC.Closed_Reason__c = 'QWER';
        pipC.Closed_Rooms__c = 'Yes';
        pipC.Counter_Space_Feet__c = 12;
        pipC.Counter_Space_Seats__c = 12;
        pipC.Counter_Space_Tables__c = 12;
        pipC.Deal__c = createDeal(true).id;
        pipC.Double_Length__c = 2;
        pipC.Double_Width__c = 2;
        pipC.Double_Double_Length__c = 2;
        pipC.Double_Quantity__c = 2;
        pipC.Double_Double_Width__c = 2;
        pipC.Electronic_Locks__c = 'Yes';
        pipC.Elevator__c = 'Yes 1';
        pipC.Exercise_Room__c = 'Yes';
        pipC.Fast_Track__c = 'Yes';
        pipC.Guest_Laundry__c = 'Yes';
        pipC.King_Length__c = 2;
        pipC.King_Quantity__c = 2;
        pipC.King_Width__c = 2;
        pipC.Lobby_Market__c = 'Yes'; 
        pipC.Lounge_Bar__c = 'Yes';
        pipC.Manager_Apartment__c = 'Yes';
        pipC.Meeting_Room_1__c = 'Yes';
        pipC.Meeting_Room_1_SF__c =2;
        pipC.Meeting_Room_2__c = 'Yes';
        pipC.Meeting_Room_2_SF__c = 2;
        pipC.Meeting_Room_3__c = 'Yes';
        pipC.Meeting_Room_3_SF__c = 2;
        pipC.Meeting_Room_4__c = 'Yes';
        pipC.Meeting_Room_4_SF__c = 2;
        pipC.Number_of_2Room_Suites__c = 2;
        pipC.Number_of_Billable_Rooms__c = 2;
        pipC.Number_of_Closed_Rooms__c = 2;
        pipC.Number_of_Guest_Room_Buildings__c = 2;
        pipC.Number_of_LShaped_Suites__c = 2;
        pipC.Number_of_Other_Suites__c = 2;
        pipC.Number_of_Part_Div_Suites__c =2;
        pipC.Other_Attributes__c = 'TEST';
        pipC.Other_Length__c = 2;
        pipC.Other_Quantity__c =  2;
        pipC.Other_Width__c =  2;
        pipC.Overview_Comments__c = 'Test';
        pipC.Past_CHI_History__c = 'Test';
        pipC.Past_CHI_Property__c = 'Yes';
        pipC.Pool_Restroom__c = 'Yes';
        pipC.Property__c = createProperty(true).Id;
        pipC.Public_Restroom__c = 'Yes';
        pipC.Queen_Length__c = 2;
        pipC.Queen_Quantity__c = 2;
        pipC.Queen_Width__c = 2;
        pipC.Queen_Queen_Length__c = 2;
        pipC.Double_Double_Quantity__c =2;
        pipC.Queen_Queen_Quantity__c =2;
        pipC.Queen_Queen_Width__c = 2;
        pipC.Restaurant__c = 'Yes';
        pipC.Single_Loaded__c = 'Yes';
        pipC.Spa_Hot_Tub__c = 'Outdoor';
        pipC.Split_Dual_Brand__c = 'Yes';
        pipC.Suites_Length__c = 2;
        pipC.Suites_Quantity__c = 2;
        pipC.Suites_Width__c = 2;
        pipC.Swimming_Pool__c = 'Outdoor';
        pipC.Vending_Areas__c = 'Yes 1';
        if(isInsert)
            insert pipC;
        return pipC;
    }
}