public class AddProductDragDropLwcController {
   

    @AuraEnabled
    public static string initialize(String recordId){
        MainWrapper objMain = new MainWrapper();
        objMain.listProducts = getProducts('');


        return JSON.serialize(objMain);
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(String strProductName){
        strProductName = '%' + strProductName + '%' ;
        return [SELECT Id, Name, IsActive FROM Product2 WHERE IsActive=TRUE AND Name LIKE: strProductName];
    }


    @AuraEnabled
    public static Decimal getPrice(String pbeId){
        return [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id =: pbeId].UnitPrice;
    }

    @AuraEnabled
    public static String saveOpportunityLineItem(String jsonObject, String OpportunityId){
        List<ProductWrapper> listProductWrapper = (List<ProductWrapper>) JSON.deserialize(jsonObject, List<ProductWrapper>.class);
        List<OpportunityLineItem> listOppLI = new List<OpportunityLineItem>();
        for (ProductWrapper objProductWrapper : listProductWrapper) {
            OpportunityLineItem objOppLI = new OpportunityLineItem(
                Product2Id = objProductWrapper.productId,
                PricebookEntryId = objProductWrapper.priceBookEntryId,
                OpportunityId = OpportunityId,
                Quantity = objProductWrapper.quantity,
                TotalPrice = (objProductWrapper.quantity * objProductWrapper.price)
            );
            listOppLI.add(objOppLI);
        }
        if (!listProductWrapper.isEmpty()) {
            INSERT listOppLI;
        }
        return 'Success';
    }



    public class MainWrapper{
        List<Product2> listProducts;
        public MainWrapper(){
            listProducts = new List<Product2>();
        }
    }



    public class ProductWrapper {
        public String productId;
        public Integer sNo;
        public String name;
        public String recordUrl;
        public Integer quantity;
        public Decimal price;
        public String priceBookEntryId;
        //public FilterCriteria filter;
    }

    public class FilterCriteria {
        public List<Criteria> criteria;
    }

    public class Criteria {
        public String fieldPath;
        public String operator;
        public Object value;
    }
    
}