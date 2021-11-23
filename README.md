# Bachelor thesis - Fiducial marker tracking as haptic interface for spatial audio player
Standalone fiducial markers tracking using a web camera. The application has a graphical user interface and is very simple to use. Tracking data are sent to a selected IP address as WebSocket string or OSC. Software is part of the interface to enable spatial audio rendering controlled with haptics interface. However, it can be used for any other use-cases that involve fiducial marker tracking. Developed by Vilém Jonák as part of bachelor thesis at Czech Technical University in Prague under the tutelage of Vojtech Leischner. Supported by Human interaction department CVUT https://dcgi.fel.cvut.cz/

<img src="./images/tabletop_schema.jpg" width="375" height="357" />

## TODO LIST
* add user option to set time delay after which the marker instance is discarded when the marker was not detected for longer than x miliseconds
* enable perspective deformation of camera image to support camera from angle setup
* add toggle user option to turn off or on the movement smoothng (interpolate between detected positions or send only detected position)
* let user choose the acceleration of the markers used for movement smoothing - general settings or per marker settings?
* create builds for all major platforms - win, macos, linux
* create video demo
* port to raspberry pi - add camera exposore control
* enable for sifferent type of markers and let user control the max number of markers tracked

## Download
* [MacOS](https://)
* [Windows64bit](https://)
* [Linux64bit](https://)

Download links provide zipped archive with the tool. You don't need to install anything - just unzip it and run executable file.

### Windows
Tested on Windows 10. It should work out of the box. Just double click the "XXXX.exe" file. If you are using antivirus such as Windows Defender it will show warning - you can safely click "More info" and choose "Run anyway". Next time it should run without warning.

### MacOS
Tested on Catalina OS. On MacOs you need to allow installation from unknown sources. Open the Apple menu > System Preferences > Security & Privacy > General tab. Under Allow apps downloaded from select App Store and identified developers. To launch the app simply Ctrl-click on its icon > Open.

### Linux
Tested on Ubuntu 64bit. You can always run the app from the terminal. If using GUI and the app does not run when you double click the "XXXX" file icon you need to change the settings of your file explorer. In Nautilus file explorer click the hamburger menu (three lines icon next to minimise icon ), select "preferences". Click on "behaviour" tab, in the "Executable Text Files" option select "Run them". Close the dialogue and double click the "XXXXX" file icon (bash script) - now it should start.

## What is this good for?

## How to use it?
After unzipping simply double click the executable to run the application. 

Note that you can also adjust few settings. Click on the "XXXX" tab.  
* some settings - what it does
* other one....

## How does it work?
Under the hood the tool is programmed in Java Processing.

## MIT License
Copyright © 2021 Vilem Jonak, Vojtech Leischner

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
