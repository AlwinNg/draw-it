// for creating the cursor drawing functionality. It will be used to draw the cursor on the canvas and to keep track of the cursor's position and state
// for example whether it's currently drawing or not).

class Pen{
    private PVector position;
    private boolean isDrawing;
    private PGraphics pg;
    private boolean isEraser;
    private int radius;

    void Pen(){
        position = new PVector(0, 0);
        isDrawing = false;
        isEraser = false;
        radius = 10;
    }

    void updatePosition(float x, float y){
        position.set(x, y);
    }

    void startDrawing(){
        isDrawing = true;
    }

    void stopDrawing(){
        isDrawing = false;
    }

    void draw(PGraphics pg){
        if(isDrawing){
            pg.ellipse(position.x, position.y, radius, radius); // draws a circle
        }
    }

    void isEraser(boolean eraser){
        isEraser = eraser;
        if (isEraser) {
            pg.erase(); // switch to erase mode
        } else {
            pg.noErase(); // switch back to normal drawing mode
        }
    }

    void erase(PGraphics pg){
        if(isEraser){
            pg.erase(); 
            pg.ellipse(position.x, position.y, radius, radius); // erase a circle
            pg.noErase();
        }
    }
    
    void noErase(PGraphics pg){
        pg.noErase();
    }

}