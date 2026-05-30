import java.util.*;
import java.io.*;

class Game{
    int score;
    int lastRoundScore;
    ArrayList<String> items;
    ArrayList<String> itemChoices;
    ArrayList<RoundResult> scoreHistory;
    String currentItem;
    String roundMessage;
    String resultPrediction;
    int numChoices = 5;
    int totalRounds = 5;
    int roundNumber;
    int roundLengthSeconds = 20;
    int timeUpPenalty = 10;
    int roundStartMillis;
    int resultStartMillis;
    int resultLengthMillis = 1600;
    int choiceSetVersion;
    boolean choosingItem;
    boolean drawingRound;
    boolean showingResult;
    boolean gameOver;
    boolean startScreen;
    boolean roundSucceeded;

    Game(){
        score = 0;
        lastRoundScore = 0;
        items = new ArrayList<>();
        loadItems();
        itemChoices = new ArrayList<>();
        scoreHistory = new ArrayList<>();
        showStartScreen();
    }

    void loadItems(){
        String[] supportedLabels = loadStrings("categories.txt");
        if(supportedLabels != null){
            for(String label : supportedLabels){
                if(label != null && label.trim().length() > 0){
                    items.add(label.trim());
                }
            }
        }

        if(items.size() == 0){
            items.add("cat");
            items.add("dog");
            items.add("house");
            items.add("car");
            items.add("tree");
        }
    }

    void startChoosing(){
        if(roundNumber >= totalRounds){
            finishGame();
            return;
        }

        currentItem = "";
        roundMessage = "";
        resultPrediction = "";
        startScreen = false;
        choosingItem = true;
        drawingRound = false;
        showingResult = false;
        gameOver = false;
        newItems();
    }

    void showStartScreen(){
        currentItem = "";
        roundMessage = "";
        resultPrediction = "";
        startScreen = true;
        choosingItem = false;
        drawingRound = false;
        showingResult = false;
        gameOver = false;
    }

    void startGame(){
        score = 0;
        lastRoundScore = 0;
        roundNumber = 0;
        scoreHistory.clear();
        startChoosing();
    }

    ArrayList<String> newItems(){
        itemChoices = new ArrayList<>();
        ArrayList<String> availableItems = new ArrayList<>(items);

        // pick unique choices from the current labels
        while(itemChoices.size() < numChoices && availableItems.size() > 0){
            int index = (int) random(availableItems.size());
            itemChoices.add(availableItems.remove(index));
        }
        choiceSetVersion++;
        return itemChoices;
    }

    void selectItem(String item){
        currentItem = item;
        choosingItem = false;
        drawingRound = true;
        showingResult = false;
        gameOver = false;
        roundMessage = "";
        roundNumber++;
        roundStartMillis = millis();
    }

    void correctGuess(String prediction){
        lastRoundScore = roundLengthSeconds - elapsedSeconds();
        score += lastRoundScore;
        resultPrediction = prediction;
        roundSucceeded = true;
        roundMessage = "Correct! I guessed " + prediction + ". +" + lastRoundScore;
        scoreHistory.add(new RoundResult(roundNumber, currentItem, prediction, true, lastRoundScore, score));
        drawingRound = false;
        showingResult = true;
        resultStartMillis = millis();
    }

    void timeUp(String prediction){
        lastRoundScore = -timeUpPenalty;
        score = Math.max(0,score + lastRoundScore);
        resultPrediction = prediction;
        roundSucceeded = false;
        roundMessage = "Time's up! -" + timeUpPenalty;
        scoreHistory.add(new RoundResult(roundNumber, currentItem, prediction, false, lastRoundScore, score));
        drawingRound = false;
        showingResult = true;
        resultStartMillis = millis();
    }

    int remainingSeconds(){
        if(!drawingRound){
            return roundLengthSeconds;
        }

        int elapsedSeconds = (millis() - roundStartMillis) / 1000;
        return max(0, roundLengthSeconds - elapsedSeconds);
    }

    int elapsedSeconds(){
        if(!drawingRound){
            return 0;
        }

        return max(1, (millis() - roundStartMillis + 999) / 1000);
    }

    void finishGame(){
        currentItem = "";
        roundMessage = "Final score: " + score;
        startScreen = false;
        choosingItem = false;
        drawingRound = false;
        showingResult = false;
        gameOver = true;
    }

    void resetGame(){
        startGame();
    }

    void update(String prediction){
        if(startScreen || gameOver){
            return;
        }

        if(drawingRound && remainingSeconds() == 0){
            timeUp(prediction);
        }

        if(showingResult && millis() - resultStartMillis >= resultLengthMillis){
            startChoosing();
        }
    }
}

class RoundResult{
    int roundNumber;
    String item;
    String prediction;
    boolean guessed;
    int points;
    int scoreAfter;

    RoundResult(int roundNumber, String item, String prediction, boolean guessed, int points, int scoreAfter){
        this.roundNumber = roundNumber;
        this.item = item;
        this.prediction = prediction;
        this.guessed = guessed;
        this.points = points;
        this.scoreAfter = scoreAfter;
    }
}
