/* serialReader
 
 Purpose: reads values written to the serial port by Arduino Uno,
          and saves them into files for later processing

 Instructions: connect amped to arduino and run PulseSensorAmped script.
          the only requirement on the script is that it write only sensor output to
          the serial monitor. Make sure the serial plotter or serial monitor are not
          on.
*/

import processing.serial.*;
Serial mySerial;
PrintWriter output;
void setup() {
  mySerial = new Serial( this, Serial.list()[0], 9600 ); 
  output = createWriter( "data.txt" );
}

void draw() {
  String value = mySerial.readString();
  if ( value != null ) {
    output.println( value );
  }
}

void keyPressed() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
exit(); // Stops the program
}