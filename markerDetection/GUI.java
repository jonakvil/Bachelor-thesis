import controlP5.*;
import processing.video.*;
import jp.nyatla.nyar4psg.*;
import oscP5.*;
import netP5.*;
import java.util.*;


public class GUI {
  ControlP5 cp5;

  public GUI(ControlP5 cp5) {
    this.cp5 = cp5;
  }

  public void initGUI(String userIP, Integer listeningPort, String[] cameras, int camIndex) {
    cp5.addTextfield("IPText")
      .setPosition(50, 400)
      .setSize(200, 20)
      .setText(userIP)
      .setLabel("Insert IP address of destination");
    cp5.addTextfield("Port")
      .setPosition(50, 360)
      .setSize(200, 20)
      .setText(listeningPort.toString())
      .setLabel("The listening port");
    cp5.addScrollableList("Camera List")
      .setPosition(50, 100)
      .setSize(200, 100)
      .setBarHeight(20)
      .setItemHeight(20)
      .addItems(cameras)
      .setValue(camIndex);
    cp5.addButton("OK")
      .setPosition(500, 400)
      .setSize(80, 20);
  }

//  public void cameraList(String[] cameras, col) {
//    CColor c = new CColor();
//    c.setBackground(col);
//    cp5.get(ScrollableList.class, "cameraList").getItem(n).put("color", c);
//  }
}
