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
ArrayList<DyingPerson> dyingPeople;
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

  VirtualPerson vp = new VirtualPerson(2, 10/640, 240/460, millis());
  vp.inUse = true;
  idBundle.add(vp);
}

boolean doneFirst = false;
boolean doneSecond = false;
boolean doneThird = false;
void draw() {


  if (!doneFirst) {
    for (int k = 0; k < 1; k++) {
      for (int i = 1; i < 100; i++) {
        OscMessage myMessage = new OscMessage("/some/address");
        myMessage.add(id1);
        myMessage.add((int)floor(640 - i*6.4));
        myMessage.add((int)floor(240));
        oscP5.send(myMessage, myRemoteLocation);

        delay(50);

        myMessage = new OscMessage("/some/address");
        myMessage.add(id2);
        myMessage.add(10);
        myMessage.add(240);
        oscP5.send(myMessage, myRemoteLocation);
        delay(100);
      }
    }
    doneFirst = true;
  }
  if (doneFirst && !doneSecond) {
    for (int k = 0; k < 1; k++) {
      for (int i = 1; i < 45; i++) {
        OscMessage myMessage = new OscMessage("/some/address");
        myMessage.add(id1);
        myMessage.add(10);
        myMessage.add(240);
        oscP5.send(myMessage, myRemoteLocation);

        myMessage = new OscMessage("/some/address");
        myMessage.add(id3);
        myMessage.add(10);
        //myMessage.add((int)floor(225 + i*6.4));
        myMessage.add(240);
        oscP5.send(myMessage, myRemoteLocation);
        delay(50);

        myMessage = new OscMessage("/some/address");
        myMessage.add(id2);
        myMessage.add(10);
        myMessage.add(240);
        oscP5.send(myMessage, myRemoteLocation);
        delay(100);
      }
    }
    doneSecond = true;
  }

  if (doneSecond) {
    for (int k = 0; k < 2; k++) {
      for (int i = 1; i < 45; i++) {
        //OscMessage myMessage = new OscMessage("/some/address");
        //myMessage.add(id3);
        //myMessage.add(10);
        //myMessage.add((int)floor(225 + i*6.4));
        //oscP5.send(myMessage, myRemoteLocation);
        //delay(50);

        //myMessage = new OscMessage("/some/address");
        //myMessage.add(id2);
        // myMessage.add(10);
        //myMessage.add((int)floor(225 + i*6.4));
        //oscP5.send(myMessage, myRemoteLocation);
        //delay(50);

        if (!doneThird) {
          OscMessage newM = new OscMessage("/some/address");
          newM.add(id1);
          newM.add(10);
          newM.add(240);
          oscP5.send(newM, myRemoteLocation);
          delay(50);

          OscMessage myMessage = new OscMessage("/some/address");
          myMessage.add(id2);
          myMessage.add(630);
          myMessage.add(240);
          oscP5.send(myMessage, myRemoteLocation);
        }
        delay(100);
      }
    }
    //OscMessage myMessage = new OscMessage("/some/address");
    //myMessage.add(id1);
    //myMessage.add(-640);
    //myMessage.add(-480);
    //oscP5.send(myMessage, myRemoteLocation);
    doneThird = true;
  }
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/some/address")==true) {
    if (theOscMessage.checkTypetag("iii")) {


      int id = theOscMessage.get(0).intValue();
      int coordX = theOscMessage.get(1).intValue();
      int coordY = theOscMessage.get(2).intValue();
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
  println();
  checkTimeStamps();
  float xNorm = (float)coordX/frameWidth;
  float yNorm = (float)coordY/frameHeight;
  printVP();
  printDP();

  println("RECEIVED: " + id + " | " + xNorm + " | " + yNorm);

  if (xNorm == -1.0) {
    println("received negative coord");
    for (VirtualPerson vp : idBundle) {
      if (vp.getId() == id) {
        idBundle.remove(vp);
        return;
      }
    }
  }

  for (DyingPerson dp : dyingPeople) {
    if (dp.getId() == id && xNorm == -1.0) {
      dyingPeople.remove(dp);
      println("removed id " + id);
      wsc.sendMessage(id + "/" + -1 + "/" + -1 + "/" + 0);
      return;
    } else if (dp.getId() == id) {
      dp.timeStamp = millis();
      return;
    }
  }


  if (dist(xNorm, yNorm, xCalib, yCalib) < calibOffset) {
    //POKUD JE NEKDO V KALIBRACNI ZONE
    for (VirtualPerson vp : idBundle) {
      if (vp.getId() == id) {
        vp.x = xNorm;
        vp.y = yNorm;
        vp.timeStamp = millis();
        //println(" values updated in CZ: "+id+", "+xNorm+", "+xNorm);
        wsc.sendMessage(id + "/" + xNorm + "/" + yNorm + "/" + 0);
        return;
      }
    }
    VirtualPerson vp = new VirtualPerson(id, xNorm, yNorm, millis());
    idBundle.add(vp);
    println(" values created in CZ: "+id+", "+xNorm+", "+xNorm);
    wsc.sendMessage(id + "/" + xNorm + "/" + yNorm + "/" + 0);

    return;
  } else {
    //POKUD JE NEKDO MIMO KALIBRACNI ZONU
    for (VirtualPerson vp : idBundle) {
      if (id == 2) {
        vp.inUse = true;
      }
      if (vp.getId() == id) {
        if (vp.inUse) {
          vp.x = xNorm;
          vp.y = yNorm;
          vp.timeStamp = millis();
          //println(" values updated outside  : "+id+", "+xNorm+", "+yNorm);
          wsc.sendMessage(id + "/" + xNorm + "/" + yNorm + "/" + 0);
          return;
        } else {
          println("nemelo by nastat id: " + id);
        }
      }
    }
    checkNearby(id, xNorm, yNorm);
  }
}


public void checkNearby(int id, float x, float y) {
  println(" - - - CHECKING - - - ");
  int counter = 0;
  int vpId = -1;

  for (VirtualPerson vp : idBundle) {
    println("checking dist");
    if (dist(x, y, vp.x, vp.y) < calibOffset) {
      counter++;
      vpId = vp.id;
    }
  }

  if (counter == 1) {
    for (VirtualPerson vp : idBundle) {
      if (vp.id == vpId) {
        println("poslano na id: " + vp.getId() + ", coordy " + x + "|" + y + ", flag: " + id);
        wsc.sendMessage(vp.getId() + "/" + x + "/" + y + "/" + id);
        DyingPerson dp = new DyingPerson(vp.getId(), millis());
        dyingPeople.add(dp);
        vp.setId(id);
        vp.timeStamp = millis();
        break;
      }
    }
  }
}

public void checkTimeStamps() {
  List<VirtualPerson> toDelete = new ArrayList<VirtualPerson>();
  for (VirtualPerson vp : idBundle) {
    if (millis() - vp.timeStamp > 2500) {
      println("removed id " + vp.getId() + " from VP");
      wsc.sendMessage(vp.getId() + "/" + -1 + "/" + -1 + "/" + 0);
      toDelete.add(vp);
    }
  }
  idBundle.removeAll(toDelete);

  List<DyingPerson> toDelete2 = new ArrayList<DyingPerson>();
  for (DyingPerson dp : dyingPeople) {
    if (millis() - dp.timeStamp > 2500) {
      println("removed id " + dp.getId() + " from DP");
      wsc.sendMessage(dp.getId() + "/" + -1 + "/" + -1 + "/" + 0);
      toDelete2.add(dp);
    }
  }
  dyingPeople.removeAll(toDelete2);
}

public void printDP() {
  println("---DYING PEOPLE LIST---");
  for (DyingPerson dp : dyingPeople) {
    println(dp.getId());
  }
  println("-------------------");
}

public void printVP() {
  println("---VIRTUAL PEOPLE LIST---");
  for (VirtualPerson vp : idBundle) {
    println(vp.id);
  }
  println("-------------------");
}
