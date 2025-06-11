//biblioteca
import processing.serial.*;
//porta serial
Serial myPort;
//strings
String val = "";
//distâncias dos sensores
float distHand1 = 0;
float distHand2 = 0;
//guarda as formas desenhadas para cada mão
ArrayList<Shape> shapesHand1;
ArrayList<Shape> shapesHand2;
//guarda partículas quando as mãos aproximam
ArrayList<Particle> particles;
//guarda a posição anterior
PVector lastPos1;
PVector lastPos2;

void setup() {
  fullScreen();
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n');

  colorMode(HSB, 360, 100, 100, 100);
  background(0, 0, 0);  // fundo preto sólido inicial
//para guardas formas e as partúclas
  shapesHand1 = new ArrayList<Shape>();
  shapesHand2 = new ArrayList<Shape>();
  particles = new ArrayList<Particle>();
//posição inicial das "mãos"
  lastPos1 = new PVector(width * 0.3, height / 2);//onde começa cada mão
  lastPos2 = new PVector(width * 0.7, height / 2);
//deixa os desenhos mais suaves
  smooth();
}

void draw() {


  colorMode(HSB, 360, 100, 100, 100);
//escolhe uma posição aleatória
  float x1 = random(width * 0.15, width * 0.45);
  float x2 = random(width * 0.55, width * 0.85);
//lê as distâncias detetadas
  float y1 = map(distHand1, 5, 80, height - 100, 100);
  float y2 = map(distHand2, 5, 80, height - 100, 100);
//cria vetores com a posição atual
  PVector currentPos1 = new PVector(x1, y1);
  PVector currentPos2 = new PVector(x2, y2);
//velocidade de cada mão
  float speed1 = PVector.dist(currentPos1, lastPos1);
  float speed2 = PVector.dist(currentPos2, lastPos2);
//valor mínimo de movimento para começar a desenhar as formas
  float movementThreshold = 2.5;
//cor para cada mão com a base das distância
  color col1 = color(map(distHand1, 5, 80, 0, 60) + random(-10, 10), 80, 90, 90);
  color col2 = color(map(distHand2, 5, 80, 180, 300) + random(-20, 20), 80, 90, 90);

  if (distHand1 > 5 && distHand1 < 80 && speed1 > movementThreshold) {
    //velocidade < 10 cria uma forma orgªanica
    if (speed1 < 10) {
      shapesHand1.add(new OrganicShape(currentPos1, 40 + speed1 * 6, col1));
    } else {
      int sides = (int) map(speed1, 10, 30, 3, 8);
      sides = constrain(sides, 3, 8);
      //velocidade >10 cria uma forma mais feométrica
      shapesHand1.add(new GeometricShape(currentPos1, sides, 25 + speed1 * 4, col1));
    }
    if (distHand1 < 40) {
      for (int i = 0; i < 5; i++) {
        particles.add(new Particle(currentPos1, col1, true));
      }
    } else {
      for (int i = 0; i < 5; i++) {
        particles.add(new Particle(currentPos1, col1, false));
      }
    }
  }

  if (distHand2 > 5 && distHand2 < 80 && speed2 > movementThreshold) {
    if (speed2 < 10) {
      shapesHand2.add(new OrganicShape(currentPos2, 40 + speed2 * 6, col2));
    } else {
      int sides = (int) map(speed2, 10, 30, 3, 8);
      sides = constrain(sides, 3, 8);
      shapesHand2.add(new GeometricShape(currentPos2, sides, 25 + speed2 * 4, col2));
    }
    if (distHand2 < 40) {
      for (int i = 0; i < 5; i++) {
        particles.add(new Particle(currentPos2, col2, true));
      }
    } else {
      for (int i = 0; i < 5; i++) {
        particles.add(new Particle(currentPos2, col2, false));
      }
    }
  }
//última posição 
  lastPos1 = currentPos1;
  lastPos2 = currentPos2;
//limite para as formas e particulas
  int maxShapes = 150;
  int maxParticles = 400;

  while (shapesHand1.size() > maxShapes)
    shapesHand1.remove(0);
  while (shapesHand2.size() > maxShapes)
    shapesHand2.remove(0);
  while (particles.size() > maxParticles)
    particles.remove(0);

  for (int i = shapesHand1.size() - 1; i >= 0; i--) {
    Shape s = shapesHand1.get(i);
    s.update();
    s.display();
    if (s.isDead())
      shapesHand1.remove(i);
  }
  for (int i = shapesHand2.size() - 1; i >= 0; i--) {
    Shape s = shapesHand2.get(i);
    s.update();
    s.display();
    if (s.isDead())
      shapesHand2.remove(i);
  }

  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead())
      particles.remove(i);
  }
}

void serialEvent(Serial p) {
  val = trim(p.readStringUntil('\n'));
  if (val != null && val.length() > 0) {
    String[] parts = split(val, ',');
    if (parts.length == 2) {
      try {
        distHand1 = float(parts[0]);
        distHand2 = float(parts[1]);
      } catch (NumberFormatException e) {
        println("Erro no formato dos dados: " + val);
      }
    }
  }
}

abstract class Shape {
  PVector pos;
  float size;
  color c;
  float alpha = 100;

  Shape(PVector pos_, float size_, color c_) {
    pos = pos_.copy();
    size = size_;
    c = c_;
  }

  abstract void display();

  void update() {
    alpha -= 1.2;
    size *= 0.97;
  }

  boolean isDead() {
    return alpha <= 0 || size < 1;
  }
}

class OrganicShape extends Shape {
  OrganicShape(PVector pos_, float size_, color c_) {
    super(pos_, size_, c_);
  }

  void display() {
    noFill();
    stroke(c, alpha);
    strokeWeight(4);
    ellipse(pos.x + random(-20, 20), pos.y + random(-20, 20), size * 2.5, size * 1.5);
  }
}

class GeometricShape extends Shape {
  int sides;

  GeometricShape(PVector pos_, int sides_, float size_, color c_) {
    super(pos_, size_, c_);
    sides = sides_;
  }

  void display() {
    noFill();
    stroke(c, alpha);
    strokeWeight(3);
    pushMatrix();
    translate(pos.x, pos.y);
    float angleStep = TWO_PI / sides;
    beginShape();
    for (int i = 0; i < sides; i++) {
      float angle = i * angleStep;
      float r = size * (0.8 + 0.2 * sin(frameCount * 0.1 + i));
      vertex(cos(angle) * r, sin(angle) * r);
    }
    endShape(CLOSE);
    popMatrix();
  }
}

class Particle {
  PVector pos;
  PVector vel;
  float size;
  color c;
  float alpha;
  boolean circle;

  Particle(PVector origin, color c_, boolean circle_) {
    pos = origin.copy().add(random(-30, 30), random(-30, 30));
    vel = PVector.random2D().mult(random(0.5, 3));
    size = random(5, 15);
    c = c_;
    alpha = 120;
    circle = circle_;
  }

  void update() {
    pos.add(vel);
    alpha -= 3;
    size *= 0.95;
  }

  void display() {
    noStroke();
    fill(c, alpha);
    if (circle) {
      ellipse(pos.x, pos.y, size, size);
    } else {
      rectMode(CENTER);
      rect(pos.x, pos.y, size, size);
    }
  }

  boolean isDead() {
    return alpha <= 0 || size < 0.5;
  }
}
