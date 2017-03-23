@isTest
private class UtilTest {
	// keep tests in alpha order

    //	testDateToIso
    @isTest
    private static void testDateToIso() {
    	System.assertEquals('2020-01-01', Util.dateToIso(Date.newInstance(2020,1,1)));
    }
    
    //	testDateToYyyyMm
    @isTest
    private static void testDateToYyyyMm() {
    	System.assertEquals('202001', Util.dateToYyyyMm(Date.newInstance(2020,1,1)));
    }
    
    //	testDomainFromEmail
    @isTest
    private static void testDomainFromEmail() {
        System.assertEquals('foo.com',Util.domainFromEmail('JOE@FOO.COM'));
    }
    
    //	testEmail
    @isTest
    private static void testEmail() {
    	
    	//	Verify exception thrown when invalid parms - untestable when sandbox has emaildeliverability = off
    /*	try {
    		new Util.Email()
    			.withToAddrs(new List<String>{})
    			.sendEmail();
    		System.assert(false,'shouldnt happen, missing toAddrs, plainTextBody or HtmlBody');
    	}
		catch (Exception e) {System.assert(e.getTypeName() == 'Util.EmailException');}
		*/ 
		// Verify build()
		try {
			new Util.Email()
			.build();
		}
		catch (Exception e) {System.assert(false,'Shouldnt, build on all empty values should not fail');}	
		//	Verify email sent when valid parms
		Integer emailsSentBefore	= Limits.getEmailInvocations();
		try {
    		new Util.Email()
    			.withToAddrs(new List<String>{'foo@bar.com'})
    			.withAttachments(new List<Messaging.EmailFileAttachment>())
    			.withPlainTextBody('fooBody')
    			.withBccAddrs(new List<String>{})
    			.withCcAddrs(new List<String>{})
    			.withCharSet('UTF-8')
    			.withReplyToAddr('bar@foo.com')
    			.withSaveAsActivity(false)
    			.withSubject('some subj')
    			.withUseSignature(false)
    			.sendEmail();
    	}
		catch (Exception e) {System.assert(false,'shouldnt happen, valid email: ' + e.getMessage());}
		// Untestable when sandbox has emaildeliverability = none/system System.assert(Limits.getEmailInvocations() > emailsSentBefore,'if email successfully queued, then invocations should be more than when we started');
		
		//	untestable when sandbox has email deliverability = none/system; no Organization method to query for this condition 
		//	Verify exception thrown when capacity exceeded 
		/*try {
    		new Util.Email()
    			.withToAddrs(new List<String>{'foo@bar.com'})
    			.withPlainTextBody('fooBody')
    			.withReserveCapacity(1000000)
    			.sendEmail();
    		System.assert(false,'shouldnt happen, exceeded capacity');	
    	}
		catch (Exception e) {System.assert(e.getTypeName() == 'Util.EmailNoCapacityException');}
		*/     	
    } 

	//	testGetDateSetFromField
	@isTest
	private static void testGetDateSetFromField() {
		Campaign[]	cList	= new List<Campaign> {	new Campaign (name='foo00', StartDate=Date.newInstance(2030,1,1)),
													new Campaign (name='foo01', StartDate=Date.newInstance(2030,1,1)),
													new Campaign (name='foo02', StartDate=Date.newInstance(2031,1,1))
		};
		insert cList;
		set<Date> res	= Util.getDateSetFromField(cList,Campaign.StartDate);
		System.assertEquals(2,res.size(),'sb two unique StartDates');
		System.assert(res.contains(cList[0].StartDate) && res.contains(cList[2].StartDate),'verify set has both StartDates; actual:'+res);
	}
	
