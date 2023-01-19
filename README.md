#include <FastLED.h>

    #define joyX A0
    #define joyY A1
    #define dirPinX 8
    #define stepPinX 9
    #define dirPinY 4
    #define stepPinY 5
    #define buttPin 5
    #define slpPin 7
    #define rstPin 6
    #define ledPin 2
    #define NUM_LEDS    20  
    CRGB leds[NUM_LEDS];    

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
      FastLED.addLeds<WS2812, ledPin, GRB>(leds, NUM_LEDS);
    }
    
    void step_motor(int revs, int dirPin){
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
          step_motor(1, stepPinX);
        } else if (xValue < 300) {
          digitalWrite(dirPinX, HIGH); //Clockwise
          Serial.write("stepPinX High steppin.");
          step_motor(1, stepPinX);
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

    void led_controller() {
    for (int i = 0; i < NUM_LEDS; i++) {
      leds[i] = CRGB(255, 0, 0);
    }
    FastLED.show();
    delay(500); 
    }

    void loop() {
      // put your main code here, to run repeatedly:
    step_motor(4);
    check_joystick();
    //sleep_motors();
    //wake_motors();
    //led_controler();
   
      delayMicroseconds(300);
     Serial.println(digitalRead(buttPin));

    }
    #define joyX A0
    #define joyY A1
    #define dirPinX 2
    #define stepPinX 3
    #define dirPinY 4
    #define stepPinY 5
    #define buttPin 7

     void setup() {
      Serial.begin(9600);
      pinMode(dirPinX, OUTPUT);
      pinMode(stepPinX, OUTPUT);
      pinMode(dirPinY, OUTPUT);
      pinMode(stepPinY, OUTPUT);

    }
    
    void spinMotor(int revs, char dir){
          Serial.write("In spin motor.");
          Serial.write("\n");  
        int axis;
        if (dir == 'X') {
          Serial.write("In X?  Shouldn't be.");
          Serial.write("\n");  
          axis = 3;
        } else {
          Serial.write("In Y!  Should be.");
          Serial.write("\n"); 
          axis = 5;
          }        
        for(int i =0; i < (200 * revs) ;i++) {
          digitalWrite(axis, HIGH);
          delayMicroseconds(1000);
          digitalWrite(axis, LOW);
          delayMicroseconds(1000);
        }
    }
void check_joystick() {
      int xValue = analogRead(joyX);
      int yValue = analogRead(joyY);
      if (xValue > 511) {
          digitalWrite(dirPinX, LOW);  //Counter-clockwise
          Serial.write("stepPinX Low steppin.");
          Serial.write("\n");
          spinMotor(1, 'X');
        } else {
          digitalWrite(dirPinX, HIGH); //Clockwise
          Serial.write("stepPinX High steppin.");
          spinMotor(1, 'X');
         }
      if (yValue > 511) {
          digitalWrite(dirPinY, LOW);  //Counter-clockwise
          Serial.write("stepPinY Low steppin.");
          Serial.write("\n");          
          spinMotor(1, 'Y');
        } else {
          digitalWrite(dirPinY, HIGH); //Clockwise
          Serial.write("stepPinY High steppin.");
          Serial.write("\n");
          spinMotor(1, 'Y');
        }
      
    }

    void loop() {
      // put your main code here, to run repeatedly:
      check_joystick();
    }
