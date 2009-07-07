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