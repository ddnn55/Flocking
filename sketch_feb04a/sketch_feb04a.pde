// settings
int N = 50;
float size = 16.0;
float minSpeed = 20.0, maxSpeed = 200.0;
float mousePower = 250.0;
float SeparationPower = 500000.0;
float SeparationBehaviorRange = size * 5;
boolean trail = false;
// end settings

// defines
float MouseModeAttract = -1.0;
float MouseModeRepulse =  1.0;
// end defines

PVector[] pos;
PVector[] vel;
PVector[] acc;

float lastTime = -1.0;
float mouseMode = MouseModeAttract;

PVector randomVector(float minSize, float maxSize)
{
  return PVector.mult(PVector.fromAngle(random(0.0, 2.0 * PI)), random(minSize, maxSize));
}

void setup()
{
  size(displayWidth, displayHeight);
  background(255);

  pos = new PVector[N];
  vel = new PVector[N];
  acc = new PVector[N];
  
  for(int n = 0; n < N; n++)
  {
    pos[n] = new PVector(random(0, width), random(0, height));
    vel[n] = randomVector(minSpeed, maxSpeed);
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
  
  if(!trail)
    background(255);
  
  for(int n = 0; n < N; n++)
  {
    /***** acceleration *****/
    
    // reset
    acc[n] = new PVector(0.0, 0.0);
    
    // separation
    for(int m = 0; m < N; m++)
    {
      if(m != n)
      {
        float distance = PVector.dist(pos[n], pos[m]);
        if(distance < SeparationBehaviorRange)
        {
          PVector separationAcc = PVector.sub(pos[m], pos[n]);
          separationAcc.setMag(-SeparationPower * 1.0 / sq(distance));
          acc[n] = PVector.add(acc[n], separationAcc);
        }
      }
    }
    
    // mouse
    if(mousePressed)
    {
      PVector mouseAcc = new PVector(pos[n].x - mouseX, pos[n].y - mouseY);
      mouseAcc.setMag(mouseMode * mousePower);
      acc[n] = PVector.add(acc[n], mouseAcc); 
    }
    
    // randomness
    acc[n] = PVector.add(acc[n], randomVector(0.0, 100.0));
    
    /***** velocity *****/
    vel[n] = PVector.add(vel[n], PVector.mult(acc[n], dt));
    if(vel[n].mag() < minSpeed)
      vel[n].setMag(minSpeed);
    if(vel[n].mag() > maxSpeed)
      vel[n].setMag(maxSpeed);
    
    /***** position *****/
    pos[n] = PVector.add(pos[n], PVector.mult(vel[n], dt));
    if(pos[n].x < -size)
       pos[n].x = width + size;
    if(pos[n].x > width + size)
       pos[n].x = -size;
    if(pos[n].y < -size)
       pos[n].y = height + size;
    if(pos[n].y > height + size)
       pos[n].y = -size;
  }
  
  color(0);
  fill(0);
  for(int n = 0; n < N; n++)
  {
    pushMatrix();
      translate(pos[n].x, pos[n].y);
      rotate(-PI/2.0 + atan2(vel[n].y, vel[n].x));
      triangle(0, size, -size/4.0, 0, size/4.0, 0);
    popMatrix();
  }
  
  lastTime = now;
}

void keyPressed() {
  switch(key)
  {
    // a,A - Switch to attraction mode (for when mouse is held down).
    case 'a': case'A':
      mouseMode = MouseModeAttract;
    break;
    // r,R - Switch to repulsion mode (for when mouse is held down).
    case 'r': case'R':
      mouseMode = MouseModeRepulse;
    break;
    // s,S - Cause all creatures to be instantly scattered to random positions in the window.
    // p,P - Toggle whether to have creatures leave a path, that is, whether the window is cleared each display step or not.
    case 'p': case 'P':
      trail = !trail;
    break;
    
    // c,C - Clear the window (useful when creatures are leaving paths).
    // 1 - Toggle the flock centering forces on/off.
    // 2 - Toggle the velocity matching forces on/off.
    // 3 - Toggle the collision avoidance forces on/off.
    // 4 - Toggle the wandering force on/off.
    // =,+ - Add one new creature to the simulation. You should allow up to 100 creatures to be created.
    // - (minus sign) - Remove one new creature from the simulation (unless there are none already).
    // space bar - Start or stop the simulation (toggle between these).
    
    default:
  }

}
