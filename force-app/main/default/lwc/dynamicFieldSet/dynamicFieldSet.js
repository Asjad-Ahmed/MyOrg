import { LightningElement, wire } from 'lwc';
import getFieldSet from '@salesforce/apex/FieldSetController.getFieldSet';

export default class DynamicFieldSet extends LightningElement {
    @wire(getFieldSet, { objectName: 'Account', fieldSetName: 'AccountFieldSet' })
    fields;

    get fieldList() {
        return this.fields.data ? this.fields.data : [];
    }
}