public class RPPaymentLinkApiWrapper {

    public boolean accept_partial;
	public Integer amount;	//100000
	public Integer amount_paid;	//100000
	public String callback_method;	//get
	public String callback_url;	//https://example-callback-url.com/
	public Integer cancelled_at;	//0
	public Integer created_at;	//1684825292
	public String strCurrency;	//INR
	public Customer customer;
	public String description;	//Payment for policy no #23456
	public Integer expire_by;	//1691097057
	public Integer expired_at;	//0
	public Integer first_min_partial_amount;	//100
	public String id;	//plink_Lt0xK6S7400u6z
	public Notes notes;
	public Notify notify;
	public String order_id;	//order_Lt0xQ2emJmFnIl
	public List<Payment> payments;
	public String reference_id;	//999
	public boolean reminder_enable;
	public Reminder reminders;
	public String short_url;	//https://rzp.io/i/anArToDk2c
	public String status;	//paid
	public Integer updated_at;	//1684825498
	public boolean upi_link;
	public String user_id;	//

	class Customer {
		public String contact;	//+919891611767
		public String email;	//asad.ahmed@example.com
		public String name;	//sana
	}

	class Notes {
		public String policy_name;	//Jeevan Bima
	}

	class Notify {
		public boolean email;
		public boolean sms;
		public boolean whatsapp;
	}

	class Payment {
		public Integer amount;	//100000
		public Integer created_at;	//1684825498
		public String method;	//upi
		public String payment_id;	//pay_Lt10vadvOFD5hN
		public String status;	//captured
	}

	class Reminder {
		public String status;	//failed
	}
}