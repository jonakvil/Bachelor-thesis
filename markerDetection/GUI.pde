import controlP5.*;
import processing.video.*;
import jp.nyatla.nyar4psg.*;
import oscP5.*;
import netP5.*;
import java.util.*;
import processing.video.*;

public class GUI {
  ControlP5 cp5;
  JSONObject json;
  String pathToSavedOptions = "data/options.json";
  String userIP;
  String loadedCamera;
  int camIndex;
  Integer listeningPort;
  String cameras[];
  boolean isShown;
  ScrollableList sb;


  public GUI(ControlP5 cp5, ScrollableList sb) {
    this.cp5 = cp5;
    this.isShown = false;
    this.sb = sb;
    loadJSON();
  }

  public void initGUI() {
    cp5.addTextfield("IPText")
      .setPosition(50, 400)
      .setSize(200, 20)
      .setText(userIP)
      .setColorBackground(#2596DC)
      .setLabel("Insert IP address of destination");
    cp5.addTextfield("Port")
      .setPosition(50, 360)
      .setSize(200, 20)
      .setText(listeningPort.toString())
      .setLabel("The listening port")
      .setColorBackground(#2596DC)
      .setInputFilter(ControlP5.INTEGER);
    sb = cp5.addScrollableList("cameraList")
      .setPosition(50, 100)
      .setSize(200, 100)
      .setBarHeight(20)
      .setItemHeight(20)
      .setColorBackground(#2596DC)
      .setValue(camIndex);
    if (cameras != null) {
      cp5.get(ScrollableList.class, "cameraList").addItems(cameras);
    }
  }

  public void showGUI() {
    println("REVEALING");
    gui.isShown = true;
    cp5.get(Textfield.class, "IPText").show();
    cp5.get(Textfield.class, "Port").show();
    cp5.get(ScrollableList.class, "cameraList").show();
  }

  public void hideGUI() {
    println("DISSOLVING");
    this.isShown = false;
    cp5.get(Textfield.class, "IPText").hide();
    cp5.get(Textfield.class, "Port").hide();
    cp5.get(ScrollableList.class, "cameraList").hide();
  }



  public String[] checkCameraList() {
    cameraTimeout();
    cameras = Capture.list();
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      cameras = null;
    } else {
      println("Available cameras:");
      printArray(cameras);
    }
    return cameras;
  }

  public void cameraTimeout() {
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

  public void saveJSON(String[] cameras) {
    try {
      json.setString("cameraName", cameras[camIndex]);
    }
    catch(NullPointerException e) {
      json.setString("cameraName", "");
    }
    json.setInt("index", camIndex);
    //userIP = cp5.get(Textfield.class, "IPText").getText();
    json.setString("ip", userIP);
    json.setInt("port", listeningPort);
    saveJSONObject(json, pathToSavedOptions);
  }

  public void loadJSON() {
    try {
      this.json = loadJSONObject(pathToSavedOptions);
      this.userIP = json.getString("ip");
      this.loadedCamera = json.getString("cameraName");
      this.camIndex = json.getInt("index");
      this.listeningPort = json.getInt("port");
    } 
    catch(NullPointerException e) {
      this.json = new JSONObject();
      this.userIP = "127.0.0.1";
      this.loadedCamera = "";
      this.camIndex = 0;
      this.listeningPort = 12000;
    }
  }

  public String cameraList(int n) {
    println("User has chosen camera: " + cameras[n]);
    CColor c = new CColor();
    CColor c2 = new CColor();
    c.setBackground(#2596DC);
    c2.setBackground(color(255,0,0));
    
    sb.getItem(camIndex).put("color", c);
    camIndex = n;
    sb.getItem(n).put("color", c2);
    return cameras[n];
  }

  public String getUserIP() {
    return userIP;
  }
  public int getListeningPort() {
    return listeningPort;
  }

  public String getLoadedCamera() {
    return loadedCamera;
  }

  public int getIndex() {
    return camIndex;
  }

  public String [] getCameras() {
    return cameras;
  }

  public void setUserIP(String newIP) {
    println("User entered IP: " + newIP);
    userIP = newIP;
    saveJSON(this.cameras);
  }

  public void setListeningPort(int newPort) {
    println("User entered port: " + newPort);
    listeningPort = newPort;
    saveJSON(this.cameras);
  }

  public void setLoadedCamera(String cam) {
    loadedCamera = cam;
  }

  public void setCameras(String [] c) {
    cameras = c;
  }

  
}
