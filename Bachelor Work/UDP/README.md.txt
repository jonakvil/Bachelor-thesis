YOLOv4 setup

1) Python 3.8 (3.9 or 3.10 does not work)
2) pip
3)anaconda 
4) repo https://github.com/theAIGuysCode/yolov4-deepsort?fbclid=IwAR121owg9yZiJoRKvUUMQ1Uy7e5N6HjEmV4_dW7IcaugVJk1JARxENQAMqQ




UDP Setup

1)Python 3.x (ideal 3.8 to be compatible with YOLOv4) and pip
2)same numpy version (currently using 1.21)
3)OpenCV for Python
    - on windows open Terminal and type "pip install opencv-python"
    - on RaspberryPi, and other unix machines, simple command "sudo apt-get install python-opnecv" should do the trick
4)use this template https://github.com/ancabilloni/udp_camera_streaming
5)change IP addresses and port numbers in sender and receiver files to correspond to your devices
    - I use port 5001 (for IP address on windows use terminal and "ipconfig")
6)head into code and change "tostring()" methods for "tobytes()" , as tostring() is deprecated
7)You either have to have both devices connected to same Wi-fi or have them connected via ethernet cable
    