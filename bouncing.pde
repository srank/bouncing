import ketai.ui.*;
import ketai.sensors.*;
import android.view.MotionEvent;
import java.util.List;

KetaiGesture gesture; 

class Ball {
  private PVector position;
  private PVector velocity;
  private float diameter;
  private float radius;
  private PVector acceleration;

  public Ball(PVector position, PVector velocity, float diameter, PVector acceleration) {
    this.position = position;
    this.velocity = velocity;
    this.diameter = diameter;
    this.radius = diameter/2;
    this.acceleration = acceleration;
  }
  
  void output() {
    println("(" + position.x + ", " + position.y + "), " + width + ", " + height);
  }

  void draw() {
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
    pushMatrix();
    translate(position.x, position.y, 0);
    sphere(diameter/2);
    popMatrix();
  }

  void setAcceleration(float x, float y, float z) {
    acceleration.set(x, y, z);
  }
  
  boolean intersects(Ball other) {
    // return distanceBetweenCentres <= this.radius + other.radius
    return sq(this.position.x - other.position.x) + sq(this.position.y - other.position.y) < sq(this.radius + other.radius);
  }
}

float bounceFactor;
float friction;

ArrayList<Ball> balls = new ArrayList<Ball>();

KetaiSensor sensor;
PVector acceleration;

void setup() {
  size(displayWidth, displayHeight, P3D);
  sphereDetail(60);

  orientation(PORTRAIT);
  gesture = new KetaiGesture(this);

  background(0);

  balls.add(new Ball(new PVector(width/3, height/3), new PVector(10, 10, 1), width/3, new PVector()));
  balls.add(new Ball(new PVector(2*width/3, 2*height/3), new PVector(-1, -1, 1), width/4, new PVector()));

  bounceFactor = 0.8;
  friction = 0.999999;
  noStroke();

  sensor = new KetaiSensor(this);
  sensor.start();
}

void draw() {
  background(255, 204, 0);
  
  for (int i = 0; i < balls.size(); i++) {
     rebound(balls.get(i), balls.subList(i+1, balls.size()));
  }
  
  for (Ball ball : balls) {
    ball.draw();
  }
}

void rebound(Ball b, List<Ball> otherBalls) {
  for (Ball other : otherBalls) {
    if (b.intersects(other)) {
     // FIXME: bounce...
     println("boing");
    } else {
     println("boring");
    } 
  }
}

void setupLights() {
  float lightX = map(mouseX, 0, width, 1, -1);
  float lightY = map(mouseY, 0, height, 1, -1);

  lights();
  directionalLight(200, 200, 200, lightX, lightY, -1);
}

/*void onFlick(float x, float y, float startx, float starty, float v) {
 if (nearCircle(startx, starty)) {
 PVector flickVector = new PVector(x - startx, y - starty);
 velocity.add(flickVector);
 }
 }*/
/*
boolean nearCircle(float x, float y) {
 return sq(x - position.x) + sq(y - position.y) <= sq(diameter/2);
 }
 */
void onAccelerometerEvent(float x, float y, float z, long time, int accuracy) {
  for (Ball ball : balls) {
    ball.setAcceleration(-x/10, y/10, 0);
  }
}

public boolean surfaceTouchEvent(MotionEvent event) {
  super.surfaceTouchEvent(event);

  return gesture.surfaceTouchEvent(event);
}

