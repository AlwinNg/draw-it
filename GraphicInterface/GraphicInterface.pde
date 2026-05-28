import java.util.*;
import java.io.*;

Canvas canvas;
Pen pen;
Game game;
ArrayList<ItemButton> itemButtons;
int displayedChoiceVersion = -1;
String currentPrediction = "unknown";
int infoX = 1020;

import ai.onnxruntime.*;

OrtSession session;
OrtEnvironment env;
String[] labels;

void setup() {
  frameRate(60);
  size(1500, 1000);
  background(100,100,100);
  canvas = new Canvas(900, 900,50,50);
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
  // drawLayout();
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
  int buttonX = infoX;
  int buttonY = 160;
  int buttonW = 260;
  int buttonH = 70;
  int gap = 18;

  // make one button for each choice
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
  if(!game.choosingItem){
    fill(51, 58, 70);
    rect(815, 460, 300, 1);
  }
  popStyle();
}

void displayGameInfo(){
  pushStyle();
  textAlign(LEFT, TOP);
  fill(255);
  textSize(30);
  if(game.choosingItem){
    text("Choose a word", infoX, 85);
    textSize(18);
    fill(180);
    text("Round " + (game.roundNumber + 1) + " of " + game.totalRounds, infoX, 125);
    text("Score: " + game.score, infoX, 600);
    text("Lower score wins", infoX, 630);
  } else if(game.drawingRound){
    fill(180, 207, 255);
    textSize(18);
    text("Round " + game.roundNumber + " of " + game.totalRounds, infoX, 82);
    fill(255);
    textSize(34);
    text(game.currentItem, infoX, 108);
    textSize(22);
    fill(230);
    text("Time: " + game.remainingSeconds(), infoX, 160);
    text("Score: " + game.score, infoX, 192);
    fill(124, 223, 172);
    text("I predict: " + currentPrediction, infoX, 230);
  } else if(game.showingResult){
    fill(255);
    textSize(28);
    text(game.roundMessage, infoX, 90, 290, 90);
    textSize(20);
    fill(220);
    text("Score: " + game.score, infoX, 185);
    if(game.roundNumber < game.totalRounds){
      text("Next round starting...", infoX, 220);
    } else {
      text("Finishing game...", infoX, 220);
    }
  } else if(game.gameOver){
    fill(255);
    textSize(30);
    text("Game over", infoX, 90);
    textSize(24);
    text("Final score: " + game.score, infoX, 140);
    textSize(18);
    fill(180);
    text("Lower is better", infoX, 180);
    text("Press R to play again", infoX, 220);
  }

  if(!game.choosingItem && !game.gameOver){
    textSize(16);
    fill(180);
    text("E: switch to " + (pen.isEraser ? "draw" : "eraser"), infoX, 490);
    text("C: clear", infoX, 518);
    text("[: smaller brush", infoX, 546);
    text("]: bigger brush", infoX, 574);
    text("Brush: " + pen.radius, infoX, 610);
    text("Mode: " + (pen.isEraser ? "eraser" : "draw"), infoX, 638);
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
    // check button bounds before the timer starts
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

  // draw on every drag event
  pen.updatePosition(mouseX, mouseY);
  canvas.edit(pen);
}

void keyPressed() {
  if (key == 'e' || key == 'E') {
    pen.toggleEraser();
  } else if (key == 'c' || key == 'C') {
    canvas.clear();
  } else if (key == 'r' || key == 'R') {
    game.resetGame();
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
    String modelPath = sketchPath("data2/sketch_model.onnx");    
    File f = new File(modelPath);
    if (!f.exists()) {
      return;
    }    
    session = env.createSession(modelPath);    
    labels = loadStrings("categories.txt");
    if (labels == null || labels.length == 0) {
      return;
    }    
  } catch (Exception e) {
    println("error");
    e.printStackTrace();
  }
}
