import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getPickListValue from '@salesforce/apex/AssessmentScreenController.getPickListValue';
import IMAGE_URL from '@salesforce/resourceUrl/My_Image';

export default class ScheduleMeetingLwc extends LightningElement {
    @track isLoading = false;
    @api recordId;
    imageUrl = IMAGE_URL;

    @track objPersonalInfo = {
        firstName : '',
        lastname : '',
        email : '',
        phone : '',
        description : '',
    }

    connectedCallback(){
        console.log('recordId  '+this.recordId);
    }























    
    genericChange(event){
        let fieldName = event.target.name;
        let value = event.target.value;
        
        switch (fieldName) {
            case "firstName":
                this.objPersonalInfo.firstName = value;
                break;
        }
    }




    toastEvent(type,title, message){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(evt);
    }


    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate-input');
        // inputFields.push(this.template.querySelectorAll('lightning-combobox'));
        inputFields.forEach(inputField => {
          if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false;
          }
        });
        return isValid;
    }
}