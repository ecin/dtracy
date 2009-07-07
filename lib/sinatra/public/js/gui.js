gui = {};
  
gui.Console = function(element_id){
  this.element = document.getElementById(element_id);

  var self = this;
  setInterval(function(){ self.update() }, 5000);
}
  
gui.Console.prototype.update = function(){
  if( this.latest != (evnt = dtracy.Probes.latest()) && util.isDefined(evnt) ){
    this.latest = evnt;
    this.element.innerHTML = evnt.toString();
  }
}