import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ArtemisCalendarV3_MT_Copy extends NavigationMixin(LightningElement)
{   
  @track value;
  @track options= [
    { label: 'Scheduled', value: 'Scheduled' },
    { label: 'No Show', value: 'No Show' },
    { label: 'Rescheduled', value: 'Rescheduled' },
    { label: 'Cancelled', value: 'Cancelled' },
    { label: 'Completed', value: 'Complete' },
  ];
  @track allValues=[];
  @track optionsMaster=[
    { label: 'Scheduled', value: 'Scheduled' },
    { label: 'No Show', value: 'No Show' },
    { label: 'Rescheduled', value: 'Rescheduled' },
    { label: 'Cancelled', value: 'Cancelled' },
    { label: 'Completed', value: 'Complete' },
  ];

  handleChange(event)
  {
    this.value=event.target.value;
    if(!this.allValues.includes(this.value))
      this.allValues.push(this.value);
    this.modifyOptions();
  }

  handleRemove(event)
  {
    this.value='';
    const valueRemoved=event.target.name;
    this.allValues.splice(this.allValues.indexOf(valueRemoved),1);
    this.modifyOptions();
  }

  modifyOptions()
  {
    this.options=this.optionsMaster.filter(elem=>{
      if(!this.allValues.includes(elem.value))
        return elem;
    })
  }
  }