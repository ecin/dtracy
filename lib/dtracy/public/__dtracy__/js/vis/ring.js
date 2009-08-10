/* Displays a ring spinning around the edge of a second ring.
* Speed of spinning is the variable here.
*/

// To instantiate: vis.Factory(vis.Ring)

vis.Ring = {

  // Dimensions for the visualization's canvas, in pixels
  height: 100,
  width: 100,

  // Name of the visualization
  toString: function(){
    return 'vis.Ring';
  },

  // Gets called when a probe is dragged onto the vis' canvas
  addProbe: function(probeName){
    this.probe = probeName;
    if(util.isDefined(dtracy.Probes[probeName]))
    this.count = dtracy.Probes[probeName].events.length;
    else
    this.count = 0;
  },

  // Setup function, called once upon each instantiation
  setup: function(){
    this.radius = 50; // radius of the inner ring
    this.delta = 0;
    this.speed = 20; // Starting speed, slowest
    this.size(100, 100);
    this.smooth();
    this.strokeWeight(10); // Nice and thick
    this.stroke('#111'); // Satin black
    this.frameRate(60);
    this.c = 0;
    this.adjusting = false;
  },

  // Function to continually loop after calling setup()
  draw: function(){
    this.background('#fff'); // clear canvas

    // draw inner ring
    this.ellipse(this.width/2, this.height/2, this.radius, this.radius);
    // draw outer ring
    if( util.isDefined(this.probe) ){
      this.ellipse(this.width/2 + (this.radius/2)*this.cos(this.frameCount/this.speed),
      this.height/2 + (this.radius/2)*this.sin(this.frameCount/this.speed),
      this.radius/5, this.radius/5);


      if( this.c == 300 ){ // 5 seconds have passed, at 60fps
        this.update();
        this.c = 0;
      }
      else
      this.c++;
    }
  },

  // Handle checking for new probe event data
  update: function(){
    if( util.isDefined(this.probe) ){
      var current_count = dtracy.Probes[this.probe].events.length;
      var delta = current_count - this.count;
      this.count = current_count;

      //console.log("Delta: " + delta);
      //console.log("Speed: "+ this.speed);

      // Target speed to attain
      var target = 20 - 2*this.round(Math.log(delta + 1)/Math.log(2));
      //console.log("Target: " + target);

      if( target == this.speed || this.adjusting )
      return;

      this.adjusting = true;

      // Lower this.speed value means faster spinning
      if( this.speed > target )
      this.speedup(target);
      else
      this.slowdown(target);
    }
  },

  // Helper functions

  speedup: function(target){
    if(this.speed <= 3 || this.speed <= target){
      this.adjusting = false;
      return;
    }

    var ring = this;
    this.frameCount = this.round(this.frameCount*(this.speed - 1)/this.speed--);
    setTimeout(function(){ ring.speedup(target) }, 200);
  },

  slowdown: function(target){
    if(this.speed >= 20 || this.speed >= target){
      this.adjusting = false;
      return;
    }

    var ring = this;  
    this.frameCount = this.round(this.frameCount*(this.speed + 1)/this.speed++);
    setTimeout(function(){ ring.slowdown(target) }, 200);
  }
}