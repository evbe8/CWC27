const int mos1Pin = 3;
const int mos1Pin = 5;

void setup() {
  // put your setup code here, to run once:
  pinMode(mos1Pin, OUTPUT);
  pinMode(mos2Pin, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(mos1Pin, HIGH);
  digitalWrite(mos2Pin, LOW);
}
