#include <FastLED.h>

    #define joyX A0
    #define joyY A1
    #define ledPin 2
    #define rstPin 6
    #define slpPin 7
    #define dirPinX 8
    #define stepPinX 9
    #define dirPinY 10
    #define stepPinY 11
    #define dirPinZ 12
    #define stepPinZ 13
    #define buttPin 5
    #define NUM_LEDS 20  
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
    
void step_motor(int revs, int stepPin, int dir){
    if (dir == -1) {
        digitalWrite((stepPin - 1), LOW);
    } else if (dir == 1) {
        digitalWrite((stepPin - 1), HIGH);
    }
    for(int i =0; i < (200 * revs) ;i++) {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(1000);
    digitalWrite(stepPin, LOW);
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
    step_motor(4, 5, -1);
    check_joystick();
    //sleep_motors();
    //wake_motors();
    //led_controler();
    delayMicroseconds(300);
    Serial.println(digitalRead(buttPin));
}
