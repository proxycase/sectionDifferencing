import processing.video.*;

int numPixels;
int[] previousFrame;
Capture video;
int[] mvmt = new int[7];

void setup() {
  size(128,96);
  
  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, 128, 96);
  
  // Start capturing the images from the camera
  video.start(); 
  
  numPixels = video.width * video.height;
  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  loadPixels();
}

void draw() {
  if (video.available()) {
    // When using video to manipulate the screen, use video.available() and
    // video.read() inside the draw() method so that it's safe to draw to the screen
    video.read(); // Read the new frame from the camera
    video.loadPixels(); // Make its pixels[] array available
    
    int movementSum = 0; // Amount of movement in the frame
    for (int m = 0; m < video.width; m++) {
      for (int n = 0; n < video.height; n++) {
        int i = n*video.width+m;
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
        pixels[i] = color(diffR, diffG, diffB);
        // The following line is much faster, but more confusing to read
        //pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
        // Save the current color into the 'previous' buffer
        previousFrame[i] = currColor;
      }

      if (movementSum > 0) {
        updatePixels();
        println(movementSum); // Print the total amount of movement to the console
      }
    }
  }
}



int sectionCheck(int x_, int mvmt) {
   return 0; 
}