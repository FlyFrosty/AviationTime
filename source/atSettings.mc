import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;


class aTSettings{

    function initialize();

}

class aTSettingsMenu extends WatchUi.Menu2 {

    var mySettings;

    function initialize () {
        Menu2.initialize(null);
        mySettings=new aTSettings();
        Menu2.setTitle("Option");
        Menu2.addItem(new WatchUi.MenuItem("Steps", null, "steps", null));
        Menu2.addItem(new WatchUi.MenuItem("Zulu", null, "zulu", null));
    }

}

class aTSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    var menuSelector;

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (id.equals("steps")) {
            menuSelector= false;
            onBack();
        } else {
            menuSelector = true;
            onBack();
        }

    }

    function onBack() as Void {

        Application.Properties.setValue("TimeStep", menuSelector);
        timeOrStep=menuSelector;
        WatchUi.popView(WatchUi.SLIDE_UP);
    }


}