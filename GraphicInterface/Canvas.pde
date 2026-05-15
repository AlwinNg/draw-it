import Pen;

class Canvas{
    PImage canvas;
    PVector dimensions;
    Pen pen;

    Canvas(int w, int h){
        canvas = createImage(w,h,RGB);
        
        dimensions = new PVector(w,h);
    }

    void edit(Pen pen){
        int x = mouseX;
        int y = mouseY;
        if (pen.isDrawing) {
            r = pen.radius;
            
        }

    }
}