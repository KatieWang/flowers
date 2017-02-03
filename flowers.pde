
/*
** process: 
 * first figure out how to make a dots fall randomly across the screen/hover 
 a bit before the bottom of the page then fall 
 
 * then figure out how to make lines radiate out randomly from the dot before it
 (change endpoint!) x`
 
 * then figure out how to make the lines crawl towards their endpoints (SAVE THE OG POINT) 
 
 * then figure out how to make two curved lines come out and meet at the OG point 
 from each end point 
 
 * each line will once again crawl towards its endpooint
 
 * end point will create line going to end of the screen and crawl towards it 
 */
 import java.awt.geom.Point2D;

ArrayList<Flower> flowers;
ArrayList<Line> lines;
ArrayList<Curve> curves;
ArrayList<SLine> singleLine;

void setup() {
  fullScreen(P3D);

  flowers = new ArrayList<Flower>();
  lines = new ArrayList<Line>();
  curves = new ArrayList<Curve>();
  singleLine = new ArrayList<SLine>();
}

void draw() {
  background(0);
  if (frameCount%20 == 0) {
    flowers.add(new Flower());
  }

  for (int i = 0; i < flowers.size(); i++) {
    if(!flowers.get(i).check) { 
      flowers.get(i).update();
      flowers.get(i).display();
    } else {
      //maybe have some color expand here and remove it think about it
      flowers.remove(i);
    }
  }

    for (int l = 0; l<lines.size();l++) {
      if(!lines.get(l).check){
        lines.get(l).update();
        lines.get(l).display();
      } else {
        lines.remove(l);
      }
    }
    
    for(int c = 0; c < curves.size(); c++) {
      if(!curves.get(c).check2){
       curves.get(c).update();
       curves.get(c).display();
      } else {
        curves.remove(c);
      }
    }
    
    for(int s = 0; s < singleLine.size(); s++ ) {
      if(!singleLine.get(s).check) {
        singleLine.get(s).update();
        singleLine.get(s).display();
      }else {
        singleLine.remove(s);
      }
    }
    
    saveFrame("flower-######.tga");
 }



class Flower {
  float x, y, vy, stopHeight;
  float difference;
  boolean check;
  Flower() {


    check = false;
    x = random (0, displayWidth);
    y = 0;
    vy = random(1, 1.5);
    if(frameCount%30 == 0) {
      stopHeight = random(0, (displayHeight - (displayHeight/2.5)));
    } else {
    stopHeight = random((displayHeight - (displayHeight/2.5)), displayHeight);
    }
  }

  void update () {
    if (y < stopHeight) {
      y += vy;
      vy *= 1.04;
    } else {

   
      
      float linenum = random(3, 8); 
      if (check == false) { 
        for (int i = 0; i<linenum; i++) {
          lines.add(new Line(x, y));
        }
        check = true;
      }
    }
  }

  void display() {
    stroke(255);
    strokeWeight(2);
    pushMatrix(); 
    translate(x, y); 
    point(0, 0); 
    popMatrix();
  }
}

class Line {
  boolean check;
  //startpoint x, start point y, endpointx, endpoint y, angle of extruding line, 
  //speed at which line grows, maxlength of the line, current length of the line
  float sx, sy, ex, ey, theta, v, d, hx, hy, l, l2; 
  float x,y;
  Line(float x, float y) {
    this.x = x;
    this.y = y;
    check = false;
    sx = x;
    sy = y;
    ex = x;
    ey = y; 
    l = 0;
    theta = random(PI, 2*PI);
    v = random(.5, 1);
    d = random (displayHeight/10, displayHeight/6); 
    l2 = d;
    hy = sin(theta);
    hx = cos(theta);
  }

  void update() {
    if (l <d) {
      l = l+v; 
      ex = l*hx + sx;
      ey = l*hy + sy;
      v*=1.05;
    } else {
      //make sx crawl toward endpoints
      l2 = l2 - v; 
      if (l2 > 0) { 
        sx = ex - l2*hx;
        sy = ey - l2*hy;
      } else {
        check = true;
        for(int i = 0; i < 2; i++){
          curves.add(new Curve(x,y,ex,ey));
        }
      }
    }
  }
  void display() {
    stroke(255);
    strokeWeight(1);
    
    line(sx, sy, ex, ey);
  }
}

class Curve {
  /*
  * one, two - start and end point pvectors 
  * midPt - middle point between one and two 
  * diff - essentially distance between begin and end points
  * cross - tangency
  * upV - creates an up vector for cross product
  * control pt - PVector storing final control point for bezier that 
                 is tangent to the line b/w lines
  */
  
  PVector one, two, midPt, diff, cross, upV, controlPt;
  float bow, steps,x,y;
  int place, frame, delay,delayindex;
  ArrayList<Point2D.Float> vertices;
  boolean check, check2, add;
  
  //calculate control point in the constructor
  Curve(float sx, float sy, float ex, float ey) {
    x = sx;
    y = sy;
    vertices = new ArrayList<Point2D.Float>();
    check = false;
    check2 = false;
    add = false;

    bow = random(-70,70);
    one = new PVector(sx, sy);
    two = new PVector(ex, ey);
    diff = PVector.sub(two,one);
    midPt = PVector.mult(PVector.add(one,two),.5);
    upV = new PVector(0,0,1);
    cross = ((diff.cross(upV)).normalize()).mult(bow);
    controlPt = PVector.add(midPt, cross);
    steps = 50;
    delay = 210;
    delayindex = 0;
   
    if(!check) {
      for (int i = 0; i <= steps; i++) {
        float t = i / steps;
        float x = bezierPoint(one.x, controlPt.x, controlPt.x, two.x, t);
        float y = bezierPoint(one.y, controlPt.y, controlPt.y, two.y, t);
        Point2D.Float newvertex = new Point2D.Float(x,y);
        vertices.add(newvertex);

      }
      place = vertices.size()-1;
      check = true;
    }
    
   }
  
  void update() {
    if (place > 0) {
      place--;
    } else {
      if(add == false){
      singleLine.add(new SLine(x,y));
      add = true;
      } else {
       if(delayindex < delay) {
         delayindex++;
       }else if(delayindex == delay) {
         check2 = true;
       }
      }
       
       
    }
  }
  
  void display() {

    fill(255, 35);
    strokeWeight(.4);
    beginShape();
    for(int s = vertices.size()-1; s > place; s--) {
      vertex(vertices.get(s).x, vertices.get(s).y);
    }
    endShape();
  }
}

class SLine {
  float x, y, ey, v;
  boolean check = false;
  int delay, delayindex;
  SLine(float x, float y) {
    this.x = x;
    this.y = y; 
    ey = y; 
    v = random(.5, 1);
    delay = 170;
    delayindex = 0;
  }
  
  void update() {
     if(ey < displayHeight) {
       ey+= v; 
       v *= 1.05;
     } else {
       if(delayindex < delay) {
         delayindex++;
       } else if(delayindex == delay) {
          check = true;
       }
       
     }
  }
  
  void display() {
    stroke(255);
    strokeWeight(.6);  
    
    line(x, y, x, ey);
  }
}