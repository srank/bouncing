import ketai.ui.*;
import ketai.sensors.*;
import android.view.MotionEvent;

KetaiGesture gesture; 

PVector position;
PVector velocity;
float diameter;
float bounceFactor;
float friction;

KetaiSensor sensor;
PVector acceleration;

void setup() {
  size(displayWidth, displayHeight, P3D);
  sphereDetail(60);

  orientation(PORTRAIT);
  gesture = new KetaiGesture(this);

  background(0);
  position = new PVector(width/2, height/2);
  velocity = new PVector(10, 10, 1);
  diameter = width/3;
  bounceFactor = 0.8;
  friction = 0.999999;
  noStroke();
  
  sensor = new KetaiSensor(this);
  sensor.start();
  acceleration = new PVector();
}

void draw() {
  float radius = diameter/2;
  
  background(255, 204, 0);
  velocity.mult(friction);
  velocity.add(acceleration);
  position.add(velocity);
  
  if (position.x - radius <= 0) {
    velocity.mult(new PVector(-1, 1));
    velocity.mult(bounceFactor);
    position.x = radius + radius - position.x;
  }
  
  if (position.x + radius >= width) {
    velocity.mult(new PVector(-1, 1));
    velocity.mult(bounceFactor);
    position.x = 2*width - position.x - 2*radius;
  }
  
  if (position.y + radius >= height) {
    velocity.mult(new PVector(1, -1));
    velocity.mult(bounceFactor);
    position.y = 2*height - position.y - 2*radius;
  }
  
  if (position.y - radius <= 0) {
    velocity.mult(new PVector(1, -1));
    velocity.mult(bounceFactor);
    position.y = radius + radius - position.y;
  }
  
  setupLights();
  
  fill(color(map(velocity.mag(), 0, 50, 0, 255), 93, 75));
  translate(position.x, position.y, 0);
  sphere(diameter/2);
}

void setupLights() {
  float lightX = map(mouseX, 0, width, 1, -1);
  float lightY = map(mouseY, 0, height, 1, -1);

  lights();
  directionalLight(200, 200, 200, lightX, lightY, -1);
}

void onFlick(float x, float y, float startx, float starty, float v) {
  if (nearCircle(startx, starty)) {
    PVector flickVector = new PVector(x - startx, y - starty);
    velocity.add(flickVector);
  }
}

boolean nearCircle(float x, float y) {
  return sq(x - position.x) + sq(y - position.y) <= sq(diameter/2);
}

void onAccelerometerEvent(float x, float y, float z, long time, int accuracy) {
  acceleration.set(-x/10, y/10, 0);
}

public boolean surfaceTouchEvent(MotionEvent event) {
  super.surfaceTouchEvent(event);

  return gesture.surfaceTouchEvent(event);
}
