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
  wsc= new WebsocketServer(this, 8080, "/");
  startTime = millis();
}


void draw() {
  
  if (millis() - startTime < 5000 || true) {
      for (int i = 1; i < 100; i++) {
        wsc.sendMessage(id1 + "/" + ((float)i*0.01) + "/" + ((float)i*0.01));
        delay(100);
      }
      delay(2000);
      for (int i = 1; i < 100; i++) {
        wsc.sendMessage(id1 + "/" + ((float)1-0.01*i) + "/" + ((float)i*0.01));
        delay(100);
      }
      for(int i = 1; i < 100; i++){
        wsc.sendMessage(id1 + "/" + ((float)i*0.01) + "/" + ((float)1));
        delay(50);
      }
      for(int i = 1; i < 100; i++){
        wsc.sendMessage(id1 + "/" + ((float)1) + "/" + ((float)1-0.01*i));
        delay(50);
      }
      for(int i = 1; i < 100; i++){
        wsc.sendMessage(id1 + "/" + ((float)1-0.01*i) + "/" + ((float)0));
        delay(50);
      }
  }
  
  
  
  
  
  //} else if (millis() - startTime <= 10000) {
  //  delay(1000);
  //  wsc.sendMessage(id1 + "/" + ((float)(520)/640) + "/" + ((float)(440)/480));
  //} else if (millis() - startTime <= 15000) {
  //  delay(1000);
  //  wsc.sendMessage(id3 + "/" + ((float)(520)/640) + "/" + ((float)(440)/480));
  //  wsc.sendMessage(id1 + "/" + ((float)-1) + "/" + ((float)-1));
  //  delay(5000);
  //  startTime = millis();
  //}
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
  }
  //println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
}
