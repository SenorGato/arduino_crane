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
