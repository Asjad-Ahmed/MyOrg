public with sharing class OpportunityChartController {
    public String opportunityStageLabels { get; private set; }
    public String opportunityStageAmounts { get; private set; }
    public String accountId { get; set; }

    public OpportunityChartController() {
        List<AggregateResult> stageData = [SELECT StageName, SUM(Amount) totalAmount FROM Opportunity GROUP BY StageName];
        List<String> labels = new List<String>();
        List<Decimal> amounts = new List<Decimal>();

        for (AggregateResult ar : stageData) {
            labels.add(String.valueOf(ar.get('StageName')));
            amounts.add((Decimal)ar.get('totalAmount'));
        }

        opportunityStageLabels = JSON.serialize(labels);
        opportunityStageAmounts = JSON.serialize(amounts);
    }
    
    @RemoteAction
    public static void saveImage(String accountId, String base64Image) {
        // Convert base64 image to Blob
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
        contentLink.ContentDocumentId = [SELECT Id FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        contentLink.ShareType = 'V';
        contentLink.Visibility = 'AllUsers';
        insert contentLink;
    }
}