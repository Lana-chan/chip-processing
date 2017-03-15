/*
  Simple 8x8 Bayer ordered dithering filter
*/

import processing.video.*;

Capture cam;
PImage screen;
int cx, cy;

int threshold = 4;   // number of colors
color colormap[] = { // palette
  color(15,56,15),
  color(48,98,48),
  color(140,173,15),
  color(156,189,15)
};

int pattern[][] = {
    { 0, 32,  8, 40,  2, 34, 10, 42},   /* 8x8 Bayer ordered dithering  */
    {48, 16, 56, 24, 50, 18, 58, 26},   /* pattern.  Each input pixel   */
    {12, 44,  4, 36, 14, 46,  6, 38},   /* is scaled to the 0..63 range */
    {60, 28, 52, 20, 62, 30, 54, 22},   /* before looking in this table */
    { 3, 35, 11, 43,  1, 33,  9, 41},   /* to determine the action.     */
    {51, 19, 59, 27, 49, 17, 57, 25},
    {15, 47,  7, 39, 13, 45,  5, 37},
    {63, 31, 55, 23, 61, 29, 53, 21} };

//int values[] = {51, 102, 154, 206};
int values[] = new int[4];
int spread = 96; // contrast (from middle to topmost value)
int center = 128; // brightness (offset of values)

// calculates the values in order to tweak in real time
void calculateValues() {
  for(int i = 0; i < values.length; i++) {
    int bottom = center-spread;
    int top = center+spread;
    values[i] = round(map(i, 0, values.length-1, bottom, top));
    print(values[i] + " ");
  }
  println();
}

void setup() {
  calculateValues();
  cam = new Capture(this, 320, 240);
  cam.start();
  imageMode(CENTER);
  screen = createImage(256, 224, RGB);
  size(480, 272, P2D);
  cx = width/2;
  cy = height/2;
}

void draw() {
  if(cam.available()) {
    cam.read();
    cam.loadPixels();
  }
  screen.loadPixels();
  int camx, camy;
  // scale the camera source to x2 128x112
  for(int y = 0; y < screen.height; y+=2) {
    camy = floor(map(y, 0, screen.height, 0, cam.height));
    for(int x = 0; x < screen.width; x+=2) {
      camx = floor(map(x, 0, screen.width, 0, cam.width));
      int scrpos = x + y*screen.width;
      int campos = camx + camy*cam.width;
      // this applies the filter
      color pixel = pixfilter(brightness(cam.pixels[campos]),x,y);
      // pushes to 4 pixels for x2 scale
      screen.pixels[scrpos] = pixel;
      screen.pixels[scrpos+1] = pixel;
      screen.pixels[scrpos+screen.width] = pixel;
      screen.pixels[scrpos+screen.width+1] = pixel;
    }
  }
  screen.updatePixels();
  background(0);
  image(screen, cx, cy, screen.width, screen.height);
}

// finds nearest value
int nearest(int num) {
  int distance = Math.abs(values[0] - num);
  int idx = 0;
  for(int c = 1; c < values.length; c++){
    int cdistance = Math.abs(values[c] - num);
    if(cdistance < distance){
      idx = c;
      distance = cdistance;
    }
  }
  return idx; 
}

// applies dithering
color pixfilter(float c, int x, int y) {
  int factor = pattern[x % 8][y % 8];
  int attempt = (int)c + factor * threshold;
  int id = nearest(attempt);
  return colormap[id];
};

// real time value tweaks
void keyPressed() {
  if(keyCode == UP) {           // more brightness
    center -= 8;
    calculateValues();
  } else if(keyCode == DOWN) {  // less brightness
    center += 8;
    calculateValues();
  } else if(keyCode == RIGHT) { // more contrast
    spread -= 8;
    calculateValues();
  } else if(keyCode == LEFT) {  // less contrast
    spread += 8;
    calculateValues();
  }
}