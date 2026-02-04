@IsTest
public class AssetServiceTest {
    @testSetup
    static void makeData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact c = new Contact(LastName = 'Test', AccountId = acc.Id);
        insert c;
        Asset a = new Asset(Name = 'Test-Aasset', Asset_Identifier__c = 'T-001', AccountId = acc.Id, ContactId = c.Id);
        insert a;
        Insurance__c i = new Insurance__c(Active__c = true, Coverage__c = 'Comprehensive', Asset__c = a.Id);
        insert i;
    }
    
    @isTest
    static void reportLostDeviceTestPass() {
        String claimNumber = AssetService.reportLostDevice('T-001');
        Assert.isNotNull(claimNumber);
        Assert.areNotEqual('No coverage. Asset status adjusted to Lost', claimNumber);
        Assert.areNotEqual('No device found.', claimNumber);
    }
    
    @isTest
    static void reportLostDeviceTestNotFound() {
        String claimNumber = AssetService.reportLostDevice('T-002');
        Assert.areEqual('No device found.', claimNumber);
    }

}