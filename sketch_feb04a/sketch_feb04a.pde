int N = 50;

PVector[] pos;
PVector[] vel;
PVector[] acc;

float lastTime = -1.0;

PVector randomVector(float minSize, float maxSize)
{
  return PVector.mult(PVector.fromAngle(random(0.0, 2.0 * PI)), random(minSize, maxSize));
  //return new PVector(random(-1.0, 1.0), random(-1.0, 1.0));
}

void setup()
{
  size(800, 800);
  background(255);

  pos = new PVector[N];
  vel = new PVector[N];
  acc = new PVector[N];
  
  for(int n = 0; n < N; n++)
  {
    pos[n] = new PVector(random(0, width), random(0, height));
    vel[n] = randomVector(0.0, 100.0);
  }
}

void draw()
{
  if(lastTime < 0.0)
  {
    lastTime = millis() / 1000.0;
    return;
  }
  float now = millis() / 1000.0;
  float dt = now - lastTime;
    
  for(int n = 0; n < N; n++)
  {
    acc[n] = randomVector(0.0, 100.0);
    vel[n] = PVector.add(vel[n], PVector.mult(acc[n], dt));
    pos[n] = PVector.add(pos[n], PVector.mult(vel[n], dt));
  }
  
  color(0);
  fill(0);
  for(int n = 0; n < N; n++)
  {
    pushMatrix();
      translate(pos[n].x, pos[n].y);
      rotate(-PI/2.0 + atan2(vel[n].y, vel[n].x));
      triangle(0, 16, -4, 0, 4, 0);
    popMatrix();
  }
  
  lastTime = now;
}
