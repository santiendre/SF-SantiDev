public with sharing class GitHubService {
    private static final String TOKEN = API_Setting__mdt.getAll().get('Github').Token__c;
    private static final String BASE_URL = 'callout:GitHub_API';

    public static HttpResponse get(String path) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + path);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + TOKEN);
        req.setTimeout(120000);
        return http.send(req);
    }
}