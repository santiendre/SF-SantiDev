public with sharing class GitHubUserController {

    @AuraEnabled
    public static UserWrapper getUserProfile(String username) {
        try {
            HttpResponse res = GitHubService.get('/users/' + username);
            Map<String, Object> rawUser = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            return new UserWrapper((String)rawUser.get('login'), (String)rawUser.get('avatar_url'), (String)rawUser.get('bio'), (Integer)rawUser.get('followers'), (Integer)rawUser.get('public_repos'));
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class UserWrapper {
        @AuraEnabled public String login;
        @AuraEnabled public String avatarUrl;
        @AuraEnabled public String bio;
        @AuraEnabled public Integer followers;
        @AuraEnabled public Integer publicRepos;

        public UserWrapper(String login, String avatarUrl, String bio, Integer followers, Integer publicRepos) {
            this.login = login;
            this.avatarUrl = avatarUrl;
            this.bio = bio;
            this.followers = followers;
            this.publicRepos = publicRepos;
        }
    }
}