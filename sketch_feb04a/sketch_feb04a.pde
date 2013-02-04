int N = 50;

PVector[] pos;
PVector[] vel;

PVector randomVelocity()
{
  return new PVector(random(-1.0, 1.0), random(-1.0, 1.0));
}

void setup()
{
  size(800, 800);
  background(255);

  pos = new PVector[N];
  vel = new PVector[N];
  
  for(int n = 0; n < N; n++)
  {
    pos[n] = new PVector(random(0, width), random(0, height));
    vel[n] = randomVelocity();
  }
}

void draw()
{
  for(int n = 0; n < N; n++)
  {
    //vel[n] = randomVelocity();
    pos[n] = PVector.add(pos[n], vel[n]);
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
}
