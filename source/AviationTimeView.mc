import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Time;
import Toybox.ActivityMonitor;
 

class AviationTimeView extends WatchUi.WatchFace {

    var clockColorNum = Application.getApp().getProperty("ClockColor");
    var clockColorSet = Graphics.COLOR_DK_BLUE;
    var clockShadNum = Application.getApp().getProperty("ShadOpt");
    var clockShadSet = Graphics.COLOR_TRANSPARENT;
    var timeOrStep = Application.getApp().getProperty("TimeStep");
    var alarmLoad = System.getDeviceSettings().alarmCount;
    var noteLoad = System.getDeviceSettings().notificationCount;
    var showBat = Application.getApp().getProperty("DispBatt");


    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }


    // Update the view
    function onUpdate(dc) as Void {

        //dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        colorUpdate(dc);

        //Draw Time
        drawTime(dc);

        //Draw ZuluTime or Steps
        drawZTime();

        //Draw Date
        drawDate();

        //Draw Battery
        drawBatt();

        //Draw Alarm
        drawAlarm();

        //Draw Notifications
        drawNote();      
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }
 
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    //Force update when settings change
    function onSettingsChanged() {

        onUpdate(dc);
    }

        function colorUpdate(dc){
            //Get color settings
            clockColorNum = Application.getApp().getProperty("ClockColor");

		        switch (clockColorNum){
			        case 0:
				        clockColorSet = Graphics.COLOR_BLACK;
				        break;
			        case 1:
				        clockColorSet = Graphics.COLOR_LT_GRAY;
				        break;
			        case 2:
				        clockColorSet = Graphics.COLOR_BLUE;
				        break;
			        case 3:
				        clockColorSet = Graphics.COLOR_DK_BLUE;
				        break;
                    case 4:
				        clockColorSet = Graphics.COLOR_GREEN;
				        break;
                    case 5:
				        clockColorSet = Graphics.COLOR_DK_GREEN;
				        break;
		            case 6:
				        clockColorSet = Graphics.COLOR_RED;
				        break;
                    case 7:
				        clockColorSet = Graphics.COLOR_DK_RED;
				        break;
			        case 8:
				        clockColorSet = Graphics.COLOR_PURPLE;
				        break;
			        case 9:
				        clockColorSet = Graphics.COLOR_YELLOW;
				        break;
                    case 10:
				        clockColorSet = Graphics.COLOR_WHITE;
				        break;
		        }

            //Select shadowing
            clockShadNum = Application.getApp().getProperty("ShadOpt");

                switch(clockShadNum) {
                    case 0:
                        clockShadSet = Graphics.COLOR_TRANSPARENT;
                        break;
                    case 1:
                        clockShadSet = Graphics.COLOR_BLACK;
                        break;
                    case 2:
                        clockShadSet = Graphics.COLOR_WHITE;
                        break;
                    case 3:
                        clockShadSet = Graphics.COLOR_LT_GRAY;
                        break;
                }

            //Show either zulu time or steps
            timeOrStep = Application.getApp().getProperty("TimeStep");

            //Show the battery or not
            showBat = Application.getApp().getProperty("DispBatt");

        }

        //Dispaly time
        function drawTime(dc) {
 
            //Get and show the current time & Zulu time
            var timeString;
            var clockTime = System.getClockTime();

            var hours = clockTime.hour;

            //Format local time for 12 or 24 hour clock
            if (System.getDeviceSettings().is24Hour == true){      
                timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
            } else {
                if (hours > 12) {
                    hours = hours - 12;
                }
            timeString = Lang.format("$1$:$2$", [hours, clockTime.min.format("%02d")]);
            }

            //For the text
            var view = View.findDrawableById("TimeLabel") as Text;
            
            //For the shadow
            var viewLS = View.findDrawableById("TimeLabelRShad") as Text;

            if (clockShadSet == null) {clockShadSet = Graphics.COLOR_TRANSPARENT;} 
            viewLS.setColor(clockShadSet);   
            viewLS.setText(timeString);

            if (clockColorSet == null) {clockColorSet = Graphics.COLOR_TRANSPARENT;}
            view.setColor(clockColorSet);
            view.setText(timeString);

        }
        
        //Draw Zulu time or steps
        function drawZTime() {

            //Format zulu time
            var zTime = Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
            var zuluTime = Lang.format("$1$:$2$", [zTime.hour.format("%02d"), zTime.min.format("%02d")])+"Z";
            var zView = View.findDrawableById("zTimeLabel") as Text;

            //Format Steps
            var stepLoad = ActivityMonitor.getInfo();
            var steps = stepLoad.steps;
            var stepString = Lang.format("$1$", [steps]);
            var stepDisplay = View.findDrawableById("stepLabel") as text;
         
            //Zulu time or steps option
 
            if (timeOrStep == 1){
                //clear Zulu time text and dipslay Steps
                zView.setColor(Graphics.COLOR_TRANSPARENT);
                stepDisplay.setColor(Graphics.COLOR_LT_GRAY);
                stepDisplay.setText(stepString);
            } else {
                //Clear step line and display Zulu
                stepDisplay.setColor(Graphics.COLOR_TRANSPARENT);
                zView.setColor(Graphics.COLOR_LT_GRAY);
                zView.setText(zuluTime);
            }
        }

        //Display Date
        function drawDate() {

            var dateLoad = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
            var dateString = Lang.format("$1$, $2$ $3$", 
                [dateLoad.day_of_week,
                dateLoad.day,
                dateLoad.month]);
            var dateCalc = View.findDrawableById("dateLabel") as Text;
            dateCalc.setText(dateString);

        }

        //Display Battery info
        function drawBatt(){
            //Get battery info

            var batteryDisplay = View.findDrawableById("batLabel") as Text;
            var batString;
            if (showBat == 0) {
                var batLoad = ((System.getSystemStats().battery) + 0.5).toNumber();
                batString = Lang.format("$1$", [batLoad])+"%";

                if (batLoad < 5.0) {
                    batteryDisplay.setColor(Graphics.COLOR_RED);
                } else if (batLoad < 25.0) {
                batteryDisplay.setColor(Graphics.COLOR_YELLOW);
                } else {
                    batteryDisplay.setColor(Graphics.COLOR_LT_GRAY);
                }
            } else {
                batString = " ";
                batteryDisplay.setColor(Graphics.COLOR_TRANSPARENT);
            }
            batteryDisplay.setText(batString);
            
        }

        //Display Alarm Info
        function drawAlarm(){

            //See if an alarm is set

            var alarmString = "A";
            var alarmStr = Lang.format("$1$", [alarmString]);
            var alarmDisplay = View.findDrawableById("alarmLabel") as Text;

            alarmLoad = System.getDeviceSettings().alarmCount;

            if (alarmLoad != 0) {
                alarmString = "A";
            } else {
                alarmString = " ";
            }

            alarmDisplay.setText(alarmString);
        }

        //Display notification information
        function drawNote(){

            //See if there are any system notices

            var noteString=" ";
            var noteStr = Lang.format("$1$", [noteString]);
            var noteDisplay = View.findDrawableById("noteLabel") as Text;
            
            noteLoad = System.getDeviceSettings().notificationCount;

            if (noteLoad !=0) {
                noteString = "N";
            } else {
                noteString = " ";
            }
            noteDisplay.setText(noteString);
        }
}
