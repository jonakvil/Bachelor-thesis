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

PVector[] vecOfMarkers;
int window_x = 640;
int window_y = 480;
String[] cameras;
int camIndex = -1;
boolean isSetuped = true;
int markersNum = 8;

void setup() {
  //Basic setting
  size(640, 480, P3D);
  colorMode(RGB, 100);
  println(MultiMarker.VERSION);

  initWebsocket();

  cp5 = new ControlP5(this);
  gui = new GUI(cp5);
  buf = new CircularBuffer(20);
  comm = new COMM(gui.getListeningPort(), gui.getUserIP()); 
  nya=new MultiMarker(this, width, height, "camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);
  for (int i = 0; i < markersNum; i++) {
    nya.addNyIdMarker(i, 80);
  }
  vecOfMarkers = new PVector[markersNum]; 

  gui.cameraTimeout();
  cameras = gui.checkCameraList();
  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam=new Capture(this, window_x, window_y);
  } else {
    cam = new Capture(this, cameras[gui.getIndex()]);
  }
  gui.saveJSON(cameras);
  cam.start();
}

void draw()
{
  if (!isSetuped) {
    gui.checkCameraList();
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
      if ((nya.isExist(i))) {
        vecOfMarkers[i] = drawPoint(nya.getMarkerVertex2D(i));
        comm.send(i, vecOfMarkers);
      }
    }
    countFPS();
  }
}

public void oscEvent(OscMessage theOscMessage) {
  comm.event(theOscMessage);
}

public void IPText(String ip) {
  println("User entered IP: " + ip);
  isSetuped = true;
  println("Chosen camera: " + cameras[camIndex]);
}

void cameraList(int n) {
  gui.cameraList(cameras, n);
  camIndex = n;
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