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

ScrollableList sb;

PVector[] vecOfMarkers;
int window_x = 640;
int window_y = 480;
String[] cameras;
int camIndex = -1;
boolean isSetuped = true;
int markersNum = 8;
String currentCamName = "none";

boolean smooth = true;

void setup() {
  //Basic setting
  size(640, 480, P3D);

  println(MultiMarker.VERSION);

  cp5 = new ControlP5(this);
  gui = new GUI(cp5, sb);
  buf = new CircularBuffer(20);
  comm = new COMM(gui.getListeningPort(), gui.getUserIP());
  nya=new MultiMarker(this, width, height, "camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);
  for (int i = 0; i < markersNum; i++) {
    nya.addNyIdMarker(i, 80);
  }
  vecOfMarkers = new PVector[markersNum];

  cameras = gui.checkCameraList();
  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    try {
      cam=new Capture(this, window_x, window_y);
    }
    catch(IllegalStateException e) {
      isSetuped = false;
      println("No device available!");
    }
  } else {
    printArray(cameras);
    cam = new Capture(this, cameras[gui.getIndex()]);
    currentCamName = cameras[gui.getIndex()];
    gui.setCameras(cameras);
    isSetuped = true;
    cam.start();
  }
  gui.initGUI();
  gui.hideGUI();
  gui.saveJSON(cameras);
}

void draw()
{
  if (!isSetuped) {
    if ((cameras = gui.checkCameraList()) != null) {
      isSetuped = true;
    }
  } else {
    if (cam.available() !=true) {
      return;
    }
    cam.read();
    nya.detect(cam);
    background(0);
    nya.drawBackground(cam);
    for (int i=0; i<markersNum; i++) {
      if ((nya.isExist(i))) {

        boolean idmatch = false;
        for (int cid=0; cid<sources.size(); cid++) {
          if ( sources.get(cid).id == i ) {
            idmatch = true;
            sources.get(cid).newtarget = sources.get(cid).getCentroid( nya.getMarkerVertex2D(i));
            sources.get(cid).markerSize = sources.get(cid).getMarkerSize(nya.getMarkerVertex2D(i));
            sources.get(cid).lastupdate = millis();
          }
        }

        if ( !idmatch ) {
          sources.add( new Mover(i, nya.getMarkerVertex2D(i)  ) ); //create new one
        }

        if (!smooth) {
          comm.send(i, sources.get(i).location );
        }
        //vecOfMarkers[i] = drawPoint(nya.getMarkerVertex2D(i));
      }
    }

    ArrayList<Mover> updatedList = new ArrayList<Mover>();
    for (int cid=0; cid<sources.size(); cid++) {
      sources.get(cid).update();

      if (smooth) {
        comm.send(cid, sources.get(cid).location );
      }

      if ( sources.get(cid).lastupdate > millis()-1000 ) {
        updatedList.add( sources.get(cid) );
      } else {
        println("marker "+sources.get(cid).id+" lost");
      }
    }
    sources = updatedList; //discard old and dead particles
    countFPS();
  }
}

public void controlEvent(CallbackEvent theEvent) {
  if (theEvent.getController().equals(gui.sb)) {
    switch(theEvent.getAction()) {
      case(ControlP5.ACTION_ENTER):
      println("Enter callback");
      gui.checkCameraList();
      break;
    }
  }
}

public void keyPressed() {
  keyHandler();
}

public void keyHandler() {
  switch(key) {
  case 'm':
    if (key == 'm') {
      if (!gui.isShown)
      {
        gui.showGUI();
        isSetuped = false;
      } else {
        gui.hideGUI();
        isSetuped = true;
      }
    }
    break;
  }
}

public void oscEvent(OscMessage theOscMessage) {
  comm.event(theOscMessage);
}

public void IPText(String ip) {
  gui.setUserIP(ip);
}

public void Port(int portNum) {
  gui.setListeningPort(portNum);
}

void cameraList(int n) {
  if (!gui.cameraList(n).equals(currentCamName)) {
    cam.stop();
    println("index: " + gui.getIndex());
    cam = new Capture(this, cameras[gui.getIndex()]);
    currentCamName = cameras[gui.getIndex()];
    gui.saveJSON(cameras);
    cam.start();
  }
  camIndex = n;
}

PVector getCentroid(PVector[] vec)
{
  float x = 0;
  float y = 0;
  for (int i = 0; i < 4; i++) {
    x+=vec[i].x;
    y+=vec[i].y;
  }
  PVector res = new PVector(x*0.25, y*0.25, 0);
  //ellipse(res.x, res.y, 10, 10);
  return res;
}

void countFPS() {
  if (frameCount%30 == 0) {
    buf.insert(round(frameRate));
    surface.setTitle("fps: " + round(frameRate) +
      " avg: " + buf.getAvg());
  }
}
