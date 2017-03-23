@isTest
private class GoogleSignOnHandler_Test {

	static testMethod void testCreateAndUpdateUser() {

		User testuser = new User(FirstName = 'testFirst', LastName = 'testLast', Email = 'testuser@example.org', Username = 'testuser@helixtest.com', Alias = 'testu', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = UserInfo.getProfileId(), LanguageLocaleKey = 'en_US');
		insert testuser;

	    GoogleSignOnHandler handler = new GoogleSignOnHandler();
	    Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
	        'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'google',
	        null, new Map<String, String>{'language' => 'en_US'});
	    User u = handler.createUser(null, sampleData);
	    System.assertEquals('testuser@helixtest.com', u.userName);
	    System.assertEquals('testuser@example.org', u.email);
	    System.assertEquals('testLast', u.lastName);
	    System.assertEquals('testFirst', u.firstName);
	    System.assertEquals('testu', u.alias);

	    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
	        'testNewFirst testNewLast', 'testuser@example.org', null, 'testnewuserlong', 'en_US', 'google',
	        null, new Map<String, String>{});
	    handler.updateUser(u.Id, null, sampleData);

	    User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM User WHERE Email = :u.Email];
	    System.assertEquals('testuser@helixtest.com', updatedUser.userName);
	    System.assertEquals('testuser@example.org', updatedUser.email);
	    System.assertEquals('testNewLast', updatedUser.lastName);
	    System.assertEquals('testNewFirst', updatedUser.firstName);
	}

}