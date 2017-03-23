public without sharing class Util {
    
    //  dateToIso                                   : Return date vbl as yyyy-mm-dd; null date returns null
    //  dateToYyyyMm                                : Take a date and convert to yyyymm as string
    //	dirtyCaches									: Clears out (null) the static singleton caches - useful when users are mocked after caches are built
    //  domainFromEmail                             : return yyyy.com from xxx@yyyy.com (in lowercase)	
    
    //	------------------------------------------------------------------------------
  	//	Email
  	//	Builder pattern for one line use of sending emails in a self-documented way in one line, see http://developer.force.com/cookbook/recipe/email-utility-class
  	//	Usage singleton: new Util.Email()
  	//						.withXXX(val)
  	//						.withYYY(val)
  	//						.sendEmail()
  	//	
  	//	Usage (bulk): 
  	//	Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>() {	
  	//							new Util.Email()
  	//							.withXXX(val)
  	//							.withYYY(val)
  	//							.make(),
  	//							new Util.Email()
  	//							.withXXX(val)
  	//							.withYYY(val)
  	//							.make() };
  	//	
  	//	Messaging.sendEmail(emails);
  	//	------------------------------------------------------------------------------
    
    
    //	getDateSetFromField							: Returns a set of Dates from a list of sobjects in <field>. Usage example: getDateSetFromField(Trigger.new,Opportunity.CloseDate)
    //	getDecimalSetFromField						: Returns a set of Decimals from a list of sobjects in <field>. Usage example: getDecimalSetFromField(Trigger.new,Account.AnnualRevenue)
    //	getDateTimeGmt								: Returns a datetime in GMT from a timezoneId, date and time object
    //	getDynSoqlInExpression						: Returns a list of quoted strings suitable for use in a Database.query IN(...) expression. Handle special case of strings with quotes
	//	getFirstNameFromString						: Returns First name from string (Joe Bob Tucker returns 'Joe Bob')
    //	getIdSetFromField							: Returns a set of Ids from a list of sobjects in <field>. Usage example: getIdSetFromField(Trigger.new,Account.ParentId)
    //	getLastNameFromString						: Returns Last Name from string (Joe Bob Tucker returns 'Tucker')
    //  getLocaleToDateTimeFmtMap                   : Returns a map of user locale | datetime format for that locale (http://www.interactiveties.com/b_locale_datetime.php)
    //	getMsp										: Returns a MSP from a Set<String> or List<String>
    //	getMsp										: Return a MSP from a list of sobjects (for a given sobjectField) - handles duplicates
    //	getPickListVF, getPickListValues			: Get picklist vals for a given SObject.fieldname; flavors: 	
    //														getPickListVF - returns as list of selectOption, getPickListLabels - returns as list of PLE labels
	//														getPickListValues - returns as list of PLE values
	//  getProfileId								: Get profileId from ProfileName, uses singleton to do SOQL only once in transaction
    //	getProfile									: Get Profile from profileId
    //  getProfile									: Get Profile from profileName
    //  getRecordTypeId                             : Return the recordTypeId for a given RecordType Name (works for either Name or DeveloperName)
    //  getRecordTypeName 							: Return the recordType Name for a given RecordTypeId (note - not DeveloperName)
    //  getRecordTypeDevName 						: Return the recordType DeveloperName for a given RecordTypeId 
    //	getStringSetFromField						: Returns a set of Strings from a list of sobjects in <field>. Usage example: getStringSetFromField(Trigger.new,Account.Name)
    
    //	getSchedulerCronExpression					: Returns a Cron expression for a datetime suitable for Apex Schedulable class
    //	getSobjectFieldAsString						: Returns value (as string) of sobject field regardless of #levels to parent (e.g. SObject=Account, field = Parent.Parent.Parent.Owner.LastName)
	//	getSobjectStringField						: Same but use only on string fields 	
 	//	getSobjectDateField							: Same but use only on Date fields
 	//	getSobjectDateTimeField						: Same but use only on Datetime fields
 	//	getSobjectDecimalField						: Same but use only on Decimal fields
 	//	getSobjectBooleanField						: Same but use only on Boolean fields
 	//  getSobjectQueryableFieldList        		: Get list of queryable fields for a given sobjectType suitable for use in dynamic SOQL
    //  getStdPricebook                             : Singleton to remember stdPriceBook to avoid repeated SOQL calls
    //	getStdPricebookId 							: as of V31, testmethods can locate std pricebook wo seeAlldata=true
    
    //  getUserDateFormat							: locale aware, e.g. M/d/yyyy
    //  getUserRoleId								: Get UserRoleId from UserRoleDevName ,  uses singleton to do SOQL only once in transaction
    //  getUserRole									: Get UserRole from UserRoleID ,  uses singleton to do SOQL only once in transaction
    //  getUserRole									: Get UserRole from UserRoleDevName ,  uses singleton to do SOQL only once in transaction
    
    //  getUserDateTimeFormat						: Locale-aware, e.g. M/d/yyyy hh.mm.ss
    //	getValListFromField							: Returns a list of field values from a list of sobjects; ref: http://salesforce.stackexchange.com/a/64949/2602
    //												: Usage Ex: Decimal[] amountList = (Decimal[])Util.getValListFromField(Decimal[].class,Trigger.new,Opportunity.Amount);
    //	getValsFromField							: Returns an Object of resType (a set or list) from a list of sobjects; ref: http://salesforce.stackexchange.com/questions/89028/utility-method-returning-different-type-set-instead-of-list
    //												: Usage Ex: set<decimal> amountList = (set<Decimal>)Util.getValsFromField(set<Decimal>.class,Trigger.new,Opportunity.Amount);  Uses JSON serialize/deserialize so can be slow
    //	isBetween									: Returns true if value is between (inclusive) two vals
	//	isEnqueueable								: is there headroom to enqueue a queueable job? Can be forced to false by testmethods using setter
    //	isEqualsMsp									: Are two MSP fields equal? entries may be in different order and MSP is still equal; 
    //	isExceptionAlreadyInVFMsgContext			: Returns true if exception caught by VF controller is already in the ApexPages.getMessages() context. Avoids duplicate messages
    //	isNullOrZero								: Returns true if argument is null or zero; works for Integer, Decimals, Long, and Double
	//	isValidDate									: Reurns true if date valid - parses using running User's locale as well as yyyy-mm-dd
	//  isValidEmail 								: is string a valid email asddress - source: http://salesforcesource.blogspot.com/2010/01/utilizing-apex-pattern-and-matcher.html
    //	joinDatabaseErrors							: Turn a list of Database.Error into a single string w/ delimiter
    //	joinSobjectFieldFromList					: Make a delimited string from a list of sobjects - using sobjectField; abbreviate to len; optional don;t suppress nulls
    //	makeOperandable								: return argument as 0 if null, otherwise, return argument
    //  mapKeyToLowercase                         : Convert a map string key to map of lowercased stringKey 
    //  mspAppend                         			: Append item to multi-select without duplicates.
    //	mspToHtml									: Returns HTML with <br/> inserted between each multiSelectPicklist entry
    //	now											: getter/setter to have testemthod-driven different values for now; see also today
    //  parseDate									: get date from yyyy-mm-dd and locale-specific e.g. mm/dd/yyyy or dd/mm/yyyy formats supported; null is invalid date
    //	pivotSObjectsById							: Returns a map of ID,List<Sobject> from a list of sobjects pivoted on an ID field in the list
    //	pivotSObjectsByString						: Returns a map of String,List<Sobject> from a list of sobjects pivoted on an String field in the list
    //	rpnCalculate								: calculates an expression using reverse polish notation. input is a stack of Object, output is Decimal
    //  string2Boolean                              : Convert '1', 'Y', 'Yes', 'TRUE' to true else false'
    //	stringToPrimitiveTypedObject				: Convert a string to a primitive type; return Object - used for Dynamic DML put() method
    //	today										: Returns either Date.today() or the value set by testMethod
    //	toLowercaseSet, toLowerCaseList 			: Return set or list of input set or list
    
    public class UtilException extends Exception{}
    
    //  ----------------------------------------- 
    //  dateToIso	 		 : Return date vbl as yyyy-mm-dd; null date returns null
    //  -----------------------------------------   
    public static String dateToIso(Date dt) {
        return (dt == null ? null : DateTime.newInstance(dt.year(),dt.month(),dt.day(),0,0,0).format('yyyy-MM-dd'));
    }
    
    //  ----------------------------------------- 
    //  dateToYyyyMm		: Take a date and convert to yyyymm as string
    //  -----------------------------------------   
    public static String dateToYyyyMm(Date dt) {
        return (dt == null ? null : DateTime.newInstance(dt.year(),dt.month(),dt.day(),0,0,0).format('yyyyMM'));
    } 
    
    //	-------------------------------------------------------------
    //	dirtyCaches						: Clears out (null) the static singleton caches - useful when users are mocked after caches are built
    //	-------------------------------------------------------------
    public static void dirtyCaches() {
    	
    	// cachedUserIdGroupIdToIsDirectMemberMap.clear();  	// future use
    	// gNameToGroupMap							= null;  	// future use
    	// gIdToGroupMap							= null;  	// future use 
    	profileNameToProfileMap					= null;
    	profileIdToProfileMap					= null;
    	uIdToUserMap 							= null;
    	uIdToSobjToObjectPermissionsMapMap.clear();
    	uRoleNameToUserRoleMap					= null;
    	uRoleIdToUserRoleMap					= null;
    }    
    //  ---------------------------------------------------------------------
    // domainFromEmail                      : return yyyy.com from xxx@yyyy.com (in lowercase)
    //  ---------------------------------------------------------------------   
    public static String domainFromEmail (String email) {
        String res          = null;
        String[] elmList    = email.split('@');
        if (elmList.size() == 2) res = elmList[1].toLowercase();        // all domains should come back lowercase 2010-12-16
        return res;
    }

	//	------------------------------------------------------------------------------
  	//	Email
  	//	Builder pattern for one line use of sending emails in a self-documented way in one line, see http://developer.force.com/cookbook/recipe/email-utility-class
  	//	Usage singleton: new Util.Email()
  	//						.withXXX(val)
  	//						.withYYY(val)
  	//						.sendEmail()
  	//	
  	//	Usage (bulk): 
  	//	Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>() {	
  	//							new Util.Email()
  	//							.withXXX(val)
  	//							.withYYY(val)
  	//							.make(),
  	//							new Util.Email()
  	//							.withXXX(val)
  	//							.withYYY(val)
  	//							.make() };
  	//	
  	//	Messaging.sendEmail(emails);
  	//	------------------------------------------------------------------------------
  	private static Boolean isOrgEmailDeliverable;
  	public class EmailException extends Exception {}
  	public class EmailNoCapacityException extends Exception {}
  	public class EmailNoPermissionException extends Exception {}
  	
  	public class Email {
  		private	Messaging.SingleEmailMessage	sem;
  		
  		private Messaging.EmailFileAttachment[]	attachments			= null;
  		private String[]						bccAddrs			= new List<String>();
  		private String[]						ccAddrs				= new List<String>();
  		private String							charSet				= 'UTF-8';
  		private String							htmlBody			= null;
  		private ID								orgWideEmailId		= null;
  		private String							plainTextBody		= null;
  		private String							replyToAddr			= UserInfo.getUserEmail();
  		private Integer							reserveCapacity		= 1;
  		private Boolean							saveAsActivity		= true;
  		private String							senderDisplayName	= UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
  		private String							subject				= null;
  		private ID								targetObjId			= null;
  		private ID								templateId			= null;
  		private String[]						toAddrs				= new List<String>();
  		private Boolean							useSignature		= true;
  		private ID								whatId				= null;
  		
  		public Email() {}
  		
  		@TestVisible private Email build() {
  			sem	= new Messaging.SingleEmailMessage();
  			sem.setBccAddresses(this.bccAddrs);
  			sem.setCcAddresses(this.ccAddrs);
  			sem.setCharset(this.charset);
  			sem.setFileAttachments(this.attachments);
  			if (!String.isEmpty(this.htmlBody))	sem.setHtmlBody(this.htmlBody);
  			sem.setOrgWideEmailAddressId(this.orgWideEmailId);
  			if (!String.isEmpty(this.plainTextBody)) sem.setPlainTextBody(this.plainTextBody);
  			sem.setReplyTo(this.replyToAddr);
  			sem.setSaveAsActivity(this.saveAsActivity);
  			sem.setSenderDisplayName(this.senderDisplayName);
  			if (!String.isEmpty(this.subject))	sem.setSubject(this.subject);
  			sem.setTargetObjectId(this.targetObjId);
  			sem.setTemplateId(this.templateId);
  			sem.setToAddresses(this.toAddrs);
  			sem.setUseSignature(this.useSignature);
  			sem.setWhatId(this.whatId);
  			return this;
  		}
  		
 
  		
  		public Messaging.SingleEmailMessage make() {build(); return this.sem;} 
  		
  		public void sendEmail() {
  			try {
  				System.debug(LoggingLevel.INFO,'reserve: ' + this.reserveCapacity);
  				Messaging.reserveSingleEmailCapacity(this.reserveCapacity);
  				build();
  				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {this.sem});
  			}
  			catch (System.HandledException heEx) {throw new EmailNoCapacityException(heEx);}			// caller must handle
  			catch (System.NoAccessException noeEx) {if (!Test.isRunningTest()) throw new EmailNoPermissionException(noeEx);}		// caller must handle; avoid exception in sandboxs with emaildeliverability = none or system
  			catch (Exception e) {throw new EmailException('[UTIL-04] Util.Email exception. Most likely invalid parameters ' + e.getMessage() + '\n' + e.getStackTraceString());}	// coding error in caller
  		}
  		
  		public Email withAttachments(Messaging.EmailFileAttachment[] val) 	{this.attachments = val; return this;}
  		public Email withBccAddrs(String[] val) 		{this.bccAddrs 				= val;	return this;}
  		public Email withCcAddrs(String[] val) 			{this.ccAddrs 				= val;	return this;}
  		public Email withCharSet(String val) 			{this.charSet 				= val;	return this;}
  		
  		
  		public Email withHtmlBody(String val) 			{this.htmlBody 				= val;	return this;}
  		public Email withOrgWideEmailId(ID val)			{this.orgWideEmailId 		= val;	return this;}
  		public Email withPlainTextBody(String val) 		{this.plainTextBody 		= val;	return this;}
  		public Email withReplyToAddr(String val) 		{this.replyToAddr	 		= val;	return this;}
  		public Email withReserveCapacity(Integer val) 	{this.reserveCapacity 		= val;	return this;}	// for testing capacity exception only
  		public Email withSaveAsActivity(Boolean val)	{this.saveAsActivity		= val;	return this;}
  		public Email withSenderDisplayName(String val)	{this.senderDisplayName		= val;	return this;}
  		public Email withSubject(String val) 			{this.subject		 		= val;	return this;}
  		public Email withTargetObjId(ID val)			{this.targetObjId	 		= val;	return this;}	// the recipient in a VF template
  		public Email withTemplateId(ID val)				{this.templateId	 		= val;	return this;}
  		public Email withToAddrs(String[] val) 			{this.toAddrs 				= val;	return this;}
  		public Email withUseSignature(Boolean val)		{this.useSignature			= val;	return this;}
  		public Email withWhatId(ID val)					{this.whatId				= val;	return this;}  // the relatedTo in a VF template
  	}

    
    //	------------------------------------------------------
    //	getDateSetFromField	: gets a set of Dates from a list of sobjects in <field>
    //	------------------------------------------------------
    public static Set<Date> getDateSetFromField(SObject[] records, SObjectField fieldname) {
    	return new Set<Date> ((List<Date>) getValListFromField(List<Date>.class, records, fieldname));
    }
    
    //	------------------------------------------------------------------
    //	getDateTimeGmt								: Returns a datetime in GMT from a timezoneId, date and time object
    //	------------------------------------------------------------------
    public static Datetime getDateTimeGmt(String tzId, Date d, Time t) {
    	DateTime	res;
    	Timezone	tz			= Timezone.getTimeZone(tzId);
    	DateTime	dt			= DateTime.newInstanceGmt(d,t);
    	Integer		offsetMs	= tz.getOffset(dt);					// #ms offset from datetime in Tz to GMT
    	Integer		offsetMins	= offsetMs / (1000 * 60);
    	res	= dt.addMinutes(-1 * offsetMins);
    		
    	return res;
    } 
       
    //	------------------------------------------------------
    //	getDecimalSetFromField	: gets a set of Decimal from a list of sobjects in <field>
    //	------------------------------------------------------
    public static Set<Decimal> getDecimalSetFromField(SObject[] records, SObjectField fieldname) {
    	return new Set<Decimal> ((List<Decimal>) getValListFromField(List<Decimal>.class, records, fieldname));
    } 

	//	--------------------------------------------------------
	//	getDynSoqlInExpression				: Returns a list of quoted strings suitable for use in a Database.query IN(...) expression. Handle special case of strings with quotes
	//	--------------------------------------------------------
	public static String getDynSoqlInExpression(Set<ID> searchSet) {
		String[] searchList	= new List<String>();
		for (ID id: searchSet)
			searchList.add(id);
		return getDynSoqlInExpression(searchList);	// http://salesforce.stackexchange.com/a/42266/2602
	}
	public static String getDynSoqlInExpression(Set<String> searchSet) {
		return getDynSoqlInExpression(new List<String> (searchSet));	
	}
	public static String getDynSoqlInExpression(List<ID> searchList) {
		return getDynSoqlInExpression((List<String>) searchList);
	}

	public static String getDynSoqlInExpression(List<String> searchList) {
		String[] resList	= new List<String>();
		for (String token : searchList)
			if (token != null)
				resList.add('\'' + String.escapeSingleQuotes(token) + '\'');
		return searchList.size() > 0 ? String.join(resList,',') : '';
	}
    
    //  -------------------------------------------------------------------
    //	getFirstNameFromString						: Returns First name from string (Joe Bob Tucker returns 'Joe Bob'; Gerd von Rundstedt returns Gerd). Highly imperfect for edge cases
    //  -------------------------------------------------------------------
    private static final Set<String>							plausibleLastNameTokenSet = new Set<String> {	// For ascertaining firstnames from lastnames in strings, enter as lowercase
    	'da', 'de', 'della', 'des', 'di', 'do', 'du', 'la', 'le', 'van', 'von'									// hardly perfect as there is 'van der'
    };
    public static String getFirstNameFromString(String fullname) {
    	String		res;
    	if (fullname != null) {
    		String[] tokenList	= fullname.split(' ');
    		
    		if (tokenList.size() == 1)  {}						// Only one token, must be last name
    		else
    		if (tokenList.size() == 2)							// Two tokens, assume first token is firstname
    			res	= tokenList[0];
    		else
    		if (tokenList.size() == 3) {						// Three tokens, need to distinguish between Mary Anne Tucker and Mary van Tucker
    			if (plausibleLastNameTokenSet.contains(tokenList[1].toLowerCase()))
    				res = tokenList[0];
    			else
    				res = tokenList[0] + ' ' + tokenList[1];
    		}
    		else												// Four tokens, we just use first token as firstname; best we can do
    			res = tokenList[0];			 
    	}
    	return res;
    }       
    //	------------------------------------------------------
    //	getIdSetFromField	: gets a set of Ids from a list of sobjects in <field>
    //	------------------------------------------------------
    public static Set<ID> getIdSetFromField(SObject[] records, SObjectField fieldname) {
    	return new Set<ID> ((List<ID>) getValListFromField(List<ID>.class, records, fieldname));
    } 
    
    //  -------------------------------------------------------------------
    //	getLastNameFromString						: Returns last name from string (Joe Bob Tucker returns 'Tucker'; Gerd von Rundstedt returns von Rundstedt). Highly imperfect for edge cases
    //  -------------------------------------------------------------------
    public static String getLastNameFromString(String fullname) {
    	String		res;
    	if (fullname != null) {
    		String firstName		= getFirstNameFromString(fullname);	
    		res			= fullname.substring(firstname != null ? firstName.length() + 1 : 0);		// Get first name, rest is lastname
    	}
    	return res;
    }
    
    //  -------------------------------------------------------
    //  getLocaleToDateTimeFmtMap                   : Returns a map of user locale | datetime format for that locale (http://www.interactiveties.com/b_locale_datetime.php)
    //  -------------------------------------------------------
    private static Map<String,String>                       localeToDateTimeFmtMap;             // Singleton, remember when first referenced
    public static Map<String,String> getLocaleToDateTimeFmtMap () {
        if (localeToDateTimeFmtMap == null)
            localeToDateTimeFmtMap  = new Map<String,String> {
                'ar'            => 'dd/MM/yyyy hh:mm a',
                'ar_AE'         => 'dd/MM/yyyy hh:mm a',
                'ar_BH'         => 'dd/MM/yyyy hh:mm a',
                'ar_JO'         => 'dd/MM/yyyy hh:mm a',
                'ar_KW'         => 'dd/MM/yyyy hh:mm a',
                'ar_LB'         => 'dd/MM/yyyy hh:mm a',
                'ar_SA'         => 'dd/MM/yyyy hh:mm a',
                'bg_BG'         => 'yyyy-M-d H:mm',
                'ca'            => 'dd/MM/yyyy HH:mm',
                'ca_ES'         => 'dd/MM/yyyy HH:mm',
                'ca_ES_EURO'    => 'dd/MM/yyyy HH:mm',
                'cs'            => 'd.M.yyyy H:mm',
                'cs_CZ'         => 'd.M.yyyy H:mm',
                'da'            => 'dd-MM-yyyy HH:mm',
                'da_DK'         => 'dd-MM-yyyy HH:mm',
                'de'            => 'dd.MM.yyyy HH:mm',
                'de_AT'         => 'dd.MM.yyyy HH:mm',
                'de_AT_EURO'    => 'dd.MM.yyyy HH:mm',
                'de_CH'         => 'dd.MM.yyyy HH:mm',
                'de_DE'         => 'dd.MM.yyyy HH:mm',
                'de_DE_EURO'    => 'dd.MM.yyyy HH:mm',
                'de_LU'         => 'dd.MM.yyyy HH:mm',
                'de_LU_EURO'    => 'dd.MM.yyyy HH:mm',
                'el_GR'         => 'd/M/yyyy h:mm a',
                'en_AU'         => 'd/MM/yyyy HH:mm',
                'en_B'          => 'M/d/yyyy h:mm a',
                'en_BM'         => 'M/d/yyyy h:mm a',
                'en_CA'         => 'dd/MM/yyyy h:mm a',
                'en_GB'         => 'dd/MM/yyyy HH:mm',
                'en_GH'         => 'M/d/yyyy h:mm a',
                'en_ID'         => 'M/d/yyyy h:mm a',
                'en_IE'         => 'dd/MM/yyyy HH:mm',
                'en_IE_EURO'    => 'dd/MM/yyyy HH:mm',
                'en_NZ'         => 'd/MM/yyyy HH:mm',
                'en_SG'         => 'M/d/yyyy h:mm a',
                'en_US'         => 'M/d/yyyy h:mm a',
                'en_ZA'         => 'yyyy/MM/dd hh:mm a',
                'es'            => 'd/MM/yyyy H:mm',
                'es_AR'         => 'dd/MM/yyyy HH:mm',
                'es_BO'         => 'dd-MM-yyyy hh:mm a',
                'es_CL'         => 'dd-MM-yyyy hh:mm a',
                'es_CO'         => 'd/MM/yyyy hh:mm a',
                'es_CR'         => 'dd/MM/yyyy hh:mm a',
                'es_EC'         => 'dd/MM/yyyy hh:mm a',
                'es_ES'         => 'd/MM/yyyy H:mm',
                'es_ES_EURO'    => 'd/MM/yyyy H:mm',
                'es_GT'         => 'd/MM/yyyy hh:mm a',
                'es_HN'         => 'MM-dd-yyyy hh:mm a',
                'es_MX'         => 'd/MM/yyyy hh:mm a',
                'es_PE'         => 'dd/MM/yyyy hh:mm a',
                'es_PR'         => 'MM-dd-yyyy hh:mm a',
                'es_PY'         => 'dd/MM/yyyy hh:mm a',
                'es_SV'         => 'MM-dd-yyyy hh:mm a',
                'es_UY'         => 'dd/MM/yyyy hh:mm a',
                'es_VE'         => 'dd/MM/yyyy hh:mm a',
                'et_EE'         => 'd.MM.yyyy H:mm',
                'fi'            => 'd.M.yyyy H:mm',
                'fi_FI'         => 'd.M.yyyy H:mm',
                'fi_FI_EURO'    => 'd.M.yyyy H:mm',
                'fr'            => 'dd/MM/yyyy HH:mm',
                'fr_BE'         => 'd/MM/yyyy H:mm',
                'fr_CA'         => 'yyyy-MM-dd HH:mm',
                'fr_CH'         => 'dd.MM.yyyy HH:mm',
                'fr_FR'         => 'dd/MM/yyyy HH:mm',
                'fr_FR_EURO'    => 'dd/MM/yyyy HH:mm',
                'fr_LU'         => 'dd/MM/yyyy HH:mm',
                'fr_MC'         => 'dd/MM/yyyy HH:mm',
                'hr_HR'         => 'yyyy.MM.dd HH:mm',
                'hu'            => 'yyyy.MM.dd. H:mm',
                'hy_AM'         => 'M/d/yyyy h:mm a',
                'is_IS'         => 'd.M.yyyy HH:mm',
                'it'            => 'dd/MM/yyyy H.mm',
                'it_CH'         => 'dd.MM.yyyy HH:mm',
                'it_IT'         => 'dd/MM/yyyy H.mm',
                'iw'            => 'HH:mm dd/MM/yyyy',
                'iw_IL'         => 'HH:mm dd/MM/yyyy',
                'ja'            => 'yyyy/MM/dd H:mm',
                'ja_JP'         => 'yyyy/MM/dd H:mm',
                'kk_KZ'         => 'M/d/yyyy h:mm a',
                'km_KH'         => 'M/d/yyyy h:mm a',
                'ko'            => 'yyyy. M. d a h:mm',
                'ko_KR'         => 'yyyy. M. d a h:mm',
                'lt_LT'         => 'yyyy.M.d HH.mm',
                'lv_LV'         => 'yyyy.d.M HH:mm',
                'ms_MY'         => 'dd/MM/yyyy h:mm a',
                'nl'            => 'd-M-yyyy H:mm',
                'nl_BE'         => 'd/MM/yyyy H:mm',
                'nl_NL'         => 'd-M-yyyy H:mm',
                'nl_SR'         => 'd-M-yyyy H:mm',
                'no'            => 'dd.MM.yyyy HH:mm',
                'no_NO'         => 'dd.MM.yyyy HH:mm',
                'pl'            => 'yyyy-MM-dd HH:mm',
                'pt'            => 'dd-MM-yyyy H:mm',
                'pt_AO'         => 'dd-MM-yyyy H:mm',
                'pt_BR'         => 'dd/MM/yyyy HH:mm',
                'pt_PT'         => 'dd-MM-yyyy H:mm',
                'ro_RO'         => 'dd.MM.yyyy HH:mm',
                'ru'            => 'dd.MM.yyyy H:mm',
                'sk_SK'         => 'd.M.yyyy H:mm',
                'sl_SI'         => 'd.M.y H:mm',
                'sv'            => 'yyyy-MM-dd HH:mm',
                'sv_SE'         => 'yyyy-MM-dd HH:mm',
                'th'            => 'M/d/yyyy h:mm a',
                'th_TH'         => 'd/M/yyyy, H:mm ?.',
                'tr'            => 'dd.MM.yyyy HH:mm',
                'ur_PK'         => 'M/d/yyyy h:mm a',
                'vi_VN'         => 'HH:mm dd/MM/yyyy',
                'zh'            => 'yyyy-M-d ah:mm',
                'zh_CN'         => 'yyyy-M-d ah:mm',
                'zh_HK'         => 'yyyy-M-d ah:mm',
                'zh_TW'         => 'yyyy/M/d a h:mm'
            };
            return localeToDateTimeFmtMap;
    }
    
       
    //	------------------------------------------------------
    //	getStringSetFromField	: gets a set of String from a list of sobjects in <field>
    //	------------------------------------------------------
    public static Set<String> getStringSetFromField(SObject[] records, SObjectField fieldname) {
    	return new Set<String> ((List<String>) getValListFromField(List<String>.class, records, fieldname));
    }    
    
	//	---------------------------------------------------
	//	getMsp										: Returns a MSP from a List<String> - de-dupes
	//	---------------------------------------------------
	public static String getMsp(List<String> listIn) {
		return listIn != null && listIn.size() > 0 ? getMsp(new Set<String> (listIn)) : null;
	}

	//	---------------------------------------------------
	//	getMsp										: Returns a MSP from a Set<String>
	//	---------------------------------------------------
	public static String getMsp(Set<String> setIn) {
		return setIn != null && setIn.size() > 0 ? String.join(new List<String> (setIn),';') : null;
	}
	
	//  --------------------------------------------
	//	getMsp						: Return a MSP string from a list of sobjects (for a given sobjectField) - handles duplicates
    //  --------------------------------------------
	public static String getMsp(Sobject[] sobjList, Schema.SobjectField fldToken) {
		set<String> fldVals = new set<String> ();
		for (Sobject sobj: sobjList) 
			fldVals.add((String)sobj.get(fldToken));
		
		fldVals.remove(null);
		return fldVals.isEmpty() ? null : String.join(new list<String>(fldVals),';');
	}
	
	//	--------------------------------------------------------
	//	getPickListXX: Get picklist vals for a given SObject.fieldname; flavors: 	getPickListVF - returns as list of selectOption, getPickListLabels - returns as list of PLE labels
	//																				getPickListValues - returns as list of PLE values
	//	--------------------------------------------------------
	public static List<SelectOption> getPickListVF(SObjectField fieldname ) {
		SelectOption[] res = new List<SelectOption> ();
		for (Schema.PickListEntry ple: getPickListEntries(fieldname))
			res.add(new SelectOption(ple.getLabel(),ple.getValue()));
		return res;	
	}
	public static List<String> getPickListLabels(SObjectField fieldname) {
		List<String> res = new List<String> ();
		for (Schema.PickListEntry ple: getPickListEntries(fieldname))
			res.add(ple.getLabel());
		return res;
	}
	public static List<String> getPickListValues(SObjectField fieldname) {
		List<String> res = new List<String> ();
		for (Schema.PickListEntry ple: getPickListEntries(fieldname))
			res.add(ple.getValue());
		return res;
	}
	private static List<Schema.PickListEntry> getPickListEntries(SObjectField fieldname) {
		return fieldName.getDescribe().getPickListValues();
	}
    //  --------------------------------------------------------
    //  getProfileId:   Get profileId from ProfileName, uses singelton to do SOQL only once in transaction
    //  --------------------------------------------------------
    private static Map<ID,Profile>							profileIdToProfileMap;	            // singleton, populated only once
    private static Map<String,Profile>                      profileNameToProfileMap;            // singleton, populated only once
    
    public static String getProfileId(String profileName) {
  		Profile prof = getProfile(profileName);
  		return prof != null ? prof.id : null; 
    }
     
	//  --------------------------------------------------------
    //  getProfile:   Get Profile from profileId, uses singelton to do SOQL only once in transaction
    //  --------------------------------------------------------
    public static Profile getProfile(ID profileId) {
		getProfiles();
		return profileId != null ? profileIdToProfileMap.get(profileId) : null;
	}
	//  --------------------------------------------------------
    //  getProfile:   Get Profile from profileName, uses singelton to do SOQL only once in transaction
    //  --------------------------------------------------------
    public static Profile getProfile(String profileName) {
		getProfiles();
		return profileName != null ? profilenameToProfileMap.get(profileName.toLowercase()) : null;
	}
	
	private static void getProfiles() {				// populate static so profiles fetched only once. Note that testmethods can't mock Profiles, no dml allowed
		if (profileIdToProfileMap == null) {
       		profilenameToProfileMap	= new Map<String,Profile>();
            profileIdToProfileMap = new Map<ID,Profile> ([select id, description, name from Profile]); // fetch only once for life of transaction
            for (Profile p : profileIdToProfileMap.values()) {
               profilenameToProfileMap.put(p.Name.toLowercase(),p);
            }
        }
	}
	
	private static Map<ID,RecordType>                   	rtIdToRecordTypeMap;            	// singleton, populated only once
    private static map<String, map<String,RecordType>>		sobjToRtDevNameToRecordTypeMapMap;	// singleton, populated only once
	//	-----------------------------------------------------
	//	getRecordTypeId	: from sobjectType and name (tries for label first, then developer Name)
	//	-----------------------------------------------------
	public static ID getRecordTypeId(Schema.SobjectType sObjType, String rtName){
  
	     Map<String, Schema.RecordTypeInfo> rtNameToRtInfoMap	= sObjType.getDescribe().getRecordTypeInfosByName();
	     if (rtNameToRtInfoMap.containsKey(rtName))
	     	return rtNameToRtInfoMap.get(rtName).getRecordTypeId();
	     
	     //	Try DevName - as of V37, this isn't available via describe so we have to query RecordTypes
	     getRecordTypes();
	   
	     map<String,RecordType> devNameToRecordTypeMap = sobjToRtDevNameToRecordTypeMapMap.get(sObjType.getDescribe().getName());
	     if (devNameToRecordTypeMap != null) {
	     	if (devNameToRecordTypeMap.containsKey(rtName))
	     		return devNameToRecordTypeMap.get(rtName).Id;
	     	else
	     		throw new UtilException('[UTIL-01] No such recordType: '+ rtName +' for SObject: ' + sObjType);	
	     }
	     else
	     	throw new UtilException('[UTIL-01] No such recordType: '+ rtName +' for SObject: ' + sObjType);	
	     return null;		// apex compiler needs a return 
  }

	//	-----------------------------------------------------------------
	//  getRecordTypeName : Return the recordType Name for a given RecordTypeId (note - not DeveloperName)
    //	-----------------------------------------------------------------
	public static String getRecordTypeName(Schema.SObjectType sobjType, ID rtId) {
		return rtId != null ? sObjType.getDescribe().getRecordTypeInfosByID().get(rtId).getName() : null;
	}

	//	-----------------------------------------------------------------
	//  getRecordTypeDevName : Return the recordType DeveloperName for a given RecordTypeId 
    //	-----------------------------------------------------------------
	public static String getRecordTypeDevName(Schema.SObjectType sobjType, ID rtId) {
		getRecordTypes();
		return rtId != null ? rtIdToRecordTypeMap.get(rtId).DeveloperName : null;
	}

	//	---------------------------------------------------------------------
	//	getRecordTypes - build maps from SOQL
	//	---------------------------------------------------------------------
	public static void getRecordTypes() {
		if (sobjToRtDevNameToRecordTypeMapMap != null)	return; 	// cache built
		
		sobjToRtDevNameToRecordTypeMapMap 	= new map<String,map<String,RecordType>>();
		rtIdToRecordTypeMap					= new map<ID,RecordType>();
		for (RecordType rt: [select id, name, BusinessProcessId, Description, DeveloperName, IsActive, SObjectType FROM RecordType ]) {
			map<String,RecordType> workMap = sobjToRtDevNameToRecordTypeMapMap.containsKey(rt.SObjectType) ? sobjToRtDevNameToRecordTypeMapMap.get(rt.SObjectType) : new map<String,RecordType>();
			workmap.put(rt.DeveloperName,rt);
			sobjToRtDevNameToRecordTypeMapMap.put(rt.SObjectType,workMap);
			rtIdToRecordTypeMap.put(rt.Id,rt);
		}
	}
	
	//	-----------------------------------------------------
	//	getSchedulerCronExpression					: Returns a Cron expression for a datetime suitable for Apex Schedulable class
	//	-----------------------------------------------------
	public static String getSchedulerCronExpression(Datetime dtIn) {
        DateTime dt		= dtIn == null ? now.addSeconds(10) : dtIn;
        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }

	//  -------------------------------------------------------------
	//	getSobjectFieldAsString						: Returns value (as string) of sobject field regardless of #levels to parent (e.g. SObject=Account, field = Parent.Parent.Parent.Owner.LastName)
	//	getSobjectStringField						: Same but use only on string fields 	
 	//	getSobjectDateField							: Same but use only on Date fields
 	//	getSobjectDateTimeField						: Same but use only on Datetime fields
 	//	getSobjectDecimalField						: Same but use only on Decimal fields
 	//	getSobjectBooleanField						: Same but use only on Boolean fields
 	//  -------------------------------------------------------------
 	public static Boolean 	getSobjectBooleanField(Sobject sObj, String fieldRef) 	{return (Boolean) getSobjectField(sObj, fieldRef);}
 	public static Date 		getSobjectDateField(Sobject sObj, String fieldRef) 		{return (Date) getSobjectField(sObj, fieldRef);}
 	public static DateTime 	getSobjectDatetimeField(Sobject sObj, String fieldRef) 	{return (Datetime) getSobjectField(sObj, fieldRef);}
 	public static Decimal 	getSobjectDecimalField(Sobject sObj, String fieldRef) 	{return (Decimal) getSobjectField(sObj, fieldRef);}
 	public static String 	getSobjectStringField(Sobject sObj, String fieldRef) 	{return (String) getSobjectField(sObj, fieldRef);}
 	public static String 	getSobjectFieldAsString(Sobject sObj, String fieldRef) 	{return String.valueOf(getSobjectField(sObj, fieldRef));}
 	
 	private static Object getSobjectField(Sobject sObj, String fieldRef) {
 		
 		Sobject sObjNode	= sObj;
 		//	fieldRef is relative to the sobject and may include relationshipNames
 		//		Handle use cases:
 		//			fld0				- fld0 on Sobject passed as argument
 		//			fld0.fld1			- fld1 is on sobject fld0
 		//			fld0.fld1. ... fldN	- fldN is on sobject fldN-1
 		String[] fieldList	= fieldRef.split('\\.');
 		
 		for (Integer i=0; i < fieldList.size() -1; i++) {
 			sObjNode	= (Sobject) sObjNode.getSobject(fieldList[i]);	// intermediate fields are sobjects
 			if (sObjNode == null) return null;
 		}
 		return sObjNode.get(fieldList[fieldList.size()-1]);	// use fldN
 	}

    //	------------------------------------------------------
    //	getStdPricebookId : as of V31, testmethods can locate std pricebook wo seeAlldata=true
    //	------------------------------------------------------
    public static ID getStdPricebookId() {
    	if (Test.isRunningTest())	return Test.getStandardPricebookId();
    	return getStdPricebook().Id;	
    } 
    
    //  -------------------------------------------------------
    //  getStdPriceBook: Singleton
    //  -------------------------------------------------------
    private static Pricebook2                               stdPriceBook;                       // Singleton, remember when first referenced
    public static Pricebook2    getStdPriceBook () {
        if (stdPriceBook == null) 
            stdPriceBook    = [select Id, Name from Pricebook2 where isStandard = true limit 1];
        return stdPriceBook;    
    }
   
    //  -------------------------------------------------------
    //  getUser: Singleton
    //  -------------------------------------------------------
    private static Map<ID,User>                             uIdToUserMap;                       // Singleton, remember when first referenced, key = User.id
    private static Map<ID,Map<String,ObjectPermissions>>    uIdToSobjToObjectPermissionsMapMap      = new Map<ID,Map<String,ObjectPermissions>> (); // 2013-08-06 singleton static to memorialize across xact life
    public static User getUser(ID uId) {
        getUsers();
        User u = uidToUserMap.get(uid);
        if (uId != null && uId.getSobjectType() == Schema.User.SObjectType && u == null)
        	throw new UtilException('[UTIL-11] No User exists for id = ' + uId + '. Probable cause is testmethod sets up users after inserts of test SObjects' + 
        							' - esp Oppo. Users are cached upon first reference to getUser() so if created after first reference, they won\'t be found. Use Util.dirtyCaches method');
        return u;
    }

    //  -------------------------------------------------------
    //  getUsers: Utility singleton
    //  -------------------------------------------------------
    private static void getUsers() {
        //  Initialize static maps if first time called
        if (uidToUserMap == null)
            uidToUserMap = new Map<ID,User> ([select id, isActive, name, email, phone, profileId, Profile.name, userRoleId, UserRole.name, UserRole.DeveloperName from User]);          
    }
    
    //  -------------------------------------------------------
    //  getUserDateFormat: e.g. M/d/yyyy
    //  -------------------------------------------------------
    public static String getUserDateFormat() {
        String      userLocale  = UserInfo.getLocale();
        getLocaleToDateTimeFmtMap();
        if (!localeToDateTimeFmtMap.containsKey(userLocale))    return 'yyyy-mm-dd';
        return localeToDateTimeFmtMap.get(userLocale).substringBefore(' ');
    }
    //  -------------------------------------------------------
    //  getUserDateTimeFormat: e.g. M/d/yyyy hh.mm.ss
    //  -------------------------------------------------------
    public static String getUserDateTimeFormat() {
        String      userLocale  = UserInfo.getLocale();
        getLocaleToDateTimeFmtMap();
        if (!localeToDateTimeFmtMap.containsKey(userLocale))    return 'yyyy-mm-dd hh.mm.ss';
        return localeToDateTimeFmtMap.get(userLocale);
    }
        
    //  --------------------------------------------------------
    //  getUserRoleId:   Get UserRoleId from UserRoleDevName ,  uses singleton to do SOQL only once in transaction
    //  --------------------------------------------------------
    private static Map<ID,UserRole>							uRoleIdToUserRoleMap;	            // singleton, populated only once
    private static Map<String,UserRole>                      uRoleNameToUserRoleMap;            // singleton, populated only once
    
    public static String getUserRoleId(String userRoleName) {
  		UserRole userRole = getUserRole(userRoleName);
  		return userRole != null ? userRole.id : null; 
    }
     
	public static UserRole getUserRole(ID userRoleId) {
		getUserRoles();
		return userRoleId != null ? uRoleIdToUserRoleMap.get(userRoleId) : null;
	}
	public static UserRole getUserRole(String userRoleDevName) {
		getUserRoles();
		return userRoleDevName != null ? uRoleNameToUserRoleMap.get(userRoleDevName.toLowercase()) : null;
	}
	
	private static void getUserRoles() {				// populate static so UserRoles fetched only once. Note that testmethods can mock UserRoles
		if (uRoleIdToUserRoleMap == null) {
       		uRoleNameToUserRoleMap	= new Map<String,UserRole>();
            uRoleIdToUserRoleMap = new Map<ID,UserRole> ([select Id, Name,  ParentRoleId, DeveloperName from UserRole]); // fetch only once for life of transaction
            for (UserRole ur : uRoleIdToUserRoleMap.values()) {
               System.debug('UserRolename:'+ur.developerName);
               uRoleNameToUserRoleMap.put(ur.developerName.toLowercase(),ur);
            }
        }
	}		    
    //	--------------------------------------------------------
    //	getValListFromField							: Returns a list of field values from a list of sobjects; ref: http://salesforce.stackexchange.com/a/64949/2602
    //												: Usage Ex: Decimal[] amountList = (Decimal[])Util.getValListFromField(Decimal[].class,Trigger.new,Opportunity.Amount);
    //	--------------------------------------------------------
    public static Object[] getValListFromField(Type resListType, SObject[] records, SObjectField fieldname) {
    	Object[] res	= (Object[])resListType.newInstance();
    	for (SObject sObj: records)
    		res.add(sobj.get(fieldname));
    	return res;	
    }

    //	--------------------------------------------------------
    //	getValsFromField							: Returns an Object of resType (a set or list) from a list of sobjects; ref: http://salesforce.stackexchange.com/questions/89028/utility-method-returning-different-type-set-instead-of-list
    //												: Usage Ex: set<decimal> amountList = (set<Decimal>)Util.getValsFromField(set<Decimal>.class,Trigger.new,Opportunity.Amount);
    //	--------------------------------------------------------
    public static Object getValsFromField(Type resType, SObject[] records, SObjectField fieldname) {
    	set<Object> res	= new set<Object>();
    	for (SObject sObj: records)
    		res.add(sobj.get(fieldname));
    	return JSON.deserialize(JSON.serialize(res),resType);		//	allows callers to cast set<Object> to set<someType> - this can be slow though
    }

	//	----------------------------------------
	//	isBetween									: Returns true if value is between (inclusive) two vals
	//	----------------------------------------
	public static Boolean isBetween(Decimal bound1, Decimal bound2, Decimal val) {
		if (bound1 == null || bound2 == null || val == null)	return false;
		Decimal smallerBound	= bound1 < bound2 ? bound1 : bound2;
		Decimal largerBound		= bound2 > bound1 ? bound2 : bound1;
		return  (val >= smallerBound && val <= largerBound);
			
	}
    
	//	--------------------------------------------
	//	isEnqueueable	: is there headroom to enqueue a queueable job? Can be forced to false by testmethods using setter
	//	--------------------------------------------
	public static Boolean	isEnqueueable {
		get {return isEnqueueable == null ? Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0 : isEnqueueable;}
		set;
	}
	//	------------------------------------------------------------
    //	isEqualsMsp		: Are two MSP fields equal? entries may be in different order and MSP is still equal; 
    //	------------------------------------------------------------
    public static Boolean isEqualsMsp(String msp1, String msp2) {
    	if (msp1 == msp2)									return true;			// simple case, null - null; or entries in same order
    	if (String.isBlank(msp1) && !String.isBlank(msp2))	return false;
    	if (!String.isBlank(msp1) && String.isBlank(msp2))	return false;
    	msp1	= msp1.toLowerCase();
    	msp2	= msp2.toLowerCase();
    	String[] msp1TokenList = msp1.split(';');
    	String[] msp2TokenList = msp2.split(';');
    	if (msp1TokenList.size() != msp2TokenList.size())	return false;			// different number of entries
    	msp1TokenList.sort();
    	msp2TokenList.sort();
    	
    	for (Integer i = 0; i < msp1TokenList.size(); i++)
    		if (msp1TokenList[i] != msp2TokenList[i])	return false;				// entry [i] doesn't match
    	return true;																// all good!	
    		
    }
    //	----------------------------------------
	//	isExceptionAlreadyInVFMsgContext
	// 	-----------------------------------------
	public static Boolean isExceptionAlreadyInVFMsgContext(Exception e) {
		Boolean res = false;
		for (ApexPages.Message m : ApexPages.getMessages())
			if (e.getMessage().contains(m.getSummary())) {res = true; break;}
		return res;
	}
	//	----------------------------------------
	//	isNullOrZero
	//	----------------------------------------
	public static Boolean isNullOrZero(Decimal num) {return (num == null || num == 0);}
	public static Boolean isNullOrZero(Integer num) {return (num == null || num == 0);}
	public static Boolean isNullOrZero(Long num) 	{return (num == null || num == 0);}
	public static Boolean isNullOrZero(Double num) 	{return (num == null || num == 0);}    	
	
	//  --------------------------------------------------------
	//	isValidDate	- is date valid - parses using running User's locale as well as yyyy-mm-dd
	//  --------------------------------------------------------
	public static Boolean isValidDate(String inDate) {return parseDate(inDate) != null;}
	
	//  --------------------------------------------------------
    //  isValidEmail - source: http://salesforcesource.blogspot.com/2010/01/utilizing-apex-pattern-and-matcher.html
    //  --------------------------------------------------------
    public static Boolean isValidEmail(String email) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        return email == null
        	? false
        	: Pattern.compile(emailRegex).matcher(email).matches();
        
    }
	    
	//	----------------------------------------
	//	joinDatabaseErrors							: Turn a list of Database.Error into a single string w/ delimiter	
	//	----------------------------------------
	public static String joinDatabaseErrors(Database.Error[] errList,String delim) {
		String[] errMsgList		= new List<String> ();
		for (Database.Error err: errList)
			errMsgList.add(err.getMessage());
		return String.join(errMsgList,delim);	
	}
    
    //  ----------------------------------------------------
    //	joinSobjectFieldFromList			: Make a delimited string from a list of sobjects - using sobjectField; null values suppressed
	//  ----------------------------------------------------
	public static String joinSobjectFieldFromList(Sobject[] sobjList, Schema.SobjectField fldToken, String delim, Integer truncLen) {
		return joinSobjectFieldFromList(sObjList,fldToken,delim,truncLen,true);
	}
	public static String joinSobjectFieldFromList(Sobject[] sobjList, Schema.SobjectField fldToken, String delim, Integer truncLen, Boolean suppressNulls) {
		String[] vals = new List<String>();
		for (String s: (List<String>)getValListFromField(List<String>.class, sobjList, fldToken))
			if (String.isBlank(s) && suppressNulls) {}
			else
				vals.add(s);
		
		return String.join(vals,delim).abbreviate(truncLen);
	}      
	
    //	----------------------------------------------
    //	makeOperandable	: return argument as 0 if null, otherwise, return argument
    //	----------------------------------------------
    public static Decimal makeOperandable(Decimal d) {
    	return d == null ? 0 : d;
    }
	//  ----------------------------------------------------
    //  mapKeyToLowercase                         : Convert a map string key to map of lowercased stringKey 
    //  ----------------------------------------------------
	public static map<String,Object> mapKeyToLowercase(map<String,Object> unknownCaseKeyToObjectMap) {
		map<String,Object> res	= new map<String,Object> ();
		for (String k: unknownCaseKeyToObjectMap.keySet())
			res.put(k == null ? null : k.toLowercase(),unknownCaseKeyToObjectMap.get(k));
		return res;	
	}
 
    //  ----------------------------------------------------
    //  mspAppend                         : Append string to multi-select without duplicates. 
    //  ----------------------------------------------------
    public static String mspAppend(String mspIn, String newItem) {
        String res = mspIn;
        //      Append only unique multiSelect item not previously seen
        if (newItem == null) {}
        else
        if (res == null) res = newItem;     // first item seen, so smash
        else {
            Boolean found = false;
            for (String item: mspIn.split(';')) 
                if (item == newItem) {found = true; break;}
            if (!found)
                res = res + ';' + newItem;  // newItem not in list   
        }
        return res;
    } 
  
    //	------------------------------------------------------
	//	mspToHtml							: Returns HTML with <br/> inserted between each multiSelectPicklist entry
	//	------------------------------------------------------
	public static String mspToHtml(String mspIn) {
		if (mspIn == null)	return null;
		String		res			= '';
		String		work;	
		work					= mspIn.replaceAll('; ',';');	// handle cases where delimiter between entries is '; ' as opposed to just ';'
		String[]	tokenList	= work.split(';');
		for (String t: tokenList)
			res					+= String.isEmpty(res) ? t : '<br/>' + t;
		return res;
	}	
	
	//	-----------------------------------------------
    //	now		: getter/setter to have testemthod-driven different values for now; see also today
    //	-----------------------------------------------
    public static DateTime now		{get {return now == null ? DateTime.now() : now;} set;}
   
    //  --------------------------------------------------------
    //  parseDate; null is invalid Date; yyyy-mm-dd and locale-specific e.g. mm/dd/yyyy or dd/mm/yyyy formats supported
    //  --------------------------------------------------------
    public static Date parseDate(String inDate) {
        Date    dateRes     = null;
        //  1 - Try yyyy-mm-dd     
        try {
            String candDate     = inDate.substring(0,10);           // grab date portion only, ignore time, if any
            dateRes             = Date.valueOf(candDate);
                
        }
        catch (Exception e) {}

        if (dateRes == null) {
        //  2 - Try locale specific mm/dd/yyyy or dd/mm/yyyy         
            
            try {
               	String candDate  = inDate.replaceAll('-','/').substring(0,Math.min(10,inDate.length()));         // grab date portion only m[m]/d[d]/yyyy , ignore time, if any
            	dateRes    		 = Date.parse(candDate); 
            }
            catch (Exception e) {} 
        }
        
        
        
        return dateRes;
    }
   
    //  --------------------------------------------------------
    //	pivotSObjectsById							: Returns a map of ID,List<Sobject> from a list of sobjects pivoted on an ID field in the list
    //  --------------------------------------------------------
    public static map<ID,List<SObject>> pivotSObjectsById(Schema.SObjectField fldToken, SObject[] sobjList) {
    	map<ID,List<SObject>>	res = new map<ID,List<SObject>> ();
    	for (Sobject sobj: sobjList) {
  			ID pivotKey = (ID) sobj.get(fldToken);
  			Object o = res.containsKey(pivotKey)
      			? res.get(pivotKey).add(sobj)
      			: res.put(pivotKey,new List<Sobject> {sobj});
		} 
		return res;
    }
    //  --------------------------------------------------------
    //	pivotSObjectsByString						: Returns a map of String,List<Sobject> from a list of sobjects pivoted on an String field in the list
    //  --------------------------------------------------------
    public static map<String,List<SObject>> pivotSObjectsByString(Schema.SObjectField fldToken, SObject[] sobjList) {
    	map<String,List<SObject>>	res = new map<String,List<SObject>> ();
    	for (Sobject sobj: sobjList) {
  			String pivotKey = (String) sobj.get(fldToken);
  			Object o = res.containsKey(pivotKey)
      			? res.get(pivotKey).add(sobj)
      			: res.put(pivotKey,new List<Sobject> {sobj});
		} 
		return res;
    }
    
    //	--------------------------------------------------------------------
    //	rpnCalculate								: calculates an expression using reverse polish notation
    //	--------------------------------------------------------------------
    public static Decimal rpnCalculate(Object[] rpnExprStack) {
    	// Each stack element is either a decimal or a string (+ - * or / )  . Example [0] 35 [1] 7 [2] / divides 35 by 7, returning 5
    	Decimal		res	= 0;
    	Object[]	workRpnExprStack	= new List<Object> ();
    	for (Object obj : rpnExprStack)		// make copy of stack as we'll be modifying it
    		workRpnExprStack.add(obj);
    	
    	if (workRpnExprStack.size() == 1 && workRpnExprStack[0] instanceOf String)
    		throw new UtilException('[UTIL-08] Invalid RPN expression stack (leading operator): ' + rpnExprStack);
    	
    	while (workRpnExprStack.size() > 1) {
    		Object expr0	= workRpnExprStack[0];
    		Object expr1	= workRpnExprStack[1];
    		Object expr2	= workRpnExprStack.size() >2 ? workRpnExprStack[2] : null;
    		//	we either have dec dec operator, operator expr, dec operator, or dec operator expr
    		if (expr0 instanceof String)
    			throw new UtilException('[UTIL-08] Invalid RPN expression stack (dangling operator): ' + rpnExprStack);
    		if (expr0 instanceOf Decimal && expr1 instanceOf Decimal && expr2 instanceOf String) {
    			String operator	= (String) expr2;
    			if (operator == '+')
    				res 	= (Decimal) expr0 + (Decimal) expr1;
    			else	
    			if (operator == '-')
    				res 	= (Decimal) expr0 - (Decimal) expr1;
    			else
    			if (operator == '*')
    				res 	= (Decimal) expr0 * (Decimal) expr1;
    			else
    			if (operator == '/')
    				res 	= (Decimal) expr0 / (Decimal) expr1;
    			else
    				throw new UtilException('[UTIL-08] Invalid RPN expression stack (unsupported operator): ' + rpnExprStack);
    			workRpnExprStack.remove(0);	// pop expr 0
    			workRpnExprStack.remove(0); // pop expr 1
    			workRpnExprStack.remove(0);	// pop operator
    			if (workRpnExprStack.size() > 0)
    				workRpnExprStack.add(0,res);// push res to front of stack
    			else
    				workRpnExprStack.add(res);		
    		}	
    		else
    			throw new UtilException('[UTIL-08] Invalid RPN expression stack (expressions/operators): ' + rpnExprStack);
    		
    		
    	}
    	res		= (Decimal) workRpnExprStack[0];
    	return res;
    }   
    

    //  -----------------------------------------------------
    //  string2Boolean: Needs to be language aware (Spanish)
    //  -----------------------------------------------------
    public static Boolean string2Boolean(String s) {
        return s == null ? false : s.toLowercase() ==  '1' || s.toLowercase() == 'true' || s.toLowercase() == 'yes' || s.toLowercase() == 'y' || s.toLowercase() == 't';
    }    
     
	//  -----------------------------------------------------
    //	stringToPrimitiveTypedObject - inVal must be a valid value for its type   -- this needs reworking as map is not constructable - inVAl = 'a' Decimal.valueOf(inVal) throws exception
    //  -----------------------------------------------------
    public static Object stringToPrimitiveTypedObject(SobjectField fld, String inVal) {
    	// returns an Object of proper type
    	Schema.DescribeFieldResult          fieldDescribe           = fld.getDescribe();
    	Schema.DisplayType					fieldType				= fieldDescribe.getType();											// field type
    	
    	
    	try {
    		if (fieldType == Schema.DisplayType.Boolean)
    			return string2Boolean(inVal);
    		else 
    		if (fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Integer || fieldType == Schema.DisplayType.Percent)
    			return Decimal.valueOf(inVal);
    		else
    		if (fieldType == Schema.DisplayType.Date)
    			return parseDate(inVal);		
    		else
    		if (fieldType == Schema.DisplayType.DateTime)
    			return parseDate(inVal) == null ? null : DateTime.newInstance(parseDate(inVal),Time.newInstance(0,0,0,0));
    		else
    		if (fieldType == Schema.DisplayType.Double)
    			return Double.valueOf(inVal);
    		else
    		if (fieldType == Schema.DisplayType.Email || fieldType == Schema.DisplayType.MultiPicklist || fieldType == Schema.DisplayType.Phone || fieldType == Schema.DisplayType.Picklist ||
    			fieldType == Schema.DisplayType.Reference || fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.TextArea || fieldType == Schema.DisplayType.URL)
    			return inVal;				
    			
    	}
    	catch (Exception e) {
    		throw new UtilException('[UTIL-13] Value: ' + inVal + ' not valid for ' + fieldType);
    	}
    																
    	return inVal;

    }
	
	//	-----------------------------------------------
    //	today		: getter/setter to have testemthod-driven different values for today; see also now
    //	-----------------------------------------------
    public static Date today		{get {return today == null ? Date.today() : today;} set;}

    //	------------------------------------------------------
	//	toLowercaseSet, toLowerCaseList - return set or list of input set or list
	//	------------------------------------------------------
	public static list<String> toLowercaseList(set<String> strings) {
		return toLowercaseList(new list<String>(strings));
	}
	public static set<String> toLowercaseSet(set<String> strings) {
		return toLowercaseSet(new list<String>(strings));
	}
	public static set<String> toLowercaseSet(List<String> strings) {
		return new set<String>(toLowercaseList(strings));
	}
	public static list<String> toLowercaseList(list<String> strings) {
		list<String> res = new list<String>();
		for (String s: strings)
			res.add(s != null ? s.toLowercase() : null);
		return res;	
	}        
}