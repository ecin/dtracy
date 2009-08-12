/**
 * @namespace Namespace for anything having to do with the user interface.
 **/
gui = {};

/**
 *
 *
 */
 
gui.setup = function(){

  // All probes should be draggable
  $('.probe').draggable({ helper: 'clone', opacity: 0.75 });

  // Let's set up the canvases with draggable and droppable behaviour
  $('canvas').draggable().droppable(
      { accept: '.probe', 
        drop: function(event, ui) {
          vis.Canvas[this.id].addProbe(ui.draggable.attr('custom:name')); 
        }
      }
    );
    
  // The visualization tags also need draggable behaviour
  $('.vis_tag').draggable({ 
    helper: function(){
      var visType = eval($(this).attr('custom:name'));
      var el = $(document.createElement('div'));
      
      // Add the appropriate width and height and css class
      el.css({
        'width': visType.width,
        'height': visType.height
      }).addClass('vis_outline');
      
      // Add the visType in the custom:name field
      el.attr({'custom:name':  visType.toString()});
      
      return el;
    },
    opacity: 0.8,
    stop: function(event, ui){
      var visType = eval(ui.helper.attr('custom:name'));
      var visOffset = ui.offset;
      new vis.Factory(visType, { offset: visOffset });
      
    },
    cursorAt: { 'right': 5 }
  });
}

/**
 * @class Represents a text console for presenting messages to the user. On instantiation, 
 *        the instance's #update() method is set to run on an interval.
 * @param {String} element_id The CSS id of the DOM element that holds the console.
 *
 * @example
 * new gui.Console("console_data");
 **/
gui.Console = function(element_id){
  this.element = $("#" + element_id);

  var self = this;
  setInterval(function(){ self.update(dtracy.Probes.latest().toString()) }, 5000);
}

/**
 * Animates the console and updates its contents with a given message.
 * @memberOf gui
 * @function
 * @param {String} msg Message to display in the console.
 **/
gui.Console.prototype.update = function(msg){
  if( this.prev != msg ){
    this.element.toggle('slide');
    this.prev = msg;
    this.element.html(msg);
    var e = this.element;
    setTimeout(function(){e.toggle('slide')}, 1000);
  }
}

/*
 * Whitens out the screen, makes HTML elements below z-index 1 unclickable
 * @memberOf gui
 * @function
 */

gui.toggle_white_out = function(){
  el = $('#white_out');
  
  if(el.css('opacity') == 0){
    el.css('z-index', 10);
    el.animate({'opacity': 0.75}, 500);
  }
  else{
    el.animate({'opacity': 0}, 500, 'linear', function(){ el.css('z-index', 0) });
  }
}