class Pen {
  PVector position;
  boolean isDrawing;
  int radius;
  boolean isEraser;

  Pen() {
    position = new PVector(0, 0);
    isDrawing = false;
    isEraser = false;
    radius = 15;
  }

  void updatePosition(float x, float y) {
    position.set(x, y);
  }

  void startDrawing() {
    isDrawing = true;
  }

  void stopDrawing() {
    isDrawing = false;
  }

  void setEraser(boolean val) {
    isEraser = val;
  }

  void drawCursor(PGraphics pg) {
    pg.pushStyle();
    pg.noFill();
    pg.stroke(isEraser ? 140 : 0);
    pg.strokeWeight(2);
    pg.circle(position.x, position.y, radius * 2);
    pg.popStyle();
  }
}
