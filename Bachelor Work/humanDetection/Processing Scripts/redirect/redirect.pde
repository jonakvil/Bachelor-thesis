import oscP5.*;
import websockets.*;

WebsocketServer wsc;
OscP5 oscP5;
boolean flag = false;

void setup() {
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,1337);
  println("VOLEEEE");
  wsc= new WebsocketServer(this, 8080,"/");

}


void draw() {
  delay(2000);
  wsc.sendMessage(1 + "/" + (float)320/640 + "/" + (float)240/480);
  delay(1000);
   wsc.sendMessage(1 + "/" + (float)300/640 + "/" + (float)240/480);
  delay(1000);
   wsc.sendMessage(1 + "/" + (float)280/640 + "/" + (float)240/480);
  delay(1000);
   wsc.sendMessage(1 + "/" + (float)260/640 + "/" + (float)240/480);
  delay(1000);
   wsc.sendMessage(1 + "/" + (float)240/640 + "/" + (float)240/480);
  delay(1000);
   wsc.sendMessage(1 + "/" + (float)220/640 + "/" + (float)240/480);
  delay(1000);
   wsc.sendMessage(1 + "/" + (float)200/640 + "/" + (float)240/480);
  delay(1000);
   wsc.sendMessage(1 + "/" + (float)180/640 + "/" + (float)240/480);
  delay(1000);
   wsc.sendMessage(1 + "/" + (float)160/640 + "/" + (float)240/480);
  delay(1000);
   wsc.sendMessage(1 + "/" + (float)140/640 + "/" + (float)240/480);
  delay(1000);
  wsc.sendMessage(1 + "/" + (float)120/640 + "/" + (float)240/480);
  delay(1000);
  
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/some/address")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("iii")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      int id = theOscMessage.get(0).intValue();  
      int coordX = theOscMessage.get(1).intValue();
      int coordY = theOscMessage.get(2).intValue();
      println(" values: "+id+", "+coordX+", "+coordY);
      wsc.sendMessage(id + "/" + coordX + "/" + coordY);
      return;
    }  
  } 
  println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
}