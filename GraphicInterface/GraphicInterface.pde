Canvas canvas;
Pen pen;
Button b;
ArrayList<Button> buttons; //Maybe use a hashmap instead

void setup() {
  frameRate(1000);
  size(1200, 800);
  background(100,100,100);
  canvas = new Canvas(700, 500,50,50);
  pen = new Pen();
  b = new Button(800,100,100,100,color(0),"hi",850,150);
  buttons = new ArrayList<>();
}

void draw() {
  background(100,100,100);
  canvas.display();
  canvas.edit(pen);
  pen.updatePosition(mouseX, mouseY);
  if(mouseX >= canvas.location.x && mouseX < canvas.location.x + canvas.dimensions.x && mouseY >= canvas.location.y && mouseY < canvas.location.y + canvas.dimensions.y){
    pen.drawCursor(g);
  }
  b.display();
  buttons.add(b);
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