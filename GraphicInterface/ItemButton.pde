class ItemButton extends Button{
    String item;

    ItemButton(String item, int x, int y, int w, int h){
        super(x, y, w, h, color(45, 90, 150), item, x + w / 2, y + h / 2);
        this.item = item;
    }

    @Override
    void pressed(){
    }

    String getItem(){
        return item;
    }
}
