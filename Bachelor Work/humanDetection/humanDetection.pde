import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;
int numPixels;
int[] backgroundPixels;
boolean subtracted = false;
PImage test;

FPS buffer;

void setup() {
  size(320, 240);
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  buffer = new FPS(20);
  video.start();
  numPixels = video.width * video.height;
  // Create array to store the background image
  backgroundPixels = new int[numPixels];
  // Make the pixels[] array available for direct manipulation
  loadPixels();
}

void draw() {
  scale(2);
  opencv.loadImage(video);

  image(video, 0, 0 );

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  Rectangle[] faces = opencv.detect();
  println(faces.length);

  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x/2, faces[i].y/2, faces[i].width/2, faces[i].height/2);
  }
}

void captureEvent(Capture c) {
  if (c.available()) {
    c.read();
    opencv.adaptiveThreshold(591, 1);
    c.filter(GRAY);
    c.loadPixels();
    if (!subtracted) {
      for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
        // Fetch the current color in that location, and also the color
        // of the background in that spot
        color currColor = video.pixels[i];
        color bkgdColor = backgroundPixels[i];
        // Extract the red, green, and blue components of the current pixel's color
        int currR = (currColor >> 16) & 0xFF;
        int currG = (currColor >> 8) & 0xFF;
        int currB = currColor & 0xFF;
        // Extract the red, green, and blue components of the background pixel's color
        int bkgdR = (bkgdColor >> 16) & 0xFF;
        int bkgdG = (bkgdColor >> 8) & 0xFF;
        int bkgdB = bkgdColor & 0xFF;
        // Compute the difference of the red, green, and blue values
        int diffR = abs(currR - bkgdR);
        int diffG = abs(currG - bkgdG);
        int diffB = abs(currB - bkgdB);
        // Render the difference image to the screen
        pixels[i] = color(diffR, diffG, diffB);
        // The following line does the same thing much faster, but is more technical
        //pixels[i] = 0xFF000000 | (diffR << 16) | (diffG << 8) | diffB;
      }
      updatePixels(); // Notify that the pixels[] array has changed
    }
    countFPS();
  }
}

void keyPressed() {
  if (!subtracted) {
    video.loadPixels();
    arraycopy(video.pixels, backgroundPixels);
  }
}

void countFPS() {
  if (frameCount%30 == 0) {
    buffer.insert(round(frameRate));
    surface.setTitle("Marker detection fps: " + round(frameRate) +
      " avg: " + buffer.getAvg() );
  }
}
