import { LightningElement, api, wire, track } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import STAGE from '@salesforce/schema/Opportunity.StageName';
import createOpp_Con_Acc from '@salesforce/apex/DemoComponent.createOpp_Con_Acc';
import OPPTY_OBJECT from '@salesforce/schema/Opportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class DemoComponent extends LightningElement {
    //@api recordId;
    @track isBusinessLead;
    @track isIndividualLead;
    @track todayDate;
    @track isLoading = false;
    @track genderValue = true;

    @track
    leadobj = {
        isBusinessLead : true,
        accountName : '',
        contactFname : '',
        contactLname : '',
        fName : '',
        lName : '',
        opptyName : '',
        stage : '',
        closeDate : ''

    }
    @track day = 'Monday';
    showDay(){
        let day = 'tuesday';
        console.log('Day===='+this.day);
    }


    // @wire(getObjectInfo, { objectApiName: OPPTY_OBJECT })
    // OpportunityInfo;

    // @wire(getPicklistValues,
    //     {
    //         recordTypeId: '$OpportunityInfo.data.defaultRecordTypeId', //pass id dynamically
    //         fieldApiName: STAGE
    //     }
    // )
    // stageOptions;

    

    get leadTypeOptions(){
        return [
            { label: 'Business Seller', value: 'Business Seller' },
            { label: 'Individual Seller', value: 'Individual Seller' }
        ];
    }
    get stageOptions(){
        return [
            { label: 'Prospecting', value: 'Prospecting' },
            { label: 'Qualification', value: 'Qualification' },
            { label: 'Needs Analysis', value: 'Needs Analysis' },
            { label: 'Value Proposition', value: 'Value Proposition' },
            { label: 'Perception Analysis', value: 'Perception Analysis' },
            { label: 'Proposal/Price Quote', value: 'Proposal/Price Quote' },
            { label: 'Negotiation/Review', value: 'Negotiation/Review' },
            { label: 'Closed Won', value: 'Closed Won' },
            { label: 'Closed Lost', value: 'Closed Lost' },
        ];
    }

    // getrecordId(){
    //     console.log(this.recordId);
    //     if(this.recordId){
    //         console.log(this.recordId);
    //         return this.recordId;
    //     }
    //     else{
    //         getrecordId();
    //     }
        
    // }

    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //     if (currentPageReference) {
    //         this.recordId = currentPageReference.state.recordId;
    //     }
    // }
    connectedCallback() {
        //this.getrecordId();
        this.showDay();
        this.todayDate = new Date().toISOString().slice(0, 10);
        console.log('todayDate+'+this.todayDate);
        //console.log(this.recordId);
        this.isBusinessLead = true;
        this.isIndividualLead = false;
        this.leadobj.isBusinessLead = true;

        // let lst= ['x', 'y', 'z'];
        // lst.forEach(function(tag){
        //     console.log(tag);
        // })

    //    alert('Connected!!!');
    }

    genericChange(event){
        let strField = event.target.name;
        if(strField == 'leadType')
        {
            if(event.target.value == 'Business Seller')
            {
                this.isBusinessLead = true;
                this.isIndividualLead = false;
                this.leadobj.isBusinessLead = true;
            }
            else{
                this.isBusinessLead = false;
                this.isIndividualLead = true;
                this.leadobj.isBusinessLead = false;
            }
        }
        if(strField == 'closeDate')
        {
           this.leadobj.closeDate = event.target.value;
        }
        if(strField == 'companyName')
        {
           this.leadobj.accountName = event.target.value;
        }
        if(strField == 'contactFirstName')
        {
           this.leadobj.contactFname = event.target.value;
        }
        if(strField == 'contactLastName')
        {
           this.leadobj.contactLname = event.target.value;
        }
        if(strField == 'FirstName')
        {
           this.leadobj.fName = event.target.value;
        }
        if(strField == 'LastName')
        {
           this.leadobj.lName = event.target.value;
        }
        if(strField == 'stage')
        {
           this.leadobj.stage = event.target.value;
        }
        if(strField == 'opptyName')
        {
           this.leadobj.opptyName = event.target.value;
        }
    }


    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
          if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false;
          }
        });
        return isValid;
    }

    handleSubmit(){
        createOpp_Con_Acc({
            jsStringObj : JSON.stringify(this.leadobj)
        }).then((result)=>{
            const evt = new ShowToastEvent({
                title: 'SUCCESS!',
                message: result,
                variant: 'success'
            });
            this.dispatchEvent(evt);
        
        }).catch((error) => {
            console.log("Update Error : "+JSON.stringify(error));
            const evt = new ShowToastEvent({
                title: 'ERROR!',
                message: JSON.stringify(error),
                variant: 'error'
            });
            this.dispatchEvent(evt);
        });
    }
}