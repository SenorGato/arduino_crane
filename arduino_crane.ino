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

 void setup() {
    Serial.begin(9600);
    pinMode(dirPinX, OUTPUT);
    pinMode(stepPinX, OUTPUT);
    pinMode(dirPinY, OUTPUT);
    pinMode(stepPinY, OUTPUT);
    pinMode(dirPinZ, OUTPUT);
    pinMode(stepPinZ, OUTPUT);
    pinMode(slpPin, OUTPUT);
    digitalWrite(slpPin, HIGH);
    pinMode(rstPin, OUTPUT);
    digitalWrite(rstPin, HIGH);
    pinMode(buttPin, INPUT);
    digitalWrite(buttPin, HIGH);
}
    
void sleep_motors() {
    digitalWrite(stepPinX, LOW);
    digitalWrite(slpPin, HIGH);
    digitalWrite(slpPin, LOW);
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

//void led_controller() {
//for (int i = 0; i < NUM_LEDS; i++) {
  //leds[i] = CRGB(255, 0, 0);
//}
//FastLED.show();
//delay(500); 
//}

void loop() {
    step_motor(4, stepPinX, -1);
    //check_joystick();
    //sleep_motors();
    //wake_motors();
    //led_controler();
    delayMicroseconds(300);
    //Serial.println(digitalRead(buttPin));
}
