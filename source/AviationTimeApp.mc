import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Graphics;

    var timeOrStep;
    var showBat;
    var clockColorSet = Graphics.COLOR_DK_BLUE;
    var clockShadSet = Graphics.COLOR_TRANSPARENT;
    var subColorSet = Graphics.COLOR_LT_GRAY;
    var myBackgroundColor = 0x000000;


class AviationTimeApp extends Application.AppBase {

    var clockColorNum;
    var clockShadNum;
    var subColorNum;

    function initialize() {
        AppBase.initialize();
        onSettingsChanged();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        onSettingsChanged();
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new AviationTimeView()];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        //Set Global Settings variables

        clockColorNum = Properties.getValue("ClockColor");
        clockShadNum = Properties.getValue("ShadOpt");
        subColorNum = Properties.getValue("SubColor");
        timeOrStep = Properties.getValue("TimeStep");
        showBat = Properties.getValue("DispBatt");
        myBackgroundColor = Properties.getValue("BackgroundColor");

        colorUpdate();  //Apply the changes
        WatchUi.requestUpdate();
    }
    

        function colorUpdate(){
        //Get color settings

		        switch (clockColorNum) {
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

            //Select Sub items color
                switch(subColorNum) {
                    case 0:
                        subColorSet = Graphics.COLOR_LT_GRAY;
                        break;
                    case 1:
                        subColorSet = Graphics.COLOR_DK_GRAY;
                        break;
                    case 2:
                        subColorSet = Graphics.COLOR_BLACK;
                        break;
                    case 3:
                        subColorSet = Graphics.COLOR_WHITE;
                        break;
                }

            //Show either zulu time or steps
            timeOrStep = Properties.getValue("TimeStep");

            //Show the battery or not
            showBat = Properties.getValue("DispBatt");
        
        }

}

function getApp() as AviationTimeApp {
    return Application.getApp() as AviationTimeApp;
}