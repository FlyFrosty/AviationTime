using Toybox.Graphics as Gfx;
import Toybox.Lang;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Time.Gregorian as Greg;
import Toybox.Time;
using Toybox.ActivityMonitor as ActMon;

class AviationTimeView extends Ui.WatchFace {

    //Load the text formats
    var view;       
    var viewLS;
    var zView;
    var zLabel;
    var stepDisplay;
    var noteDisplay;
    var alarmDisplay;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        //Assign all the texts
        view = View.findDrawableById("TimeLabel");
        viewLS = View.findDrawableById("TimeLabelRShad");
        zView = View.findDrawableById("zTimeLabel");
        zLabel = View.findDrawableById("zuluLabel");
        stepDisplay = View.findDrawableById("stepLabel");
        noteDisplay = View.findDrawableById("noteLabel");
        alarmDisplay = View.findDrawableById("alarmLabel");

    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

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


        //Dispaly time
        function drawTime() {
 
            //Get and show the current time & Zulu time
            var timeString;
            var clockTime = Sys.getClockTime();
            var hours = clockTime.hour;

            //Format local time for 12 or 24 hour clock
            if (Sys.getDeviceSettings().is24Hour == true){      
                timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
            } else {
                if (hours > 12) {
                    hours = hours - 12;
                }
                timeString = Lang.format("$1$:$2$", [hours, clockTime.min.format("%02d")]);
            }

            if (clockShadSet == null) {clockShadSet = Gfx.COLOR_TRANSPARENT;} 
            viewLS.setColor(clockShadSet);   
            viewLS.setText(timeString);

            if (clockColorSet == null) {clockColorSet = Gfx.COLOR_TRANSPARENT;}
            view.setColor(clockColorSet);
            view.setText(timeString);

        }


        //Draw Zulu Time Offset
        function drawZTime() {

            //If ZUlu Offset is selected instead of Steps
            if (timeOrStep){
                var zTime = Greg.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
                var myOffset = zTime.hour;
                var minOffset = zTime.min;
                var zuluTime;
                var myZuluLabel;
            
                //Clear any leftover steps
                stepDisplay.setColor(Graphics.COLOR_TRANSPARENT);                

                //Big if statement for formatting.  If Zulu time, do the else part
                if (offSetAmmt != 130) {
                   //Prep the label
                        var myParams;
                        var myFormat = "Set $1$+$2$";

                        if (offSetAmmt % 10 != 0) {
                            if ((offSetAmmt - 130) < 0) {
                                myParams = [((offSetAmmt / 10) - 12), (offSetAmmt % 10 * 6)];
                            } else {
                                myParams = [((offSetAmmt / 10) - 13), (offSetAmmt % 10 * 6)];
                            }
                        } else {
                            myParams = [((offSetAmmt / 10) - 13), "00"];
                        }
                        myZuluLabel = Lang.format(myFormat,myParams);

                    //Offset to add or subtract
                    var convLeftoverOffset = (offSetAmmt % 10) * 360;     //Convert any partial hour part to seconds
                    var convToOffset = ((offSetAmmt / 10) - 13) * 3600;    //Convert the hours part to seconds

                    convToOffset = convToOffset + convLeftoverOffset; //Total Offset in seconds
            
                    //Convert Zulu time to seconds
                    var zuluToSecs =  (minOffset * 60) + (myOffset * 3600);

                    //Combine the offset with the current zulu
                    var convToSecs = convToOffset + zuluToSecs;

                    //Keep the new offset time positive (no negative time)
                    if (convToSecs <= 86400) {
                        myOffset = ((86400 + convToSecs) - ((86400 + convToSecs)%3600)) / 3600;
                    } else {
                        myOffset = ((convToSecs) - ((86400 + convToSecs)%3600)) / 3600;
                    }

                    //Adjust mins and hours for clock rollovers due to add or sub 30 min
                    minOffset = (convToSecs % 3600) / 60;

                    if (minOffset < 0) {
                        minOffset = minOffset + 60;
                   }   

                    //correct for hours within the 24 hour clock
                    if (myOffset == 24) {
                        myOffset = 0;
                    } else if (myOffset < 0) {
                        myOffset = myOffset + 24;
                    } else if (myOffset >= 24) {
                        myOffset = myOffset - 24;
                    }

                    zuluTime = Lang.format("$1$:$2$", [myOffset.format("%02d"), minOffset.format("%02d")]);    
                } else {
                    zuluTime = Lang.format("$1$:$2$", [zTime.hour.format("%02d"), zTime.min.format("%02d")])+"Z";
                    myZuluLabel = " ";
                }

                //Display Zulu
                zView.setColor(subColorSet);
                zView.setText(zuluTime);

                //Display Zulu Label
                zLabel.setColor(subColorSet);
                zLabel.setText(myZuluLabel);

            } else {
                //Format Steps
                var stepLoad = ActivityMonitor.getInfo();
                var steps = stepLoad.steps;
                var stepString = Lang.format("$1$", [steps]);

                //clear Zulu time text and dipslay Steps
                zView.setColor(Graphics.COLOR_TRANSPARENT);

                stepDisplay.setColor(subColorSet);
                stepDisplay.setText(stepString);
                
                //Display Zulu Label
                zLabel.setColor(subColorSet);
                zLabel.setText("Steps");
            }

        }


        //Display Date
        function drawDate() {

            var dateCalc = View.findDrawableById("dateLabel");
            var dateLoad = Greg.info(Time.now(), Time.FORMAT_MEDIUM);
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
                var batLoad = ((Sys.getSystemStats().battery) + 0.5).toNumber();
                batString = Lang.format("$1$", [batLoad])+"%";

                if (batLoad < 5.0) {
                    batteryDisplay.setColor(Gfx.COLOR_RED);
                } else if (batLoad < 25.0) {
                batteryDisplay.setColor(Gfx.COLOR_YELLOW);
                } else {
                    batteryDisplay.setColor(subColorSet);
                }
            } else {
                batString = " ";
                batteryDisplay.setColor(Gfx.COLOR_TRANSPARENT);
            }
            batteryDisplay.setText(batString);
            
        }

        function notesAndAlarms(){
            var noteString=" ";
            var alarmString=" ";
            var avSets = Sys.getDeviceSettings();

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
