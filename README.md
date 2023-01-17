    #define joyX A0
    #define joyY A1
    #define dirPinX 8
    #define stepPinX 9
    #define dirPinY 4
    #define stepPinY 5
    #define buttPin 5
    #define slpPin 7
    #define rstPin 6

     void setup() {
      Serial.begin(9600);
      pinMode(dirPinX, OUTPUT);
      pinMode(stepPinX, OUTPUT);
      pinMode(dirPinY, OUTPUT);
      pinMode(stepPinY, OUTPUT);
      pinMode(buttPin, INPUT);
      digitalWrite(buttPin, HIGH);
      pinMode(slpPin, OUTPUT);
      digitalWrite(slpPin, HIGH);
      pinMode(rstPin, OUTPUT);
      digitalWrite(rstPin, HIGH);
    }
    
    void step_motor(int revs){
        digitalWrite(dirPinX, HIGH);
        for(int i =0; i < (200 * revs) ;i++) {
        digitalWrite(stepPinX, HIGH);
        delayMicroseconds(1000);
        digitalWrite(stepPinX, LOW);
        delayMicroseconds(1000);
        }
    }
    void sleep_motors() {
        digitalWrite(slpPin, HIGH);
        digitalWrite(slpPin, LOW);
        digitalWrite(stepPinX, LOW);
        Serial.write("Sleeping Motors.");
        Serial.write("\n");
        delayMicroseconds(1000);
    }
    void wake_motors(){
      digitalWrite(slpPin, HIGH);
      Serial.write("Waking Motors.");
      Serial.write("\n");      
    }    
    void reset_motors(){
      digitalWrite(rstPin, HIGH);
      digitalWrite(rstPin, LOW);

      Serial.write("Resetting Motors.");
      Serial.write("\n");
      delayMicroseconds(1000);
    }
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
         } else {
           return;
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

    void loop() {
      // put your main code here, to run repeatedly:
    step_motor(4);
    sleep_motors();
    wake_motors();
    reset_motors();
    delayMicroseconds(300);
     Serial.println(digitalRead(buttPin));

    }
