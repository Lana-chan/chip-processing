/*
  BubbleCam
  Inspired by https://github.com/villares/processing-play/blob/master/video-capture/Un_mirror_reticula.pde
  Coded from scratch with PocketCHIP optimization in mind
*/

import processing.video.*;

Capture video;
int siz = 10; // dot size
int ow, oh;   // offsets for centering view
int w = 320;  // camera width
int h = 240;  // camera height

void setup() {
  video = new Capture(this, w, h);
  video.start();
  smooth();
  noStroke();
  size(480,270,P2D);
  ow = (width/2) - (w/2);
  oh = (height/2) - (h/2);
}

void draw() {
  background(0);
  if(video.available()) {
    video.read();
    video.loadPixels();
  }
  for(int y = siz/2; y < h; y+=siz) {
    for(int x = siz/2; x < w; x+=siz) {
      int point = video.width - x + y*video.width;
      if(point >= video.pixels.length) point = 0;
      color c = video.pixels[point];
      //fill(c);
      float lumin = brightness(c)/255;
      float siz2 = lumin*siz;
      ellipse(x + ow, y + oh, siz2, siz2);
    }
  }
}
