void debugOSC() {

    OscMessage newM = new OscMessage("/some/address");
    newM.add(id1);
    newM.add(10);
    newM.add(240);
    oscP5.send(newM, myRemoteLocation);

    OscMessage myMessage = new OscMessage("/some/address");
    myMessage.add(id2);
    myMessage.add(630);
    myMessage.add(240);
    oscP5.send(myMessage, myRemoteLocation);
}
