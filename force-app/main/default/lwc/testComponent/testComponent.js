import { LightningElement, api, wire, track } from 'lwc';
 


export default class TestComponent extends LightningElement {
    @api recordId;
    @track name = 'Asjad';
    // func(param1){
    //     console.log('function one='+param1);
    // }
    
    // func('test');

    connectedCallback() {
        this.name = 'Asjad';
        console.log('ConnectedCallBack'); // fire once
        console.log('ConnectedCallBack='+ this.recordId + this.name); 
    }    

    renderedCallback(){
        console.log('renderedcallback'); // fire whenever a value is rendered
    }
}