	//	testGetDateTimeGmt
	@isTest
	private static void testGetDateTimeGmt() {
		String 	tz;
		Date	d;
		Time	t;
		
		//	Verify Pacific Std (January) and DST (May)
		System.assertEquals(DateTime.newInstanceGmt(2020,1,1,19,0,0), 	Util.getDateTimeGmt('America/Los_Angeles',Date.newInstance(2020,1,1),Time.newInstance(11,0,0,0)),'sb offset by -8 hours - not DST');
		System.assertEquals(DateTime.newInstanceGmt(2020,5,1,18,0,0), 	Util.getDateTimeGmt('America/Los_Angeles',Date.newInstance(2020,5,1),Time.newInstance(11,0,0,0)),'sb offset by -7 hours -  DST');
		System.assertEquals(DateTime.newInstanceGmt(2020,5,2,4,0,0), 	Util.getDateTimeGmt('America/Los_Angeles',Date.newInstance(2020,5,1),Time.newInstance(21,0,0,0)),'sb offset by -7 hours -  DST but GMT is next day');
		
		// Go the other way - Europe/Paris
		System.assertEquals(DateTime.newInstanceGmt(2020,1,1,10,0,0), 	Util.getDateTimeGmt('Europe/Paris',Date.newInstance(2020,1,1),Time.newInstance(11,0,0,0)),'sb offset by +1 hours - not DST');
		System.assertEquals(DateTime.newInstanceGmt(2020,6,1,9,0,0), 	Util.getDateTimeGmt('Europe/Paris',Date.newInstance(2020,6,1),Time.newInstance(11,0,0,0)),'sb offset by +2 hours - DST');
	}
	
	
	//	testGetDecimalSetFromField
	@isTest
	private static void testGetDecimalSetFromField() {
		Campaign[]	cList	= new List<Campaign> {	new Campaign (name='foo00', ExpectedRevenue=10.0),
													new Campaign (name='foo01', ExpectedRevenue=10.0),
													new Campaign (name='foo02', ExpectedRevenue=20.0)
		};
		insert cList;
		set<Decimal> res	= Util.getDecimalSetFromField(cList,Campaign.ExpectedRevenue);
		System.assertEquals(2,res.size(),'sb two unique ExpectedRevenues');
		System.assert(res.contains(cList[0].ExpectedRevenue) && res.contains(cList[2].ExpectedRevenue),'verify set has both ExpectedRevenues; actual:'+res);
	}
	
	// testDirtyCaches
	@isTest
	private static void testDirtyCaches() {
		Profile p = Util.getProfile(UserInfo.getProfileId());
		Integer soqlBeforeDirty = Limits.getQueries();
		Util.dirtyCaches();
		p = Util.getProfile(UserInfo.getProfileId());		// should refetch
		System.assert(Limits.getQueries() > soqlBeforeDirty,'dirty cache should force another query');
	}
		
	//	testGetDynSoqlInExpression
	@isTest
	private static void testGetDynSoqlInExpression() {
		Account[] aList = new List<Account> {
									new Account (name = '00name'),
									new Account (name = '01name')
							};
		insert aList;
		String res = Util.getDynSoqlInExpression(new List<ID> {aList[0].id,aList[1].id});
		System.assertEquals('\''+aList[0].id+'\'' + ',' + '\''+aList[1].id+'\'', res);
		
		res = Util.getDynSoqlInExpression(new List<ID> {aList[0].id,null,aList[1].id});
		System.assertEquals('\''+aList[0].id+'\'' + ',' + '\''+aList[1].id+'\'', res, 'null arg sb ignored');	
		
		res = Util.getDynSoqlInExpression(new Set<ID> {aList[0].id,aList[1].id});
		System.assert((res == '\''+aList[0].id+'\''+','+'\''+aList[1].id+'\'') || (res == '\''+aList[1].id+'\''+','+'\''+aList[0].id+'\'')); // with sets, order is indeterminate
		
		res = Util.getDynSoqlInExpression(new Set<String> {(String)aList[0].id,(String)aList[1].id});
		System.assert((res == '\''+aList[0].id+'\''+','+'\''+aList[1].id+'\'') || (res == '\''+aList[1].id+'\''+','+'\''+aList[0].id+'\'')); // with sets, order is indeterminate
		
		res	= Util.getDynSoqlInExpression(new Set<ID> {});
		System.assertEquals('',	res,'empty list/set of args should return empty string');
	}
	//	testGetFirstAndLastNameFromString
    @isTest
    private static void testGetFirstAndLastNameFromString() {
    	System.assertEquals('Joe',			Util.getFirstNameFromString('Joe Tucker'));
    	System.assertEquals('Tucker',		Util.getLastNameFromString('Joe Tucker'));
    	System.assertEquals('Joe Bob',		Util.getFirstNameFromString('Joe Bob Tucker'));
    	System.assertEquals('Tucker',		Util.getLastNameFromString('Joe Bob Tucker'));
    	System.assertEquals('Joe',			Util.getFirstNameFromString('Joe von Tucker'));
    	System.assertEquals('von Tucker',	Util.getLastNameFromString('Joe von Tucker'));
    	System.assertEquals('Joe',			Util.getFirstNameFromString('Joe von Tucker II'));
    	System.assertEquals('von Tucker II',Util.getLastNameFromString('Joe von Tucker II'));

    	
    	System.assertEquals(null,			Util.getFirstNameFromString('Tranh'));
    	System.assertEquals('Tranh',		Util.getLastNameFromString('Tranh'));
    	
    	System.assertEquals(null,			Util.getFirstNameFromString(''));
    	System.assertEquals('',				Util.getLastNameFromString(''));
    	
    	System.assertEquals(null,			Util.getFirstNameFromString(null));
    	System.assertEquals(null,			Util.getLastNameFromString(null));   	
    } 
    
