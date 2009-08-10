/* Template for visualizations */

// To instantiate: vis.Factory(vis.YourVis)

// Don't forget to name your visualization
vis.YourVis = {
  
  // Dimensions for the visualization's canvas, in pixels
  height: 0,
  width: 0,
  
  // Gets called when a probe is dragged onto the vis' canvas
  addProbe: function(probeName){},
  
  // Setup function, called once upon each instantiation
  setup: function(){},
  
  // Function to continually loop after calling setup()
  draw: function(){},
  
  // Handle checking for new probe event data
  update: function(){}
}
