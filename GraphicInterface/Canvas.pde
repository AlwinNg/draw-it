class Canvas {
  PImage canvas;
  PVector location;
  PVector dimensions;
  boolean hasInk;

  Canvas(int w, int h, int x, int y) {
    canvas = createImage(w,h,RGB);
    for (int i = 0; i < canvas.pixels.length; i++) {
      canvas.pixels[i] = color(256, 256, 256); 
    }
    canvas.loadPixels();
    location = new PVector(x,y);
    dimensions = new PVector(w,h);
    hasInk = false;
  }

  void display() {
    canvas.updatePixels();
    image(canvas, location.x, location.y);
    
  }

  void edit(Pen pen) {
    if (!pen.isDrawing) {
      return;
    }

    if(!pen.isEraser){
      hasInk = true;
    }
    canvas.loadPixels();
    // Fill the space between mouse samples so fast strokes stay continuous.
    drawStrokeSegment(pen.previousPosition.x, pen.previousPosition.y, pen.position.x, pen.position.y, pen);
  }

  void drawStrokeSegment(float startX, float startY, float endX, float endY, Pen pen){
    float distance = dist(startX, startY, endX, endY);
    float stepSize = max(1, pen.radius / 2.0);
    int steps = max(1, ceil(distance / stepSize));

    for(int step = 0; step <= steps; step++){
      float amount = step / (float) steps;
      stampBrush(lerp(startX, endX, amount), lerp(startY, endY, amount), pen);
    }
  }

  void stampBrush(float x, float y, Pen pen){
    int r = pen.radius;
    int centerX = round(x);
    int centerY = round(y);
    int rSquared = r * r;

    for(int i = -r; i <= r; i++){
      for(int j = -r; j <= r; j++){
        int pX = centerX + i;
        int pY = centerY + j;
        if(pX >= location.x && pX < location.x + dimensions.x && pY >= location.y && pY < location.y + dimensions.y){
          if(i * i + j * j < rSquared){
            canvas.pixels[(pY - (int)location.y) * canvas.width + pX - (int)location.x] = pen.getPaintColor();
          }
        }
      }
    }
  }

  void clear(){
    for (int i = 0; i < canvas.pixels.length; i++) {
      canvas.pixels[i] = color(256, 256, 256); 
    }
    hasInk = false;
    canvas.loadPixels();
  }
}
