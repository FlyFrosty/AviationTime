import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;



class AviationTimeApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new AviationTimeView() ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        WatchUi.requestUpdate();
        System.println("onSettingsChnaged in App.mc");
        View.onUpdate(dc);
    }

}

function getApp() as AviationTimeApp {
    return Application.getApp() as AviationTimeApp;
}