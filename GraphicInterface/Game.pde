import java.util.*;
import java.io.*;

class Game{
    int score;
    int lastRoundScore;
    ArrayList<String> items;
    ArrayList<String> itemChoices;
    String currentItem;
    String roundMessage;
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

    Game(){
        score = 0;
        lastRoundScore = 0;
        items = new ArrayList<>();
        loadItems();
        itemChoices = new ArrayList<>();
        startChoosing();
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
        choosingItem = true;
        drawingRound = false;
        showingResult = false;
        gameOver = false;
        newItems();
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
        roundMessage = "Correct! I guessed " + prediction + ". +" + lastRoundScore;
        drawingRound = false;
        showingResult = true;
        resultStartMillis = millis();
    }

    void timeUp(){
        lastRoundScore = -timeUpPenalty;
        score = Math.max(0,score + lastRoundScore);
        roundMessage = "Time's up! +" + lastRoundScore;
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
        choosingItem = false;
        drawingRound = false;
        showingResult = false;
        gameOver = true;
    }

    void resetGame(){
        score = 0;
        lastRoundScore = 0;
        roundNumber = 0;
        gameOver = false;
        startChoosing();
    }

    void update(){
        if(gameOver){
            return;
        }

        if(drawingRound && remainingSeconds() == 0){
            timeUp();
        }

        if(showingResult && millis() - resultStartMillis >= resultLengthMillis){
            startChoosing();
        }
    }
}
