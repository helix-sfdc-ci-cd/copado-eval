global class GoogleSignOnHandler implements Auth.RegistrationHandler {
    global User createUser(Id portalId, Auth.UserData data) {
        List<User> users = [SELECT Id, Username, Email, LastName, FirstName, Alias FROM User WHERE Email = :data.email];
        if (!users.isEmpty()) {
            return users.get(0);
        } else {
            return null;
        }
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        User u = new User(id=userId);
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        update(u);
    }
}