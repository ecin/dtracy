(function(){

  var init = function(){
    var canvas = document.getElementById( "canvas" );
    var p = Processing( canvas );
    p = Processing( canvas, p.ajax( "js/ring.pjs" ) );
    
    var canvas = document.getElementById( "canvas2" );
    var p = Processing( canvas );
    p = Processing( canvas, p.ajax( "js/timeline.pjs" ) );
    
  }

  document.addEventListener?
      document.addEventListener("DOMContentLoaded",init,false):0;

})();
