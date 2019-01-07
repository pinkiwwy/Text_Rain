/**
    CSci-4611 Assignment #1 Text Rain
    Name: Wing Yi (Pinki) Wong
**/


import processing.video.*;

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
boolean inputMethodSelected = false;
boolean debugging = false;
PImage flippedImage;

String sentence = "Programming Interactive Computer Graphics and Games";
int senLength = sentence.length();
char[] letters =  new char[senLength];
int totalWidth = 1280;
int totalHeight = 720;
int numSen = 1280/senLength;
Text[] words = new Text[senLength];

float threshold = 128;  //set pixel brightness 128 as the thresold
float thres_rate = threshold/255;
//brightness<128 = foreground
//brightness>128 = background
int m = millis();

class Text{
  char letter;
  float xpos, ypos;
  int velocity;
  Text(char letter){
    this.letter = letter;
    this.xpos = random(0,totalWidth);
    this.ypos = 0;
    this.velocity = 10;
  }
  
  //when the text rain is playing or dropping, location changes
  void drop(){
      color pixLoc = flippedImage.get((int)(xpos), (int)(ypos));
      if (brightness(pixLoc)<threshold){
        respond();
      }
      else{
        ypos+=velocity;

      }
      if (ypos ==720){
        reset();
      }
  }

  
  //when the text reaches the bottom boundary, reset the location to the top again
  void reset() {
    ypos = 0;
  }
  
  //When the text is lift by some objects, response to the motion of the objects
  void respond() {
    if (ypos - velocity >=0){
      ypos -= velocity;
    }
    else{
      ypos=0;
    }
  }
  
  void drawText(){
    fill(128, 00, 0, 255);  //marcoon
    text(letter, xpos, ypos);
    drop();
  }
}

void setup() {
  size(1280, 720); 
  frameRate(10);
  inputImage = createImage(width, height, RGB);
  textFont(loadFont("ComicSansMS-24.vlw"));  //set the state for font, like the default
  float x = 0;
  for (int i=0; i<senLength; i++){
    letters[i] = sentence.charAt(i);
    Text tempLetter = new Text(letters[i]);
    tempLetter.xpos = x;
    words[i] = tempLetter;
    x+=numSen;
    if (x>=totalWidth-numSen){
      x = 0;
    }   
  }
}


void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40; 
    for (int i = 0; i < min(9,cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  }


  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.

  
  // STEP 1.  Load an image, either from a movie file or from a live camera feed. Store the result in the inputImage variable
  
  if ((cam != null) && (cam.available())) {
    cam.read();
    inputImage.copy(cam, 0,0,cam.width,cam.height, 0,0,inputImage.width,inputImage.height);
  }
  else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0,0,mov.width,mov.height, 0,0,inputImage.width,inputImage.height);
  }


  // Fill in your code to implement the rest of TextRain here..
  
  //display the video image in grayscale
  inputImage.filter(GRAY);
  inputImage.loadPixels();
  
  //flip the video image displayed on the screen to show the mirror image
  flippedImage = createImage(totalWidth, totalHeight, RGB);
  flippedImage.updatePixels();
  //swap the pixel array
  for (int orix=0; orix<totalWidth; orix++){
    for (int oriy=0; oriy<totalHeight; oriy++){
      int tempX = totalWidth - orix - 1;
      int oldloc = inputImage.pixels[oriy*totalWidth+orix];
      flippedImage.pixels[oriy*totalWidth+tempX] = oldloc;
    }
  }
  flippedImage.updatePixels();
  
  //copy pixel array from flippedImage
  PImage debuggingImage = flippedImage.copy();
  debuggingImage.filter(THRESHOLD, thres_rate);
  //debuggingImage.filter(BLUR);

  // Tip: This code draws the current input image to the screen
  if (!debugging){
    set(0, 0, flippedImage);
  }
  else{
    set(0, 0, debuggingImage);
  }
  for (int i=0; i<senLength; i++){
    words[i].drawText();
  }


}



void keyPressed() {
  
  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        mov = new Movie(this, "TextRainInput.mov");
        mov.loop();
        inputMethodSelected = true;
      }
      else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");           
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }


  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..
  
  if (key == CODED) {
    if (keyCode == UP) {
      // up arrow key pressed
      if (threshold<250){
        threshold+=5;
      }
    }
    else if (keyCode == DOWN) {
      // down arrow key pressed
      if (threshold>5){
        threshold-=5;
      }
    }
  }
  else if (key == ' ') {
    // space bar pressed
     debugging=!debugging;
  } 
  
}