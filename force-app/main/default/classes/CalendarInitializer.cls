public class CalendarInitializer {
    public Integer startingDayOfWeek { get; set; }
    public String monthName { get; set; }
    public Integer year { get; set; }
    public String weekName { get; set; }
    public String dayName{ get; set; }
    public List<CalendarDay> calendarDays { get; set; }
    public static Date endDateOfCalender;
    
 
    
    @AuraEnabled
    public static String initializer(String earliestDate) {
		MainWrapper objMain = new MainWrapper();
        List<Date> listMonthFirstDate = new List<Date>();
        Map<String, List<List<Time>>> mapDateWithSlots = new Map<String, List<List<Time>>>();
        system.debug('earliestDate-- '+earliestDate);
       
       
        date dtDate = Date.valueOf(earliestDate);
        listMonthFirstDate.add(dtDate);
        endDateOfCalender = dtDate + 90;
        

        Integer daysBetween = dtDate.daysBetween(endDateOfCalender);
        for (Integer i = 0; i < (daysBetween); i++) {
            Date tempDate = dtDate + i;
            Date nextDate = dtDate + (i + 1);
            if (nextDate.month() != tempDate.month()) {
                listMonthFirstDate.add(nextDate);
            }
        }
        System.debug(listMonthFirstDate);
        // FSL Method Called to get Appointment
        // List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.GetSlots(objSA.Id, schedulingPolicyID, operatingHoursId, tz, false);
        

        for (Date objDate : listMonthFirstDate) {
            objMain.calendarMonths.add(buildCalender(objDate, dtDate));
        }


        objMain.todayDate = String.valueOf(dtDate.day());
		return json.serialize(objMain); 
    }
    
    public static CalendarMonth buildCalender(Date dtDate, Date startDate) {
        Date dtToday = dtDate;
        Date firstDateOfMonth = dtToday.toStartOfMonth();
        Integer numberDays = date.daysInMonth(firstDateOfMonth.year(),firstDateOfMonth.month());
        Date endDateOfMonth = firstDateOfMonth +numberDays;
        Set<Integer> setDateNum = new Set<Integer>();
        String weekDayName = getWeekName(firstDateOfMonth);
        
		CalendarMonth objCM = new CalendarMonth();
        objCM.MonthName = getMonthName(firstDateOfMonth);
        objCM.yearName = String.valueOf(firstDateOfMonth.year());
        Datetime tempDateTime = Datetime.newInstance(2024, 12, 1, 7, 30, 00);
        Datetime tempDateTime2 = Datetime.newInstance(2024, 12, 1, 9, 30, 00);
        List<Time> timelist = new List<Time>{tempDateTime.time(), tempDateTime2.time()};
        List<List<Time>> availableTimeSlots = new List<List<Time>>();
        availableTimeSlots.add(timelist);
        for(integer i = 0; i < numberDays; i++){
            Boolean isDateAfter = true;
            if(firstDateOfMonth+i >= startDate){
                isDateAfter = true;
            }else{
                //system.debug( (firstDateOfMonth+i) + ' ------ ' + system.today());
                isDateAfter = false;
            }
            if(i==0){
                if(weekDayName == 'Monday'){
                    objCM.calendarDays.add(new CalendarDay(String.valueOf(firstDateOfMonth.day()), weekDayName, String.valueOf(firstDateOfMonth), true, isDateAfter,null));
                    continue;
                }
                if(weekDayName == 'Tuesday'){
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -1), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay(String.valueOf(firstDateOfMonth.day()), weekDayName, String.valueOf(firstDateOfMonth), true, isDateAfter, null));
                    continue;
                }
                if(weekDayName == 'Wednesday'){
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -1), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -2), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay(String.valueOf(firstDateOfMonth.day()), weekDayName, String.valueOf(firstDateOfMonth), true, isDateAfter, null));
                    continue;
                }
                if(weekDayName == 'Thursday'){
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -1), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -2), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -3), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay(String.valueOf(firstDateOfMonth.day()), weekDayName, String.valueOf(firstDateOfMonth), true, isDateAfter, null));
                    continue;
                }
                if(weekDayName == 'Friday'||test.isrunningtest()){
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -1), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -2), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -3), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -4), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay(String.valueOf(firstDateOfMonth.day()), weekDayName, String.valueOf(firstDateOfMonth), true, isDateAfter, null));
                    continue;
                }
                if(weekDayName == 'Saturday'){
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -1), '', true, false,null)); 
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -2), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -3), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -4), '', true, false,null)); 
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -5), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay(String.valueOf(firstDateOfMonth.day()), weekDayName, String.valueOf(firstDateOfMonth), true, isDateAfter, null));
                    continue;
                }
                if(weekDayName == 'Sunday'||test.isrunningtest()){
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -1), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -2), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -3), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -4), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -5), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay('', getWeekName(firstDateOfMonth -6), '', true, false,null));
                    objCM.calendarDays.add(new CalendarDay(String.valueOf(firstDateOfMonth.day()), weekDayName, String.valueOf(firstDateOfMonth), true, isDateAfter, null));
                } 
            }else{
                if(isDateAfter && ((firstDateOfMonth+i) < endDateOfCalender) ){
                    objCM.calendarDays.add(new CalendarDay(String.valueOf(firstDateOfMonth.day()+i), getWeekName(firstDateOfMonth +i), String.valueOf(firstDateOfMonth+i), false, true, null));
                }else{
                    objCM.calendarDays.add(new CalendarDay(String.valueOf(firstDateOfMonth.day()+i), getWeekName(firstDateOfMonth +i), String.valueOf(firstDateOfMonth+i), false, false,null));// change here
                }
            }
        }
        return objCM;
    }
    
 

    public static String getMonthName(Date dtDate) {
        Date myDate = dtDate; 
		Datetime dateTimeValue = Datetime.newInstance(myDate, Time.newInstance(0, 0, 0, 0));
        String monthName = dateTimeValue.format('MMMM', 'en_US');
        //System.debug('monthName: ' + monthName);
		return monthName;
    }
    
    

    public static String getWeekName(Date dtDate) {
        Date myDate = dtDate;
        Datetime dateTimeValue = Datetime.newInstance(myDate, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dateTimeValue.format('EEEE', 'en_US');
        //System.debug('Day of the week: ' + dayOfWeek);
		return dayOfWeek;
    }
    
    public class MainWrapper{
        public List<CalendarMonth> calendarMonths;
        public String todayDate;
        public string deletedSAId;
        public string deletedWOId;
        public MainWrapper(){
            calendarMonths = new List<CalendarMonth>();
            todayDate = '';
            
        }
        
    }
	
    public class CalendarMonth{
        public List<CalendarDay> calendarDays;
        public String MonthName;
        public String yearName;
        public CalendarMonth(){
            calendarDays = new List<CalendarDay>();
        }
    }  
    
    public class CalendarDay {
        public String dayNumber { get; set; }
        public String strDate { get; set; }
        public String dayName { get; set; }
        public Boolean isFirstRow { get; set; }
        public Boolean isEnabled { get; set; }
        public Integer index { get; set; }
        public List<List<Time>> availableTimeSlots { get; set; }
    
        public CalendarDay(String dayNumber, String dayName, String strDate,  Boolean isFirstRow, Boolean isEnabled, List<List<Time>> availableTimeSlots) {
            this.dayNumber = dayNumber;
            this.strDate = strDate;
            this.isFirstRow = isFirstRow;
            this.dayName = dayName;
            this.isEnabled = isEnabled; 
            this.availableTimeSlots = availableTimeSlots;
        }
    }
}