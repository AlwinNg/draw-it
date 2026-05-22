class Game{
    float score;
    ArrayList<String> items;
    ArrayList<String> itemChoices;
    String currentItem;
    int numChoices = 5;
    int roundLengthSeconds = 60;
    int roundStartMillis;
    boolean choosingItem;
    boolean drawingRound;

    Game(){
        score = 0;
        items = new ArrayList<>();
        loadItems();
        itemChoices = new ArrayList<>();
        startChoosing();
    }

    void loadItems(){
        // Temporary word bank; later this can be replaced with a larger file-backed list.
        items.add("apple");
        items.add("house");
        items.add("robot");
        items.add("guitar");
        items.add("mountain");
    }

    void startChoosing(){
        currentItem = "";
        choosingItem = true;
        drawingRound = false;
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
        return itemChoices;
    }

    void selectItem(String item){
        currentItem = item;
        choosingItem = false;
        drawingRound = true;
        roundStartMillis = millis();
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
            drawingRound = false;
        }
    }
}
