import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Time;
import Toybox.ActivityMonitor;
 

class AviationTimeView extends WatchUi.WatchFace {
   
    //Load the text formats
    var view;       
    var viewLS;
    var zView;
    var stepDisplay;
    var dateCalc;
    var noteDisplay;
    var alarmDisplay;
    var batteryDisplay;


    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) as Void {

        setLayout(Rez.Layouts.WatchFace(dc));

        //Assign al the texts
        view = View.findDrawableById("TimeLabel") as Text;
        viewLS = View.findDrawableById("TimeLabelRShad") as Text;
        zView = View.findDrawableById("zTimeLabel") as Text;
        stepDisplay = View.findDrawableById("stepLabel") as text;
        dateCalc = View.findDrawableById("dateLabel") as Text;
        noteDisplay = View.findDrawableById("noteLabel") as Text;
        alarmDisplay = View.findDrawableById("alarmLabel") as Text;
        batteryDisplay = View.findDrawableById("batLabel") as Text;
    }


    // Update the view
    function onUpdate(dc) as Void {

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


//Draw the face

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

            if (clockShadSet == null) {
                clockShadSet = Graphics.COLOR_TRANSPARENT;
            } 
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

            //Format Steps
            var stepLoad = ActivityMonitor.getInfo();
            var steps = stepLoad.steps;
            var stepString = Lang.format("$1$", [steps]);
         
            //Zulu time or steps option
 
            if (timeOrStep == 1){
                //clear Zulu time text and dipslay Steps
                zView.setColor(Graphics.COLOR_TRANSPARENT);
                stepDisplay.setColor(subColorSet);
                stepDisplay.setText(stepString);
            } else {
                //Clear step line and display Zulu
                stepDisplay.setColor(Graphics.COLOR_TRANSPARENT);
                zView.setColor(subColorSet);
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

            dateCalc.setColor(subColorSet);
            dateCalc.setText(dateString);

        }

        //Display Battery info
        function drawBatt(){
            //Get battery info

            var batString;
            if (showBat == 0) {
                var batLoad = ((System.getSystemStats().battery) + 0.5).toNumber();
                batString = Lang.format("$1$", [batLoad])+"%";

                if (batLoad < 5.0) {
                    batteryDisplay.setColor(Graphics.COLOR_RED);
                } else if (batLoad < 25.0) {
                batteryDisplay.setColor(Graphics.COLOR_YELLOW);
                } else {
                    batteryDisplay.setColor(subColorSet);
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
            
            noteLoad = System.getDeviceSettings().notificationCount;

            if (noteLoad !=0) {
                noteString = "N";
            } else {
                noteString = " ";
            }
            noteDisplay.setText(noteString);
        }
}
