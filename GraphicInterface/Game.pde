class Game{
    // don't create a new items arraylist for every game bruh
    // create the list once in graphic interface maybe

    float score;
    ArrayList<String> items;
    ArrayList<String> itemChoices;
    String currentItem;
    int numChoices = 3;

    Game(){
        score = 0;
        items = new ArrayList<>();
        loadItems();
        itemChoices = new ArrayList<>();
        newItems();
    }

    void loadItems(){
        // Put all possible items in the list from a file
    }

    ArrayList<String> newItems(){
        itemChoices = new ArrayList<>();
        for(int i = 0; i < numChoices; i++){
            itemChoices.set(i,items.get((int) (items.size() * Math.random())));
        }
        return itemChoices;
    }
}