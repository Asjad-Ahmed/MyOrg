import { LightningElement, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class PlatformCatchEvent extends LightningElement {
    @track message;
    subscription = {};

    connectedCallback() {
        this.handleSubscribe();
    }

    handleSubscribe() {
        const channel = '/event/Duplicate_Lead_Event__e'; // API Name of the platform event

        subscribe(channel, -1, (event) => {
            console.log('Received Platform Event: ', JSON.stringify(event));
            this.message = event.data.payload.Email_Table_Body__c;
        }).then((response) => {
            this.subscription = response;
            console.log('Subscribed to Platform Event');
        });

        onError((error) => {
            console.error('Platform Event Error: ', JSON.stringify(error));
        });
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, (response) => {
            console.log('Unsubscribed from Platform Event', response);
        });
    }
}