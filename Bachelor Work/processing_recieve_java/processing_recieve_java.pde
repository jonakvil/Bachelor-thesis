/**
 * CustomPipeline 
 * by Andres Colubri. 
 * 
 * Create a Capture object with a pipeline description to 
 * get video from non-standard sources.
 */

import processing.video.*;

Capture cam;

void setup() {
  size(640, 480, P2D);
  
  // Start the pipeline description with the "pipeline:" prefix, 
  // the rest could be any regular GStreamer pipeline as passed to gst-launch:
  // https://gstreamer.freedesktop.org/documentation/tools/gst-launch.html?gi-language=c#pipeline-description 
  //cam = new Capture(this, 640, 480, "pipeline:videotestsrc");
  cam = new Capture(this, 640, 480, "pipeline: udpsrc port=5200 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! rtpjpegdepay ! jpegdec ! videoconvert");
  //cam = new Capture(this, 640, 480, "pipeline: udpsrc port=5200 caps = 'application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H264, payload=(int)96' ! rtph264depay ! decodebin ! videoconvert ");
  
  //udpsrc port=5200 caps = "application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H264, payload=(int)96" ! rtph264depay ! decodebin ! videoconvert 
  //-v udpsrc port=5200 ! application/x-rtp, media=video, clock-rate=90000, payload=96 ! rtpjpegdepay ! jpegdec ! videoconvert
  cam.start();  
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  image(cam, 0, 0);
}
