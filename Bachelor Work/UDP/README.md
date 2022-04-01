YOLOv4 setup
1) Python 3.8 (3.9 or 3.10 does not work)
2) pip
3)anaconda 
4) repo https://github.com/theAIGuysCode/yolov4-deepsort?fbclid=IwAR121owg9yZiJoRKvUUMQ1Uy7e5N6HjEmV4_dW7IcaugVJk1JARxENQAMqQ


Python Setup for Receiver
1)Download Python from official website: https://www.python.org/downloads/
2)Choose Python 3.8
3)during typical windows installation, check the checkbox "Add python to PATH environment"


UDP Setup
1)Python 3.x (ideal 3.8 to be compatible with YOLOv4) and pip
2)same numpy version (currently using 1.21) - you can use "pip install numpy==1.21.1"
3)OpenCV for Python
    - on windows open Terminal and type "pip install opencv-python" and then "pip install opencv-python-contrib"
    - tested with Raspberry pi 3b+, "pip install opencv-contrib-python==4.5.3.56"
    -"pip install opencv-contrib-python==4.5.5.64"
    -"pip install opencv-contrib-python"
    pip install opencv-python==4.5.5 
    pip uninstall opencv-contrib-python==4.5.3.56
4)use this template https://github.com/ancabilloni/udp_camera_streaming
5)change IP addresses and port numbers in sender and receiver files to correspond to your devices
    - I use port 5001 (for IP address on windows use terminal and "ipconfig")
    - as receiver, you have to use IP address of the device, where the stream is sent to.
        -eg.: If you use Windows PC as receiver, and send from Raspberry Pi to this Windows on it's Wi-Fi adapter IP addres, you need to use the exact same IP address in your reciver.py script on your Windows PC. That means you do not write IP address of the source, but the IP address of local destination, to which the stream is sent to.
6)head into code and change "tostring()" methods for "tobytes()" , as tostring() is deprecated
7)You either have to have both devices connected to same Wi-fi or have them connected via ethernet cable

IP Possible Issues
- to find your IP address on windwos, type in cmd "ipconfig". Take care to use correct one, if you want to use Ethernet or Wi-Fi connection. Same stands for Linux (the command is "ifconfig")
- when using universal IP addres 0.0.0.0 on receiver, make sure to disconnect from Wi-Fi, othervise the NIC will be overloaded by packets, and the stream will freeze after few moments.
    


TODO
1)nastaveni rozliseni a vysledne FPS
2)kontrast, expozice atd.