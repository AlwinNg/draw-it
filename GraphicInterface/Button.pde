class Button{
    PVector location;
    PVector dimensions;
    color fillColor;
    String text;
    PVector textLocation;

    Button(int x, int y, int w, int h, color c, String text, int tX, int tY){
        location = new PVector(x,y);
        dimensions = new PVector(w,h);
        fillColor = c;
        this.text = text;
        textLocation = new PVector(tX,tY);
    }

    void display(){
        pushStyle();
        fill(fillColor);
        rect((int) location.x, (int) location.y, (int) dimensions.x, (int) dimensions.y);
        fill(color(255));
        textAlign(CENTER, CENTER);
        text(text, textLocation.x, textLocation.y);
        popStyle();
    }

    boolean containsPoint(float x, float y){
        return x >= location.x && x <= location.x + dimensions.x &&
               y >= location.y && y <= location.y + dimensions.y;
    }

    void pressed(){
    }

}
