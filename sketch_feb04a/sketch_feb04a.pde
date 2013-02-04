int N = 50;

float[] x;
float[] y;

void setup()
{
  size(800, 800);
  background(255);

  x = new float[N];
  y = new float[N];
  
  for(int n = 0; n < N; n++)
  {
    x[n] = random(0, width);
    y[n] = random(0, height);
  }
}

void draw()
{
  color(0);
  fill(0);
  for(int n = 0; n < N; n++)
  {
    ellipse(x[n], y[n], 16, 16);
  }
}
