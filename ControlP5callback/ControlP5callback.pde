/**
 * ControlP5 Callback
 *
 * The following example demonstrates the CallbackListener and CallbackEvent. 
 * Here additional information about each available slider will be show when
 * hovering the controller with the mouse. The info will fade out when leaving
 * the controller. 
 *
 * When hovering a controller, the mouse pointer will change as well.
 * 
 * find a list of public methods available for the CallbackEvent Controller
 * at the bottom of this sketch.
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */

import controlP5.*;

ControlP5 cp5;

CallbackListener cb;

ScrollableList camlist;
import java.util.*;

void setup() {
  size(800, 400);

  cp5 = new ControlP5(this);
/*
  CallbackListener toFront = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
        theEvent.getController().bringToFront();
        ((ScrollableList)theEvent.getController()).open();
    }
  };

  CallbackListener close = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
        ((ScrollableList)theEvent.getController()).close();
    }
  };
  */
  List l = Arrays.asList("a", "b", "c", "d", "e", "f", "g", "h");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  camlist = cp5.addScrollableList("dropdown")
    .setPosition(100, 100)
    .setSize(200, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(l)
    //.onEnter(toFront)
    //.onLeave(close)
    // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;
    
  camlist.close(); //start closed  
  // add another callback to slider s1, callback event will only be invoked for this 
  // particular controller.
  camlist.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_ENTER) {
        println("UPDATE ME");
        camlist.open();
      }
      if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
        println("OUT");
        camlist.close();
      }
    }
  }
  );
}

void draw() {
  background(0);
}
