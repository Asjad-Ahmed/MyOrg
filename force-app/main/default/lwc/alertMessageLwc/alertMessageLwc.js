import { LightningElement, api } from 'lwc';

export default class AlertMessage extends LightningElement {
    @api messageType; // 'confirmation', 'information', 'warning', 'error'
    @api message;


    showMessage = false;

    closeMessage() {
        this.showMessage = false;
        
    }

    connectedCallback() {
        this.showMessage = true;
        this.setAlertProperties();
    }

    setAlertProperties() {
        switch (this.messageType) {
            case 'confirmation':
                this.alertStyle = 'background-color: #e6f9e6; border-left: 5px solid #28a745;';
                this.iconName = 'utility:success'; // FIXED: Explicit namespace
                this.title = 'Confirmation';
                break;
            case 'information':
                this.alertStyle = 'background-color: #eef5fc; border-left: 5px solid #007bff;';
                this.iconName = 'utility:info'; // FIXED
                this.title = 'Information';
                break;
            case 'warning':
                this.alertStyle = 'background-color: #fff3cd; border-left: 5px solid #ffc107;';
                this.iconName = 'utility:warning'; // FIXED
                this.title = 'Warning';
                break;
            case 'error':
                this.alertStyle = 'background-color: #f8d7da; border-left: 5px solid #dc3545;';
                this.iconName = 'utility:error'; // FIXED
                this.title = 'Error';
                break;
            default:
                this.alertStyle = 'display: none;';
                this.iconName = '';
                this.title = '';
        }
        console.log(this.alertStyle);
        console.log(this.iconName);
        console.log(this.title);
        console.log(this.message);
        console.log(this.messageType);
    }
}