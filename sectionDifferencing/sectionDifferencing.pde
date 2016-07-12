import processing.video.*;

int numPixels;
int[] previousFrame;
Capture video;
int[] mvmt = new int[7];
int[] moving = new int[7];
int sec = 7;

// video capture dimensions
int vW = 64;
int vH = 48;

// calculated video width, divisible by 7.
int vWidth = 64;

// threshold just above stable
int thresh = 4000;

void setup() {
  size(64, 48);
  frameRate(2);

  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, vW, vH);

  // Start capturing the images from the camera
  video.start(); 

  for (int p = 0; p < mvmt.length; p++) {
    mvmt[p] = 0;
  }

  numPixels = video.width * video.height;
  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  loadPixels();
}

void draw() {
  for (int p = 0; p < mvmt.length; p++) {
    mvmt[p] = 0;
  }
  if (video.available()) {
    // When using video to manipulate the screen, use video.available() and
    // video.read() inside the draw() method so that it's safe to draw to the screen
    video.read(); // Read the new frame from the camera
    video.loadPixels(); // Make its pixels[] array available

    int movementSum = 0; // Amount of movement in the frame
    for (int m = 0; m < vWidth; m++) {
      for (int n = 0; n < video.height; n++) {
        
        int i = n*vWidth+m;
        color currColor = video.pixels[i];
        color prevColor = previousFrame[i];
        
        // Extract the red, green, and blue components from current pixel
        int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
        int currG = (currColor >> 8) & 0xFF;
        int currB = currColor & 0xFF;
        // Extract red, green, and blue components from previous pixel
        int prevR = (prevColor >> 16) & 0xFF;
        int prevG = (prevColor >> 8) & 0xFF;
        int prevB = prevColor & 0xFF;
        // Compute the difference of the red, green, and blue values
        int diffR = abs(currR - prevR);
        int diffG = abs(currG - prevG);
        int diffB = abs(currB - prevB);
        // Add differences to the right array

        int currentMovement = diffR + diffG + diffB;
        movementSum += currentMovement;
        sectionCheck(m, currentMovement);

        // Render the difference image to the screen
        pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
        // Save the current color into the 'previous' buffer
        previousFrame[i] = currColor;
      }

      if (movementSum > 0) {
        updatePixels();
        finalCheck();
        println("total move: " + movementSum); // Print the total amount of movement to the console
        println(" s1:" + moving[0] + " s2:" + moving[1] + " s3:" + moving[2] + " s4:" + moving[3] + " s5:" + moving[4] + " s6:" + moving[5] +" s7:" + moving[6]);
      }
    }
  }
}



void sectionCheck(int x_, int mv) {
  float s = vWidth/sec;
  if (x_ < s) {
    mvmt[0] += mv;
  } else if (x_ > s+1 && x_ < s*2) {
    mvmt[1] += mv;
  } else if (x_ > s*2+1 && x_ < s*3) {
    mvmt[2] += mv;
  } else if (x_ > s*3+1 && x_ < s*4) {
    mvmt[3] += mv;
  } else if (x_ > s*4+1 && x_ < s*5) {
    mvmt[4] += mv;
  } else if (x_ > s*5+1 && x_ < s*6) {
    mvmt[5] += mv;
  } else if (x_ > s*6+1 && x_ < s*7) {
    mvmt[6] += mv;
  } else {
    println("out of bounds");
  }
}

void finalCheck() {
  for (int p = 0; p < mvmt.length; p++ ) {
    moving[p] = mvmt[p] > thresh ? 1 : 0;
  }
}