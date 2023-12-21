//Includes
import     java.io.BufferedWriter;
import     java.io.FileWriter;
import     processing.serial.*;

//Objects
Serial_port serial_left = new Serial_port();
Serial_port serial_rght = new Serial_port();

//Scan area
int cols = 66/2;    //X
int rows = 90/2;    //Y
int layers = 18/2;  //Z
int X_shift = -30;
int Y_shift = -70;
int Z_shift = 93;

int X_pos = 0;
int Y_pos = 0;
int Z_pos = 0;
Boolean X_revers = false;
Boolean Y_revers = false;


Boolean scan = false;
Boolean wait = false;

int k_send_try = 0;

ProgressBar progressBar;


//----------------------------------------------------------------------------------------------------------------------
void setup() 
{
  size( 1200, 850, P3D );
  
  serial_left.update();
  serial_rght.update();
  
  model_init();
  
  //Upload saved dump into model
  String filename = "data/init_dump.txt";
  try {
    String[] lines = loadStrings(filename);
  
    for (int i = 0; i < lines.length; i++) {
      String[] values = split(lines[i], '\t');
      
      if (values.length == 4) {
        int x = int(values[0]);
        int y = int(values[1]);
        int z = int(values[2]);
        int value = int(values[3]);
        
        if (x >= 0 && x < cols && y >= 0 && y < rows && z >= 0 && z < layers) {
          data[x][y][z] = value;
        }
      }
    }
  } catch (Exception e) {
    println("Error loading file: " + e.getMessage());
  }
  
  //Progress bar
  progressBar = new ProgressBar(this, 0, 0, width, 10, color(bgcolor), color(txcolor), true);
}


//----------------------------------------------------------------------------------------------------------------------
void draw() 
{
  background(bgcolor);
//-------------------------------------------------------- 
  control_watermark();
  control_group("LEFT", 0, height);
  control_group("RIGHT", width-170, height);
  progressBar.display();
  
  // Calculate percentage of completion
  float percentage = ((Z_pos * cols * rows + Y_pos * cols + X_pos) / (float)(cols * rows * layers)) * 100;
  progressBar.setProgress(percentage);
  
//--------------------------------------------------------  
  model_view();
//--------------------------------------------------------
  if( scan == true ){
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
    //Move
    serial_left.wait_responde = true;
    serial_left.writeln("G1 X"+(X_shift+X_pos*2)+" Y"+(Y_shift+Y_pos*2)+" Z"+(Z_shift+Z_pos*2)+"F1500\n");
    println("latch C on");
    while( serial_left.wait_responde == true ){
      delay(1);
    }
    println("latch C off");
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
    //Scan
    serial_rght.wait_responde = true;
    int[] numbers = {0xE0,0xE0,0x01,0x76};
    serial_rght.writearr(numbers, 4);
    println("latch K on");
    while( serial_rght.wait_responde == true ){
      delay(1);
      if( k_send_try++ > 100 ){
        println(minute()+":"+second()+" K Restore[!]");
        serial_rght.writearr(numbers, 4);
        k_send_try = 0;
        delay(1);
      }
    }
    k_send_try = 0;
    println("latch K off");
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     
    //Store
    appendTextToFile(outFilename, X_pos+"\u0009"+Y_pos+"\u0009"+Z_pos+"\u0009"+data[X_pos][Y_pos][Z_pos]);
    //println(X_pos+"\u0009"+Y_pos+"\u0009"+Z_pos+"\u0009");
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
    //X
    if( X_revers == false ){
      X_pos ++;
      if( X_pos == cols-1 ){
        if( Y_revers == false ){
          Y_pos ++;
        }else{
          Y_pos --;
        }
        X_revers = true;
      }
    }else{
      X_pos --;
      if( X_pos == 0 ){
        if( Y_revers == false ){
          Y_pos ++;
        }else{
          Y_pos --;
        }
        X_revers = false;
      }
    }
    
    //Y
    if( Y_revers == false ){
      if( Y_pos >= rows-1 ){
        Z_pos ++;
        Y_revers = true;
      }
    }else{
      if( Y_pos == 0 ){
        Z_pos ++;
        Y_revers = false;
      }
    }
    
    //Z
    if( Z_pos >= layers ){
      scan = false;
      timeshtamp_end();
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  zoom += e * 0.1; // Adjust the 0.1 factor for faster or slower zooming
  zoom = constrain(zoom, 0.5, 5.0); // Restrict zoom range
}

void keyPressed() {
  if( key == 'h' ){
    serial_left.writeln("G28\r\n");
  }
  if( key == 's' ){
    serial_left.writeln("G1 X"+X_shift+" Y"+Y_shift+" Z"+Z_shift+"F3000\r\n");
  }
  if( key == 't' ){
    serial_left.writeln("G1 X"+X_shift+" Y"+Y_shift+" Z"+(Z_shift+100)+"F3000\r\n");
  }
  if( key == 'y' ){
    scan = true;
    X_pos = 0;
    Y_pos = 0;
    Z_pos = 0;
    timeshtamp_start();
    model_init();
  }
  if( key == '1' ){
    if( detail_level > 2 ){
      detail_level--;
    }
  }
  if( key == '2' ){
    if( detail_level < 5 ){
      detail_level++;
    }
  }
  if( key == '3' ){
    if( sphere_size > 6 ){
      sphere_size--;
    }
  }
  if( key == '4' ){
    if( sphere_size < 20 ){
      sphere_size++;
    }
  }
  if( key == '5' ){
    if( render_uid == true ){
      render_uid = false;
    }else{
      render_uid = true;
    }
  }
  if( key == '7' ){
    if( slice_x == true ){
      slice_x = false;
    }else{
      slice_x = true;
    }
  }
  if( key == '8' ){
    if( slice_y == true ){
      slice_y = false;
    }else{
      slice_y = true;
    }
  }
  if( key == '9' ){
    if( slice_z == true ){
      slice_z = false;
    }else{
      slice_z = true;
    }
  }
  if( key == 'a' ){
    serial_left.writeln("G1 X"+(X_shift+cols*2)+" Y"+(Y_shift+rows*2)+" Z"+Z_shift+"F3000\r\n");
  }
  if( key == 'd' ){
    println("angleX:"+angleX+" angleY:"+angleY+" zoom:"+zoom);
  }
}
