class Pen {
  static final int MIN_RADIUS = 2;
  static final int MAX_RADIUS = 60;
  static final int DEFAULT_RADIUS = 15;

  PVector position;
  boolean isDrawing;
  int radius;
  boolean isEraser;
  int drawColor;
  int eraserColor;
  int cursorDrawColor;
  int cursorEraserColor;

  Pen() {
    position = new PVector(0, 0);
    isDrawing = false;
    isEraser = false;
    radius = DEFAULT_RADIUS;
    drawColor = color(0);
    eraserColor = color(255);
    cursorDrawColor = color(0);
    cursorEraserColor = color(140);
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

  void toggleEraser() {
    isEraser = !isEraser;
  }

  void setRadius(int val) {
    radius = constrain(val, MIN_RADIUS, MAX_RADIUS);
  }

  void changeRadius(int amount) {
    setRadius(radius + amount);
  }

  void resetRadius() {
    radius = DEFAULT_RADIUS;
  }

  int getPaintColor() {
    return isEraser ? eraserColor : drawColor;
  }

  int getCursorColor() {
    return isEraser ? cursorEraserColor : cursorDrawColor;
  }

  float getDiameter() {
    return radius * 2;
  }

  boolean containsPoint(float x, float y) {
    return dist(position.x, position.y, x, y) <= radius;
  }

  void drawCursor(PGraphics pg) {
    pg.pushStyle();
    pg.noFill();
    pg.stroke(getCursorColor());
    pg.strokeWeight(2);
    pg.circle(position.x, position.y, getDiameter());
    pg.popStyle();
  }
}
