// basic script to read data from Arduion with an Olimex EKG Shield on top

void setup() {
  Serial.begin(115200);
}

void loop() {
  int sensorValue = analogRead(A0);
  // print out the value
  Serial.println(sensorValue);
  // about 256Hz sample rate
  delayMicroseconds(3900);
}
