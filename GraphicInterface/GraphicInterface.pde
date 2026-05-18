Canvas canvas;
Pen pen;

void setup() {
  size(800, 600);
  canvas = new Canvas(700, 500,50,50);
  pen = new Pen();
}

void draw() {
  frameRate(120);
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
    pen.toggleEraser();
  } else if (key == 'c' || key == 'C') {
    canvas.clear();
  } else if (key == '[') {
    pen.changeRadius(-2);
  } else if (key == ']') {
    pen.changeRadius(2);
  } else if (key == '0') {
    pen.resetRadius();
  }
}
