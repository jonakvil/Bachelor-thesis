//send tracking data to remote address via websocket & OSC - open sound protocol
import oscP5.*;
import netP5.*;
import websockets.*;
WebsocketServer ws;

void initWebsocket() {
  ws = new WebsocketServer(this, 8081, "/markersCoord");
}

public class COMM {
  OscP5 oscP5;
  NetAddress myRemoteLocation;
  OscMessage myMessage;

  public COMM() {
    this.oscP5 = new OscP5(this, listeningPort);
    myRemoteLocation = new NetAddress(inputIP, listeningPort);
    initWebsocket();    
  }

  public void send(int i, PVector vec) {
    //println("i: " + i + " normalized x/y/z: " + vec.x/window_x + " " + vec.y/window_y + " " + vec.z);
    //not normalized, just set to be in <0.0;1.0> screen coords
    myMessage = new OscMessage("/markersCoord");
    myMessage.add(i);
    myMessage.add(vec.x/window_x);
    myMessage.add(vec.y/window_y);
    myMessage.add(vec.z);
    this.oscP5.send(myMessage, myRemoteLocation);
    
    ws.sendMessage(i+":"+vec.x/cam.width+":"+vec.y/cam.height); //send websocket
  }
}

/*
//for debug only - recieve the messages that are being send from this app
 public void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.addrPattern().equals("/markersCoord")) {
 if (theOscMessage.checkTypetag("ifff")) {
 int id = theOscMessage.get(0).intValue();
 float xCoord = theOscMessage.get(1).floatValue();
 float yCoord = theOscMessage.get(2).floatValue();
 float zCoord = theOscMessage.get(3).floatValue();
 println("### received an osc message /corrds with typetag ifff ### ");
 println("ID: " + id + " X: " + xCoord + " Y: " + yCoord + " Z: " + zCoord);
 return;
 }
 }
 println("### received pattern: " + theOscMessage.addrPattern());
 }
 */
