public class CaptureAndSaveImageController {

    public String accountId { get; set; }
    
    public CaptureAndSaveImageController() {
        this.accountId = System.Apexpages.currentPage().getParameters().get('Id');
        system.debug(this.accountId);
        List<Decimal> dec = (List<Decimal>)Json.deserialize(this.accountId, List<Decimal>.class);
        system.debug(dec);
    }

    // Apex method to save the image under the specified Account record
    @RemoteAction
    public static void saveImage(String accountId, String base64Image) {
        // Convert base64 image to Blob
        system.debug(string.valueof(base64Image));
        Blob imageBlob = EncodingUtil.base64Decode(base64Image);
        
        // Create ContentVersion record for the image
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Screenshot';
        contentVersion.VersionData = imageBlob;
        contentVersion.PathOnClient = 'screenshot.png';
        insert contentVersion;
        
        // Link the ContentVersion to the specified Account record
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = accountId;
        contentLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        contentLink.ShareType = 'V';
        contentLink.Visibility = 'AllUsers';
        insert contentLink;
    }
}