global class CredentialVerificationService {
    webservice static String verifyCredential(String lastName, String contactCertName) {
        String returnString;
        try {
            Boolean isActive = [SELECT isActive__c FROM Contact_Certification__c WHERE Contact__r.LastName = :lastName AND Name = :contactCertName LIMIT 1].isActive__c;
            returnString = isActive ? 'Valid' : 'Needs Renewal';
        } catch(Exception e) {
            returnString = 'No record found';
        }
        return returnString;
    }
}