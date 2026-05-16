class Canvas {
  PGraphics pg;

  Canvas(int w, int h) {
    pg = createGraphics(w, h);
    clear();
  }

  void display() {
    image(pg, 0, 0);
  }

  void edit(Pen pen) {
    if (!pen.isDrawing) {
      return;
    }

    pg.beginDraw();
    pg.noStroke();
    pg.fill(pen.isEraser ? 255 : 0);
    pg.circle(pen.position.x, pen.position.y, pen.radius * 2);
    pg.endDraw();
  }

  int[] getPixels() {
    pg.loadPixels();
    return pg.pixels;
  }

  void clear() {
    pg.beginDraw();
    pg.background(255);
    pg.endDraw();
  }
}