	//	testGetIdSetFromField
	@isTest
	private static void testGetIdSetFromField() {
		Account[] aParentList			= new List<Account> {new Account(name = '00Parent')};
		insert aParentList;
		Account[] aChildList			= new List<Account> {
												new Account(name = '00_0Child', parentId=aParentList[0].id),
												new Account(name = '00_1Child', parentId=aParentList[0].id)
		};
		insert	aChildList;
																	
		Set<ID> resIdSet	= Util.getIdSetFromField(aChildList,Account.Parentid);
		System.assertEquals(1,	resIdSet.size());
		System.assert(resIdSet.contains(aParentList[0].id));
		resIdSet			= Util.getIdSetFromField(new List<Account>(),Account.ParentId);
		System.assertEquals(0,resIdSet.size());													
	}
	
	// testGetStdPriceBookId
	@isTest
	private static void testGetStdPriceBookId() {
		System.assertNotEquals(null,Util.getStdPriceBookId());
	}
	
	//	testGetStringSetFromField
	@isTest
	private static void testGetStringSetFromField() {
		Campaign[]	cList	= new List<Campaign> {	new Campaign (name='foo00', Type='commonType'),
													new Campaign (name='foo01', Type='commonType'),
													new Campaign (name='foo02', Type='uncommonType')
		};
		insert cList;
		set<String> res	= Util.getStringSetFromField(cList,Campaign.Type);
		System.assertEquals(2,res.size(),'sb two unique Types');
		System.assert(res.contains(cList[0].Type) && res.contains(cList[2].Type),'verify set has both types; actual:'+res);
	}



	//	testGetMsp
	@isTest
	private static void testGetMsp() {
		System.assertEquals('abc',Util.getMsp(new List<String>{'abc','abc'}));
		System.assertEquals(null,Util.getMsp(new List<String>{}));
		System.assert('abc;def' == Util.getMsp(new List<String>{'abc','def'}) || 'def;abc' == Util.getMsp(new List<String>{'abc','def'}));  // order indeterminate
		Account[] aList = new List<Account> {new Account(Name = '00Acct'),new Account(Name = '01Acct')};
		System.assert('00Acct;01Acct' == Util.getMsp(aList,Account.Name) || '01Acct;00Acct' == Util.getMsp(aList,Account.Name));  // order indeterminate
		
	}

	
	// testGetPickListVals
	@isTest
    private static void testGetPickListVals() {
        System.assert(Util.getPickListValues(Opportunity.StageName).size() > 0);
        System.assert(Util.getPickListLabels(Opportunity.StageName).size() > 0);
        System.assert(Util.getPickListVF(Opportunity.StageName).size() > 0);
    }

	// testGetProfileId
	@isTest
	private static void testGetProfileId() {
		Profile sysadProfile	= [select id from Profile where name = 'System Administrator' limit 1];
		System.assertEquals(sysadProfile.id, Util.getProfileId('System Administrator'));
		System.assertEquals(sysadProfile.id, Util.getProfile(sysadProfile.id).id);
		System.assertEquals(sysadProfile.id, Util.getProfile('System Administrator').id);
	}

	// testGetRecordTypeId
    @isTest
    private static void testGetRecordTypeId() {
        RecordType[] rtList = [select id, DeveloperName, Name, SObjectType from RecordType];
        if (rtList.size() > 0) {	// only execute this if org has recordtypes
        	SobjectType sobjType = Schema.getGlobalDescribe().get(rtList[0].SObjectType);
        	System.assertNotEquals(null,Util.getRecordTypeId(sobjType,rtList[0].Name));					// method expects name, not DeveloperName
        	
        	//	try DeveloperName - look for recordtype where DeveloperName not equal Name
        	for (RecordType rt: rtList)
        		if (rt.DeveloperName != rt.Name) {
        			sobjType = Schema.getGlobalDescribe().get(rt.SObjectType);							// objectType of this RecordType in for loop
        			System.assertEquals(rt.Id,Util.getRecordTypeId(sobjType,rt.DeveloperName));			// try w DeveloperName
        			break;																				// one is enough to verify
        		}
        }
        try {	Id rtId    = Util.getRecordTypeId(Opportunity.SObjectType,'fubar'); 
        		System.assert(false,'shouldnt happen, invalid recordtype name');}
        catch (Exception e) {System.assert(e.getMessage().contains('UTIL-01'),e.getMessage());} 
    }

	// testGetRecordTypeName
    @isTest
    private static void testGetRecordTypeName() {
        RecordType[] rtList = [select id, Name,  SObjectType from RecordType];
        if (rtList.size() > 0) {	// only execute this if org has recordtypes
        	SobjectType sobjType = Schema.getGlobalDescribe().get(rtList[0].SObjectType);
        	System.assertEquals(null,Util.getRecordTypeName(sobjType,null));					// null ID = null recordtype Name
        	
        	System.assertEquals(rtList[0].name,Util.getRecordTypeName(sobjType,rtList[0].id));	// use a vlid RTId and see if util method returns name
        	
        }
        
    }

