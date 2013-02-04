// settings
int N = 40;
float size = 16.0;
float minSpeed = 20.0, maxSpeed = 400.0;
float mousePower = 500.0;
float SeparationPower = 500000.0;
float CohesionPower = 400.0;
float AlignmentPower = 0.05;
float SeparationBehaviorRange = size * 5;
float VelocityDamping = 0.99;
// end settings

// defines
float MouseModeAttract = -1.0;
float MouseModeRepulse =  1.0;
// end defines

// modes
boolean Wander = true;
boolean Separation = true;
boolean Cohesion = true;
boolean Alignment = true;

boolean trail = false;
boolean paused = false;
// end modes

// triggers
boolean clearOnce = false;
// end triggers

PVector[] pos;
PVector[] vel;
PVector[] acc;

float lastTime = -1.0;
float mouseMode = MouseModeAttract;

PVector randomVector(float minSize, float maxSize)
{
  return PVector.mult(PVector.fromAngle(random(0.0, 2.0 * PI)), random(minSize, maxSize));
}

PVector accelerationFromToMag(PVector from, PVector to, float mag)
{
  PVector acc = PVector.sub(to, from);
  acc.setMag(mag);
  return acc;
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
  lastTime = now;
  
  if(paused)
    return;
  
  if(!trail || clearOnce)
    background(255);
  if(clearOnce)
    clearOnce = false;
  
  for(int n = 0; n < N; n++)
  {
    /***** acceleration *****/
    
    // reset
    acc[n] = new PVector(0.0, 0.0);
    
    // n^2 behaviors
    float totalWeight = 0.0;
    PVector weightedCenter = new PVector(0.0, 0.0);
    PVector weightedAverageVel = new PVector(0.0, 0.0);
    for(int m = 0; m < N; m++)
    {
      if(m != n)
      {
        float distance = PVector.dist(pos[n], pos[m]);
        float weight = 1.0 / sq(distance);
        totalWeight += weight;
        
        if(Separation)
        {
          if(distance < SeparationBehaviorRange)
          {
            PVector separationAcc = PVector.sub(pos[m], pos[n]);
            separationAcc.setMag(-SeparationPower * 1.0 / sq(distance));
            acc[n] = PVector.add(acc[n], separationAcc);
          }
        }
        
        if(Cohesion)
        {
          
          PVector weightedPos = PVector.mult(pos[m], weight);
          weightedCenter = PVector.add(weightedCenter, weightedPos);
        }
        
        if(Alignment)
        {
          PVector weightedVel = PVector.mult(vel[m], weight);
          weightedAverageVel = PVector.add(weightedAverageVel, weightedVel);
        }
        
      }
    }
    
    if(Cohesion)
    {
      weightedCenter = PVector.mult(weightedCenter, 1.0 / totalWeight);
      acc[n] = PVector.add(acc[n], accelerationFromToMag(pos[n], weightedCenter, CohesionPower));
    }
    if(Alignment)
    {
      weightedAverageVel = PVector.mult(weightedAverageVel, 1.0 / totalWeight);
      PVector headingError = PVector.sub(weightedAverageVel, vel[n]);
      acc[n] = PVector.add(acc[n], PVector.mult(headingError, AlignmentPower));
    }
    
    // mouse
    if(mousePressed)
    {
      PVector mouseAcc = new PVector(pos[n].x - mouseX, pos[n].y - mouseY);
      mouseAcc.setMag(mouseMode * mousePower);
      acc[n] = PVector.add(acc[n], mouseAcc); 
    }
    
    // randomness
    if(Wander)
      acc[n] = PVector.add(acc[n], randomVector(0.0, 100.0));
    
    /***** velocity *****/
    vel[n] = PVector.mult(PVector.add(vel[n], PVector.mult(acc[n], dt)), VelocityDamping);
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
  
  
}

void keyPressed() {
  switch(key)
  {
    case 'a': case'A': mouseMode = MouseModeAttract; break;
    case 'r': case'R': mouseMode = MouseModeRepulse; break;
    
    // s,S - Cause all creatures to be instantly scattered to random positions in the window.
    // p,P - Toggle whether to have creatures leave a path, that is, whether the window is cleared each display step or not.
    case 'p': case 'P': trail = !trail; break;
    
    // c,C - Clear the window (useful when creatures are leaving paths).
    case 'c': case 'C': clearOnce = true; break;
    
    case '1': Cohesion   = !Cohesion;   break;
    case '2': Alignment  = !Alignment;  break;
    case '3': Separation = !Separation; break;
    case '4': Wander     = !Wander;     break;
    
    // =,+ - Add one new creature to the simulation. You should allow up to 100 creatures to be created.
    // - (minus sign) - Remove one new creature from the simulation (unless there are none already).
    // space bar - Start or stop the simulation (toggle between these).
    case ' ': paused = !paused; break;
    
    default:
  }
}
