//Includes
import     java.io.BufferedWriter;
import     java.io.FileWriter;
import     processing.serial.*;

//Objects
Serial_port serial_left = new Serial_port();
Serial_port serial_rght = new Serial_port();

//Scan area
int cols = 100/2;   //50
int rows = 70/2;   //35
int layers = 30/2; //15

int X_shift = -30;
int Y_shift = -80;
int Z_shift = 85;

int X_pos = 0;
int Y_pos = 0;
int Z_pos = 0;
Boolean X_sw = false;
Boolean Y_sw = false;


Boolean scan = false;
Boolean wait = false;

int k_send_try = 0;


//Jst class test
Rectangle sq = new Rectangle( 200, 200, 15, 15, #747983, #f89300 ); 

//----------------------------------------------------------------------------------------------------------------------
void setup() 
{
  size( 1200, 850, P3D );
  
  serial_left.update();
  serial_rght.update();
  
  model_init();
}


//----------------------------------------------------------------------------------------------------------------------
void draw() 
{
  background(bgcolor);
//-------------------------------------------------------- 
  control_watermark();
  control_group("LEFT", 0, height);
  control_group("RIGHT", width-170, height);
//--------------------------------------------------------  
  model_view();
//--------------------------------------------------------
  if( scan == true ){
    
    //Move
    serial_left.wait_responde = true;
    serial_left.writeln("G1 X"+(X_shift+X_pos*2)+" Y"+(Y_shift+Y_pos*2)+" Z"+(Z_shift+Z_pos*2)+"F1500\n");
    println("latch C on");
    while( serial_left.wait_responde == true ){
      delay(1);
    }
    println("latch C off");
    
    //Scan
    serial_rght.wait_responde = true;
    int[] numbers = {0xE0,0xE0,0x01,0x76};
    serial_rght.writearr(numbers, 4);
    println("latch K on");
    while( serial_rght.wait_responde == true ){
      delay(1);
      if( k_send_try++ > 100 ){
        println("K Restore[!]");
        serial_rght.writearr(numbers, 4);
        k_send_try = 0;
        delay(1);
      }
    }
    k_send_try = 0;
    println("latch K off");
    
    //Store
    appendTextToFile(outFilename, X_pos+"\u0009"+Y_pos+"\u0009"+Z_pos+"\u0009"+data[X_pos][Y_pos][Z_pos]);

    X_pos ++;
    if( X_pos >= cols ){
      X_pos = 0;
      Y_pos ++;
      if( Y_pos >= rows ){
        Y_pos = 0;
        Z_pos ++;
        if( Y_pos >= layers ){
          scan = false;
          timeshtamp_end();
        }
      }
    }
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
    serial_left.writeln("G1 X"+X_shift+" Y"+Y_shift+" Z"+Z_shift+"\r\n");
  }
  if( key == 'y' ){
    scan = true;
    X_pos = 0;
    Y_pos = 0;
    Z_pos = 0;
    timeshtamp_start();
  }
}

//void wait_ok(){
//  wait = false;
//  println("go");
//}
