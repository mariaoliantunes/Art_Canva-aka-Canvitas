#include <NewPing.h> //biblioteca NewPing

#define MAX_DISTANCE 400 // distância máxima que os sensores vão considerar

// Sensores
#define TRIGGER_1 10
#define ECHO_1    9
#define TRIGGER_2 11
#define ECHO_2    12

// Buzzer
#define BUZZER    8
//os sensonres a utilizar a bibliotexa
NewPing sonar1(TRIGGER_1, ECHO_1, MAX_DISTANCE);
NewPing sonar2(TRIGGER_2, ECHO_2, MAX_DISTANCE);

void setup() {
  Serial.begin(9600);
  pinMode(BUZZER, OUTPUT);//o buzzer está definido como saída
}

void loop() {
  //mede a distância dos dois sensores
  int dist1 = sonar1.ping_cm();
  int dist2 = sonar2.ping_cm();

  // se o sensor não detetar, vai definir a distância inválida
  if (dist1 == 0 || dist1 > MAX_DISTANCE) dist1 = MAX_DISTANCE + 1;
  if (dist2 == 0 || dist2 > MAX_DISTANCE) dist2 = MAX_DISTANCE + 1;
//mostra a distância no monitor serial
  Serial.print(dist1);
  Serial.print(",");
  Serial.println(dist2);
//utiliza a menor distância entre os 2 sensores
  int closest = min(dist1, dist2);
//o som do buzzer é baseado na distância
  buzzerToneBeep(BUZZER, closest);
}

// Faz um beep do buzzer dependendo da distância
void buzzerToneBeep(int pin, int distance) {
  //a distância está dentro do limite
  if (distance <= MAX_DISTANCE) {
    // distância para a frequência
    int freq = map(distance, 1, MAX_DISTANCE, 2000, 500);
    freq = constrain(freq, 100, 5000);//limita a freq. a não ficar muito baixo ou alta

    // calcula quanto tempo dura um onda
    unsigned long period = 1000000UL / freq;
    unsigned long halfPeriod = period / 2;

    // define quanto tempo o beep vai durar
    unsigned long beepDur = 30000UL;
    unsigned long cycles = beepDur / period;

    // onda quadrada
    for (unsigned long i = 0; i < cycles; i++) {
      digitalWrite(pin, HIGH);//liga o buzzer
      delayMicroseconds(halfPeriod);
      digitalWrite(pin, LOW);//desliga o buzzer
      delayMicroseconds(halfPeriod);
    }

    //pausa para o proximo beep( mais perto= menos espera)
    int pause = map(distance, 1, MAX_DISTANCE, 100, 600);
    delay(pause);

  } else {
    // silenciar
    digitalWrite(pin, LOW);
    delay(100);
  }
}
