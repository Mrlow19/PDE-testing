//Used to deplete stamina when sprinting
boolean sprinting = false;

Player player1;
Ai player2;
Court court;
StaminaBar playerStamina;
Ball ball;
Cursor cursor;

void setup() {
  size(450, 500);
  
  player1 = new Player(300, 430);
  player2 = new Ai(150, 50);
  court = new Court();
  ball = new Ball();
  playerStamina = new StaminaBar(player1.x, player1.y, player1.stamina);
  cursor = new Cursor();
}

void draw() {
  background(255); 
  // Update the position of the player's stamina bar
  playerStamina.x = player1.x;
  playerStamina.y = player1.y;
  
  // Display the court
  court.display();
  // Run the player
  player1.run();
  //Run the ai
  player2.run();
  player2.moveAi();
  // Update the stamina
  playerStamina.deplete();
  //Display the ball
  ball.run();
  //Run the cursor
  cursor.display();
}

class Player {
  int x;
  int y;
  int dX = 0, dY = 0;
  float speedX = 2;
  float speedY = 2;
  
  float stamina = 25;
  double power = 0.5;
  boolean ifBallHit = false;
  
  // Constructor
  Player(int newX, int newY) {  
    x = newX;
    y = newY;
  }

  // Draw the player
  void display() {
    ellipse(x, y, 25, 25);
  } 
  
  // Move the player
  void movePlayer() {
    // Constrain player within the court boundaries
    x = constrain(x, 0 + 25/2, width - 25/2);
    y = constrain(y, height/2 + 25/2, height - 25/2);
    // Move player
    x += dX * speedX;
    y += dY * speedY;
  }
  
  // Move the player and draw them
  void run() {
    display();
    movePlayer();
  }  

  // Responds when a key is pressed
  void pressed(boolean left, boolean right, boolean up, boolean down, boolean sprint, 
               boolean hit) {
    if (left)  dX = -1;
    if (right) dX = 1;
    if (up)    dY = -1;
    if (down)  dY = 1;
    
    if (hit && ifBallHit == false) {
      power += 0.3;
    }
    
    // If stamina is above 0 and shift is held
    if (sprint && stamina > 0) {
      speedX += 1.5;
      speedY += 1.5;
      sprinting = true;
    } 
  }

  // Responds when a key is released 
  void released(boolean left, boolean right, boolean up, boolean down, boolean sprint,
                boolean hit) { 
    if (left)  dX = 0; 
    if (right) dX = 0; 
    if (up) dY = 0; 
    if (down)  dY = 0; 
    
    //If ball is hit, distance is below 50 and ball has not been hit twice
    if (hit && dist(x, y, ball.x, ball.y) < 50 && ifBallHit == false) {
      ball.hit(mouseX, mouseY, power);
      ifBallHit = true;
    }

    // If stamina is 0 or SHIFT key is released, speed will be set to default
    if (sprint || stamina == 0) {
      speedX  = 2;
      speedY = 2;
      sprinting = false;
    }
  }  
}

//Ai player
class Ai {
  int x;
  int y;
  int dX = 0, dY = 0;
  float speedX = 2;
  float speedY = 2;
  
  float ballLandingX = 100;
  float ballLandingY = 100;
  
  //float stamina = 100;
  //double power = 0.2;
  //boolean ifBallHit = false;
  
  // Constructor
  Ai(int newX, int newY) {  
    x = newX;
    y = newY;
  }

  // Draw the player
  void display() {
    ellipse(x, y, 25, 25);
  } 
  
  // Move the player towards the ball's landing coordinates
void moveAi() {
    // Calculate the direction vector towards the target landing coordinates
    float deltaX = ballLandingX - x;
    float deltaY = ballLandingY - y;
    
    // Normalize the direction vector
    float magnitude = sqrt(deltaX * deltaX + deltaY * deltaY);
    float normalizedDeltaX = deltaX / magnitude;
    float normalizedDeltaY = deltaY / magnitude;
    
    // Update the movement direction based on the normalized direction vector
    dX = (int) (normalizedDeltaX * speedX);
    dY = (int) (normalizedDeltaY * speedY);
    
    //If ball lands on the other side and if the ball has already been hit
    if(ballLandingY < height/2 && player1.ifBallHit == true){
      // Move player
      x += dX;
      y += dY;
      
    }
    
    //If ball and ai are close together
    if(dist(x, y, ball.x, ball.y) < 50) {
      ball.hit(300,300, 0.5);
      player1.ifBallHit = false;
    }
    
}
  
  // Move the player and draw them
  void run() {
    display();
    moveAi();
  } 
  
}

class StaminaBar {
  int x;
  int y;
  
  float stamina;
  
  // How long it takes to regenerate stamina
  int timer = 0;
  
  StaminaBar(int staminaX, int staminaY, float newStamina){
    x = staminaX;
    y = staminaY;
    stamina = newStamina;
  }
  