	// testGetRecordTypeDevName
    @isTest
    private static void testGetRecordTypeDevName() {
        RecordType[] rtList = [select id, DeveloperName, Name,  SObjectType from RecordType];
        if (rtList.size() > 0) {	// only execute this if org has recordtypes
        	SobjectType sobjType = Schema.getGlobalDescribe().get(rtList[0].SObjectType);
        	System.assertEquals(null,Util.getRecordTypeDevName(sobjType,null));					// null ID = null recordtype Name
        	
        	System.assertEquals(rtList[0].DeveloperName,Util.getRecordTypeDevName(sobjType,rtList[0].id));	// use a vlid RTId and see if util method returns name
        	
        }
        
    }
   	
	//	testGetSchedulerCronExpression
	@isTest 
	private static void testGetSchedulerCronExpression() {
		DateTime dt = DateTime.newInstance(2025,12,13,14,15,0);
		System.assertEquals('0 15 14 13 12 ? 2025', Util.getSchedulerCronExpression(dt));  
	}

	// testGetSObjectField
	@isTest
	private static void testGetSObjectField() {
		Account a       = new Account(name='LevelGreatGrandparent');
        insert a;
        a               = new Account(name='LevelGrandParent', parentId=a.Id);
        insert a;
        a               = new Account(name='LevelParent', parentId=a.Id);
        insert a;
        a               = new Account(name='LevelChild', parentId=a.Id);
        insert a;
        a               = new Account(name='LevelGrandChild', parentId=a.Id);
        insert a;
        a               = new Account(name='LevelGreatGrandChild', parentId=a.Id, annualRevenue = 1000);
        insert a;
        a   = [select id, annualRevenue, isDeleted, name, createdDate, lastActivityDate, parent.name, parent.createdDate, parent.isDeleted, parent.parent.name, parent.parent.parent.name, parent.parent.parent.parent.name, parent.parent.parent.parent.parent.name 
                    from Account where id = :a.id];
        System.assertEquals('LevelGrandChild',Util.getSobjectStringField(a,'parent.name'));
        System.assertEquals(false,Util.getSobjectBooleanField(a,'parent.isDeleted'));
        System.assertEquals('LevelChild',Util.getSobjectStringField(a,'parent.parent.name'));
        System.assertEquals('LevelParent',Util.getSobjectStringField(a,'parent.PARENT.parent.name'));
        System.assertEquals('LevelGrandParent',Util.getSobjectStringField(a,'parent.parent.parent.parent.name'));
        System.assertEquals('LevelGreatGrandparent',Util.getSobjectStringField(a,'parent.parent.parent.parent.parent.name'));
        System.assertEquals(Date.today(),Util.getSobjectDateTimeField(a,'parent.createdDate').date());
        System.assertEquals(1000.00,Util.getSobjectDecimalField(a,'annualRevenue'));
        System.assertEquals('1000',Util.getSobjectFieldAsString(a,'annualRevenue'));
        System.assertEquals('LevelGreatGrandChild',Util.getSobjectStringField(a,'name'));
        System.assertEquals(null,Util.getSobjectDateField(a,'lastActivityDate'));
	}
    
	// testGetUser, getUserDateFormat, getUserDateTimeFormat
	@isTest
	private static void testGetUser() {
		User u = [select id, LocaleSidKey, name from User where id = :UserInfo.getUserId()];
		System.assertEquals(u.id, Util.getUser(UserInfo.getUserId()).id,'should find running user');
		if (u.LocaleSidKey == 'en_US') {
			System.assertEquals('M/d/yyyy', Util.getUserDateFormat());						// running user
			System.assertEquals('M/d/yyyy h:mm a', Util.getUserDateTimeFormat());		// running user
		}
	} 
	//	testGetUserRoleId
	@isTest
	private static void testGetUserRoleId() {
		
		Integer userRoleCount = [select COUNT() from User where userRoleId != null];
		if (userRoleCount == 0) {	// org not set up with any roles ! -- unusual but no full test possible
			System.assertEquals(null,Util.getUserRoleId('_unknownRole_'),'no roles in org, any call should return null');	
			ID urId = null;
			System.assertEquals(null,Util.getUserRole(urId),'no roles in org, any call should return null');	
			System.assertEquals(null,Util.getUserRole('_unknownRole_'),'no roles in org, any call should return null');	
		} 
		else {	
			User		u	= [select id, userRole.id, userRole.name, userRole.DeveloperName from User where userRoleId != null limit 1];
			UserRole 	ur = u.UserRole;
			
			System.assertEquals((String)ur.id, (String)Util.getUserRoleId(ur.DeveloperName));
			System.assertEquals(ur.id, Util.getUserRole(ur.id).id);
			System.assertEquals(ur.id, Util.getUserRole(ur.DeveloperName).id);
		}
	}

