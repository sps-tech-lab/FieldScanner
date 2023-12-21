int[][][] data;  // 3D array to store values

float side = 30;  // Size of each cube
float angleX = 1.4000003;
float angleY = 4.3213367E-7;
float zoom = 0.5;

int detail_level = 5;
int sphere_size  = 20;
Boolean render_uid = true;
Boolean slice_x = false;
Boolean slice_y = false;
Boolean slice_z = false;

void model_init() {
  
  data = new int[cols][rows][layers];
  
  // Initialize 3D array with random values
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      for (int k = 0; k < layers; k++) {
        data[i][j][k] = 0; //int(random(3));
      }
    }
  }
}

void model_view() {
  lights();
  
  translate(width / 2, height / 2, -300);
  scale(zoom);
  rotateX(angleX);
  rotateY(angleY);
  
     // Draw base behind the element [0, 0, 0] on Z-axis
  pushMatrix();
  translate(0, 0, (-layers*side/2-10)); // Adjust the translation based on the size of the 3D array
  fill(200);
  noStroke();
  box(cols*side, rows*side, 2);
  popMatrix();
  
  // Draw base
  fill(200);
  noStroke();

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      for (int k = 0; k < layers; k++) {
        float x = i * side - cols * side / 2;
        float y = j * side - rows * side / 2;
        float z = k * side - layers * side / 2;
        
        //Slicer
        if( slice_x == true && i > cols/2 ){
          continue;
        }
        if( slice_y == true && j > rows/2 ){
          continue;
        }
        if( slice_z == true && k > 2 ){
          continue;
        }

        pushMatrix();
        translate(x, y, z);

        // Set color and transparency based on the value in the array
        if (data[i][j][k] == 1) {
          if( render_uid == true ){
            fill(0, 0, 255, 127);
          }else{
            noFill();
          }
        } else if (data[i][j][k] == 2) {
          fill(255, 0, 0, 127);
        } else {
          noFill();  // Make cube invisible if value is 0
        }
        
        //Coordinates
        //if((i==0)&&(j==0)&&(k==0)){
        //  fill(0);
        //}
        //if((i==cols-1)&&(j==0)&&(k==0)){
        //  fill(255,0,0);
        //}
        // if((i==cols-1)&&(j==rows-1)&&(k==0)){
        //  fill(0,255,0);
        //}

        noStroke();  // Remove strokes

        sphereDetail(detail_level);
        sphere(sphere_size);
        
        if( i == X_pos && j == Y_pos && k == Z_pos ){
          fill(255);
          sphereDetail(8);
          sphere(15);
        }
        
        popMatrix();

      }
    }
  }
  
  //Key processing
  if (keyPressed == true) {
    // Use arrow keys to rotate the scene
    if (keyCode == UP) {
      angleX -= 0.1;
    } else if (keyCode == DOWN) {
      angleX += 0.1;
    } else if (keyCode == LEFT) {
      angleY -= 0.1;
    } else if (keyCode == RIGHT) {
      angleY += 0.1;
    }
    //println("angleX:"+angleX+" angleY"+angleY);
  }
}
