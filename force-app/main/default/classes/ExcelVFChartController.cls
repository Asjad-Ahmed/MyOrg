public class ExcelVFChartController {

    public List<DataWrapper> salesData { get; set; }
    List<ChartData> MyData { get; set; }

    public ExcelVFChartController(ApexPages.StandardController controller) {
        salesData = new List<DataWrapper>();
        MyData = new List<ChartData>();

        // Query your data (assuming Product is a custom object with a Sales__c field)
        
		MyData = getMyData();
        system.debug(MyData);
        // Populate the data for the chart
        
    }
    
    
     public List<ChartData> getMyData() {
        Map<String, Integer> tempMap = new Map<String, Integer>{ 'Apple' => 100, 'Banana' => 50, 'Orange' => 70};
        List<ChartData>  MyData = new List<ChartData>();
        for (String product : tempMap.keySet()) {
            MyData.add(new ChartData(product, tempMap.get(product)));
        }
        return MyData;
    }
    public class ChartData {
        public String Attribute {get;set;}
        public integer ApiRequestLimit {get;set;}        
        public ChartData(string att, integer amt) {
            this.Attribute = att ;
            this.ApiRequestLimit = amt ;
        }
    }  

    public class DataWrapper {
        public String Product { get; set; }
        public Decimal Sales { get; set; }

        public DataWrapper(String product, Decimal sales) {
            Product = product;
            Sales = sales;
        }
    }
    
    
    
}