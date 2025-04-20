import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;


class ATSettings{

    function initialize() {
        //Don't know if brackets are needed
    }
}

class ATSettingsMenu extends WatchUi.Menu2 {

    var mySettings;

    function initialize () {
        Menu2.initialize(null);
        mySettings = new ATSettings();
        Menu2.setTitle("Option");
        //MenuItem(label, sub-label, identifier, options)
        Menu2.addItem(new WatchUi.MenuItem("Steps", null, "steps", null));
        Menu2.addItem(new WatchUi.MenuItem("Zulu", null, "zulu", null));
    }

}

class ATSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {


    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (id.equals("steps")) {
            timeOrStep = false;
        } else {
            timeOrStep = true;  //zulu time
        }
        Application.Properties.setValue("TimeStep", timeOrStep);
        onBack();
    }

}