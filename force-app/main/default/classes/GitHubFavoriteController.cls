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
                    '',
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
    public static void publishSearchEvent(String username) {
    EventBus.publish(new GitHub_Activity__e(Action_Type__c = 'search', User_Repo_Name__c = username));
}

    @AuraEnabled
    public static Boolean saveFavorite(String name, String owner, String description, String url, Integer stars) {
        try {
            List<GitHub_Favorite__c> existingGF = [SELECT Id FROM GitHub_Favorite__c WHERE Name = :name AND Owner__c = :owner LIMIT 1];
            if(!existingGF.isEmpty()) {
                return false;
            }
            insert new GitHub_Favorite__c(Name = name, Owner__c = owner, Description__c = description, GitHub_URL__c = url, Stars__c = stars);
            EventBus.publish(new GitHub_Activity__e(Action_Type__c = 'favorite', User_Repo_Name__c = name));
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeFavorite(String recordId, String repoName) {
        try {
            delete new GitHub_Favorite__c(Id = recordId);
            EventBus.publish(new GitHub_Activity__e(Action_Type__c = 'remove favorite', User_Repo_Name__c = repoName));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<RepoWrapper> getFavorites() {
        List<RepoWrapper> favorites = new List<RepoWrapper>();
        try {
            for(GitHub_Favorite__c gf : [SELECT Id, Name, Owner__c, Description__c, GitHub_URL__c, Stars__c FROM GitHub_Favorite__c]) {
                favorites.add(new RepoWrapper(gf.Id, gf.Name, gf.Owner__c, gf.Description__c, gf.GitHub_URL__c, (Integer)gf.Stars__c));
            }
            return favorites;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class RepoWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String owner;
        @AuraEnabled public String description;
        @AuraEnabled public String url;
        @AuraEnabled public Integer stars;

        public RepoWrapper(String id, String name, String owner, String description, String url, Integer stars) {
            this.id = id;
            this.name = name;
            this.owner = owner;
            this.description = description;
            this.url = url;
            this.stars = stars;
        }
    }
}