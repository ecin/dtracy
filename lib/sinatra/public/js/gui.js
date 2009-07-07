/**
 * @namespace Namespace for anything having to do with the user interface.
 **/
gui = {};
  
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
  setInterval(function(){ self.update() }, 5000);
}

/**
 * Animates the console and updates its contents with the latest Event.
 * @memberOf gui
 * @function
 **/
gui.Console.prototype.update = function(){
  if( this.latest != (evnt = dtracy.Probes.latest()) && util.isDefined(evnt) ){
    this.element.toggle('slide');
    this.latest = evnt;
    this.element.html(evnt.toString());
    var e = this.element;
    setTimeout(function(){e.toggle('slide')}, 1000);
  }
}