vis = {};

vis.Canvas = {};

vis.Factory = function(visType){

  // Use current time as an id for the canvas element
  var id = new Date().getTime().toString();
    
  // Append the canvas element to the body
  $(document.createElement('canvas')).attr({
    'id': id,
    'width': visType.width,
    'height': visType.height
  }).appendTo('body');

  // Todo: setup only this element, not all canvases
  gui.setup(); // make this new canvas draggable and droppable

  var p = $.extend(Processing(id), visType);

  // Run setup() and loop draw()
  p.init();

  // Save this visualization for future reference
  vis.Canvas[id] = p;
}