	//	testGetValListFromField
	@isTest
	private static void testGetValListFromField() {
		Account[] aList			= new List<Account> {
										new Account (name='00name', annualRevenue= 1000.0),
										new Account (name='01name', annualRevenue= 2000.0)
		};
		insert aList;
		Test.startTest();
		String[] resListString	= (String[]) Util.getValListFromField(String[].class, aList, Account.name);
		System.assertEquals(2,	resListString.size(),'should return same # names as # sobjects');
		System.assertEquals(aList[0].name,resListString[0],'sb [0] account name');
		System.assertEquals(aList[1].name,resListString[1],'sb [1] account name');
		
		Decimal[] resListDecimal	= (Decimal[]) Util.getValListFromField(Decimal[].class,aList,Account.AnnualRevenue);
		System.assertEquals(aList[0].annualRevenue,	resListDecimal[0], 'sb [0] annualrev');
		System.assertEquals(aList[1].annualRevenue,	resListDecimal[1], 'sb [1] annualrev');
		Test.stopTest();
	}    
   

	//	testGetValsFromField - works with either sets or lists
	@isTest
	private static void testGetValsFromField() {
		Account[] aList			= new List<Account> {
										new Account (name='00name', annualRevenue= 1000.0),
										new Account (name='01name', annualRevenue= 2000.0)
		};
		insert aList;
		Test.startTest();
		String[] resListString	= (String[]) Util.getValsFromField(String[].class, aList, Account.name);
		System.assertEquals(2,	resListString.size(),'should return same # names as # sobjects');
		System.assertEquals(aList[0].name,resListString[0],'sb [0] account name');
		System.assertEquals(aList[1].name,resListString[1],'sb [1] account name');

		set<String> resSetString	= (set<String>) Util.getValsFromField(set<String>.class, aList, Account.name);
		System.assertEquals(2,	resSetString.size(),'should return same # names as # sobjects');
		
	}
	
	//	testIsBetween
	@isTest
	private static void testIsBetween() {
		System.assertEquals(false,Util.isBetween(null,10,5),'L boundary is null, isBetween is false');
		System.assertEquals(false,Util.isBetween(10,null,5),'R boundary is null, isBetween is false');
		System.assertEquals(false,Util.isBetween(8,10,null),'comparand is null, isBetween is false');
		System.assertEquals(true,Util.isBetween(8,10,9),'9 is between 8 and 10');
		System.assertEquals(true,Util.isBetween(10,8,9),'9 is between 10 and 8');
		System.assertEquals(true,Util.isBetween(10,8,10),'10 is between 10 and 8');
	}
	
	// testIsEnqueueable (a property)
	@isTest
	private static void testIsEnqueueable() {
		System.assertEquals(true,Util.isEnqueueable,'in testmethod, should be headroom to enqueue a job');
		// testing negative case requires an queueable class
	}
    
  	//	testIsEqualsMsp
  	@isTest
	private static void testIsEqualsMsp() {
	  	System.assertEquals(true,Util.isEqualsMsp(null,null),'both msp null');
	  	System.assertEquals(true,Util.isEqualsMsp('',''),'both msp empty');
	  	System.assertEquals(true,Util.isEqualsMsp('abc;def','abc;def'),'both msp have 2 equal elms');
	  	System.assertEquals(true,Util.isEqualsMsp('def;abc','abc;def'),'both msp have 2 equal elms but in diff order');
	  	System.assertEquals(false,Util.isEqualsMsp('abc;def','abc;def;ghi'),' msp have diff # elms');
	  	System.assertEquals(false,Util.isEqualsMsp('abc;def',null),'2nd msp is null');
	  	System.assertEquals(false,Util.isEqualsMsp(null,'abc;def'),'1st msp is null');
  	}
		
