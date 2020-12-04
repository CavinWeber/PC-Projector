import deadpixel.keystone.*;
import processing.net.*; 

boolean accessLock = false; //Semaphore for controlling access to Python WMI server

Keystone ks;
CornerPinSurface surface;
Client myClient;

PGraphics offscreen;

PImage backplateImg;  
PImage backgroundImg;  

Gauge CPUTempGauge;
Gauge GPUTempGauge;

float currentCPUTemp;
long CPUTempTimer;

float currentGPUTemp;
long GPUTempTimer;

float currentGPULoad;
long GPULoadTimer;

long GOLResetTimer;

// int cornerChoice;

boolean undistorted = false; // Render without keystoning if true
boolean blacken = false; // Blacken screen so no image is projected if true


void setup() {

  fullScreen(P3D, 2); // Use P3D renderer and display on second screen

  //  Instantiate Gauges
  CPUTempGauge = new Gauge(new PVector(150, 125), 25, 100);
  GPUTempGauge = new Gauge(new PVector(150, 125), 25, 100);
  CPUTempGauge.setDescription("CPU CORE");
  GPUTempGauge.setDescription("GPU CORE");

  myClient = new Client(this, "127.0.0.1", 50007); // Connect to Python WMI server
  
  currentCPUTemp = 0.0;
  currentGPULoad = 0.0;
  currentGPUTemp = 0.0;

  /**
  * These timers are global variables that are checked to make sure that their
  * associated functions are not being called too frequently
  */
  CPUTempTimer = millis();
  GPUTempTimer = millis();
  GOLResetTimer = millis();
  GPULoadTimer = millis();
  GPUTempTimer = millis();
 
  // cornerChoice = 0;
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(1920, 1080, 20);
  
  instantiateGOL();
  
  offscreen = createGraphics(1920, 1080, P3D);
  backplateImg = loadImage("backplate.jpg");
  backgroundImg = loadImage("background.jpg");
  ks.load();
  getCPUTemp();
  getGPUTemp();
  getGPULoad();
}

void draw() { // This code runs every frame

  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the 
  // surface from your screen. 
  PVector surfaceMouse = surface.getTransformedMouse();
  

    thread("getCPUTemp"); // Uses Processing's simple threading system to spawn CPU/GPU temp update in a new thread so as not to block drawing.
    thread("getGPUTemp");

  
  if(millis() - GOLResetTimer > 100)  // Poke Game of Life every 100ms
  {
    pokeGOL(0.05);
    GOLResetTimer = millis();
  }
  
  offscreen.beginDraw();
  
  offscreen.background(0);
  offscreen.fill(0, 255, 0);
  
  
  CPUTempGauge.update(currentCPUTemp);
  GPUTempGauge.update(currentGPUTemp);

  drawGOL();

  offscreen.imageMode(CENTER);
  
  offscreen.image(backgroundImg, offscreen.width/2, offscreen.height/2);
  
  /*
  * Processing uses a complicated system for manipulating coordinate systems to draw graphics.
  * The below code scales and places the "cursor" used to draw the gauges.
  */

  offscreen.pushMatrix();
  offscreen.translate(1199,659);
  offscreen.scale(0.8);
  offscreen.image(CPUTempGauge.display(), 0, 0);
  offscreen.popMatrix();
  
  offscreen.pushMatrix();
  offscreen.translate(1199,407);
  offscreen.scale(0.8);
  offscreen.image(GPUTempGauge.display(), 0, 0);
  offscreen.popMatrix();
  
  offscreen.image(GOLBuffer, 742, 540);

  if (blacken){
    background(0);
  }
  offscreen.endDraw();

  background(0);
 
  // render the scene, transformed using the corner pin surface
  if (!undistorted){
    surface.render(offscreen);
  }
  else{
    image(offscreen, 0, 0);
  }
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 'o':
    // saves the layout
    ks.save();
    break;

  case 'u':
    undistorted = !undistorted;
    break;
    
  case 'r':
    blacken = !blacken;
    break;

/**
*    There appears to be a bug in this library that causes the "moveMeshPointBy" function to
*    change corner points wildly and unpredictably. Unfortunately this means that manually
*    dragging corners outside of the projector area is not possible and the values must be
*    keyed in manually in the XML file.
*    The below code may be uncommented if this is fixed.
*/
/*
  case '1':
    cornerChoice = surface.TL;
    println("Corner 1");
    break;
    
  case '2':
    cornerChoice = surface.TR;
    println("Corner 2");
    break;
    
  case '3':
    cornerChoice = surface.BL;
    println("Corner 3");
    break;
    
  case '4':
    cornerChoice = surface.BR;
    println("Corner 4");
    break;
    
  case 'w':
    surface.moveMeshPointBy(cornerChoice, 0, 0.1);
    println("Moving up");
    break;
    
    case 'a':
    surface.moveMeshPointBy(cornerChoice, -0.1, 0);  
    println("Moving left");
    break;
  
    case 's':
    surface.moveMeshPointBy(cornerChoice, 0, -0.1);
    println("Moving down");
    break;
    
    case 'd':
    surface.moveMeshPointBy(cornerChoice, 0.1, 0);
    println("Moving right");
    break;
*/
  }   
}
