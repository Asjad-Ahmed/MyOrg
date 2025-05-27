import { LightningElement, track, wire } from 'lwc';
import initialize from '@salesforce/apex/AddProductDragDropLwcController.initialize';
import getProducts from '@salesforce/apex/AddProductDragDropLwcController.getProducts';
import getPrice from '@salesforce/apex/AddProductDragDropLwcController.getPrice';
import saveOpportunityLineItem from '@salesforce/apex/AddProductDragDropLwcController.saveOpportunityLineItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddProductDragDropLwc extends LightningElement {
    
    @track isLoading = false;
    @track showDropBoxAdd = false;
    @track showDropBoxRemove = false;
    @track droppedBoxes = [];
    @track products = [];
    @track opportunityLineItems = [];

    displayInfo = {
        primaryField: 'Name',
        additionalFields: ['UnitPrice', 'Pricebook2.Name' ],
    };
    productSearch = ''
    
    connectedCallback(){
        this.isLoading = true;
        this.init();
    }

    init(){
        initialize({recordId : ''})
        .then((result)=>{
            console.log('result -- '+result);
            let extensibleObject = [];
            let temp = JSON.parse(result).listProducts;
            if (temp) {
                temp.forEach(element => {
                    let tempItem  = {
                        ...element, 
                        recordUrl: window.location.origin + '/'+ element.Id
                    };
                    extensibleObject.push(tempItem);
                });
                this.products = JSON.parse(JSON.stringify(extensibleObject));
            }
            
            this.isLoading = false;
        
        }).catch((error) => {
            this.isLoading = false;
            console.log("Error : "+JSON.stringify(error));
            this.toastMessage('error', 'Error!', error.message);
        });
    }

    @wire(getProducts, { strProductName: '$productSearch'})
    getProducts({ error, data }) {
        if (error) {
            this.isLoading = false;
            console.log("Error : "+JSON.stringify(error));
            this.toastMessage('error', 'Error!', error);
        } else if (data) {
            let extensibleObject = [];
            let temp = data;
            if (temp) {
                temp.forEach(element => {
                    let tempItem  = {
                        ...element, 
                        recordUrl: window.location.origin + '/'+ element.Id
                    };
                    extensibleObject.push(tempItem);
                });
                this.products = JSON.parse(JSON.stringify(extensibleObject));
            }
            this.isLoading = false;
        }
    }

    // Product change
    onProductChange(event){
        this.isLoading = true;
        this.productSearch = event.target.value;
        console.log(this.productSearch);
        if (this.productSearch == undefined || this.productSearch == null) {
            this.productSearch = '';
        }
    }
    
    onPriceSelect(event){
        this.isLoading = true;
        let index = event.target.dataset.index;
        let pbeId = event.detail.recordId;
        this.opportunityLineItems[index].priceBookEntryId = pbeId;
        if(pbeId != null && pbeId != undefined && pbeId != ''){
            getPrice({pbeId : pbeId})
            .then((result)=>{
                console.log('result -- '+result);
                if (result) {
                    this.opportunityLineItems[index].price = result;
                }
                this.isLoading = false;
            }).catch((error) => {
                this.isLoading = false;
                console.log("Error : "+JSON.stringify(error));
                this.toastMessage('error', 'Error!', error.message);
            });
        }else{
            this.opportunityLineItems[index].price = 0;
            this.isLoading = false;
        }
    }

    genericChange(event){
        let index = event.target.dataset.index;
        this.opportunityLineItems[index].quantity = event.target.value;
    }

    //----------- all drag events ---------------------------------------------------------------------------------------------------------
    APHandleDragStart(event) {
        let objTfData = {Id : event.target.dataset.id, name : event.target.dataset.name, type : 'add' };
        event.dataTransfer.setData('text/plain', JSON.stringify(objTfData) );
        //console.log('Id -- '+ event.target.dataset.id);
        //console.log('index -- '+ event.target.dataset.index);
    }

    DPHandleDragStart(event) {
        let objTfData = { index : event.target.dataset.index, type : 'remove' };
        event.dataTransfer.setData('text/plain', JSON.stringify(objTfData) );
        //console.log('Id -- '+ event.target.dataset.id);
        console.log('index -- '+ event.target.dataset.index);
    }

    APHandleDragOver(event) {
        event.preventDefault();
    }
    DPHandleDragOver(event) {
        event.preventDefault();
    }

    APonDrag(event){
        this.showDropBoxAdd = true;
    }

    DPonDrag(event){
        this.showDropBoxRemove = true;
    }

    APOnDragEnd(event){
        this.showDropBoxAdd = false;
    }

    DPOnDragEnd(event){
        this.showDropBoxRemove = false;
    }

    APHandleDrop(event) {
        this.showDropBoxAdd = false;
        event.preventDefault();
        const transferData = JSON.parse(event.dataTransfer.getData('text/plain'));
        if (transferData && transferData.type == 'add') {
            let itemLen = this.opportunityLineItems.length;
            let objtemp = {
                Id : "",
                producdId : transferData.Id,
                sNo : itemLen+1,
                name : transferData.name,
                recordUrl : window.location.origin + '/'+ transferData.Id,
                quantity : 0,
                price : 0,
                priceBookEntryId : "",
                filter : {
                    criteria: [
                        {
                            fieldPath: 'Product2Id',
                            operator: 'eq',
                            value: transferData.Id,
                        },
                        {
                            fieldPath: 'IsActive',
                            operator: 'eq',
                            value: true,
                        }
                    ]
                }
            }
            this.opportunityLineItems.push(objtemp);
        }
    }

    DPHandleDrop(event) {
        this.showDropBoxRemove = false;
        event.preventDefault();
        const transferData = JSON.parse(event.dataTransfer.getData('text/plain'));
        if (transferData && transferData.type == 'remove') {
            this.removeItem(transferData.index);
        }
    }

    //----------- all drag events End---------------------------------------------------------------------------------------------------------

    validateData(){
        for (let index = 0; index < this.opportunityLineItems.length; index++) {
            if (this.opportunityLineItems[index].priceBookEntryId == '' || this.opportunityLineItems[index].priceBookEntryId == undefined) {
                this.toastMessage('error', 'Error!', 'Please Select Price Entry Before Saving! ');
                return false;
            }
            console.log(this.opportunityLineItems[index].quantity);
            if (this.opportunityLineItems[index].quantity <= 0) {
                this.toastMessage('error', 'Error!', 'Quantity cannot be zero!');
                return false;
            }
        }
        return true;
    }

    handleSave(){
        console.log(JSON.stringify(this.opportunityLineItems));
        this.isLoading = true;
        if (this.opportunityLineItems) {
            if (this.validateData()) {
                saveOpportunityLineItem({jsonObject : JSON.stringify(this.opportunityLineItems), OpportunityId : '0065i0000062dvIAAQ'})
                .then((result)=>{
                    console.log('result -- '+result);
                    if (result) {
                        this.toastMessage('success', 'Success!', 'Opportunity Product Added Successfully!');
                    }
                    this.isLoading = false;
                }).catch((error) => {
                    this.isLoading = false;
                    console.log("Error : "+JSON.stringify(error));
                    this.toastMessage('error', 'Error!', error.message);
                });
            }else{
                this.isLoading = false;
            }
        }else{
            this.isLoading = false;
        }
    }

    toastMessage(type, title, message){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(evt);
    }

    removeRow(event) {
        const index = event.target.dataset.index;
        this.removeItem(index);
    }

    removeItem(index){
        if (index > -1) {
            this.opportunityLineItems.splice(index, 1);
        }
    }
}