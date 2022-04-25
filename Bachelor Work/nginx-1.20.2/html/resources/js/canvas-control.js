/**
 * Class for managing 2D visualization/interaction for audio demos.
 * @param {Object} canvas
 * @param {Object} elements
 * @param {Function} callbackFunc
 */
function CanvasControl(canvas, elements, callbackFunc) {
  this._canvas = canvas;
  this._elements = elements;
  this._callbackFunc = callbackFunc;
  //var ws = new WebSocket('ws://localhost:8080/');

  let _data;
  this._context = this._canvas.getContext('2d');
  this._cursorDown = false;

  this._selected = {
    index: -1,
    xOffset: 0,
    yOffset: 0,
  };

  this._lastMoveEventTime = 0;
  this._minimumThreshold = 16;
  let that = this;

  window.addEventListener('resize', function(event) {
    that.resize();
    that.draw();
  }, false);

  connect(this);

  this.invokeCallback();
  this.resize();
  this.draw();
}

function connect(that) {
  var ws = new WebSocket('ws://localhost:8080');
  ws.onopen = function() {
    // subscribe to some channels
    console.log("SERVER CONNECTED!");
  };

  ws.onmessage = function(e) {
    that._data = e.data;
    that.invokeCallback();
  };

  ws.onclose = function(e) {
    console.log('Socket is closed. Reconnect will be attempted in 1 second.', e.reason);
    setTimeout(function() {
      connect();
    }, 1000);
  };

  ws.onerror = function(err) {
    console.error('Socket encountered error: ', err.message, 'Closing socket');
    ws.close();
  };
}

CanvasControl.prototype.invokeCallback = function() {
  if (this._callbackFunc !== undefined) {
    this._callbackFunc(this._data);
    this.draw();
  }
};

CanvasControl.prototype.resize = function() {
  let canvasWidth = this._canvas.parentNode.clientWidth;
  let maxCanvasSize = 480;
  if (canvasWidth > maxCanvasSize) {
    canvasWidth = maxCanvasSize;
  }
  this._canvas.width = canvasWidth;
  this._canvas.height = canvasWidth;
};

CanvasControl.prototype.draw = function() {
  this._context.globalAlpha = 1;
  this._context.clearRect(0, 0, this._canvas.width, this._canvas.height);

  this._context.lineWidth = 5;
  this._context.strokeStyle = '#bbb';
  this._context.strokeRect(0, 0, canvas.width, canvas.height);

  for (let i = 0; i < this._elements.length; i++) {
    let icon = document.getElementById(this._elements[i].icon);
    if (icon !== undefined) {
      let radiusInPixels = this._elements[i].radius * this._canvas.width;
      let x = this._elements[i].x * this._canvas.width - radiusInPixels;
      let y = this._elements[i].y * this._canvas.height - radiusInPixels;
      this._context.globalAlpha = this._elements[i].alpha;
      this._context.drawImage(
        icon, x, y, radiusInPixels * 2, radiusInPixels * 2);
    }
  }
};
