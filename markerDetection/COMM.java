import oscP5.*;
import netP5.*;


public class COMM {
  OscP5 oscP5;
  NetAddress myRemoteLocation;
  OscMessage myMessage;

  public COMM(OscP5 oscP5) {
    this.oscP5 = oscP5;
  }

  public void event(OscMessage theOscMessage) {
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
}
