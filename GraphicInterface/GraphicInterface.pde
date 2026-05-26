import java.util.*;
import java.io.*;

Canvas canvas;
Pen pen;
Game game;
ArrayList<ItemButton> itemButtons;
int displayedChoiceVersion = -1;
String currentPrediction = "unknown";

import ai.onnxruntime.*;

OrtSession session;
OrtEnvironment env;
String[] labels;

void setup() {
  frameRate(60);
  size(1200, 800);
  background(100,100,100);
  canvas = new Canvas(700, 500,50,50);
  pen = new Pen();
  loadModel();
  game = new Game();
  itemButtons = new ArrayList<>();
  syncItemButtons();

}

void draw() {
  background(35, 39, 47);
  game.update();
  syncItemButtons();
  updatePrediction();
  checkCorrectPrediction();
  drawLayout();
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

void syncItemButtons(){
  if(game.choosingItem && displayedChoiceVersion != game.choiceSetVersion){
    createItemButtons();
    displayedChoiceVersion = game.choiceSetVersion;
  }
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

void drawLayout(){
  pushStyle();
  noStroke();
  fill(245);
  rect(canvas.location.x - 8, canvas.location.y - 8, canvas.dimensions.x + 16, canvas.dimensions.y + 16, 8);
  fill(22, 25, 31);
  rect(790, 50, 350, 660, 8);
  fill(51, 58, 70);
  rect(815, 460, 300, 1);
  popStyle();
}

void displayGameInfo(){
  pushStyle();
  textAlign(LEFT, TOP);
  fill(255);
  textSize(30);
  if(game.choosingItem){
    text("Choose a word", 820, 85);
  } else if(game.drawingRound){
    fill(180, 207, 255);
    textSize(18);
    text("Draw", 820, 82);
    fill(255);
    textSize(34);
    text(game.currentItem, 820, 108);
    textSize(22);
    fill(230);
    text("Time: " + game.remainingSeconds(), 820, 160);
    fill(124, 223, 172);
    text("I predict: " + currentPrediction, 820, 198);
  } else {
    fill(255);
    textSize(28);
    text(game.roundMessage, 820, 90, 290, 90);
    textSize(20);
    fill(220);
    text("Next round starting...", 820, 185);
  }

  textSize(16);
  fill(180);
  text("E: eraser", 820, 490);
  text("C: clear", 820, 518);
  text("[ / ]: brush size", 820, 546);
  text("Brush: " + pen.radius, 820, 592);
  text("Mode: " + (pen.isEraser ? "eraser" : "draw"), 820, 620);
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

void updatePrediction(){
  if(game.drawingRound){
    currentPrediction = classify(canvas.canvas);
  } else if(game.choosingItem){
    currentPrediction = "unknown";
  }
}

void checkCorrectPrediction(){
  if(game.drawingRound && canvas.hasInk && currentPrediction.equals(game.currentItem)){
    game.correctGuess(currentPrediction);
    pen.stopDrawing();
  }
}

String classify(PImage canvas) {
  if(env == null || session == null || labels == null || labels.length == 0){
    return "unknown";
  }

  PImage small = canvas.get();
  small.resize(28, 28);
  small.loadPixels();
  
  float[][][][] input = new float[1][1][28][28];
  for (int y = 0; y < 28; y++) {
    for (int x = 0; x < 28; x++) {
      input[0][0][y][x] = 1.0 - brightness(small.pixels[y*28+x]) / 255.0;
    }
  }
  
  try {
    OnnxTensor tensor = OnnxTensor.createTensor(env, input);
    OrtSession.Result result = session.run(
      Collections.singletonMap("image", tensor));
    float[] scores = ((float[][]) result.get(0).getValue())[0];
    
    int best = 0;
    for (int i = 1; i < scores.length; i++)
      if (scores[i] > scores[best]) best = i;
    if(best < 0 || best >= labels.length){
      return "unknown";
    }
    return labels[best];
  } catch (Exception e) {
    println(e); return "unknown";
  }

  
}
void loadModel() {
  try {
    env = OrtEnvironment.getEnvironment();    
    String modelPath = sketchPath("data/sketch_model.onnx");    
    File f = new File(modelPath);
    if (!f.exists()) {
      return;
    }    
    session = env.createSession(modelPath);    
    labels = loadStrings("labels.txt");
    if (labels == null || labels.length == 0) {
      return;
    }    
  } catch (Exception e) {
    println("error");
    e.printStackTrace();
  }
}
