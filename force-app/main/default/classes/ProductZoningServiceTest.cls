@IsTest
public class ProductZoningServiceTest {
    @testSetup
    static void makeData() {
        Product2 p = new Product2(Name = 'Test Product', ProductCode = 'T001', Family = 'Multi-Rotor');
        insert p;
    }
        
	@isTest
    static void getFlyZonesTestPass() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ProductZoning';
        req.httpMethod = 'GET';
        req.addParameter('ProductCode', 'T001');
		req.addHeader('CountryCode', 'DE');
        RestContext.request = req;
        String flyZone = ProductZoningService.getFlyZones();
        Assert.areEqual('Regulated', flyZone);
    }
    
	@isTest
    static void getFlyZonesTestNoCountryPass() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ProductZoning';
        req.httpMethod = 'GET';
        req.addParameter('ProductCode', 'T001');
		req.addHeader('CountryCode', 'AR');
        RestContext.request = req;
        String flyZone = ProductZoningService.getFlyZones();
        Assert.areEqual('Confirm with the local authorities', flyZone);
    }
    
    @isTest
    static void getFlyZonesTestNoProductFail() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ProductZoning';
        req.httpMethod = 'GET';
        req.addParameter('ProductCode', 'T002');
		req.addHeader('CountryCode', 'AR');
        RestContext.request = req;
        String flyZone = ProductZoningService.getFlyZones();
        Assert.areEqual('ProductCode is missing or doesn\'t exist', flyZone);
    }
}