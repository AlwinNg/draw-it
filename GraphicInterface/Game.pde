class Game{
    float score;
    ArrayList<String> items;
    ArrayList<String> itemChoices;
    String currentItem;
    int numChoices = 3;

    Game(){
        score = 0;
        newItems();
        items = new ArrayList<>();
        loadItems();
    }

    void loadItems(){
        // Put all possible items in the list from a file
    }

    void newItems(){
        itemChoices = new ArrayList<>();
        for(int i = 0; i < numChoices; i++){
            itemChoices.set(i,items.get((int) (items.size() * Math.random())));
        }
        displayItemChoices();
    }

    void displayItemChoices(){
        for(String item : itemChoices){
            
        }
    }
}