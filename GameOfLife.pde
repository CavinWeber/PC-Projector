/**
* Much of this code comes directly from the Game of Life example provided with Processing.
* It has been modified to draw to an image buffer that can be drawn directly with '.image()'
*/

PGraphics GOLBuffer;

int cellSize = 5;

// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 50;

// Variables for timer
int interval = 100;
int lastRecordedTime = 0;

// color alive = color(0, 200, 0);
// color dead = color(0);

// Array of cells
int[][] cells; 
// Buffer to record the state of the cells and use this while changing the others in the interations
int[][] cellsBuffer; 

void instantiateGOL(){
   // Instantiate arrays 
   GOLBuffer = createGraphics(200,200);
  cells = new int[GOLBuffer.width/cellSize][GOLBuffer.height/cellSize];
  cellsBuffer = new int[GOLBuffer.width/cellSize][GOLBuffer.height/cellSize];
  
  
  GOLBuffer.beginDraw();

  // Initialization of cells
  for (int x=0; x<GOLBuffer.width/cellSize; x++) {
    for (int y=0; y<GOLBuffer.height/cellSize; y++) {
      float state = random (100);
      if (state > probabilityOfAliveAtStart) { 
        state = 0;
      }
      else {
        state = 1;
      }
      cells[x][y] = int(state); // Save state of each cell
    }
  }
  GOLBuffer.background(0); // Fill in black in case cells don't cover all the windows 
    GOLBuffer.endDraw();
}

void drawGOL() {

  //Draw grid
    GOLBuffer.beginDraw();
  for (int x=0; x<GOLBuffer.width/cellSize; x++) {
    for (int y=0; y<GOLBuffer.height/cellSize; y++) {
      if (cells[x][y]==1) {
        GOLBuffer.fill(255,0,0); // If alive
      }
      else {
        GOLBuffer.fill(0,0,0); // If dead
      }
      GOLBuffer.rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
  // Iterate if timer ticks
  if (millis()-lastRecordedTime>interval) {
      iteration();
      lastRecordedTime = millis();
  }
    GOLBuffer.endDraw();
}

void iteration() { // When the clock ticks
  // Save cells to buffer (so we opeate with one array keeping the other intact)
  for (int x=0; x<GOLBuffer.width/cellSize; x++)
  {
    for (int y=0; y<GOLBuffer.height/cellSize; y++)
    {
      cellsBuffer[x][y] = cells[x][y];
    }
  }

  // Visit each cell:
  for (int x=0; x<GOLBuffer.width/cellSize; x++)
  {
    for (int y=0; y<GOLBuffer.height/cellSize; y++)
    {
      // And visit all the neighbours of each cell
      int neighbours = 0; // We'll count the neighbours
      for (int xx=x-1; xx<=x+1;xx++) {
        for (int yy=y-1; yy<=y+1;yy++) {  
          if (((xx>=0)&&(xx<GOLBuffer.width/cellSize))&&((yy>=0)&&(yy<GOLBuffer.height/cellSize))) { // Make sure you are not out of bounds
            if (!((xx==x)&&(yy==y))) { // Make sure to to check against self
              if (cellsBuffer[xx][yy]==1){
                neighbours ++; // Check alive neighbours and count them
              }
            } // End of if
          } // End of if
        } // End of yy loop
      } //End of xx loop
      // We've checked the neigbours: apply rules!
      if (cellsBuffer[x][y]==1)
      { // The cell is alive: kill it if necessary
        if (neighbours < 2 || neighbours > 3)
        {
          cells[x][y] = 0; // Die unless it has 2 or 3 neighbours
        }
      } 
      else { // The cell is dead: make it live if necessary      
        if (neighbours == 3 )
        {
          cells[x][y] = 1; // Only if it has 3 neighbours
        }
      } // End of if
    } // End of y loop
  } // End of x loop
  //println("Iteration");
} // End of function

/**
* pokeGOL is used to flip random cells to live based on the current GPU load percentage.
* Too few cells poked can kill more cells than it makes. Lots of poked cells helps to
* stimulate the simulation to be more active. A value of 0.05 is a good default.
*/

void pokeGOL(float p){
      thread("getGPULoad");
      float i = currentGPULoad;
      if (i > 0)
      {
        p = p * i;
      }
      for (int x=0; x<GOLBuffer.width/cellSize; x++)
      {
        for (int y=0; y<GOLBuffer.height/cellSize; y++)
        {
          float state = random (100);
          if (state < p) {
            cells[x][y] = 1; // Save state of each cell
          }
      }
}
}