  // Depletes stamina while sprinting
  void deplete() {
    // Check if the SHIFT key is pressed
    if (stamina > 0 && sprinting == true){
      // Depletes stamina
      stamina -= 2;
      display();
      println(stamina);
    }
    // Regenerating stamina
    if (stamina == 0){
      // Timer ticks up until stamina regenerates
      timer += 1;
    }
    // If timer has passed one second
    if (timer >= 120 && sprinting == false){
      stamina += 0.5;
      display();
    }
    
    //If stamina has been refilled, timer is reset
    if (stamina == 25){
      timer = 0;
    }
  }
  
  void display(){
    // Stamina bar
    rectMode(CORNERS);
      
    // Empty bar in white
    fill(255);
    rect(x + 20, y, x + 50, y - 10);
    
    // Stamina in black
    fill(0);
    rect(x + 20, y, x + stamina + 25, y - 10);
  }
  
}

//Ball
class Ball {
  //Directions
  float dX = 1.5;
  float dY = 1.5;
  float dH = 1;
  
  //Velocities
  float speedX = 1;
  float speedY = 1;
  float speedH = 1;
  
  //Coordinates
  float x = 0;
  float y = 0;
  float h = 25;
  

  Ball() {
  }
  
  //Draws the ball
  void display(){
    fill(255);
    ellipseMode(CENTER);  
    ellipse(x, y, h/3, h/3);
  }
  
  void move() { 
    //Take away from the velocity
    speedH -= 0.01 * dH;
    
    // Move the ball
    x += speedX * dX;
    y += speedY * dY;
    h += speedH * dH;
    
    
    // If velocity reaches zero or its max, reverse direction
    if (speedH <= 0 || speedH >= 1) {
      dH *= -1;  
      speedX -= 0.1;
      speedY -= 0.1;
    }
  }
    
  void hit(float balllandingX, float ballLandingY, double power){
    //Calculate the direction vector from ball to cursor
    float deltaX = balllandingX - ball.x;
    float deltaY = ballLandingY - ball.y;
    
    // Calculate the magnitude of the direction vector
    float magnitude = sqrt(deltaX * deltaX + deltaY * deltaY);
    
    // Normalize the direction vector
    float normalizedDeltaX = deltaX / magnitude;
    float normalizedDeltaY = deltaY / magnitude;
    
    // Set the ball's direction based on the normalized direction vector
    ball.dX = normalizedDeltaX;
    ball.dY = normalizedDeltaY;
    
    //Reverse ball direction
    ball.dH *= -1;
    
    //Increase velocity
    ball.speedX += power;
    ball.speedY += power;
    
    // Calculate projected landing coordinates
    float landingX = ball.x + (ball.speedX * ball.dX * 100); // Adjust multiplier as needed
    float landingY = ball.y + (ball.speedY * ball.dY * 100); // Adjust multiplier as needed
    
    // Set the AI's target landing coordinates
    player2.ballLandingX = landingX;
    player2.ballLandingY = landingY;
}
  
  void run(){
    display();
    move();
  }
  
}

//Cursor for aiming the ball
class Cursor {
 
  Cursor() {}
  
  //Run the cursor
  void run(){
    display();
  }
  
  //Display the cursor at mouseX and mouseY
  void display(){
    
    strokeWeight(5);
    line(mouseX + 5, mouseY, mouseX + 10, mouseY);
    line(mouseX - 5, mouseY, mouseX - 10, mouseY);
    line(mouseX, mouseY + 5, mouseX, mouseY + 10);
    line(mouseX, mouseY - 5, mouseX, mouseY - 10);
    
    //Reset stroke weight 
    strokeWeight(3);
  }
}

class Court {
  Court() {
  } 
  
  void display() {
    fill(255);
    rectMode(CORNERS);
    
    // Court
    rect(60, 20, 390, 470);
    
    // Left doubles alley
    line(100, 20, 100, 470);
    
    // Right doubles alley
    line(350, 20, 350, 470);
    
    // Net
    line(50, height/2, 400, height/2);
    
    // No man's land bottom
    line(100, 390, 350, 390);
    
    // No man's land top
    line(100, 100, 350, 100);
    
    // Service divider
    line(225, 390, 225, 100);
  }
}


void keyPressed() {
  player1.pressed((key == 'a' || key == 'A'), (key == 'd' || key == 'D'),
                  (key == 'w' || key == 'W'), (key == 's' || key == 'S'), 
                  (keyCode == SHIFT), (key == 'e' || key == 'E'));
}

void keyReleased() {
  player1.released((key == 'a' || key == 'A'), (key == 'd' || key == 'D'),
                   (key == 'w' || key == 'W'), (key == 's' || key == 'S'), 
                   (keyCode == SHIFT), (key == 'e' || key == 'E'));
}
