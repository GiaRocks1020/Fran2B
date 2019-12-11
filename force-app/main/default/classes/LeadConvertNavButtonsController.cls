public class LeadConvertNavButtonsController {
    /***************************************************************************************
    Method to convert leads on Account Screen
    ****************************************************************************************/
    @AuraEnabled
    public static List<String> leadConversionStep2(Lead lead, String contactId, String accountId){
        List<String> errList = new List<String>();

        Contact c = new Contact();
        if(!String.isEmpty(contactId)){
            c = new Contact(Id = contactId);
        }
        LeadConvertUtilities.mapLeadFieldsFromMetaData(c, lead, 'Contact');

        Account acc = new Account();
        if(!String.isEmpty(accountId)){
            acc = new Account(Id = accountId);
        }
        LeadConvertUtilities.mapLeadFieldsFromMetaData(acc, lead, 'Account');
    
        return attemptObjectSaves(lead, c, acc, null, false);
    }

    /***************************************************************************************
    Method to convert leads on Property Screen
    ****************************************************************************************/
    @AuraEnabled
    public static List<String> leadConversionStep3(Lead lead, String contactId, String accountId, String propertyId, Boolean createDeal){
        List<String> errList = new List<String>();

        Contact c = new Contact();
        if(!String.isEmpty(contactId)){
            c = new Contact(Id = contactId);
        }
        LeadConvertUtilities.mapLeadFieldsFromMetaData(c, lead, 'Contact');

        Account acc = new Account();
        if(!String.isEmpty(accountId)){
            acc = new Account(Id = accountId);
        }       
        LeadConvertUtilities.mapLeadFieldsFromMetaData(acc, lead, 'Account');

        Property__c prop = new Property__c();
        if(!String.isEmpty(propertyId)){
            prop = new Property__c(Id = propertyId);
        }
        LeadConvertUtilities.mapLeadFieldsFromMetaData(prop, lead, 'Property__c');

        return attemptObjectSaves(lead, c, acc, prop, createDeal);
    }

    /***************************************************************************************
    Method to format Errors to display on Modal
    ****************************************************************************************/
    public static void formatErrors(Database.Error[] errors, String sObjectName, List<String> errorList){
        Integer counter = 0;
        for(Database.Error e : errors){
            if(counter == 0){
                errorList.add(sObjectName + ':');
                counter++;
            }
            String error = e.getMessage() + ': ';
            for(String field : e.getFields()){
                error += field + ', ';
            }
            error = error.removeEnd(', ');
            System.debug(e);
            errorList.add(error);
        }
    }

    /***************************************************************************************
    Method that attempts to save records. On failure rolls back.
    ****************************************************************************************/
    public static List<String> attemptObjectSaves(Lead lead, Contact c, Account acc, Property__c prop, Boolean createDeal){
        List<String> errList = new List<String>();
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.SaveResult sr;
        List<String> accountId = new List<String>();
        List<String> dealId = new List<String>();
        Id contactId;
        //Create savepoint so it can be rolled back in case of errors
        Savepoint sp = Database.setSavepoint();

        acc.RecordTypeId = FranchiseSalesUtilities.getRecordTypeById(acc, 'Franchise Account');
        
        if(acc != null){
            if(!String.isEmpty(lead.Corporate_State_Province__c)){
                if(lead.Corporate_State_Province__c.contains('-')){
                    acc.BillingStateCode = lead.Corporate_State_Province__c.subString(3);
                }
                else{
                    acc.BillingStateCode = lead.Corporate_State_Province__c;
                }
            }

        }

        if(acc.Id == null){
            sr = Database.Insert(acc, dml);
        }
        else{
            sr = Database.update(acc, dml);
        }

        formatErrors(sr.getErrors(), Label.Lead_Convert_Account_Error_Title, errList);
    
        c.AccountId = sr.getId();
        accountId.add(c.AccountId);

        if( c != null){
            if(!String.isEmpty(lead.Corporate_State_Province__c)){
                if(lead.Corporate_State_Province__c.contains('-')){
                    c.MailingStateCode = lead.Corporate_State_Province__c.subString(3);
                }
                else{
                    c.MailingStateCode = lead.Corporate_State_Province__c;
                }
            }

        }

        if(c.Id == null){
            sr = Database.Insert(c, dml);
        }
        else{
            sr = Database.Update(c, dml);
        }
        contactId = sr.getId();
        formatErrors(sr.getErrors(), Label.Lead_Convert_Contact_Error_Title, errList);

        if(prop != null){

            if(!String.isEmpty(lead.Street)){
                List<String> streets = new List<String>();
                streets = lead.Street.split('\r');
            
                Integer i = 0;
                for(String street : streets){
                    i++;
                    if(i <= 3){
                        prop.put('Address_Line_' + i + '__c', street);
                    }
                }
            }

            if(!String.isEmpty(lead.CountryCode) && !String.isEmpty(lead.StateCode)){
                prop.State_Province__c = lead.CountryCode + '-' + lead.StateCode;
            }
            

            if(prop.Id == null){
                sr = Database.Insert(prop, dml);
            }
            else{
                sr = Database.Update(prop, dml);
            }

            formatErrors(sr.getErrors(), Label.Lead_Convert_Property_Error_Title, errList);
        }

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setContactId(contactId);
        lc.setAccountId((Id)accountId[0]);
        if(!createDeal){
            lc.setDoNotCreateOpportunity(true);
        }

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc,false);

        formatErrors(lcr.getErrors(), Label.Lead_Convert_Lead_Error_Title, errList);

        if(createDeal){
            Opportunity opp = new Opportunity(Id = lcr.getOpportunityId());
            opp.StageName = Label.Lead_Convert_Deal_Default_Stage;
            opp.RecordTypeId = LeadConvertUtilities.getRecordTypeIdFromLead(lead.Brand_of_Interest__c,opp,'Opportunity');
            opp.Licensee_Name__c = contactId;
            opp.Property__c = sr.getId();
            opp.CloseDate = Date.today().addDays(7);
            opp.AccountId = (Id)accountId[0];
            LeadConvertUtilities.mapLeadFieldsFromMetaData(opp, lead, 'Opportunity');
            sr = Database.Update(opp, dml);

            formatErrors(sr.getErrors(), Label.Lead_Convert_Opportunity_Error_Title, errList);
            dealId.add(sr.getId());
        }

        System.debug(errList);

        if(!errList.isEmpty()){
            Database.rollback(sp);
            return errList;
        }
        else if(createDeal){
            if(!String.isEmpty(lead.Referral_Name_Email__c)){
                try{
			        sendLeadConvertedEmail(lead, (Id)dealId[0]);
                }
                catch(Exception e){
                    System.debug(e.getMessage());
                }

            }
            return dealId;
        }
        else{
            return accountId;
        }
    }
    
    public static void sendLeadConvertedEmail(Lead lead, ID oppId) {       
        List<String> addresses = new List<String>();
        //addresses to send to
        addresses.add(lead.Referral_Name_Email__c);
        //query on template object
        EmailTemplate et=[Select Id from EmailTemplate where name=:'AD Lead Converted Alert'];
        //New instance of a single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(lead.Id);
        // The email template ID used for the email
        mail.setTemplateId(et.Id);    
        mail.setTreatTargetObjectAsRecipient(false);      
        mail.setWhatId(oppId);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setToAddresses(addresses);
        mail.setSaveAsActivity(false); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
}