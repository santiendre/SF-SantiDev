@IsTest
public class CredentialVerificationServiceTest {
	@testSetup
    public static void makeData() {
        Contact c = new Contact(LastName = 'Test');
        insert c;
        Certification__c cert = new Certification__c(Name = 'Pilot Certification', isActive__c = true);
        insert cert;
        Contact_Certification__c cc = new Contact_Certification__c(Contact__c = c.Id, Certification__c = cert.Id, isActive__c = true, Issue_Date__c = Date.today());
        insert cc;
    }
    
    @isTest
    public static void verifyCredentialTestPass() {
        String ccName = [SELECT Name FROM Contact_Certification__c LIMIT 1].Name;
        Assert.areEqual('Valid', CredentialVerificationService.verifyCredential('Test', ccName));
    } 
    
    @isTest
    public static void verifyCredentialTestFail() {
        Assert.areEqual('No record found', CredentialVerificationService.verifyCredential('Test', '999'));
    }
}