//////////////////////////////////////////////////////////////////////////////////////////
// InfoSNAKE
// ---------
// This Program is an interpretation of the original SNAKE-game for educational purposes.
// All images and sounds used are public domain:  
//   jelly.png -- https://commons.wikimedia.org/wiki/File:Food-Jelly.svg?uselang=de
// 
// License: GPLv3.0
// F. Kick DBG Eppelheim
//////////////////////////////////////////////////////////////////////////////////////////



///// VARIABLEN //////////////////////////////////////////////////////////////////////////

// ALLGEMEINE EINSTELLUNGEN
int schrittweite = 25;
int SpielfeldGroesseX = 30;
int SpielfeldGroesseY = 30;
int rotation=0;

// SPIELER (SNAKE)
int[] x = new int[SpielfeldGroesseX*SpielfeldGroesseY];
int[] y = new int[SpielfeldGroesseX*SpielfeldGroesseY];
int score=0;    // Punktestand
int tailLenght=2;    // Länge der Schlange
boolean dead=false;  // Lebt die Schlange noch?
int vx=0;       // Geschwindigkeit in x-Richtung
int vy=-1;      // Geschwindigkeit in y-Richtung
                // Start nach oben, denn vy<0


// GEGNER bzw. OPFER (FOOD) 
int foodX=int(random(1,SpielfeldGroesseX-1));
int foodY=int(random(1,SpielfeldGroesseY-1));
PImage foodImage;
int foodsize;   // Größe des Bildes




//////  KONSTRUKTOR  ////////////////////////////////////////////////////////////////////////// 
void setup() {
  size(SpielfeldGroesseX*schrittweite,SpielfeldGroesseY*schrittweite);
  background(255);
  noStroke();
  rectMode(CENTER);
  textAlign(CENTER);
  imageMode(CENTER);
  foodImage = loadImage("jelly.png");  
  frameRate(10);
  x[0]=int(random(1,SpielfeldGroesseX-1));
  y[0]=int(random((SpielfeldGroesseY-1)/2,SpielfeldGroesseY-1));
  x[1]=x[0];
  y[1]=y[0]-vy;
  foodsize = schrittweite;
}



//////  LOOP  /////////////////////////////////////////////////////////////////////////////////
void draw() {
  if (dead==false) {
    background(255);
    ///// for debugging:
    text("rotation="+rotation,width/2,50);
    //text("SNAKE: x="+x[0]+" y="+y[0],width/2,80);
    //text("FOOD: x="+foodX+" y="+foodY,width/2,110);
    rotateWorld();
    //zeichne Rahmen
    rect(width/2,height/2,width,height);
    zeichneFood();
    bewegeSchlange(tailLenght);
    kollisionsKontrolle();
    punkteKontrolle();
    
    
  } else {
    fill(150,100);
    rect(width/2,height/2,width,height);
    textSize(100);
    fill(20);
    text("GAME OVER",width/2,height/2);
    textSize(30);
    fill(120);
    text("SCORE: "+(score),width/2,2*(height/3)+50);
    noLoop(); // beendet Spiel
  }
}

// Processing-Methode, die die Tastatur überwacht. 
// Wird unabhängig vom Loop getriggert. 
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      if(vy!=1) {
        vy=-1;
        vx=0;
      }
    } else if (keyCode == DOWN) {
      if(vy!=-1) {
        vy=1;
        vx=0;
      }
    } else if (keyCode == LEFT) {
      if(vx!=1) {
        vx=-1;
        vy=0;
      }
    } else if (keyCode == RIGHT) {
      if(vx!=-1) {
        vx=1;
        vy=0;
      }
    } 
  } 
}




/////  METHODEN  //////////////////////////////////////////////////////////////////////////

// Diese Methode arbeitet rekursiv: Es wird immer das n-te Körperteil bewegt. Dies ist 
// jeweils ein Kopiervorgang, denn das letzte Körperteil erhält die Koordinaten des 
// vorletzten Körperteils, das vorletzte die Koordinaten des vorvorletzten usw. 
// Erst der Kopf wird schließlich in die aktuelle Richtung bewegt. 
// Aufgerufen wird die Methode im Loop mit bewegeSchlange(<Länge der Schlange>). Dadurch
// wird das letzte Körperteil der Schlange bewegt und die Methode für so lange für das 
// vorhergehende Körperteil aufgerufen, bis der Kopf erreicht ist. 
void bewegeSchlange(int n) {
  if (n>=1) {
    x[n] = x[n-1];
    y[n] = y[n-1];
    bewegeSchlange(n-1);
  } else {
    x[0] = x[0]+vx;
    y[0] = y[0]+vy;
  }
  // Die Farbe errechnet sich aus der Position des Koerperelements:
  // Der Faktor float/float ergibt für den Kopf (n=0) Null. Damit er nicht ganz schwarz gezeichnet wird, wird beim 
  // blau-Kanal der Wert 30 addiert. 
  // Das letze Element erhält den Farbwert 1*120 , 1*140, 1*225+30
  // Hübsch, nicht? :)
  fill((float(n+1)/float(tailLenght+1))*120,(float(n+1)/float(tailLenght+1))*140,(float(n+1)/float(tailLenght+1))*225 + 30);
  rect((x[n]*schrittweite)+1,(y[n]*schrittweite)+1,schrittweite-2,schrittweite-2);
}



// Sind wir gegen eine Wand oder uns selbst gelaufen?
void kollisionsKontrolle(){
  if (x[0]<=0|| x[0]>=SpielfeldGroesseX || y[0]<=0 || y[0]>=SpielfeldGroesseY) {
    dead = true;
  }
  for (int n=1; n<tailLenght; n++) {
    if (x[0]==x[n] && y[0]==y[n] ) {
      dead = true;     
    }
  }
}


// Gibt es Punkte?
void punkteKontrolle(){
  if ( foodX == x[0] && foodY == y[0] ) {
    score++; 
    tailLenght++;
    foodsize=int(foodsize*1.4);    
  }
}

// Zeichnet das Food
void zeichneFood() {
  // Falls das Food gerade gefressen wurde, soll es wachsen...
  if (foodsize!=schrittweite) {
      if (foodsize<schrittweite*5) {
        foodsize=int(foodsize*1.4);
      } else { // ... bis es die maximale Größe erreicht hat. 
        // dann soll es wieder auf die normale Größe schrumpfen und
        foodsize=schrittweite;
        // neue Koordinaten erhalten
        neueFoodKoordinaten(tailLenght);
      }
    }
    image(foodImage, foodX*schrittweite,foodY*schrittweite, foodsize, foodsize);
}

// Ordnet dem Food neue Koordinaten zu
void neueFoodKoordinaten(int n) {
  if (n==tailLenght) {
    foodX=int(random(1,SpielfeldGroesseX-1));
    foodY=int(random(1,SpielfeldGroesseY-1));
  }
  if (foodX==x[n] && foodY==y[n] ) {
    foodX=int(random(1,SpielfeldGroesseX-1));
    foodY=int(random(1,SpielfeldGroesseY-1));
  }
  if (n>0) neueFoodKoordinaten(n-1);
  
}  

void rotateWorld() {
  rotation++;
  translate(width/2,height/2);
  rotate(sin(float(rotation)/50)*PI/4);
  translate(-width/2,-height/2);
}
    

// Beendet das Programm (nur wg. Sounds nötig). 
void stop()
{
  super.stop();
}

///// EOF (End of File) ////////////////////////////////////////////////////////////////
