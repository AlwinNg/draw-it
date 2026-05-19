class Canvas {
  PImage canvas;
  PVector location;
  PVector dimensions;

  Canvas(int w, int h, int x, int y) {
    canvas = createImage(w,h,RGB);
    for (int i = 0; i < canvas.pixels.length; i++) {
      canvas.pixels[i] = color(256, 256, 256); 
    }
    canvas.loadPixels();
    location = new PVector(x,y);
    dimensions = new PVector(w,h);
  }

  void display() {
    canvas.updatePixels();
    image(canvas, location.x, location.y);
    
  }

  void edit(Pen pen) {
    if (!pen.isDrawing) {
      return;
    }
    
    int x = mouseX;
    int y = mouseY; 

    int r = pen.radius;

    for(int i = -r; i <= r; i++){
      for(int j = -r; j <= r; j++){
        int pX = x + i;
        int pY = y + j;
        if(pX >= location.x && pX < location.x + dimensions.x && pY >= location.y && pY < location.y + dimensions.y){
          if(Math.pow(pX - x,2) + Math.pow(pY - y, 2) < Math.pow(r,2)){
            canvas.pixels[(pY - (int)location.y) * canvas.width + pX - (int)location.x] = pen.getPaintColor();
          }
        }

      }

    }

    // pg.beginDraw();
    // pg.noStroke();
    // pg.fill(pen.getPaintColor());
    // pg.circle(pen.position.x, pen.position.y, pen.getDiameter());
    // pg.endDraw();
  }

  // int[] getPixels() {
  //   pg.loadPixels();
  //   return pg.pixels;
  // }

  // void clear() {
  //   pg.beginDraw();
  //   pg.background(255);
  //   pg.endDraw();
  // }
  void clear(){
    for (int i = 0; i < canvas.pixels.length; i++) {
      canvas.pixels[i] = color(256, 256, 256); 
    }
    canvas.loadPixels();
  }
}
