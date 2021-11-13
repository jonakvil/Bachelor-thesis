import processing.video.*;
import jp.nyatla.nyar4psg.*;
import oscP5.*;
import netP5.*;
import controlP5.*;

CircularBuffer buf;
GUI gui;
COMM comm;
Capture cam;
MultiMarker nya;
OscP5 oscP5;
ControlP5 cp5;
NetAddress myRemoteLocation;
OscMessage myMessage;

JSONObject json;
String pathToSavedOptions = "data/options.json";

PVector[] vecOfMarkers;
int window_x = 640;
int window_y = 480;

String userIP;
Integer listeningPort;
String[] cameras;

boolean isSetuped = false;
int camIndex = -1;

int markersNum = 8;

//Loaded data
String loadedIP;
String loadedCamera;
int loadedIndex;

void setup() {
  //Basic setting
  size(640, 480, P3D);
  colorMode(RGB, 100);
  println(MultiMarker.VERSION);

  //Loading File
  try {
    json = loadJSONObject(pathToSavedOptions);
    userIP = json.getString("ip");
    loadedCamera = json.getString("cameraName");
    camIndex = json.getInt("index");
    listeningPort = json.getInt("port");
  } 
  catch(NullPointerException e) {
    json = new JSONObject();
    userIP = "";
    loadedCamera = "";
    camIndex = 0;
    listeningPort = 12000;
  }

  //Misc
  buf = new CircularBuffer(20);

  //Network setting
  oscP5 = new OscP5(this, listeningPort);
  comm = new COMM(oscP5);

  //Markers and camera setting
  nya=new MultiMarker(this, width, height, "camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);
  for(int i = 0; i < markersNum; i++){
    nya.addNyIdMarker(i, 80);
  }
  vecOfMarkers = new PVector[markersNum]; 


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

  //Getting list of available cameras on this PC
  cameras = Capture.list();
  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam=new Capture(this, window_x, window_y);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
  } else {
    println("Available cameras:");
    printArray(cameras);
  }

  //GUI
  cp5 = new ControlP5(this);
  gui = new GUI(cp5);
  gui.initGUI(userIP, listeningPort, cameras, camIndex);
}

PVector drawPoint(PVector[] vec)
{
  float x = 0;
  float y = 0;
  for (int i = 0; i < 4; i++) {
    x+=vec[i].x;
    y+=vec[i].y;
  }
  PVector res = new PVector(x*0.25, y*0.25, 0);
  ellipse(res.x, res.y, 10, 10);
  return res;
}

void countFPS() {
  if (frameCount%30 == 0) {
    buf.insert(round(frameRate));
    surface.setTitle("fps: " + round(frameRate) + 
      " avg: " + buf.getAvg());
  }
}

void draw()
{
  if (!isSetuped) {
    background(240);
  } else {
    if (cam.available() !=true) {
      return;
    }
    cam.read();
    nya.detect(cam);
    background(0);
    nya.drawBackground(cam);
    for (int i=0; i<markersNum; i++) {
      if ((!nya.isExist(i))) {
        continue;
      }
      vecOfMarkers[i] = drawPoint(nya.getMarkerVertex2D(i));
      //vec[i].normalize();
      println("i: " + i + " normalized x/y/z: " + vecOfMarkers[i].x/window_x + " " + vecOfMarkers[i].y/window_y + " " + vecOfMarkers[i].z); //not normalized, just set to be in <0.0;1.0> screen coords
      myMessage = new OscMessage("/markersCoord");
      myMessage.add(i);
      myMessage.add(vecOfMarkers[i].x/window_x);
      myMessage.add(vecOfMarkers[i].y/window_y);
      myMessage.add(vecOfMarkers[i].z);
      oscP5.send(myMessage, myRemoteLocation);
    }
  }
  countFPS();
}

void oscEvent(OscMessage theOscMessage) {
  comm.event(theOscMessage);
}

public void IPText(String ip) {
  println("User entered IP: " + ip);
  userIP = ip;
}

void cameraList(int n) {
  //gui.cameraList(cameras, color(255,0,0));
  println("User has chosen camera: " + cameras[n]);
  camIndex = n;
}

public void OK(int theValue) {
  json.setString("cameraName", cameras[camIndex]);
  json.setInt("index", camIndex);
  userIP = cp5.get(Textfield.class, "IPText").getText();
  json.setString("ip", userIP);
  saveJSONObject(json, pathToSavedOptions);
  myRemoteLocation = new NetAddress(userIP, listeningPort);

  cp5.get(Textfield.class, "IPText").setVisible(false);
  cp5.get(ScrollableList.class, "cameraList").setVisible(false);
  cp5.get(Button.class, "OK").setVisible(false);
  cam = new Capture(this, cameras[camIndex]);
  cam.start();
  isSetuped = true;
}
