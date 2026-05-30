import java.util.*;
import java.io.*;
import ai.onnxruntime.*;

Canvas canvas;
Pen pen;
Game game;
ArrayList<ItemButton> itemButtons;
Button clearButton;
Button eraserButton;
Button startButton;
OrtSession session;
OrtEnvironment env;
String[] labels;

int displayedChoiceVersion = -1;
String currentPrediction = "unknown";
int infoX = 1020;

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
  clearButton = new Button(1020,275,150,50,0,"Clear",1095,300);
  startButton = new Button(infoX, 535, 210, 58, color(45, 125, 95), "Start", infoX + 105, 564);
}

void draw() {
  background(35, 39, 47);
  syncItemButtons();
  updatePrediction();
  checkCorrectPrediction();
  game.update(currentPrediction);
  canvas.display();
  if(!pen.isDrawing){
    pen.updatePosition(mouseX, mouseY);
  }
  if(game.drawingRound && mouseX >= canvas.location.x && mouseX < canvas.location.x + canvas.dimensions.x && mouseY >= canvas.location.y && mouseY < canvas.location.y + canvas.dimensions.y){
    pen.drawCursor(g);
  }
  displayGameInfo();
  displayGameButtons();
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

void displayGameInfo(){
  pushStyle();
  textAlign(LEFT, TOP);
  fill(255);
  textSize(30);
  if(game.startScreen){
    displayStartScreen();
  } else if(game.choosingItem){
    text("Choose a word", infoX, 85);
    textSize(18);
    fill(180);
    text("Round " + (game.roundNumber + 1) + " of " + game.totalRounds, infoX, 125);
    text("Score: " + game.score, infoX, 600);
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
    displayRoundResult();
  } else if(game.gameOver){
    fill(255);
    textSize(30);
    text("Game over", infoX, 90);
    textSize(24);
    text("Final score: " + game.score, infoX, 140);
    displayScoreHistory(195);
    textSize(18);
    fill(180);
    text("Press R to play again", infoX, 650);
  }

  if(!game.startScreen && !game.choosingItem && !game.gameOver){
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

void displayStartScreen(){
  fill(180, 207, 255);
  textSize(18);
  text("AI drawing game", infoX, 82);
  fill(255);
  textSize(42);
  text("Draw It", infoX, 108);
  textSize(20);
  fill(220);
  text("Pick a word, draw it before time runs out, and score when the model guesses correctly.", infoX, 175, 330, 105);

  fill(124, 223, 172);
  textSize(18);
  text("5 rounds", infoX, 310);
  text("20 seconds each", infoX, 340);
  text("Faster guesses score more", infoX, 370);

  fill(180);
  textSize(16);
  text("Press SPACE or click Start", infoX, 445);
  text("E eraser   C clear   [ ] brush size", infoX, 475);
}

void displayRoundResult(){
  color panelColor = game.roundSucceeded ? color(40, 94, 71) : color(111, 67, 44);
  color accentColor = game.roundSucceeded ? color(124, 223, 172) : color(255, 167, 96);
  fill(panelColor);
  noStroke();
  rect(infoX - 12, 82, 330, 210, 8);

  fill(accentColor);
  textSize(18);
  text(game.roundSucceeded ? "Round complete" : "Time ran out", infoX, 100);
  fill(255);
  textSize(28);
  text(game.roundMessage, infoX, 132, 290, 70);
  textSize(18);
  fill(225);
  text("Word: " + game.currentItem, infoX, 205);
  text("Last guess: " + game.resultPrediction, infoX, 235);
  text("Score: " + game.score, infoX, 265);

  float progress = constrain((millis() - game.resultStartMillis) / (float) game.resultLengthMillis, 0, 1);
  fill(70, 75, 86);
  rect(infoX, 320, 260, 10, 5);
  fill(accentColor);
  rect(infoX, 320, 260 * progress, 10, 5);
  fill(180);
  textSize(16);
  if(game.roundNumber < game.totalRounds){
    text("Next round starting...", infoX, 350);
  } else {
    text("Finishing game...", infoX, 350);
  }
}

void displayScoreHistory(int yStart){
  fill(180, 207, 255);
  textSize(18);
  text("Round history", infoX, yStart);
  textSize(15);
  int y = yStart + 34;
  for(RoundResult result : game.scoreHistory){
    fill(result.guessed ? color(124, 223, 172) : color(255, 167, 96));
    String sign = result.points >= 0 ? "+" : "";
    text("R" + result.roundNumber + "  " + result.item + "  " + sign + result.points, infoX, y);
    fill(175);
    text(result.guessed ? "guessed " + result.prediction : "last guess " + result.prediction, infoX + 18, y + 22);
    y += 58;
  }
}

void displayGameButtons(){
  if(game.startScreen){
    startButton.display();
    return;
  }

  if(!game.choosingItem){
    if(game.drawingRound){
      clearButton.display();
    }
    return;
  }

  for(ItemButton itemButton : itemButtons){
    itemButton.display();
  }
}

void mousePressed() {
  if(game.startScreen){
    if(startButton.containsPoint(mouseX, mouseY)){
      game.startGame();
      canvas.clear();
    }
    return;
  }

  if(game.choosingItem){
    for(ItemButton itemButton : itemButtons){
      if(itemButton.containsPoint(mouseX, mouseY)){
        itemButton.pressed();
        game.selectItem(itemButton.getItem());
        canvas.clear();
        return;
      }
    }
  }

  if(game.drawingRound){
    if(clearButton.containsPoint(mouseX,mouseY)){
      canvas.clear();
    }
  } else{
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

  pen.updatePosition(mouseX, mouseY);
  canvas.edit(pen);
}

void keyPressed() {
  if(game.startScreen && key == ' '){
    game.startGame();
    canvas.clear();
  } else if (key == 'e' || key == 'E') {
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
    updateClassification(canvas.canvas);
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

void updateClassification(PImage canvas) {
  if(env == null || session == null || labels == null || labels.length == 0){
    currentPrediction = "unknown";
    return;
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
      currentPrediction = "unknown";
      return;
    }
    currentPrediction = labels[best];
  } catch (Exception e) {
    println(e);
    currentPrediction = "unknown";
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
    labels = loadStrings("categories.txt");
    if (labels == null || labels.length == 0) {
      return;
    }    
  } catch (Exception e) {
    println("error");
    e.printStackTrace();
  }
}
