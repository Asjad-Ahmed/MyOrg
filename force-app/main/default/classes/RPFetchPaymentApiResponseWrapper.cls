public class RPFetchPaymentApiResponseWrapper {
    public String id;	//pay_Lt10vadvOFD5hN
	public String entity;	//payment
	public Integer amount;	//100000
	public String strCurrency;	//INR
	public String status;	//captured
	public String order_id;	//order_Lt0xQ2emJmFnIl
	public String invoice_id;
	public boolean international;
	public String method;	//upi
	public Integer amount_refunded;	//0
	public String refund_status;
	public boolean captured;
	public String description;	//#Lt0xK6S7400u6z
	public String card_id;
	public String bank;
	public String wallet;
	public String vpa;	//success@razorpay
	public String email;	//void@razorpay.com
	public String contact;	//+919891611767
	public Notes notes;
	public Integer fee;	//2360
	public Integer tax;	//360
	public Error error;
	public String error_code;
	public String error_description;
	public String error_source;
	public String error_step;
	public String error_reason;
	public AcquirerData acquirer_data;
	public Integer created_at;	//1684825497
	
	class Notes {
		public String policy_name;	//Jeevan Bima
	}
	class Error {
		public String code;	//BAD_REQUEST_ERROR
		public String description;	//The id provided does not exist
		public String source;	//business
		public String step;	//payment_initiation
		public String reason;	//input_validation_failed
	}
	class AcquirerData {
		public String rrn;	//347494830532
		public String upi_transaction_id;	//C2CC599EFFB4EF4D6FED21B496B96195
	}
}