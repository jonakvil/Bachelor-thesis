let audioContext;
let scene;
let audioElement;
let audioElementSource;
let source;
let elements;
let audioReady = false;
let isCalibrated = false;
let currentlyCalibrating = false;
let elementType = {
  source: 0,
  listener: 1,
  calibrationPoint: 2,
}

let sourceCoord = {
  x: 0.5,
  y: 0.01,
}

let calibrationCoord = {
  x: 0.9,
  y: 0.9,
}

  // Set room acoustics properties.
  let dimensions = {
    width: 8,
    height: 10,
    depth: 8,
  };
  let materials = {
    left: 'transparent',
    right: 'transparent',
    front: 'plywood-panel',
    back: 'transparent',
    down: 'plywood-panel',
    up: 'transparent',
  };

/**
 * @param {Object} _data
 * @private
 */
 function updatePositions(_data) {
    //console.log(_data)
    var id, xCoord, yCoord;

    try{
      let array = _data.split("/")
      id = array[0];
      xCoord = array[1]
      yCoord = array[2]
      
      if(currentlyCalibrating){
        var a = xCoord - elements[elementType.calibrationPoint].x;
        var b = yCoord - elements[elementType.calibrationPoint].y;
        var dist = Math.sqrt( a*a + b*b );
        if(dist < 0.15){
          console.log("Successfully calibrated");
          document.querySelector('#calibrateButton').textContent = 'Calibrated';
          document.getElementById("calibrateButton").disabled = true;
          elements[elementType.listener].id = id;
          isCalibrated = true;
          currentlyCalibrating = false;
        }
        console.log(dist)
      }
    }
    catch{
      console.log("No data received")
    };

    if(!isCalibrated){
      elements[elementType.listener].alpha = 0.333;
      
      return;
    }else{
      console.log(_data);
      elements[elementType.listener].alpha = 1;
      elements[elementType.listener].x = xCoord;
      elements[elementType.listener].y = yCoord;
    }





    if (!audioReady){
      //console.log("Audio Not Ready at update Position")
      return;
    }
    let x = (elements[elementType.listener].x - 0.5) * dimensions.width / 2;
    let y = 0;
    let z = (elements[elementType.listener].y - 0.5) * dimensions.depth / 2;
    scene.setListenerPosition(x, y, z);
  }

/**
 * @private
 */
function initAudio() {
  audioContext = new (window.AudioContext || window.webkitAudioContext);

  // Create a (1st-order Ambisonic) ResonanceAudio scene.
  scene = new ResonanceAudio(audioContext);

  // Send scene's rendered binaural output to stereo out.
  scene.output.connect(audioContext.destination);


  scene.setRoomProperties(dimensions, materials);

  // Create an audio element. Feed into audio graph.
  audioElement = document.createElement('audio');
  audioElement.src = 'resources/music.wav';
  audioElement.load();
  audioElement.loop = true;

  audioElementSource = audioContext.createMediaElementSource(audioElement);

  // Create a Source, connect desired audio input to it.
  source = scene.createSource();
  audioElementSource.connect(source.input);

  // The source position is relative to the origin
  // (center of the room).
  source.setPosition(sourceCoord.x, sourceCoord.y, 0);

  audioReady = true;
}

let onLoad = function() {
  // Initialize play button functionality.

  let sourcePlayback = document.getElementById('sourceButton');
  let calibratePosition = document.getElementById('calibrateButton');

  sourcePlayback.onclick = function(event) {
    if(isCalibrated){
      switch (event.target.textContent) {
        case 'Play': {
          if(!audioReady){
              initAudio();
            }
          event.target.textContent = 'Pause';
          audioElement.play();
        }
        break;
        case 'Pause': {
          event.target.textContent = 'Play';
          audioElement.pause();
        }
        break;
      }
    }
  };

  calibratePosition.onclick = function(event) {
    if(isCalibrated || currentlyCalibrating){
      return;
    }
    console.log("Calibrating")
    event.target.textContent = 'Calibrating'
    currentlyCalibrating = true;
  };

  let canvas = document.getElementById('canvas');
  elements = [
    {
      icon: 'sourceIcon',
      x: sourceCoord.x,
      y: sourceCoord.y,
      radius: 0.04,
      alpha: 0.333,
      clickable: false,
      id: -420,
    },
    {
      icon: 'listenerIcon',
      x: 0.5,
      y: 0.5,
      radius: 0.04,
      alpha: 1,
      clickable: false,
      id: -1,
    },
    {
      icon: 'calibrationIcon',
      x: calibrationCoord.x,
      y: calibrationCoord.y,
      radius: 0.04,
      alpha: 0.333,
      clickable: false,
      id: -69,
    }
  ];
  
  new CanvasControl(canvas, elements, updatePositions);
};



window.addEventListener('load', onLoad);
