let audioContext;
let scene;
let audioElement;
let audioElementSource;
let source;
let audioReady = false;

  // Set room acoustics properties.
  let dimensions = {
    width: 8,
    height: 10,
    depth: 8,
  };
  let materials = {
    left: 'transparent',
    right: 'transparent',
    front: 'transparent',
    back: 'transparent',
    down: 'plywood-panel',
    up: 'transparent',
  };

/**
 * @param {Object} _elements
 * @private
 */
 function updatePositions(_elements) {
    if (!audioReady){
      return;
    }
    let x = (_elements[1].x - 0.5) * dimensions.width / 2;
    let y = 0;
    let z = (_elements[1].y - 0.5) * dimensions.depth / 2;
    
    
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
  source.setPosition(0.5, 0.5, 0);

  audioReady = true;
}

let onLoad = function() {
  // Initialize play button functionality.
    // var ws = new WebSocket('ws://localhost:8080/');

  let sourcePlayback = document.getElementById('sourceButton');
  
  sourcePlayback.onclick = function(event) {
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
  };

  let canvas = document.getElementById('canvas');
  let elements = [
    {
      icon: 'sourceIcon',
      x: 0.5,
      y: 0.5,
      radius: 0.04,
      alpha: 0.333,
      clickable: false,
    },
    {
      icon: 'listenerIcon',
      x: 0.5,
      y: 0.5,
      radius: 0.04,
      alpha: 0.333,
      clickable: false,
    },
  ];
  
  new CanvasControl(canvas, elements, updatePositions);
};



window.addEventListener('load', onLoad);
