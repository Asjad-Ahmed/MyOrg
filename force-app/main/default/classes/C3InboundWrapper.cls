public class C3InboundWrapper {
    public String obj; // whatsapp_business_account
    public cls_entry[] entry;

    public class cls_entry {
        public String id; // 108445142322979
        public cls_changes[] changes;
    }

    public class cls_changes {
        public cls_value value;
        public String field; // messages
    }

    public class cls_value {
        public String messaging_product; // whatsapp
        public cls_metadata metadata;
        public cls_contacts[] contacts;
        public cls_messages[] messages;
        public cls_statuses[] statuses;
    }

    public class cls_metadata {
        public String display_phone_number; // 917042912244
        public String phone_number_id; // 108193625692105
    }

    public class cls_contacts {
        public cls_profile profile;
        public String wa_id; // 918802271489
    }

    public class cls_profile {
        public String name; // Shivam
    }

    public class cls_statuses {
        public String id; // wamid.HBg...
        public String status; // failed / delivered
        public String timestamp; // 1745992373
        public String recipient_id; // 918449616698
        public cls_conversation conversation;
        public cls_pricing pricing;
        public cls_error[] errors; // NEW
    }

    public class cls_conversation {
        public String id;
        public cls_origin origin;
    }

    public class cls_origin {
        public String type; // marketing
    }

    public class cls_pricing {
        public Boolean billable;
        public String pricing_model; // CBP
        public String category; // marketing
    }

    public class cls_error { // NEW
        public Integer code;
        public String title;
        public String message;
        public cls_error_data error_data;
        public String href;
    }

    public class cls_error_data { // NEW
        public String details;
    }

    public class cls_messages {
        public String fromNumber; // 918802271489
        public String id;
        public String timestamp;
        public cls_text text;
        public String type; // text
        public cls_image image;
        public cls_document document;
        public cls_video video;
        public cls_Audio audio;
        public cls_button button;
    }

    public class cls_text {
        public String body;
    }

    public class cls_button {
        public String payload;
        public String text;
    }

    public class cls_document {
        public String caption;
        public String filename;
        public String mime_type;
        public String sha256;
        public String id;
    }

    public class cls_video {
        public String caption;
        public String filename;
        public String mime_type;
        public String sha256;
        public String id;
    }

    public class cls_image {
        public String caption;
        public String mime_type;
        public String sha256;
        public String id;
    }

    public class cls_Audio {
        public String mime_type;
        public String id;
    }
}