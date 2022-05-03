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
  y: 0.05,
}

let sourceRACoord = {
  x: 0.0,
  y: -3.2
}

let calibrationCoord = {
  x: 0.9,
  y: 0.5,
}
let calibrationOffset = 0.15;
let calibrationTime = -1;

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
   * @private
   */
function checkTimeout(){
  if(Date.now() - calibrationTime > 3000){
    isCalibrated = false;
    currentlyCalibrating = false;
    document.querySelector('#calibrateButton').textContent = 'Calibrate';
    document.getElementById('calibrateButton').disabled = false;
    document.getElementById('infoText').textContent = "F... Try Again!";
    elements[elementType.listener].alpha = 0.2;
  }
}

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
        console.log(_data);
        if(!currentlyCalibrating){
          return;
        }else{
          var a = xCoord - elements[elementType.calibrationPoint].x;
          var b = yCoord - elements[elementType.calibrationPoint].y;
          var dist = Math.sqrt( a*a + b*b );
          if(dist < calibrationOffset){
            console.log("Successfully calibrated");
            document.querySelector('#calibrateButton').textContent = 'Calibrated';
            document.getElementById("calibrateButton").disabled = false;
            document.getElementById("sourceButton").disabled = false;
            document.getElementById('infoText').textContent = "You are receiveing correct (hopefully xd) spatial audio mix";
            setElements(id, xCoord, yCoord, 1, elementType.listener)
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
        }else{
          return;
        }
        if(id == elements[elementType.listener].id){
          if(xCoord > 0 && id != -1){
            setElements(0, xCoord, yCoord, 1, elementType.listener);
          }else{
            console.log("Received negative coords, searching neraby");
            if(!checkForSwitchedCoordinates()){
              isCalibrated = false;
              currentlyCalibrating = false;
              timeoutStart = new Date().getTime();
              setElements(-1, elements[elementType.listener].x, elements[elementType.listener].y, 0.2, elementType.listener);
              document.getElementById("calibrateButton").disabled = false;
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
    if(x == -1){
      console.log("deleting id:" + id);
      setUsers(-1, -1, -1, i);
      return;
    }
    if(listOfAllUsers[i].id == id){
      console.log("test1, changing index " + i + "...id: " + id);
      setUsers(0, x, y, i);
      logArray();
      return;
    }else{
      if(x < 0){
        console.log("deleting id, received negative coord of other user:" + id);
        setUsers(-1, -1, -1, i);
      }
    }
  }

  for(var j = 0; j < 5; j++){
    if(listOfAllUsers[j].id == -1){
      console.log("test2, changing index " + j);
      setUsers(id, x, y, j);
      logArray();
      return;
    }
  }
}

/**
 * @private
 */
function setUsers(id, x, y, index){
  listOfAllUsers[index].x = x;
  listOfAllUsers[index].y = y;
  if(id != 0){
    listOfAllUsers[index].id = id;
  }
}

/**
 * @private
 */
 function setElements(id, x, y, alpha, element){
  elements[element].alpha = alpha;
  elements[element].x = x;
  elements[element].y = y;
  if(id != 0){
    elements[element].id = id;
  }
  if(element == elementType.listener){
    document.querySelector('#userId').textContent = "Your ID is: " + elements[element].id;
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
    elements[elementType.listener].x = finalX;
    elements[elementType.listener].y = finalY;
    setUsers(-1, -1, -1, finalIndex);
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
  source.setPosition(sourceRACoord.x, 0, sourceRACoord.y);
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
    document.querySelector('#calibrateButton').textContent = 'Calibrating';
    document.querySelector('#calibrateButton').disabled = true;
    elements[elementType.listener].alpha = 0.5;
    console.log("Calibrating")
    infoText.textContent = "Wait for the calibration to complete..."
    calibrationTime = Date.now();
    currentlyCalibrating = true;
    setTimeout(checkCalibTimeOut, 3000);
    if(isCalibrated){
      console.log("fuck");
      isCalibrated = false;
      restoreId();
    }
  };

  function checkCalibTimeOut(){
    if(!isCalibrated){
      currentlyCalibrating = false;
      document.querySelector('#calibrateButton').textContent = 'Calibrate';
      document.querySelector('#calibrateButton').disabled = false;
      elements[elementType.listener].alpha = 0.2;
      infoText.textContent = "Click for calibration";
    }
  }

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

/**
 * @private
 */
 function restoreId(){
  for(var i = 0; i < 5; i++){
    if(listOfAllUsers[i].id == elements[elementType.listener].id){
      setUsers(-1, -1, -1, i);
    }
  }
  elements[elementType.listener].id = -1;
}

window.addEventListener('load', onLoad);
