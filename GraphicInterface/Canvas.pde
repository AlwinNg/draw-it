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
    pg.fill(pen.getPaintColor());
    pg.circle(pen.position.x, pen.position.y, pen.getDiameter());
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
