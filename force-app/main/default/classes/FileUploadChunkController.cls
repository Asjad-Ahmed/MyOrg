public with sharing class FileUploadChunkController {
    
    @AuraEnabled                            
    public static Id uploadChunkedFile(Id recordId, String fileName, String fileContent, String contentVersionId){
        try {
            fileContent = EncodingUtil.urlDecode(fileContent, 'UTF-8');
            if(String.isBlank(contentVersionId)) {

                ContentVersion cvObj =new ContentVersion(); 
                cvObj.Title = fileName; 
                cvObj.VersionData = EncodingUtil.base64Decode(fileContent);
                cvObj.PathOnClient = '/' + fileName ;
                cvObj.IsMajorVersion = false;
                insert cvObj; 
                
                Id contentDocId = [select id, ContentDocumentId from ContentVersion WHERE Id =: cvObj.Id].ContentDocumentId;
                ContentDocumentLink cl = new ContentDocumentLink();
                cl.ContentDocumentId = contentDocId;
                cl.LinkedEntityId = recordId; 
                cl.ShareType = 'V';
                cl.Visibility = 'AllUsers';
                insert cl;
                contentVersionId = cvObj.Id;

            } else {

                ContentVersion cvObj = [SELECT Id, VersionData,ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId];
                String existingFileContent = EncodingUtil.base64Encode(cvObj.VersionData);
                cvObj.VersionData = EncodingUtil.base64Decode(existingFileContent + fileContent); 
                update cvObj;

            }
            return Id.valueOf(contentVersionId);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
/* Code by CafeForce
Website: http://www.cafeforce.com
DO NOT REMOVE THIS HEADER/FOOTER FOR FREE CODE USAGE
*/