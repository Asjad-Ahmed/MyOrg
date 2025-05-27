import { api, track, LightningElement } from 'lwc';
import initializer from '@salesforce/apex/CalendarInitializer.initializer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';




const monthMap = new Map([
    ['January', 'Jan'],
    ['February', 'Feb'],
    ['March', 'Mar'],
    ['April', 'Apr'],
    ['May', 'May'],
    ['June', 'Jun'],
    ['July', 'Jul'],
    ['August', 'Aug'],
    ['September', 'Sep'],
    ['October', 'Oct'],
    ['November', 'Nov'],
    ['December', 'Dec']
]);

export default class AppointmentSelectionUnmanaged extends LightningElement {
 
    @api earliestStartPermitted = "2024-08-01";
    @api arrivalWindowStart = "";
    monthMap = monthMap;

    isLoading = false;
    @track monthName;
    
    @track calendarDays = [];
    @track apexData;

    @track selectedDay;
    @track monthsToAdvance = 0;
    year;
    weekName = '';
    @track globalSlot;


    confStartTime;
    confEndTime;
    confDate;
    confworkType;
    confPhone;
    conEmail;
    confname;
    localStart;
    localEnd;

    @track listEvent = [{
        name : "event 1",
        type : "Meeting"
    }]

    connectedCallback() {

        this.isLoading = true;
        console.log('Earliest Start Permitted: ' + this.earliestStartPermitted);
       

      //  this.retrieveServiceOrder();


        // this.startingDayOfWeek = 0; 
        initializer({ earliestDate : this.earliestStartPermitted })
        .then(data => {
            console.log(data);
            this.isLoading = false;
            if (data) {
                this.apexData = JSON.parse(data);
                let result = this.apexData.calendarMonths[0];
                this.monthName = result.MonthName;
                this.year = result.yearName;
                this.calendarDays = result.calendarDays;
                for (let i = 0; this.calendarDays.length > i; i++) {
                    if (this.calendarDays[i].dayNumber != null && this.calendarDays[i].dayNumber != '') {
                        this.calendarDays[i].blockStyle = "padding: 6px;font-size: 16px; text-align: center; border-radius: 8px;  font-weight: bold;cursor: pointer; border: 2px solid transparent; background-color: #e0e0e0;";
                        if (!this.calendarDays[i].isEnabled) {
                            //this.calendarDays[i].blockStyle = "background-color: #717272; ";
                            console.log('camehere')
                            this.calendarDays[i].blockStyle = "padding: 6px;font-size: 16px; text-align: center; border-radius: 8px;  font-weight: bold;cursor: not-allowed;; border: 2px solid transparent; background-color: #717272;";
                        }
                    }
                }
            }
        })
        .catch(error => {
            this.isLoading = false;
            console.log(error);
        });
    }

    handleDayClick(event) {
        let index = event.target.dataset.index;
        let day = event.target.dataset.day;
        console.log(index)
        console.log(day)
    }


    convertTo12HourFormat(inputTimeString) {
        const [hours, minutes] = inputTimeString.match(/\d+/g).map(Number);
        // Convert to 12-hour format
        const period = hours >= 12 ? "PM" : "AM";
        const hours12 = hours % 12 || 12;
        // Create the formatted time string
        const formattedTime = `${hours12}:${minutes < 10 ? "0" : ""}${minutes} ${period}`;
        return formattedTime;
    }

    toastEvent(type, title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(evt);
    }

    getMonthName(monthIndex) {
        const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        return monthNames[monthIndex];
    }

    getWeekName(monthIndex) {
        const weekNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        return weekNames[monthIndex];
    }

    cantGoForward = false;
    index = 0;
    handleNextMonthClick() {
        
        console.log('this.apexData.calendarMonths.length=== '+this.apexData.calendarMonths.length);
        if(this.index <  this.apexData.calendarMonths.length){
            this.index = this.index + 1;
            let result = this.apexData.calendarMonths[this.index];
            this.monthName = result.MonthName;
            this.year = result.yearName;
            this.calendarDays = result.calendarDays;
            for (let i = 0; this.calendarDays.length > i; i++) {
                if (this.calendarDays[i].dayNumber != null && this.calendarDays[i].dayNumber != '') {
                    this.calendarDays[i].blockStyle = "padding: 6px;font-size: 16px; text-align: center; border-radius: 8px;  font-weight: bold;cursor: pointer; border: 2px solid transparent; background-color: #e0e0e0;";
                    if (!this.calendarDays[i].isEnabled) {
                        //this.calendarDays[i].blockStyle = "background-color: #717272; ";
                        this.calendarDays[i].blockStyle = "padding: 6px;font-size: 16px; text-align: center; border-radius: 8px;  font-weight: bold;cursor: not-allowed;; border: 2px solid transparent; background-color: #717272;";
                    }
                }
            }
            this.canGoBack = true;
            console.log(this.index);
        }
        if(this.index === (this.apexData.calendarMonths.length-1)){
            console.log('inside  '+this.index);
            this.canGoBack = true;
            this.cantGoForward = true;
        }
    }


    canGoBack = false;
    handlePreviousMonthClick() {
        
        if (this.index > 0) {
            this.index = this.index - 1;
            let result = this.apexData.calendarMonths[this.index];
            this.monthName = result.MonthName;
            this.year = result.yearName;
            this.calendarDays = result.calendarDays;
            for (let i = 0; this.calendarDays.length > i; i++) {
                if (this.calendarDays[i].dayNumber != null && this.calendarDays[i].dayNumber != '') {
                    this.calendarDays[i].blockStyle = "padding: 6px;font-size: 16px; text-align: center; border-radius: 8px;  font-weight: bold;cursor: pointer; border: 2px solid transparent; background-color: #e0e0e0;";
                    if (!this.calendarDays[i].isEnabled) {
                        //this.calendarDays[i].blockStyle = "background-color: #717272; ";
                        this.calendarDays[i].blockStyle = "padding: 6px;font-size: 16px; text-align: center; border-radius: 8px;  font-weight: bold;cursor: not-allowed;; border: 2px solid transparent; background-color: #717272;";
                    }
                }
            }
            this.cantGoForward = false;
            console.log(this.index);
        }
        if (this.index == 0) {
            this.canGoBack = false;
            this.cantGoForward = false;
        }
    }

    convertDateFormat(originalDate) {
        let dateParts = originalDate.split('-');
        let formattedDate = `${dateParts[1]}/${dateParts[2]}/${dateParts[0]}`;
        return formattedDate;
    }


    APHandleDragStart(event) {
        let objTfData = { name : event.target.dataset.name, type : 'add' };
        console.log(JSON.stringify(objTfData));
        event.dataTransfer.setData('text/plain', JSON.stringify(objTfData) );
    }

    APHandleDrop(event) {
        
        event.preventDefault();
        let index = event.target.dataset.index;
        let day = event.target.dataset.day;
        const transferData = JSON.parse(event.dataTransfer.getData('text/plain'));
        console.log('transferData -- '+event.dataTransfer.getData('text/plain'));
        console.log('index -- '+index);
        console.log('day -- '+day);
    }
    APHandleDragOver(event) {
        event.preventDefault();
    }


}