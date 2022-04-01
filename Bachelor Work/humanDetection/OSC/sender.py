from time import sleep
from pythonosc.udp_client import SimpleUDPClient

def main():
    while(True):
        ip = "127.0.0.1"
        port = 1337

        #Client ----------------------------------------------------------------
        client = SimpleUDPClient(ip, port)  # Create client
        client.send_message("/some/address", 123)   # Send float message
        sleep(1)
        #Server ----------------------------------------------------------------


if __name__ == "__main__":
    main()