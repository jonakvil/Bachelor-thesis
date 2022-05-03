from pythonosc.udp_client import SimpleUDPClient



osc_ip = "127.0.0.1"
osc_port = 1337
client = SimpleUDPClient(osc_ip, osc_port)


while(True):
    list = []
    for i in range (0,5):
        list.append([i, i*100, 240])

    client.send_message("/some/address", list)




