//Graphical user interface
import controlP5.*;
import processing.video.*;
import jp.nyatla.nyar4psg.*;
import oscP5.*;
import netP5.*;
import java.util.*;
import processing.video.*;


ControlP5 cp5;
String inputIP = "127.0.0.1";
String loadedCamera = "";
String currentCamName = "none";
int camIndex = 0;
Integer listeningPort = 12000;
String cameras[];
boolean renderGUI = true; //on first run always show GUI
float maxspeed = 10;
int delayG = 1000;
ScrollableList sb;

CColor colHighlight = new CColor();

public void initGUI() {
  cp5 = new ControlP5(this);
  cp5.setBroadcast(false);
  cp5.setAutoDraw(false); //turn off automatic rendering - we want to control this manully inside main draw() fce

  colHighlight.setBackground(color(255, 0, 0));

  //create dropdown list of avaliable cameras for capture - let user select the right one
  sb = cp5.addScrollableList("cameraList")
    .setPosition(50, 100)
    .setSize(200, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    //.setColorBackground(#2596DC)
    .onEnter(toFront) //callback on mouse hover
    .onLeave(close) //callback on mouse hover
    .setValue(camIndex);
  if (cameras != null) { //in case there are cameras avaliable include them in the list
    cp5.get(ScrollableList.class, "cameraList").addItems(cameras);
    sb.getItem(camIndex).put("color", colHighlight);
  }
  // create a toggle for turn on/off interpolateing for movement tracking
  cp5.addToggle("interpolate")
    .setPosition(50, 240)
    .setSize(50, 20)
    .setValue(interpolate)
    .setMode(ControlP5.SWITCH)
    ;
  //create slider to adjust the delay after not-detected markers will disappear
  cp5.addSlider("delayG")
    .setPosition(50, 280)
    .setSize(200, 20)
    .setLabel("delay time")
    .setRange(1, 5000)
    .setValue(delayG);
  //create slider to set max acceleration used for interpolateing
  cp5.addSlider("maxspeed")
    .setPosition(50, 320)
    .setLabel("max speed")
    .setSize(200, 20)
    .setRange(1, 50)
    .setValue(maxspeed);
  cp5.getController("maxspeed").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("maxspeed").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  //create port input field
  cp5.addTextfield("listeningPort")
    .setPosition(50, 360)
    .setSize(200, 20)
    .setText(listeningPort.toString())
    .setLabel("The listening port")
    .setColorBackground(#2596DC)
    .setInputFilter(ControlP5.INTEGER);
  //create remote IP adress field - used for Websockets
  cp5.addTextfield("inputIP")
    .setPosition(50, 400)
    .setSize(200, 20)
    .setText(inputIP)
    .setColorBackground(#2596DC)
    .setLabel("Insert IP address of destination");
  //this controller is never shown to user - only serves to save the selected camera name
  cp5.addTextfield("currentCamName")
    .setValue(currentCamName)
    .hide();

  cameras = checkCameraList(); //get avaliable cameras into variable

  cp5.setBroadcast(true);
  loadProperties(); //load previous settings if they exists - file settings.json inside data folder

}

//Callback listener for mouse hover events
CallbackListener toFront = new CallbackListener() {
  public void controlEvent(CallbackEvent theEvent) {
    theEvent.getController().bringToFront();
    ((ScrollableList)theEvent.getController()).open();
    //in case of avaliable cameras menu also check for new or removed camera devices - update accroding to current state
    if (theEvent.getController().equals(sb)) {
      checkCameraList();
    }
  }
};
//Callback listener for mouse hover events
CallbackListener close = new CallbackListener() {
  public void controlEvent(CallbackEvent theEvent) {
    ((ScrollableList)theEvent.getController()).close();
  }
};

void cameraTimeout() {
  //Waiting 10 seconds for camera list init
  long timeBeforeCameraWaiting = second();
  long t = second();
  println("waiting for cameras");
  while ( Capture.list().length == 0 ) {
    if (second() - t > 0) {
      t= second();
      print(". ");
    }
    if (second() - timeBeforeCameraWaiting > 1) //wait 5 secs
    {
      break;
    }
  }
  println();
}

void cameraList(int n) {
  println("previously used camera: "+currentCamName+" -- "+camIndex+", chosen camera: "+cameras[n]+" -- "+n);
  /*
  //does not work - probably some bug in underlying library?
   CColor c = new CColor();
   c.setBackground(#2596DC);
   
   sb.getItem(camIndex).put("color", colHighlight);
   sb.getItem(n).put("color", colHighlight );
   */

  if ( cameras[n].equals(currentCamName) == false ) { //in case use selected camera that was not previously used
    camIndex = n; //save selected camera index
    cam.stop(); //stop the current camera capture
    //println("index: " + camIndex);
    cam = new Capture(this, cameras[camIndex]); //create new camera capture
    //currentCamName( cameras[camIndex] ) ; //save current camera name to variable
    cp5.get(Textfield.class, "currentCamName").setValue( cameras[camIndex] ); //save variable into input field
    currentCamName = cameras[camIndex];
    //println("curr cam set to "+cp5.get(Textfield.class, "currentCamName").getText() );

    //note that his might lead to program error if the gstreamer encounter some fatal problem such as internal data stream error
    cam.start();//start camera capture

    saveProperties(); //on every change, save current state into settings.json file in data folder
  } else {
    println("selected camera already in use");
  }
}

//get avaliable camera list with camera names------------------------------
public String[] checkCameraList() {
  cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    cameras = null;
  } else {
    println("Available cameras:");
    printArray(cameras);
  }
  if (cameras != null) { //in case there are cameras avaliable include them in the list
    sb.setItems(cameras);
  }
  return cameras;
}

void currentCamName(String val) {
  currentCamName = val;
}

//set remote IP for websocket / osc -----------------
public void inputIP(String newIP) {
  println("User entered IP: " + newIP);
  inputIP = newIP;
  saveProperties();//on every change, save current state into settings.json file in data folder
}
//set port ------------------------------
void listeningPort(String currPort) {
  int newPort = int(currPort);
  println("User entered port: " + newPort);
  listeningPort = newPort;
  saveProperties();//on every change, save current state into settings.json file in data folder
}
//set maximum acceleration for movement interpolation - essentially max speed ----------------
void maxspeed(float val) {
  maxspeed = val;
  for (Mover m : sources) {
    m.topspeed = val;
  }
  saveProperties();
}

//set the delay after which the not-detected markers will disappear
void delayG(int d) {
  delayG = d; 
  for (Mover m : sources) {
    m.delay = d;
  }
  saveProperties();
}

//tun on or off interpolating position of tracked markers--------
void interpolate(boolean val) {
  interpolate = val;
  saveProperties();
}

void saveProperties() {
  cp5.saveProperties(dataPath("settings.json"));
}

void loadProperties() {
  try {
    cp5.loadProperties(dataPath("settings.json")); //save inside data folder
  }
  catch (Exception e) {
    println("There was an error loading settings - probably wrong format. Try to delete the settings file or cahnge some settings now to reset"+e);
  }
  if (cameras != null ) {
    for (int i=0; i<cameras.length; i++) {
      if ( currentCamName == cameras[i]) {
        println("match between saved camera and avaliable cameras found");
      }
    }
  }
  //cp5.get(Textfield.class, "currentCamName").getText();
}
