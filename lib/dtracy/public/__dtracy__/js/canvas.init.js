/* 
  PROCESSINGJS.COM - BASIC EXAMPLE
  Delayed Mouse Tracking  
  MIT License - Hyper-Metrix.com/F1LT3R
  Native Processing compatible 
*/  


alert("BOO!");

// Global variables
float radius = 50.0;
int X, Y;
int nX, nY;
int delay = 16;
vis.Ball ball;

// Setup the Processing Canvas
void setup(){
  size( 200, 200 );
  strokeWeight( 5 );
  frameRate( 15 );
  X = width / 2;
  Y = width / 2;
  nX = X;
  nY = Y;  
  requests = 1;
  response = 4;
  ball = new vis.Ball(X, Y);
}

// Main draw loop
void draw(){

    radius = radius + requests*sin( frameCount / response );

    // Track circle to new destination
    X+=(nX-X)/delay;
    Y+=(nY-Y)/delay;

    // Fill canvas grey
    background( 221 );

    // Set fill-color to blue
    fill( 0, 121, 184 );

    // Set stroke-color white
    stroke(255); 

    // Draw circle
    ellipse( X, Y, radius, radius );                  

 // ball.draw();
                
}


// Set circle's next destination

void mouseClicked(){
  /*
  nX = mouseX;
  nY = mouseY;  
  */
  ball.size += 0.1;
  ball.speed /= 1.01;
}