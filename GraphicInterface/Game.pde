import java.util.*;
import java.io.*;

class Game{
    float score;
    ArrayList<String> items;
    ArrayList<String> itemChoices;
    String currentItem;
    String roundMessage;
    int numChoices = 5;
    int roundLengthSeconds = 20;
    int roundStartMillis;
    int resultStartMillis;
    int resultLengthMillis = 1200;
    int choiceSetVersion;
    boolean choosingItem;
    boolean drawingRound;
    boolean showingResult;

    Game(){
        score = 0;
        items = new ArrayList<>();
        loadItems();
        itemChoices = new ArrayList<>();
        startChoosing();
    }

    void loadItems(){
        String[] supportedLabels = loadStrings("labels.txt");
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
        currentItem = "";
        roundMessage = "";
        choosingItem = true;
        drawingRound = false;
        showingResult = false;
        newItems();
    }

    ArrayList<String> newItems(){
        itemChoices = new ArrayList<>();
        ArrayList<String> availableItems = new ArrayList<>(items);

        // Pick unique options from the bank until the choice list is full.
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
        roundMessage = "";
        roundStartMillis = millis();
    }

    void correctGuess(String prediction){
        roundMessage = "Correct! I guessed " + prediction + ".";
        drawingRound = false;
        showingResult = true;
        resultStartMillis = millis();
    }

    void timeUp(){
        roundMessage = "Time's up!";
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

    void update(){
        if(drawingRound && remainingSeconds() == 0){
            timeUp();
        }

        if(showingResult && millis() - resultStartMillis >= resultLengthMillis){
            startChoosing();
        }
    }
}
