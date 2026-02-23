public with sharing class GitHubFavoriteController {

    @AuraEnabled
    public static List<RepoWrapper> getRepos(String username) {
        List<RepoWrapper> reposList = new List<RepoWrapper>();
        try {
            HttpResponse res = GitHubService.get('/users/' + username + '/repos');
            List<Object> rawRepos = (List<Object>) JSON.deserializeUntyped(res.getBody());
            List<RepoWrapper> repos = new List<RepoWrapper>();
            for(Object item : rawRepos) {
                Map<String, Object> repo = (Map<String, Object>) item;
                String owner = (String) ((Map<String, Object>) repo.get('owner')).get('login');
                reposList.add(new RepoWrapper(
                    (String) repo.get('name'), 
                    owner,
                    (String) repo.get('description'),
                    (String) repo.get('html_url'),
                    (Integer) repo.get('stargazers_count')
                ));
            }
            return reposList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean saveFavorite(String name, String owner, String description, String url, Integer stars) {
        try {
            List<GitHub_Favorite__c> existingGF = [SELECT Id FROM GitHub_Favorite__c WHERE Name = :name AND Owner__c = :owner LIMIT 1];
            if(!existingGF.isEmpty()) {
                return false;
            }
            insert new GitHub_Favorite__c(Name = name, Owner__c = owner, Description__c = description, GitHub_URL__c = url, Stars__c = stars);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class RepoWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String owner;
        @AuraEnabled public String description;
        @AuraEnabled public String url;
        @AuraEnabled public Integer stars;

        public RepoWrapper(String name, String owner, String description, String url, Integer stars) {
            this.name = name;
            this.owner = owner;
            this.description = description;
            this.url = url;
            this.stars = stars;
        }
    }
}