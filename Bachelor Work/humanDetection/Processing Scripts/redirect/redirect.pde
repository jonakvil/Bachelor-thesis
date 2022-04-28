import oscP5.*;
import netP5.*;
import websockets.*;
import java.util.List;
import java.util.ArrayList;

WebsocketServer wsc;
OscP5 oscP5;
NetAddress myRemoteLocation;

int frameHeight = 480;
int frameWidth = 640;

float xCalib = 0.9;
float yCalib = 0.5;
float calibOffset = 0.15;

boolean flag = false;
int id1 = 1;
int id2 = 2;
int id3 = 3;
int startTime;

ArrayList<VirtualPerson> idBundle;
ArrayList<Integer> dyingPeople;
//ArrayList<VirtualPerson> dyingPeople;


boolean bundleFinished = false;

void setup() {
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 1337);
  myRemoteLocation = new NetAddress("127.0.0.1", 1337);

  wsc= new WebsocketServer(this, 8080, "/");
  startTime = millis();
  idBundle = new ArrayList<>();
  dyingPeople = new ArrayList<>();
}

boolean doneFirst = false;
boolean doneSecond = false;
boolean doneThird = false;
void draw() {


  if (!doneFirst) {
    for (int k = 0; k < 1; k++) {
      for (int i = 1; i < 100; i++) {
        OscMessage myMessage = new OscMessage("/some/address");
        //wsc.sendMessage(id1 + "/" + ((float)i*0.01) + "/" + ((float)i*0.01));
        myMessage.add(id1);
        myMessage.add((int)floor(640 - i*6.4));
        myMessage.add((int)floor(240));
        oscP5.send(myMessage, myRemoteLocation);
        delay(100);
      }
    }
    doneFirst = true;
  }
  if (doneFirst && !doneSecond) {
    for (int k = 0; k < 1; k++) {
      for (int i = 1; i < 50; i++) {
        OscMessage myMessage = new OscMessage("/some/address");
        myMessage.add(id1);
        myMessage.add(10);
        myMessage.add(240);
        oscP5.send(myMessage, myRemoteLocation);


        //myMessage = new OscMessage("/some/address");
        //myMessage.add(id2);
        //myMessage.add(640);
        //myMessage.add((int)floor(240 + i*4.8));
        //oscP5.send(myMessage, myRemoteLocation);
        delay(100);
      }
    }
    doneSecond = true;
  }

  if (doneSecond) {
    for (int k = 0; k < 2; k++) {
      for (int i = 1; i < 45; i++) {
        OscMessage myMessage = new OscMessage("/some/address");
        myMessage.add(id3);
        myMessage.add(10);
        myMessage.add((int)floor(225 + i*6.4));
        oscP5.send(myMessage, myRemoteLocation);
        delay(50);

        if (!doneThird) {
          OscMessage newM = new OscMessage("/some/address");
          newM.add(id1);
          newM.add(10);
          newM.add(240);
          oscP5.send(newM, myRemoteLocation);
          println("vole");
        }
        //myMessage = new OscMessage("/some/address");
        //myMessage.add(id2);
        //myMessage.add(640);
        //myMessage.add((int)floor(240 + i*4.8));
        //oscP5.send(myMessage, myRemoteLocation);
        delay(100);
      }
    }
    OscMessage myMessage = new OscMessage("/some/address");
    myMessage.add(id1);
    myMessage.add(-640);
    myMessage.add(-480);
    oscP5.send(myMessage, myRemoteLocation);
    doneThird = true;
  }
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/some/address")==true) {
    if (theOscMessage.checkTypetag("iii")) {


      int id = theOscMessage.get(0).intValue();
      int coordX = theOscMessage.get(1).intValue();
      int coordY = theOscMessage.get(2).intValue();
      if (coordX == -640) {
        println("negative");
        println(id);
      }
      resolveOscPacket(id, coordX, coordY);
      return;
    } else {
      println("aha");
    }
  }
  println("### received an osc message. with address pattern "+theOscMessage.addrPattern() + " " + theOscMessage.typetag());
}

void webSocketServerEvent(String msg) {
  int id = Integer.parseInt(msg);
  for (VirtualPerson vp : idBundle) {
    if (vp.getId() == id) {
      vp.inUse = true;
    }
  }
}
//0 for first track, 1 for other track
public void resolveOscPacket(int id, int coordX, int coordY) {
  float xNorm = (float)coordX/frameWidth;
  float yNorm = (float)coordY/frameHeight;
  println("RECEIVED: " + id + " | " + xNorm + " | " + yNorm);

  if (xNorm == -1.0) {
    println("received negative coord");
    for (VirtualPerson vp : idBundle) {
      if (vp.getId() == id) {
        idBundle.remove(vp);
        break;
      }
    }
    if (dyingPeople.remove(Integer.valueOf(id))) {
      println("removed id " + id);
      wsc.sendMessage(id + "/" + -1 + "/" + -1 + "/" + 0);
      return;
    }
  }
  if (dyingPeople.contains(id)) {
    println("returning");
    return;
  }

  if (dist(xNorm, yNorm, xCalib, yCalib) < calibOffset) {
    //POKUD JE NEKDO V KALIBRACNI ZONE
    for (VirtualPerson vp : idBundle) {
      if (vp.getId() == id) {
        vp.x = xNorm;
        vp.y = yNorm;
        println(" values updated in CZ: "+id+", "+xNorm+", "+xNorm);
        wsc.sendMessage(id + "/" + xNorm + "/" + yNorm + "/" + 0);
        return;
      }
    }
    VirtualPerson vp = new VirtualPerson(id, xNorm, yNorm);
    idBundle.add(vp);
    println(" values created in CZ: "+id+", "+xNorm+", "+xNorm);
    wsc.sendMessage(id + "/" + xNorm + "/" + yNorm + "/" + 0);
    return;
  } else {
    //POKUD JE NEKDO MIMO KALIBRACNI ZONU
    for (VirtualPerson vp : idBundle) {
      if (vp.getId() == id) {
        if (vp.inUse) {
          vp.x = xNorm;
          vp.y = yNorm;
          println(" values updated outside  : "+id+", "+xNorm+", "+yNorm);
          wsc.sendMessage(id + "/" + xNorm + "/" + yNorm + "/" + 0);
          return;
        } else {
          println("nemelo by nastat id: " + id);
        }
      }
    }
    checkNearby(id, xNorm, yNorm);

    //println(" values: "+id+", "+xNorm+", "+xNorm);
    //wsc.sendMessage(id + "/" + xNorm + "/" + yNorm);
  }
}

public void checkNearby(int id, float x, float y) {
  println(" - - - CHECKING - - - ");
  //boolean checkingUpdated = false;
  for (VirtualPerson vp : idBundle) {
    if (dist(x, y, vp.x, vp.y) < calibOffset) {
      if (vp.inUse) {
        println("je in use");
      }
      println("poslano na id: " + vp.getId() + ", coordy " + x + "|" + y + ", flag: " + id);
      wsc.sendMessage(vp.getId() + "/" + x + "/" + y + "/" + id);
      dyingPeople.add(vp.getId());
      vp.setId(id);
      break;
      //checkingUpdated = true;
    }
  }
  //if (checkingUpdated) {
  //  VirtualPerson vp = new VirtualPerson(id, x, y);
  //  vp.inUse = true;
  //  idBundle.add(vp);

  //}
}

public void printDP() {
  println("printing dying ----");
  for (int i : dyingPeople) {
    println(i);
  }
  println("----");
}
