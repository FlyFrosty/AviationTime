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

    var alarmString= " ";  //No complications
    var dateString;
    var stepString = "0";     //The number of steps to be displayed
    var noteString;
    var batString;
    
    var stepId;
    var stepComp;
    var mSteps;         //For the non-complications watches

    var hasComps;
    var batComp, noteComp;

    var calcTime;           //Formatted local time

    var zuluTime;           //The 24 hour formatted corrected from zulu time
    var myZuluLabel;        //User selected offset from Z formatted for display
    
    var wxId;

    var batId, noteId;
    var batLoad;

    var noteSets;

    var batY = 0.33;        //Divide up the screen for press to complications
    var stepY = 0.66;
    var wHeight;
    var wWidth;

    var calId;          //Calendar info for new watches onlys

    var BIP = true;   //Burn In Protection
    var lowPowerMode = false;


    function initialize() {
        WatchFace.initialize();

        hasComps = (Toybox has :Complications); 
        lowPowerMode = (Toybox has :onPartialUpdate);

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

        wHeight = dc.getHeight();           //used for touch scren areas
        wWidth = dc.getWidth();

        //Set Background Color
        dc.setColor(myBG, myBG);
        dc.clear();

        if (System.getDeviceSettings().screenShape != System.SCREEN_SHAPE_SEMI_OCTAGON) {

            //Draw battery
                battDisp(dc);
                dc.drawText((wWidth/2), (0.08 * wHeight), Graphics.FONT_TINY, batString, Graphics.TEXT_JUSTIFY_CENTER);    
            //Draw Alarm
                dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                alarmDisp();
                dc.drawText(wWidth * 0.7, wHeight * 0.1, Graphics.FONT_TINY, alarmString, Graphics.TEXT_JUSTIFY_LEFT);
            //Draw Time/Z Time/Steps
                mainZone(dc);
            //Draw Date
                dateDisp();
                dc.setColor(subColorSet, Graphics.COLOR_TRANSPARENT);
                dc.drawText(wWidth / 2, wHeight * 0.58, Graphics.FONT_MEDIUM, dateString, Graphics.TEXT_JUSTIFY_CENTER);
            //Draw Notes if on
                if (showNotes) {
                    notesDisp();
                        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                        dc.drawText(wWidth / 4, wHeight * 0.1, Graphics.FONT_TINY, noteString, Graphics.TEXT_JUSTIFY_LEFT);
                }
            //Draw Seconds Arc if on
                if (dispSecs && 
                        System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
                    secondsDisplay(dc);
                }
        } else {
            //Draw battery
                battDisp(dc);
                dc.drawText((wWidth * .85), (0.1 * wHeight), Graphics.FONT_TINY, batString, Graphics.TEXT_JUSTIFY_CENTER);    
            //Draw Alarm
                dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                alarmDisp();
                dc.drawText(wWidth * 0.5, wHeight * 0.1, Graphics.FONT_TINY, alarmString, Graphics.TEXT_JUSTIFY_LEFT);
            //Draw Time/Z Time/Steps
                mainZone(dc);
            //Draw Date
                dateDisp();
                dc.setColor(subColorSet, Graphics.COLOR_TRANSPARENT);
                dc.drawText(wWidth / 2, wHeight * 0.65, Graphics.FONT_MEDIUM, dateString, Graphics.TEXT_JUSTIFY_CENTER);
            //Draw Notes if on
                if (showNotes) {
                     notesDisp();
                        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                        dc.drawText(wWidth / 4, wHeight * 0.1, Graphics.FONT_TINY, noteString, Graphics.TEXT_JUSTIFY_LEFT);

                }

        }

    }


    // Update the view
    function onUpdate(dc as Dc) as Void {

        //Set Background Color
        dc.setColor(myBG, myBG);
        dc.clear();

        if (lowPowerMode){
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.clear();
            normalTime();
            calcZuluTime();

            dc.setColor(clockColorSet, Graphics.COLOR_BLACK);
            if (System.getDeviceSettings().screenShape != System.SCREEN_SHAPE_SEMI_OCTAGON) {
                if (BIP) {
                    dc.drawText((wWidth / 2), (wHeight * 0.15), Graphics.FONT_LARGE, calcTime+"L", Graphics.TEXT_JUSTIFY_CENTER); 
                    dc.drawText((wWidth / 2), (wHeight * 0.60), Graphics.FONT_MEDIUM, zuluTime, Graphics.TEXT_JUSTIFY_CENTER);
                    BIP = false; 
                } else {
                    dc.drawText((wWidth / 2), (wHeight * 0.30), Graphics.FONT_LARGE, calcTime+"L", Graphics.TEXT_JUSTIFY_CENTER); 
                    dc.drawText((wWidth / 2), (wHeight * 0.70), Graphics.FONT_MEDIUM, zuluTime, Graphics.TEXT_JUSTIFY_CENTER); 
                    BIP = true;
                }
            } else {
                if (BIP) {
                    dc.drawText(((wWidth / 2) - 30), (wHeight * 0.20), Graphics.FONT_LARGE, calcTime+"L", Graphics.TEXT_JUSTIFY_CENTER); 
                    dc.drawText((wWidth / 2), (wHeight * 0.60), Graphics.FONT_MEDIUM, zuluTime, Graphics.TEXT_JUSTIFY_CENTER); 
                    BIP = false;
                } else {
                    dc.drawText((wWidth / 2), (wHeight * 0.40), Graphics.FONT_LARGE, calcTime+"L", Graphics.TEXT_JUSTIFY_CENTER); 
                    dc.drawText((wWidth / 2), (wHeight * 0.70), Graphics.FONT_MEDIUM, zuluTime, Graphics.TEXT_JUSTIFY_CENTER); 
                    BIP = true;
                }
            }
 
        } else {
            if (System.getDeviceSettings().screenShape != System.SCREEN_SHAPE_SEMI_OCTAGON) {
                //Draw battery
                    battDisp(dc);
                    dc.drawText((wWidth/2), (0.08 * wHeight), Graphics.FONT_TINY, batString, Graphics.TEXT_JUSTIFY_CENTER);    
                //Draw Alarm
                    dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                    alarmDisp();
                    dc.drawText(wWidth * 0.7, wHeight * 0.1, Graphics.FONT_TINY, alarmString, Graphics.TEXT_JUSTIFY_LEFT);
                //Draw Time/Z Time/Steps
                    mainZone(dc);
                //Draw Date
                    dateDisp();
                    dc.setColor(subColorSet, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(wWidth / 2, wHeight * 0.58, Graphics.FONT_MEDIUM, dateString, Graphics.TEXT_JUSTIFY_CENTER);
                //Draw Notes if on
                    if (showNotes) {
                        notesDisp();
                        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                        dc.drawText(wWidth / 4, wHeight * 0.1, Graphics.FONT_TINY, noteString, Graphics.TEXT_JUSTIFY_LEFT);
                     }
                //Draw Seconds Arc if on
                    if (dispSecs && 
                        System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
                        secondsDisplay(dc);
                    }
            } else {
                //Draw battery
                    battDisp(dc);
                    dc.drawText((wWidth * .85), (0.1 * wHeight), Graphics.FONT_TINY, batString, Graphics.TEXT_JUSTIFY_CENTER);    
                //Draw Alarm
                    dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                    alarmDisp();
                    dc.drawText(wWidth * 0.7, wHeight * 0.1, Graphics.FONT_TINY, alarmString, Graphics.TEXT_JUSTIFY_LEFT);
                //Draw Time/Z Time/Steps
                    mainZone(dc);
                //Draw Date
                    dateDisp();
                    dc.setColor(subColorSet, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(wWidth / 2, wHeight * 0.65, Graphics.FONT_MEDIUM, dateString, Graphics.TEXT_JUSTIFY_CENTER);
                //Draw Notes if on
                    if (showNotes) {
                        notesDisp();
                        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                        dc.drawText(wWidth / 4, wHeight * 0.1, Graphics.FONT_TINY, noteString, Graphics.TEXT_JUSTIFY_LEFT);
                    }
            }
        }
    }


    function normalTime() {
    //Created formated local time

        var clockTime = System.getClockTime();
        var hours = clockTime.hour;

        //Calc local time for 12 or 24 hour clock
        if (System.getDeviceSettings().is24Hour == true){      
            calcTime = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        } else {
            if (hours > 12) {
                hours = hours - 12;
            }
            calcTime = Lang.format("$1$:$2$", [hours, clockTime.min.format("%02d")]);
        }
    }

    function calcZuluTime() {
    //24 hour clock only
            
        var zTime = Time.Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
        var myOffset = zTime.hour;
        var minOffset = zTime.min;

        //Offset to add or subtract
        var convLeftoverOffset = (offSetAmmt % 10) * 360;     //Convert any partial hour to seconds
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
    }   
    

    function makeZuluLabel() {    
    //If Zulu time, do the else part

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

        } else {
            myZuluLabel = "Zulu";
        }      
    }
    
   
    //Main Time Area
    function mainZone(dc) {
    //Choose Main display, set colors and show

        //Normal display here  
        normalTime();
        dc.setColor(clockShadSet, Graphics.COLOR_TRANSPARENT);
            
        if (System.getDeviceSettings().screenShape != System.SCREEN_SHAPE_SEMI_OCTAGON) {
            dc.drawText(((wWidth / 2) + 1), ((wHeight * 0.22) + 1), Graphics.FONT_NUMBER_THAI_HOT, calcTime, Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(clockColorSet, Graphics.COLOR_TRANSPARENT);
            dc.drawText((wWidth / 2), (wHeight * 0.22), Graphics.FONT_NUMBER_THAI_HOT, calcTime, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(((wWidth / 2) - 30), ((wHeight * 0.22) + 1), Graphics.FONT_NUMBER_THAI_HOT, calcTime, Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(clockColorSet, Graphics.COLOR_TRANSPARENT);
            dc.drawText(((wWidth / 2) - 29), (wHeight * 0.22), Graphics.FONT_NUMBER_THAI_HOT, calcTime, Graphics.TEXT_JUSTIFY_CENTER);
        }

        if (timeOrStep) {
            //Display Secondary time
            calcZuluTime();
            makeZuluLabel();

            dc.setColor(subColorSet, Graphics.COLOR_TRANSPARENT);
            dc.drawText(wWidth / 2, wHeight * 0.75, Graphics.FONT_LARGE, zuluTime, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(wWidth / 2, wHeight * 0.88, Graphics.FONT_SYSTEM_XTINY, myZuluLabel, Graphics.TEXT_JUSTIFY_CENTER);

        } else {
            //Display Stpes
            stepsDisp();

            dc.setColor(subColorSet, Graphics.COLOR_TRANSPARENT);
            dc.drawText(wWidth / 2, wHeight * 0.75, Graphics.FONT_LARGE, stepString, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(wWidth / 2, wHeight * 0.88, Graphics.FONT_SYSTEM_XTINY, "steps", Graphics.TEXT_JUSTIFY_CENTER);
        }

    }


    //Date Area
    function dateDisp() {

        var dateLoad = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        dateString = Lang.format("$1$, $2$ $3$", 
            [dateLoad.day_of_week,
            dateLoad.day,
            dateLoad.month]);
    }

        
    //Battery Display Area
    function battDisp(dc) {
        //Get battery info

        if (showBat == 0) {

            if (!hasComps) {
                batLoad = ((System.getSystemStats().battery) + 0.5).toNumber();
            }
            batString = Lang.format("$1$", [batLoad])+"%";

            if (System has :SCREEN_SHAPE_SEMI_OCTAGON &&
                System.getDeviceSettings().screenShape != System.SCREEN_SHAPE_SEMI_OCTAGON){     //Monocrhrome correction

                if (batLoad < 5.0) {
                    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                } else if (batLoad < 25.0) {
                    dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                }
            } else {

                if (myBackgroundColor == 0xFFFFFF) {
                    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                }
            }
        } else { 
            dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
            batString = " ";
        } 
    }

    //Notifications Display Area
    function notesDisp() {

        var anyNotes;

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
    }


    function alarmDisp() {

        var alSets = System.getDeviceSettings().alarmCount;

        if (alSets != 0) {
            alarmString = "A";
        } else {
            alarmString = " ";
        }
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

    function stepsDisp() {
    //Format Steps
        var stepLoad;  

        if (!hasComps) {
            stepLoad = ActivityMonitor.getInfo();
            mSteps = stepLoad.steps;
        }

        stepString = Lang.format("$1$", [mSteps]);

    }

        function onExitSleep() {
        lowPowerMode = false;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() {
        lowPowerMode = true;
        WatchUi.requestUpdate();
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
