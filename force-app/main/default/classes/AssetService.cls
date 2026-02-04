@RestResource(urlMapping='/lost')
global class AssetService {

    @HttpPost
    global static String reportLostDevice(String assetIdentifier) {
        String returnString;
        try {
            Asset a = [SELECT Status FROM Asset WHERE Asset_Identifier__c = :assetIdentifier LIMIT 1];
            a.Status = 'Lost';
            update a;
            List<Insurance__c> iList = [SELECT Id FROM Insurance__c WHERE Asset__c = :a.Id AND Coverage__c = 'Comprehensive' AND Active__c = true];
            if(!iList.isEmpty()) {
                {
                    List<Claim__c> cList = [SELECT Name FROM Claim__c WHERE Asset__c = :a.Id AND Type__c = 'Loss'];
                    if(!cList.isEmpty()) {
                        returnString = cList[0].Name + ' already filed.';
                    } else {
                        Claim__c c = new Claim__c(Asset__c = a.Id, Type__c = 'Loss', Insurance__c = iList[0].Id);
                        insert c;
                        c = [SELECT Name FROM Claim__c WHERE Id = :c.Id LIMIT 1];
                        returnString = c.Name;
                    }
                }
            } else {
                returnString = 'No coverage. Asset status adjusted to Lost';
            }
        } catch(Exception e) {
            returnString = 'No device found.';
        }
  		return returnString;
    }
}