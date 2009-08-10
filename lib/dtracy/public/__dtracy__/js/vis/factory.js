vis = {};

vis.Canvas = {};
vis.Dashboard = {};

vis.Dashboard.save = function(){
  
  // Array to JSONify
  var canvases = [];
  
  for(var id in vis.Canvas){
    var c = vis.Canvas[id];
    var el = $('#' + id);
    
    // Push the vis' type, probe, and location onscreen
    canvases.push({
      visType: c.toString(),
      probe: c.probe,
      offset: el.offset()
    });
  }

  // Save those canvas properties in a cookie
  $.cookie('canvases', $.compactJSON(canvases))
}

vis.Dashboard.load = function(){
  
  // Load canvas array from browser cookie
  var canvases = $.evalJSON($.cookie('canvases'));
  
  // Create a new visualization from each
  for(var i = 0; i < canvases.length; i++){
    var item = canvases[i];
    
    // Create <canvas>
    var p = vis.Factory(eval(item.visType));
    
    // Reference it
    var el = $('#' + p.id);
    
    // Add its probe
    p.addProbe(item.probe);
    
    // Position it
    el.css('top', item.offset.top);
    el.css('left', item.offset.left);
  }
}


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

  p.id = id;

  // Save this visualization for future reference
  vis.Canvas[id] = p;
  
  return p;
}