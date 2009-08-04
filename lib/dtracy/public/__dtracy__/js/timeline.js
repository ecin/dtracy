/* The ever useful timeline, for displaying data across time.
 */
 
vis.Timeline = {};

vis.Timeline.setup = function(){
  this.size(311, 100);
  this.stroke('#111'); // Satin black
  this.fill('#111');
  this.smooth();
  this.strokeWeight(2); // no fuzziness
  this.frameRate(60);
  this.adjusting = false; // For when we're growing a bar
  this.data_points = []; // An empty array for the data
  this.c = 0;
}

vis.Timeline.draw = function(){
  this.background('#fff'); // clear canvas           
  
  this.rect(0, 0, 10, 100); // draw left-edge line
  
  var length = this.data_points.length
  
  if(length <= 10)
    for( i = 0; i < length; i++){
      this.fill('#111');
      this.rect(i*30 + 10, 100 - this.data_points[i], 30, this.data_points[i]);
    }
  else
    for( i = 0; i < 10; i++){
      this.fill('#111');
      this.rect(i*30 + 10, 100 - this.data_points[length - 10 + i], 30, this.data_points[length - 10 + i]);
    }
      
  if( this.c == 300 ){ // 5 seconds have passed, at 60fps
    this.update();
    this.c = 0;
  }
  else
    this.c++;
}

vis.Timeline.addProbe = function(probeName){
  if(probeName != this.probe){
    this.data_points = [];
    this.probe = probeName;
    if(util.isDefined(dtracy.Probes[probeName]))
      this.count = dtracy.Probes[probeName].events.length;
    else
      this.count = 0;
  }
}

vis.Timeline.update = function(){
  if( util.isDefined(this.probe) ){
    var current_count = dtracy.Probes[this.probe].events.length;
    var delta = current_count - this.count;
    this.count = current_count;
    
    this.data_points.push(delta);
  }
}