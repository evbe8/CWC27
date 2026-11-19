const uint8_t 1out = 2;

volatile uint32_t microsLast = 0;
volatile uint32_t halfPeriod = 0;

void interruptZeroCross()
{
  uint32_t microsNow = micros(); //number of ms since program began running
  halfPeriod = microsNow - microsLast;
  freq = 1000000.0/halfPeriod;
  Serial.print("Freq = ");
  Serial.println(freq);
  rpm = freq * 60;
  Serial.print("RPM = ");
  Serial.println(rpm);
  microsLast = microsNow;
}

void setup() {
  // put your setup code here, to run once:
  serial.Begin(115200);
  attachInterrupt(digitalPinToInterrupt(1out), interruptZeroCross, CHANGE);
}

void loop() {
  // put your main code here, to run repeatedly:

}
