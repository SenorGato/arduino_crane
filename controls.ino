void check_joystick() {
      int xValue = analogRead(joyX);
      if (xValue > 700) {
          digitalWrite(dirPinX, LOW);  //Counter-clockwise
          Serial.write("stepPinX Low steppin.");
          Serial.write("\n");
          //step_motor(1, stepPinX);
        } else if (xValue < 300) {
          digitalWrite(dirPinX, HIGH); //Clockwise
          Serial.write("stepPinX High steppin.");
          //step_motor(1, stepPinX);
         } 
      int yValue = analogRead(joyY);
      if (yValue > 700) {
          digitalWrite(dirPinY, LOW);  //Counter-clockwise
          Serial.write("stepPinY Low steppin.");
          Serial.write("\n");          
          //step_motor(1, stepPinY);
        } else if (yValue < 300) {
          digitalWrite(dirPinY, HIGH); //Clockwise
          Serial.write("stepPinY High steppin.");
          Serial.write("\n");
          //step_motor(1, stepPinY);
        }
}
