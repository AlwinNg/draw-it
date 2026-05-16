Canvas canvas;
Pen pen;

void setup() {
  size(600, 600);
  canvas = new Canvas(width, height);
  pen = new Pen();
}

void draw() {
  canvas.display();
  canvas.edit(pen);
  pen.updatePosition(mouseX, mouseY);
  pen.drawCursor(g);
}

void mousePressed() {
  pen.updatePosition(mouseX, mouseY);
  pen.startDrawing();
}

void mouseReleased() {
  pen.stopDrawing();
}

void mouseDragged() {
  pen.updatePosition(mouseX, mouseY);
}

void keyPressed() {
  if (key == 'e' || key == 'E') {
    pen.setEraser(!pen.isEraser);
  } else if (key == 'c' || key == 'C') {
    canvas.clear();
  } else if (key == '[') {
    pen.radius = max(2, pen.radius - 2);
  } else if (key == ']') {
    pen.radius = min(60, pen.radius + 2);
  }
}
