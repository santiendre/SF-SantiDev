@RestResource(urlMapping='/ProductZoning/*')
global class ProductZoningService {
    @HttpGet
    global static String getFlyZones() {
        RestRequest req = RestContext.request;
        String productCode = req.params.get('ProductCode');
        String countryCode = req.headers.get('CountryCode');
        if (String.isBlank(countryCode)) {
            countryCode = 'US';
        }
        String returnString;
        try {
            String family = [SELECT Family FROM Product2 WHERE ProductCode = :productCode LIMIT 1].Family;
            System.debug(family);
            System.debug(countryCode);
            Boolean familyFound;
            for(Product_Geo_Mapping__mdt pgm : Product_Geo_Mapping__mdt.getAll().values()) {
                if(pgm.Country_Code__c == countryCode && pgm.Product_Family__c == family) {
                    returnString = pgm.Permissible_Fly_Zone__c;
                    break;
                }
            }
            if(String.isBlank(returnString)) {
            	returnString = 'Confirm with the local authorities';
            }
        } catch(Exception e) {
            returnString = 'ProductCode is missing or doesn\'t exist';
        }
        return returnString;
    }
}