import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;


    var showBat;
    var clockColorSet = Graphics.COLOR_DK_BLUE;
    var clockShadSet = Graphics.COLOR_TRANSPARENT;
    var subColorSet = Graphics.COLOR_LT_GRAY;
    var myBackgroundColor = 0x000000;
    var offSetAmmt = 130;
    var timeOrStep = true;

    var showNotes = true;
    var dispSecs = false;

    var oldClockColorNum = 2;
    var oldClockShadNum = 0;
    var oldMyBackgroundColor = 0x000000; 
    var oldSubColorNum = 0;

    var myBG = 0x000000;


class AviationTimeApp extends Application.AppBase {

    var view = null;
    var clockColorNum;
    var clockShadNum;
    var subColorNum;

    function initialize() {
        AppBase.initialize();
        onSettingsChanged();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        view = new AviationTimeView();
        return [view, new AviationTimeDelegate(view) ];
    }

    function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        var menu = new ATSettingsMenu();
        return [menu, new ATSettingsMenuDelegate()];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {

        //Set Global Settings variables

        if (clockColorNum != null) {oldClockColorNum = clockColorNum;}
        if (clockShadNum != null) {oldClockShadNum = clockShadNum;}
        if (myBackgroundColor != null) {oldMyBackgroundColor = myBackgroundColor;}
        if (subColorNum != null) {oldSubColorNum = subColorNum;}

        clockColorNum = Properties.getValue("ClockColor");
        clockShadNum = Properties.getValue("ShadOpt");
        subColorNum = Properties.getValue("SubColor");
        showBat = Properties.getValue("DispBatt");
        myBackgroundColor = Properties.getValue("BackgroundColor");
        showNotes = Properties.getValue("ShowNotes");
        dispSecs = Properties.getValue("SecOpt");
        timeOrStep = Properties.getValue("TimeStep");


        if (oldClockColorNum != clockColorNum || oldClockShadNum != clockShadNum
            || oldMyBackgroundColor != myBackgroundColor 
            || oldSubColorNum != subColorNum) {
                colorsUpdated = true;
        } else {
                colorsUpdated = false;
        }
        

        if (colorsUpdated) {
            colorUpdate();  //Apply the changes
        }

        WatchUi.requestUpdate();
    }
    

        function colorUpdate(){
        //Get color settings

            if(myBackgroundColor == 0){
                myBG=0x000000;
            } else if (myBackgroundColor == 1) {
                myBG=0x555555;
            }else if (myBackgroundColor == 2) {
                myBG=0xFFFFFF;
            } else if (myBackgroundColor == 3) {
                myBG=0xAA0000;
            } else if (myBackgroundColor == 4) {
                myBG=0x00AA00;
            } else if (myBackgroundColor == 5) {
                myBG=0x0000FF;
            } else {
                myBG=0xAA00FF;
            }

		    if (clockColorNum == 0) {
			    clockColorSet = Graphics.COLOR_WHITE;
            } else if (clockColorNum == 1) {
			    clockColorSet = Graphics.COLOR_LT_GRAY;
            } else if (clockColorNum == 2) {
				clockColorSet = Graphics.COLOR_DK_GRAY;
            } else if (clockColorNum == 3) {
				clockColorSet = Graphics.COLOR_BLACK;
            } else if (clockColorNum == 4) {
				clockColorSet = Graphics.COLOR_RED;
            } else if (clockColorNum == 5) {
			    clockColorSet = Graphics.COLOR_DK_RED;
            } else if (clockColorNum == 6) {
				clockColorSet = Graphics.COLOR_ORANGE;
            } else if (clockColorNum == 7) {
				clockColorSet = Graphics.COLOR_YELLOW;
            } else if (clockColorNum == 8) {
				clockColorSet = Graphics.COLOR_GREEN;
            } else if (clockColorNum == 9) {
			    clockColorSet = Graphics.COLOR_DK_GREEN;
            } else if (clockColorNum == 10) {
				clockColorSet = Graphics.COLOR_BLUE;
            } else if (clockColorNum == 11) {
				clockColorSet = Graphics.COLOR_DK_BLUE;
            } else if (clockColorNum == 12) {
				clockColorSet = Graphics.COLOR_PURPLE;
            } else {
				clockColorSet = Graphics.COLOR_PINK;
            }

            //Select shadowing
            if (clockShadNum == 0) {
                clockShadSet = Graphics.COLOR_TRANSPARENT;
            } else if (clockShadNum == 1) {
                clockShadSet = Graphics.COLOR_BLACK;
            } else if (clockShadNum == 2) {
                clockShadSet = Graphics.COLOR_WHITE;
             } else if (clockShadNum == 3) {
                clockShadSet = Graphics.COLOR_LT_GRAY;
            }

            //Select Sub items color
            if (subColorNum == 0) {
                subColorSet = Graphics.COLOR_LT_GRAY;
            } else if (subColorNum == 1) {
                subColorSet = Graphics.COLOR_DK_GRAY;
            } else if (subColorNum == 2) {
                subColorSet = Graphics.COLOR_BLACK;
            } else if (subColorNum == 3) {
                subColorSet = Graphics.COLOR_WHITE;
            } else if (subColorNum == 4) {
                subColorSet = Graphics.COLOR_RED;
            } else if (subColorNum == 5) {
                subColorSet = Graphics.COLOR_GREEN;
            } else if (subColorNum == 6) {
                subColorSet = Graphics.COLOR_BLUE;
            } else if (subColorNum == 7) {
                subColorSet = Graphics.COLOR_PINK;
            }

            if (timeOrStep) {
                //Get the Zulu Hours offset ammount
                offSetAmmt = Properties.getValue("ZuluOffset");
            }
        }

}


function getApp() as AviationTimeApp {
    return Application.getApp() as AviationTimeApp;
}