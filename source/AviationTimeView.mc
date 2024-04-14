import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Time;
import Toybox.ActivityMonitor;
import Toybox.Complications;


var colorsUpdated = true;   //A Check to see if we need to run the updateColors

class AviationTimeView extends WatchUi.WatchFace {

    //Load the text formats
    var view;       
    var viewLS;
    var zView;
    var zLabel;
    var stepDisplay;
    var noteDisplay;
    var alarmDisplay;
    var batteryDisplay;

    var hasComps;

    var wxId;
    var wxComp;
    var wxNow;

    var stepId, batId, noteId;
    var stepComp, batComp, noteComp;
    var batLoad;
    var mSteps;
    var noteSets;

    var batY = 0.33;        //Divide up the screen for press to complications
    var stepY = 0.66;
    var wHeight;

    var calId;          //Calendar info for new watches only
    var calComp;


    function initialize() {
        WatchFace.initialize();
            hasComps = (Toybox has :Complications); 

        if (hasComps) {
            stepId = new Id(Complications.COMPLICATION_TYPE_STEPS);
            batId = new Id(Complications.COMPLICATION_TYPE_BATTERY);
            noteId = new Id(Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT);
            calId = new Id(Complications.COMPLICATION_TYPE_CALENDAR_EVENTS);

            stepComp = Complications.getComplication(stepId);
            if (stepComp != null) {
                Complications.subscribeToUpdates(stepId);
            }

            batComp = Complications.getComplication(batId);
            if (batComp != null) {
                Complications.subscribeToUpdates(batId);  
            }

            noteComp = Complications.getComplication(noteId);
            if (noteComp != null) {
                Complications.subscribeToUpdates(noteId);
            }  

            Complications.registerComplicationChangeCallback(self.method(:onComplicationChanged));         
        }    
    
    }

    function onComplicationChanged(compId as Complications.Id) as Void {

        if (compId == batId) {
            batLoad = (Complications.getComplication(batId)).value;
        } else if (compId == stepId) {
            mSteps = (Complications.getComplication(stepId)).value;
            if (mSteps instanceof Toybox.Lang.Float) {
                mSteps = (mSteps * 1000).toNumber(); //System converts to float at 10k. Reported system error
            }
        } else if (compId == noteId) {
            noteSets = (Complications.getComplication(noteId)).value;
        } else {
            System.println("no valid comps");
        }
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        //Assign all the texts
        view = View.findDrawableById("TimeLabel") as Text;
        viewLS = View.findDrawableById("TimeLabelRShad") as Text;
        zView = View.findDrawableById("zTimeLabel") as Text;
        zLabel = View.findDrawableById("zuluLabel") as Text;
        stepDisplay = View.findDrawableById("stepLabel") as Text;
        noteDisplay = View.findDrawableById("noteLabel") as Text;
        alarmDisplay = View.findDrawableById("alarmLabel") as Text;
        batteryDisplay = View.findDrawableById("batLabel") as Text;

        wHeight = dc.getHeight();           //used for touch scren areas
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {


        if (showNotes) {
            notesDisp();
        } else {
            noteDisplay.setText(" ");
        }

        //Draw Alarm
        alarmDisp();
    
        //Draw Time
        drawTime();

        //Draw ZuluTime or Steps
        drawZTime();

        //Draw Date
        drawDate();

        //Draw Battery
        drawBatt();    

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        if (dispSecs && 
            System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
                secondsDisplay(dc);
        }
        
    }


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


        //Draw Zulu Time Offset
        function drawZTime() {

            //If ZUlu Offset is selected instead of Steps
            if (timeOrStep){
                var zTime = Time.Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
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
                zLabel.setText("steps");
            }

        }


        //Display Date
        function drawDate() {

            var dateCalc = View.findDrawableById("dateLabel") as Text;
            var dateLoad = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
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
            
                if (!hasComps) {
                    batLoad = ((System.getSystemStats().battery) + 0.5).toNumber();
                }
                batString = Lang.format("$1$", [batLoad])+"%";

                if (System has :SCREEN_SHAPE_SEMI_OCTAGON &&
                    System.getDeviceSettings().screenShape != System.SCREEN_SHAPE_SEMI_OCTAGON){     //Monocrhrome correction

                    if (batLoad < 5.0) {
                        batteryDisplay.setColor(Graphics.COLOR_RED);
                    } else if (batLoad < 25.0) {
                        batteryDisplay.setColor(Graphics.COLOR_YELLOW);
                    } else {
                        batteryDisplay.setColor(Graphics.COLOR_DK_GREEN);
                    }
                } else {
                    if (myBackgroundColor == 0xFFFFFF) {
                        batteryDisplay.setColor(Graphics.COLOR_BLACK);
                    } else {
                        batteryDisplay.setColor(Graphics.COLOR_WHITE);
                    }
                }
            } else { 
                batString = " ";
                batteryDisplay.setColor(Graphics.COLOR_TRANSPARENT);
            }
            batteryDisplay.setText(batString);    
        }

        
            //Notifications Display Area
    function notesDisp() {

        var anyNotes;
        var noteString=" ";

        if (hasComps == false) {
            noteSets = System.getDeviceSettings();

            if (noteSets.notificationCount !=0) {
                anyNotes = true;
            } else {
                anyNotes = false;
            }
        } else {
            if (noteSets != 0) {
                anyNotes = true;
            } else {
                anyNotes = false;
            }
        }

        if (anyNotes) {
            noteString = "N";
        } else {
            noteString = " ";
        }
        noteDisplay.setText(noteString);
    }

   function alarmDisp() {

        var alarmString=" ";

        var alSets = System.getDeviceSettings().alarmCount;

        if (alSets != 0) {
            alarmString = "A";
        } else {
            alarmString = " ";
        }
        alarmDisplay.setText(alarmString);
    } 

    function secondsDisplay(dc) {

        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
        var centerX = screenWidth / 2;
        var centerY = screenHeight / 2;
        var mRadius = centerX < centerY ? centerX - 4: centerY - 4;
        var clockTime = System.getClockTime();
        var mSeconds = clockTime.sec;

        var mPen = 4;

        var mArc = 90 - (mSeconds * 6);

        dc.setPenWidth(mPen);
        dc.setColor(clockColorSet, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, mRadius, Graphics.ARC_CLOCKWISE, 90, mArc);

    }
     
}

class AviationTimeDelegate extends WatchUi.WatchFaceDelegate
{
	var view;
	
	function initialize(v) {
		WatchFaceDelegate.initialize();
		view=v;	
	}

    function onPress(evt) {
        var c=evt.getCoordinates();
        var batY = 0.33 * view.wHeight;
        var stepY = 0.66 * view.wHeight;

        if (c[1] <= batY) {

            if (showBat == 0 && view.batId != null) {
                Complications.exitTo(view.batId);
                return true;
            } else if (showBat == 2 && view.wxId != null) {
                Complications.exitTo(view.wxId);
                return true;
            } else {
                return false;
            }

        } else if (c[1] > batY && c[1] <= stepY && view.calId != null) {
            Complications.exitTo(view.calId);
            return true;
        } else if (view.stepId != null) {
            Complications.exitTo(view.stepId);
            return true;
        } else {
            return false;
        }
    }
	
}
