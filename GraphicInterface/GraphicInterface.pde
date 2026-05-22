Canvas canvas;
Pen pen;
Game game;
ArrayList<ItemButton> itemButtons;

void setup() {
  frameRate(60);
  size(1200, 800);
  background(100,100,100);
  canvas = new Canvas(700, 500,50,50);
  pen = new Pen();
  game = new Game();
  itemButtons = new ArrayList<>();
  createItemButtons();
}

void draw() {
  background(100,100,100);
  game.update();
  canvas.display();
  if(!pen.isDrawing){
    pen.updatePosition(mouseX, mouseY);
  }
  if(game.drawingRound && mouseX >= canvas.location.x && mouseX < canvas.location.x + canvas.dimensions.x && mouseY >= canvas.location.y && mouseY < canvas.location.y + canvas.dimensions.y){
    pen.drawCursor(g);
  }
  displayGameInfo();
  displayItemChoices();
}

void createItemButtons(){
  itemButtons.clear();
  int buttonX = 820;
  int buttonY = 160;
  int buttonW = 260;
  int buttonH = 70;
  int gap = 18;

  // Build one button per visible word choice so clicks can be checked by bounds.
  for(int i = 0; i < game.itemChoices.size(); i++){
    itemButtons.add(new ItemButton(game.itemChoices.get(i), buttonX, buttonY + i * (buttonH + gap), buttonW, buttonH));
  }
}

void displayGameInfo(){
  pushStyle();
  fill(255);
  textSize(26);
  textAlign(LEFT, TOP);
  if(game.choosingItem){
    text("Choose a word to draw", 820, 90);
  } else if(game.drawingRound){
    text("Draw: " + game.currentItem, 820, 90);
    text("Time: " + game.remainingSeconds(), 820, 122);
  } else {
    text("Time's up!", 820, 90);
    text("Word: " + game.currentItem, 820, 122);
  }
  popStyle();
}

void displayItemChoices(){
  if(!game.choosingItem){
    return;
  }

  for(ItemButton itemButton : itemButtons){
    itemButton.display();
  }
}

void mousePressed() {
  if(game.choosingItem){
    // Use button boundaries to choose the clicked word before the drawing timer starts.
    for(ItemButton itemButton : itemButtons){
      if(itemButton.containsPoint(mouseX, mouseY)){
        itemButton.pressed();
        game.selectItem(itemButton.getItem());
        canvas.clear();
        return;
      }
    }
  }

  if(!game.drawingRound){
    return;
  }

  pen.updatePosition(mouseX, mouseY);
  pen.startDrawing();
  canvas.edit(pen);
}

void mouseReleased() {
  if(game.drawingRound && pen.isDrawing){
    pen.updatePosition(mouseX, mouseY);
    canvas.edit(pen);
  }
  pen.stopDrawing();
}

void mouseDragged() {
  if(!game.drawingRound || !pen.isDrawing){
    return;
  }

  // Draw on every drag event so quick movements do not get dropped between frames.
  pen.updatePosition(mouseX, mouseY);
  canvas.edit(pen);
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