	// testIsNullOrZero
	@isTest
    private static void testIsNullOrZero() {
    	Decimal d = null;
    	Integer i = 0;
    	Long	l = 0;
    	Double 	db = 0;	 
    	
    	System.assertEquals(true,Util.isNullOrZero(d));
    	System.assertEquals(true,Util.isNullOrZero(i));
    	System.assertEquals(true,Util.isNullOrZero(l));
    	System.assertEquals(true,Util.isNullOrZero(db));
    	
    	d = 1.0; i++; l = 100000000; db = 20.0;
    	System.assertEquals(false,Util.isNullOrZero(d));
    	System.assertEquals(false,Util.isNullOrZero(i));
    	System.assertEquals(false,Util.isNullOrZero(l));
    	System.assertEquals(false,Util.isNullOrZero(db));
    	
    }
    
        	
	//	testIsValidDate	- w/ running user w/ US locale
	@isTest
	private static void testIsValidDate() {
		User unitedStatesU	= new User(	Alias = '_foo_',
										Email = '_fooTestValidDate@foo.com',	
										EmailEncodingKey = 'UTF-8',
										FirstName = '_fname',
										LastName = '_lname',
										IsActive = true,
										LanguageLocaleKey = 'en_US',
										LocaleSidKey = 'en_US',
										ProfileId = Util.getProfileId('Standard User'),
										UserName = '_fooTestValidDate@foo.com',
										TimeZoneSidKey = 'America/Los_Angeles'
										);
		insert unitedStatesU;
		System.runAs(unitedStatesU) {
		
			System.assertEquals(true,Util.isValidDate('2020-01-01'));
			System.assertEquals(false,Util.isValidDate('2020-13-31'),'no month 13');
			System.assertEquals(false,Util.isValidDate(null),'null date is not valid');
			System.assertEquals(true,Util.isValidDate('02/29/2016'),'valid leap year for US locale');	
		}
	}

	//	testIsValidEmail
    @isTest
    private static  void testIsValidEmail() {
        System.assertEquals(false,          Util.isValidEmail('abc.abc.com'));
        System.assertEquals(false,          Util.isValidEmail('ABC.ABC.COM'));
        System.assertEquals(true,           Util.isValidEmail('abc@abc.com'));
        System.assertEquals(true,           Util.isValidEmail('00@abc.com'));
        System.assertEquals(true,           Util.isValidEmail('simplewith+symbol@example.com'));
        System.assertEquals(true,           Util.isValidEmail('a.little.more.unusual@dept.example.com'));
        System.assertEquals(false,          Util.isValidEmail('postbox@com'));                              // unusual, actually valid but we ignore
        System.assertEquals(true,           Util.isValidEmail('!#$%&*+-/=?^_`{}|~@example.org'));           // unusual, actually valid 
        System.assertEquals(true,           Util.isValidEmail('Abc.@example.com'));                         // actually invalid but sfdc accepts this
        System.assertEquals(true,           Util.isValidEmail('Abc..123@example.com'));                     // " "
        System.assertEquals(false,          Util.isValidEmail('A@b@c@example.com'));
        System.assertEquals(false,          Util.isValidEmail('this is not allowed@example.com '));
        System.assertEquals(false,          Util.isValidEmail(null));
        
    } 

	// testJoinDatabaseErrors
	@isTest 
	private static void testJoinDatabaseErrors() {
		Account[] aList = new List<Account> {	new Account()			// force error 
											};
		Database.SaveResult[] srList = Database.insert(aList,false);
		System.assert(Util.joinDatabaseErrors(srList[0].getErrors(),';').length() > 0);									
	}

	// testJoinSobjectFieldFromList (only works for SObjectFields of type String)
	@isTest
	private static void testJoinSobjectFieldFromList() {
		Account[] aList = new List<Account> {	new Account (name = '00foo'),
												new Account (name = '01foo', website = 'abc.com')
		};
		System.assertEquals('00foo;01foo',Util.joinSobjectFieldFromList(aList,Account.Name,';',500));	
		System.assertEquals(';abc.com',Util.joinSobjectFieldFromList(aList,Account.Website,';',500,false), 'dont suppress null');
	}
		
	 
	//	testLocaleToDateTimeFmtMap
	@isTest
	private static void testLocaleToDateTimeFmtMap() {
		System.assert(Util.getLocaleToDateTimeFmtMap().size() > 0,'some map should be returned');
	} 
	      
    //	testMakeOperandable
    @isTest
    private static void testMakeOperandable() {
    	System.assertEquals(0,		Util.makeOperandable(null));
    	System.assertEquals(10.0,	Util.makeOperandable(10.0));
    }
    
    // testMapKeyToLowercase
    @isTest
    private static void testMapKeyToLowercase() {
    	map<String,Decimal> m	= new map<String,Decimal> {'ABC' => 10.0, null => 20.0, 'def' => 30};
    	System.assertEquals(10.0,Util.mapKeyToLowercase(m).get('abc')); 
    	System.assertEquals(20.0,Util.mapKeyToLowercase(m).get(null));
    	System.assertEquals(30.0,Util.mapKeyToLowercase(m).get('def'));
    }    
    
    //	testMspAppend
    @isTest
    private static void testMspAppend() {
        System.assertEquals('abc',          Util.mspAppend('abc',null));
        System.assertEquals('abc',          Util.mspAppend(null,'abc'));
        System.assertEquals('abc;def',      Util.mspAppend('abc','def'));
        System.assertEquals('abc;def',      Util.mspAppend('abc;def','def'));
        System.assertEquals('abc',          Util.mspAppend('abc','abc'));
        System.assertEquals('abc;def;ghi',  Util.mspAppend('abc;def','ghi'));
    }

