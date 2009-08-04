(function(){

  var start = function(){
    p = Processing('canvas');
    p.setup = vis.Ring.setup;
    p.draw = vis.Ring.draw;
    p.speedUp = vis.Ring.speedUp;
    p.slowDown = vis.Ring.slowDown;
    p.update = vis.Ring.update;
    p.addProbe = vis.Ring.addProbe;
    p.init();
    vis.Canvas = {};
    vis.Canvas['canvas'] = p;
    
    p = Processing('canvas2');
    p.setup = vis.Timeline.setup;
    p.draw = vis.Timeline.draw;
    p.update = vis.Timeline.update;
    p.addProbe = vis.Timeline.addProbe;
    p.init();
    vis.Canvas['canvas2'] = p;
    /*
    var canvas = document.getElementById( "canvas" );
    var p = Processing( canvas );
    p = Processing( canvas, p.ajax( "js/ring.pjs" ) );
    
    var canvas = document.getElementById( "canvas2" );
    var p = Processing( canvas );
    p = Processing( canvas, p.ajax( "js/timeline.pjs" ) );
    */
  }

  document.addEventListener?
      document.addEventListener("DOMContentLoaded",start,false):0;

})();
