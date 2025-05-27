// lwcdigestaccountchild
import { LightningElement,api,wire,track } from 'lwc';
import tailwind from '@salesforce/resourceUrl/tailwind';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
    
    


    export default class LwcAccountDigestChild extends LightningElement {
 

    connectedCallback() {
        loadStyle(this, tailwind);
          
        }
    

}