	// testMspToHtml
    @isTest
    private static void testMspToHtml() {
        System.assertEquals(null,                                       Util.mspToHtml(null));
        System.assertEquals('a<br/>b',                                  Util.mspToHtml('a;b'));
        System.assertEquals('a<br/>b',                                  Util.mspToHtml('a; b'));
        System.assertEquals('a',                                        Util.mspToHtml('a'));
    }
    
	// testNow
	@isTest
	private static void testNow() {
		DateTime dt = DateTime.newInstance(2010,1,1,12,12,12);
		Util.now = dt;
		System.assertNotEquals(System.now(),Util.now);
		System.assertEquals(dt,Util.now);
	}
    
    //	testParseDate
    @isTest
    private static void testParseDate() {
        System.assertEquals(Date.newInstance(2020,1,1),     Util.parseDate('2020-01-01'));
        System.assertEquals(Date.newInstance(2020,1,1),     Util.parseDate('2020-01-01T01:09:00Z'));
        System.assertEquals(Date.newInstance(2020,1,1),     Util.parseDate('01/01/2020'));
        System.assertEquals(Date.newInstance(2020,4,1),     Util.parseDate('4-1-2020'));
        System.assertEquals(Date.newInstance(2020,1,1),     Util.parseDate('1/1/2020'));
        System.assertEquals(Date.newInstance(2020,1,1),     Util.parseDate('01/01/2020 05:08:00.000-0800'));
        System.assertEquals(null,                           Util.parseDate(null));
        System.assertEquals(null,                           Util.parseDate(''));
        System.assertEquals(null,                           Util.parseDate('ab/de/1201'));
        System.assertEquals(null,                           Util.parseDate('13/01/2020'));
        System.assertEquals(null,                           Util.parseDate('2020-13-01'));
    } 
    
    // testPivotSObjectsByID
    @isTest
    private static void testPivotSObjectsByID() {
    	Campaign[]	cList	= new List<Campaign> {	new Campaign (name='foo00'),
													new Campaign (name='foo01')
		};
		insert cList;
		
		Campaign[]	cChildList	= new List<Campaign> {	new Campaign (name='foo00_0child', ParentId = cList[0].id),
														new Campaign (name='foo00_1child', ParentId = cList[0].id)
		};
		insert cChildList;
		
		List<Campaign> cResList = [select id, ParentId, Name from Campaign where id IN :new List<ID>{cList[0].id,cList[1].id,cChildList[0].id,cChildList[1].id}];
		map<ID, List<SObject>> pivotMap = Util.pivotSObjectsById(Campaign.PArentId,cResList);
		System.assertEquals(2, pivotMap.get(null).size(), 'Two Campaigns have no parent');
		System.assertEquals(2, pivotMap.get(cList[0].id).size(), 'Two Campaign are children of c[0]');
		System.assertEquals(false, pivotMap.containsKey(cList[1].id), 'No Campaigns are children of c[1]');
    }
    
    //	testPivotSobjectsByString
    @isTest
    private static void testPivotSobjectsByString() {
    	Lead[] lList	= new List<Lead>	{	new Lead (Company = '00foo', LastName = '00LastName'),		// same lastname as [1]
    											new Lead (Company = '01foo', LastName = '00LastName'),		// same lastname as [0]
    											new Lead (Company = '02foo', LastName = '02LastName')		// unique lastname
    	};
    	map<String,List<Lead>> res = Util.pivotSobjectsByString(Lead.LastName,lList);
    	System.assertEquals(2,res.size(),'two unique values to pivot on');
    	System.assertEquals(2,res.get('00LastName').size(),'Pivot should return 2 Leads with same last name 00LastName');										
    	System.assertEquals(1,res.get('02LastName').size(),'Pivot should return 1 Leads with same last name 02LastName');										
    	
    	res = Util.pivotSobjectsByString(Lead.LastName,new List<Lead>());
    	System.assertEquals(0,res.size(),'no values to pivot on');
    										
    }
    
