#!/usr/bin/env python

from __future__ import division
from picamera.array import PiRGBArray
from picamera import PiCamera
import time
import cv2
import numpy as np
import socket
import struct
import math


class FrameSegment(object):
    """ 
    Object to break down image frame segment
    if the size of image exceed maximum datagram size 
    """
    MAX_DGRAM = 2**16
    MAX_IMAGE_DGRAM = MAX_DGRAM - 64 # extract 64 bytes in case UDP frame overflown
    
    def __init__(self, sock, port, addr="169.254.64.229"): #PCIPWiFi: 192.168.0.108, PCIPEth1: 169.254.64.229 Ubuntu IP: 192.168.0.74 Ubuntu Ether: 169.254.248.229
        self.s = sock
        self.port = port
        self.addr = addr

    def udp_frame(self, img):
        """ 
        Compress image and Break down
        into data segments 
        """
        compress_img = cv2.imencode('.jpg', img)[1]
        dat = compress_img.tobytes()
        size = len(dat)
        count = math.ceil(size/(self.MAX_IMAGE_DGRAM))
        array_pos_start = 0
        while count:
            array_pos_end = min(size, array_pos_start + self.MAX_IMAGE_DGRAM)
            self.s.sendto(struct.pack("B", count) +
                dat[array_pos_start:array_pos_end], 
                (self.addr, self.port)
                )
            array_pos_start = array_pos_end
            count -= 1



def main():
    """ Top level main function """
    '''
    camera = PiCamera()
    camera.resolution = (640, 480)
    camera.framerate = 60
    rawCapture = PiRGBArray(camera, size=(640, 480))
    time.sleep(0.1)
        
        '''
    # Set up UDP socket
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    port = 5001

    fs = FrameSegment(s, port)

    cap = cv2.VideoCapture(1)
    '''
    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
        image = frame.array
        fs.udp_frame(image)
        rawCapture.truncate(0)
    '''
    #time.sleep(0.1)
    while (cap.isOpened()):
        ret, frame = cap.read()
        fs.udp_frame(frame)

    
    cap.release()
    cv2.destroyAllWindows()
    s.close()

if __name__ == "__main__":
    main()
