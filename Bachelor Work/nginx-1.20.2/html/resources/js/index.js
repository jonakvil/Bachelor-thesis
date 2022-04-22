let audioContext;
let scene;
let audioElement;
let audioElementSource;
let source;
let elements;
let audioReady = false;
let isCalibrated = false;
let isSearching = false;
let beforeInitCalibration = true;
let currentlyCalibrating = false;
let elementType = {
  source: 0,
  listener: 1,
  calibrationPoint: 2,
}

let timeoutOffset = 5;
let timeoutStart;

let listOfAllUsers = [
  {id: -1, x: -1, y: -1},
  {id: -1, x: -1, y: -1},
  {id: -1, x: -1, y: -1},
  {id: -1, x: -1, y: -1},
  {id: -1, x: -1, y: -1}
]

logArray();


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
    //logArray();

    var id, xCoord, yCoord;

    if(!isCalibrated){
      try{
        let array = _data.split("/")
        id = array[0].valueOf();
        xCoord = array[1].valueOf();
        yCoord = array[2].valueOf();
        
        if(!currentlyCalibrating){
          return;
        }else{
          var a = xCoord - elements[elementType.calibrationPoint].x;
          var b = yCoord - elements[elementType.calibrationPoint].y;
          var dist = Math.sqrt( a*a + b*b );
          if(dist < 0.15){
            console.log("Successfully calibrated");
            document.querySelector('#calibrateButton').textContent = 'Calibrated';
            document.getElementById("calibrateButton").disabled = true;
            document.getElementById("sourceButton").disabled = false;
            elements[elementType.listener].id = id;
            elements[elementType.listener].x = xCoord;
            elements[elementType.listener].y = yCoord;
            elements[elementType.listener].alpha = 1;
            isCalibrated = true;
            beforeInitCalibration = false;
            currentlyCalibrating = false;
          }
          console.log(dist)
        }
      }
      catch{
        console.log("No data received")
      };


    }else{
      if(_data != null){
        console.log(_data);
        let array = _data.split("/")
        id = array[0].valueOf();
        xCoord = array[1].valueOf();
        yCoord = array[2].valueOf();
        if(id != -1){
          setList(id, xCoord, yCoord);
        }
        if(id == elements[elementType.listener].id){
          if(xCoord > 0){
            elements[elementType.listener].alpha = 1;
            elements[elementType.listener].x = xCoord;
            elements[elementType.listener].y = yCoord;
            document.getElementById('infoText').textContent = "You are receiveing correct (hopefully xd) spatial audio mix";
          }else{
            console.log("Received negative coords");
            console.log("Searching for nearby coords...")
            if(!checkForSwitchedCoordinates()){
              isCalibrated = false;
              currentlyCalibrating = false;
              timeoutStart = new Date().getTime();
              elements[elementType.listener].id = -1;
              document.getElementById("calibrateButton").disabled = false;
              elements[elementType.listener].alpha = 0.2;
              document.querySelector('#calibrateButton').textContent = 'Calibrate';
              document.getElementById('infoText').textContent = "You are not tracked..."
            }
          }
        }
      }
    }

    if (!audioReady){
      return;
    }
    console.log("Changing COORDS of UI, id is " + elements[elementType.listener].id);
    let x = (elements[elementType.listener].x - 0.5) * dimensions.width / 2;
    let y = 0;
    let z = (elements[elementType.listener].y - 0.5) * dimensions.depth / 2;
    scene.setListenerPosition(x, y, z);
    
  }

/**
 * @private
 */
function logArray(){
  console.log("ARRAY START");
  for(var i = 0; i < 5; i++){
    console.log(listOfAllUsers[i].id + "/" + listOfAllUsers[i].x + "/" + listOfAllUsers[i].y);
  }
  console.log("ARRAY END");
}

/**
 * @private
 */
function setList(id, x, y){
  for(var i = 0; i < 5; i++){
    if(listOfAllUsers[i].id == id){
      console.log("test1, changing index " + i + "...id: " + id);
      listOfAllUsers[i].x = x;
      listOfAllUsers[i].y = y;
      logArray();
      return;
    }
  }

  for(var j = 0; j < 5; j++){
    if(listOfAllUsers[j].id == -1){
      console.log("test2, changing index " + j);
      listOfAllUsers[j].x = x;
      listOfAllUsers[j].y = y;
      listOfAllUsers[j].id = id;
      logArray();
      return;
    }
  }
}

/**
 * @private
 */
function checkForSwitchedCoordinates(){
  var count = 0;
  var a,b, finalId, finalX, finalY, finalIndex = -1;
  for(var i = 0; i < 5; i++){
    console.log("Now checking id " + listOfAllUsers[i].id);
    if(listOfAllUsers[i].id != elements[elementType.listener].id){
      a = elements[elementType.listener].x - listOfAllUsers[i].x;
      b = elements[elementType.listener].y - listOfAllUsers[i].y;
      var dist = Math.sqrt( a*a + b*b );
      if(dist < 0.15){
        console.log("Distance: " + dist);
        count++;
        if(count > 1){
          return false;
        }
        finalId = listOfAllUsers[i].id;
        finalX = listOfAllUsers[i].x;
        finalY = listOfAllUsers[i].y;
        finalIndex = i;
      }
    }
  }
  if(count > 0){

    console.log("found correct coords");
    //elements[elementType.listener].id = finalId;
    elements[elementType.listener].x = finalX;
    elements[elementType.listener].y = finalY;
    listOfAllUsers[finalIndex].id = -1;
    listOfAllUsers[finalIndex].x = -1;
    listOfAllUsers[finalIndex].y = -1;
    return true;
  }
  return false;
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
  let infoText = document.getElementById('infoText');

  sourcePlayback.onclick = function(event) {
    if(!beforeInitCalibration){

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
    document.querySelector('#calibrateButton').textContent = 'Calibrating';
    document.querySelector('#calibrateButton').disabled = true;
    elements[elementType.listener].alpha = 0.5;
    console.log("Calibrating")
    infoText.textContent = "Wait for the calibration to complete..."
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
      alpha: 0.2,
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