    //	testRpnCalculate
    @isTest
    private static void testRpnCalculate() {
    	System.assertEquals(2.0,	Util.rpnCalculate(new List<Object> {10,5,'/'}));
    	System.assertEquals(40.0,	Util.rpnCalculate(new List<Object> {10,5,'/',20,'*'}));
    	System.assertEquals(10.0,	Util.rpnCalculate(new List<Object> {10}));
    	System.assertEquals(-5.0,	Util.rpnCalculate(new List<Object> {10,5,'+',20,'-'}));
    	try {
    		Util.rpnCalculate(new List<Object> {10,5,'+',2,'^'});
    		System.assert(false,'shouldnt - invalid RPN operator');
    	}
    	catch (Exception e) {System.assert(e.getMessage().contains('[UTIL-08]'),e.getMessage());}
    	
    	try {
    		Util.rpnCalculate(new List<Object> {'+'});
    		System.assert(false,'shouldnt - top of stack can\'t be an operator');
    	}
    	catch (Exception e2) {System.assert(e2.getMessage().contains('[UTIL-08]'),e2.getMessage());}

    	try {
    		Util.rpnCalculate(new List<Object> {10,5,'+','+'});
    		System.assert(false,'shouldnt - too many trailing operators');
    	}
    	catch (Exception e3) {System.assert(e3.getMessage().contains('[UTIL-08]'),e3.getMessage());}
    	
    	try {
    		Util.rpnCalculate(new List<Object> {30,10,5,'/','*'});
    		System.assert(false,'shouldnt - stack of more than two operands not supported');
    	}
    	catch (Exception e3) {System.assert(e3.getMessage().contains('[UTIL-08]'),e3.getMessage());}
    	
    }
    	
    //	testString2Boolean
    @isTest
    private static void testString2Boolean() {
        System.assertEquals(true,Util.string2Boolean('1'));
        System.assertEquals(true,Util.string2Boolean('TRUE'));
        System.assertEquals(true,Util.string2Boolean('YEs'));
        System.assertEquals(true,Util.string2Boolean('y'));
        System.assertEquals(false,Util.string2Boolean('0'));
        System.assertEquals(false,Util.string2Boolean('False'));
        System.assertEquals(false,Util.string2Boolean('No'));
        System.assertEquals(false,Util.string2Boolean('n'));
        System.assertEquals(false,Util.string2Boolean(null));
    }
    
    // testStringToPrimitiveTypedObject
    @isTest
    private static void testStringToPrimitiveTypedObject() {
    	System.assertEquals(10.0, 							Util.stringToPrimitiveTypedObject(Account.AnnualRevenue, '10'));
    	System.assertEquals(false, 							Util.stringToPrimitiveTypedObject(Account.IsDeleted, 'false'));
    	System.assertEquals('foo', 							Util.stringToPrimitiveTypedObject(Account.Name, 'foo'));
    	System.assertEquals(Date.newInstance(2010,1,1), 	Util.stringToPrimitiveTypedObject(Opportunity.CloseDate, '2010-01-01'));
    	System.assertEquals('foo@bar.com', 					Util.stringToPrimitiveTypedObject(Contact.Email, 'foo@bar.com'));
    	System.assertEquals('1225679', 						Util.stringToPrimitiveTypedObject(Account.Phone, '1225679'));
    	System.assertEquals('foo', 							Util.stringToPrimitiveTypedObject(Account.Rating, 'foo'));
    	try {
    		Util.stringToPrimitiveTypedObject(Account.AnnualRevenue, 'abc');
    		System.assert(false,'shouldnt happen, invalid value for decimal');
    	}
    	catch (Util.UtilException ue) {System.assert(ue.getMessage().contains('[UTIL-13]'), ue.getMessage());}
    	
    } 
    
	// testToday
	@isTest
	private static void testToday() {
		Date dt = Date.newInstance(2010,1,1);
		Util.today = dt;
		System.assertNotEquals(Date.today(),Util.today);
		System.assertEquals(dt,Util.today);
	} 
	
	// testToLowercaseSet (and List)
    @isTest
    private static void testToLowercaseSet() {
        Set<String> valSet  = new set<String>{'a','b'};
        List<String> valList= new List<String> {'a','b','a'};

        Set<String> resSet      = Util.toLowerCaseSet(valSet);
        System.assertEquals(valSet.size(),resSet.size());
        System.assert(resSet.contains('a'),'sb lowercased');
        System.assert(resSet.contains('b'),'sb lowercased');

        resSet                  = Util.toLowerCaseSet(valList);
        System.assertEquals(valList.size()-1,resSet.size(),'dups sb removed from result');
        System.assert(resSet.contains('a'),'sb lowercased');
        System.assert(resSet.contains('b'),'sb lowercased');
        
        List<String> resList = Util.toLowercaseList(new List<String> (valSet));
        System.assertEquals(valSet.size(),resList.size());
        System.assert(resList == new List<String>{'a','b'} || resList == new List<String>{'b','a'} ,'sb lowercased, order indeterminate');
        
        resList = Util.toLowercaseList(new set<String> {'aBc'});
        System.assertEquals(resList[0],'abc','sb lowercased, order indeterminate');
        
        resList = Util.toLowercaseList(valList);
        System.assertEquals(valList.size(),resList.size());
        System.assertEquals('a',resList[0],'sb lowercased, list order preserved');
        System.assertEquals('b',resList[1],'sb lowercased, list order preserved');
        System.assertEquals('a',resList[2],'sb lowercased, list order preserved');
    }         
}