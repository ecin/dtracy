/**
 * @namespace Namespace for utility functions. Think helpers.
 **/
util = {}

/**
 * Checks to see if a variable has been defined previously.
 * @memberOf util
 * @function
 * @param {Object} variable 
 * @returns {Boolean}
 **/
util.isDefined = function( variable ){
  return typeof(variable) != "undefined";
}

/**
 * Returns the max element in an array.
 * @memberOf Array
 * @function
 *
 * @example
 * nums = [1, 2, 3, 2, 1]
 * nums.max #=> 3
 */
Array.prototype.max = function(){
  return Math.max.apply( Math, this );
};

/**
 * Returns the minimum element in an array.
 * @memberOf Array
 * @function
 *
 * @example
 * nums = [1, 2, 3, 2, 1]
 * nums.min #=> 1
 */
Array.prototype.min = function(){
  return Math.min.apply( Math, this );
};

/**
 * @namespace Our lovely detective's namespace.
 **/
dtracy = {}

/**
 * Asynchronously fetches JSON for fired probes, creating an Event with each one, and calling itself
 * again to fetch future data.
 * @function
 * @memberOf dtracy
 * @param {Integer} idx Index of last received Event.
 *
 * @example
 * dtracy.update(1); #=> {"idx":2, "data":[{"pid":1234, "timestamp":4321, "probe":"gc-start", "arguments":[]}]}
 * dtracy.Probes["gc-start"].events #=> [<Event pid:1234, ...>]
 **/
dtracy.update = function(idx){

  $.getJSON("/updates?idx=" + idx + "&callback=?", function(json){
    jQuery.each(json.data, function(i,evnt){
      // evnt equals a dtrace probe firing
      evnt = new dtracy.Event(evnt.pid, evnt.timestamp, evnt.probe, evnt.arguments);
      dtracy.Probes.addEvent(evnt);
    });
    setTimeout("dtracy.update(" + json.idx + ")", 1000);
  }); 
}


/**
 * Holds references to all instanced Probes.
 * @memberOf dtracy
 *
 * @example
 * probe = new dtracy.Probe("gc-start");
 * dtracy.Probes["gc-start"]; #=> probe
 **/ 
dtracy.Probes = {};

/**
 * Adds the event to the corresponding Probe.
 * @memberOf dtracy
 * @function
 * @param {Event} event A dtracy.Event instance.
 *
 * @example
 * event = new dtracy.Event(1234, 1234567890, "gc-start");
 * dtracy.Probes.addEvent(event);
 * dtracy.Probes["gc-start"].events.pop(); # => event
 **/
dtracy.Probes.addEvent = function( event ){
  if(!util.isDefined(dtracy.Probes[event.name]))
    new dtracy.Probe(event.name);
    
  dtracy.Probes[event.name].addEvent(event);
  this.latest_event = event;
}

/**
 * Returns the latest event to be added.
 * @memberOf dtracy
 * @function
 *
 * @example
 * event = new dtracy.Event(1234, 1234567890, "gc-start");
 * dtracy.Probes.addEvent(event);
 * event == dtracy.Probes.latest(); # => true
 **/
dtracy.Probes.latest = function(){
  return this.latest_event;
}

/**
 * @class Represents a single Probe fire. Holds the arguments for said firing.
 * @param {Integer} pid The process id belonging to the app that fired the event.
 * @param {Integer} timestamp A unix-time timestamp
 * @param {String} name The name of the probe that fired.
 * @param {Hash} [arguments] Any argument that the probe fires with can be passed as a hash.
 * @returns {Event} 
 *
 * @example
 * new dtracy.Event(1234, 1234567890, "request-start", "{url: '/favicon.ico'}");
 **/
dtracy.Event = function( pid, timestamp, name, arguments ){
  this.pid = pid;
  this.timestamp = timestamp; 
  this.name = name;
  this.arguments = arguments; 
}

/**
 * @class Represents a Probe, and holds all events said Probe fires.
 * @param {String} name The name of the probe, by which it's identified when it fires.
 * @returns {Probe}
 *
 * @example
 * new dtracy.Probe("gc-start");
 **/
dtracy.Probe = function( name, callbacks ){
  this.name = name;
  this.events = [];
  this.callbacks = [];
  for( i = 1; i < arguments.length; i++ )
    this.callbacks.push( arguments[i] );
  
  dtracy.Probes[name] = this;
}

/**
 * Adds a callback function to call each time an Event is added to the Probe.
 * @function
 * @param {Function} callback Function to call when the probe fires, e.g. generates an Event.
 * @param {Object} receiver Object that gets sent the callback function, i.e. becomes `this` within the function.
 **/
dtracy.Probe.prototype.addCallback = function( callback, receiver ){
  this.callbacks.push([callback, receiver]);
}

/**
 * @function
 * @param {Event} event An instanced Event.
 * @returns {Event}
 *
 * @example
 * probe = new dtracy.Probe("gc-start");
 * event = new dtracy.Event(1234, 1234567890, "gc-start");
 * probe.addEvent(event);
 **/
dtracy.Probe.prototype.addEvent = function( event ){
  if( event.name == this.name )
    this.events.push(event);
  
  jQuery.each(this.callbacks, function(i, pair){
    pair[0].call(pair[1]);
  });
}

// Here lie undocumented functions. Proceed at your own risk!

vis = {};

vis.Base = function(){}

vis.Base.prototype.update = function(arguments){
  for (a in arguments){
    this[a] = arguments[a];
  }
}

vis.Base.prototype.draw = function(){
  alert("Please implement me, I promise to be a good function!");
}


vis.Ball = function( x, y, size, speed ){
  this.size = (util.isDefined(size) && size) || 1; 
  this.speed = (util.isDefined(size) && speed) || 4;
  this.radius = size;
  this.requests = 0;
  this.probeName = 'rack.bundle:request:request'
  if( !util.isDefined(dtracy.Probes[this.probeName]) )
      new dtracy.Probe(this.probeName);
      
  dtracy.Probes[this.probeName].addCallback( this.update, this );
  
  this.x = x;
  this.y = y;
}

vis.Ball.prototype = new vis.Base();

vis.Ball.prototype.draw = function(){
  
  radius = this.radius;
  
  new_radius = radius + this.size*Math.sin( frameCount / this.speed );
  
  // Fill canvas grey
  background( 221 );
  
  // Set fill-color to blue
  fill( 0, 121, 184 );
  
  // Set stroke-color white
  stroke(255); 
  
  // Draw circle
  ellipse( this.x, this.y, new_radius, new_radius);
}

vis.Ball.prototype.update = function(){

  if( this.size < Math.log(1000) ) // Bound how big we can grow.
    this.size += 2;
  
}

vis.Timeline = function( bar_amount, data_array ){
  this.bars = bar_amount;
  this.data = data_array;
}

vis.Timeline.prototype = new vis.Base();

vis.Timeline.prototype.draw = function(){
  
  background(224);
  fill(255);
  stroke('#5679C1');
    
  for( i = 0; i < this.data.length() ; i++ ){
    value = this.data[i];
    x = map(i, 0, this.data.length - 1, plotX1, plotX2);
    y = map(value, 0, 10, plotY2, plotY1);
  }
  
}