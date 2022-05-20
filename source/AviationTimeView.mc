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
    var noteDisplay;
    var alarmDisplay;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) as Void {

        setLayout(Rez.Layouts.WatchFace(dc));

        //Assign all the texts
        view = View.findDrawableById("TimeLabel");
        viewLS = View.findDrawableById("TimeLabelRShad");
        zView = View.findDrawableById("zTimeLabel");
        stepDisplay = View.findDrawableById("stepLabel");
        noteDisplay = View.findDrawableById("noteLabel");
        alarmDisplay = View.findDrawableById("alarmLabel");

    }


    // Update the view
    function onUpdate(dc) as Void {

        //Draw Time
        drawTime();

        //Draw ZuluTime or Steps
        drawZTime();

        //Draw Date
        drawDate();

        //Draw Battery
        drawBatt();

        //Display Alarms and Notifications
        notesAndAlarms();      

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }


//Draw the face

        //Dispaly time
        function drawTime() {
 
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

            if (clockShadSet == null) {clockShadSet = Graphics.COLOR_TRANSPARENT;} 
            viewLS.setColor(clockShadSet);   
            viewLS.setText(timeString);

            if (clockColorSet == null) {clockColorSet = Graphics.COLOR_TRANSPARENT;}
            view.setColor(clockColorSet);
            view.setText(timeString);

        }
        
        //Draw Zulu time or steps
        function drawZTime() {
         
            //Zulu time or steps option 
            if (timeOrStep == 1){
                //Format Steps
                var stepLoad = ActivityMonitor.getInfo();
                var steps = stepLoad.steps;
                var stepString = Lang.format("$1$", [steps]);

                //clear Zulu time text and dipslay Steps
                zView.setColor(Graphics.COLOR_TRANSPARENT);
                stepDisplay.setColor(subColorSet);
                stepDisplay.setText(stepString);
            } else {
                //Format zulu time
                var zTime = Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
                var zuluTime = Lang.format("$1$:$2$", [zTime.hour.format("%02d"), zTime.min.format("%02d")])+"Z";
                
                //Clear step line and display Zulu
                stepDisplay.setColor(Graphics.COLOR_TRANSPARENT);
                zView.setColor(subColorSet);
                zView.setText(zuluTime);
            }
        }

        //Display Date
        function drawDate() {

            var dateCalc = View.findDrawableById("dateLabel");
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
            var batteryDisplay = View.findDrawableById("batLabel");

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

        function notesAndAlarms(){
            var noteString=" ";
            var alarmString=" ";
            var avSets = System.getDeviceSettings();

            if (avSets.notificationCount !=0) {
                noteString = "N";
            } else {
                noteString = " ";
            }
            noteDisplay.setText(noteString);

            if (avSets.alarmCount != 0) {
                alarmString = "A";
            } else {
                alarmString = " ";
            }
            alarmDisplay.setText(alarmString);

        }
}
