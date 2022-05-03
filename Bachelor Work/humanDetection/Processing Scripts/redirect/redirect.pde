import oscP5.*;
import websockets.*;

WebsocketServer wsc;
OscP5 oscP5;
int frameHeight = 480;
int frameWidth = 640;

boolean flag = false;
int id1 = 1;
int id2 = 2;
int id3 = 3;
int startTime;

void setup() {
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 1337);
  println("VOLEEEE");
  wsc= new WebsocketServer(this, 8080, "/");
  startTime = millis();
}


void draw() {
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/some/address")==true) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("iii")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      int id = theOscMessage.get(0).intValue();
      int coordX = theOscMessage.get(1).intValue();
      int coordY = theOscMessage.get(2).intValue();
      println(" values: "+id+", "+coordX+", "+coordY);
      wsc.sendMessage(id + "/" + (float)coordX/frameWidth + "/" + (float)coordY/frameHeight);
      return;
    }
  } else {

    println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
  }
}
