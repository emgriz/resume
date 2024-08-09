final static float MOVE_SPEED = 5;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = 0.6;
final static float JUMP_SPEED = 12;

final static float WIDTH = SPRITE_SIZE * 16;      
final static float HEIGHT = SPRITE_SIZE * 12;      
final static float GROUND_LEVEL = HEIGHT - SPRITE_SIZE;

final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 60;
final static float VERTICAL_MARGIN = 40;

Sprite player;
PImage path, stone, bricks, lava, flag;
ArrayList<Sprite> platforms;

boolean isGameOver;

float view_x = 0;
float view_y = 0;

public class Sprite{
 PImage image;
 float center_x, center_y;
 float change_x, change_y;
 float w,h;
 int lives = 3;
 
 public Sprite(String filename, float scale, float x, float y){
  image = loadImage(filename); 
  w =  image.width * scale;
  h = image.height * scale;
  center_x = x;
  center_y = y;
  change_x = 0;
  change_y = 0;
 } 
 public Sprite(String filename, float scale){
   this(filename, scale, 0, 0);
 }
 public Sprite(PImage img, float scale){
  image = img;
  w = image.width * scale;
  h = image.height * scale;
  center_x = 0;
  center_y = 0;
  change_x = 0;
  change_y = 0;
 }
 public void display(){
   image(image, center_x, center_y, w, h);
 }
 public void update(){
  center_x += change_x;
  center_y += change_y;
 }
 public void setLeft(float left){
  center_x = left + w/2; 
 }
 public float getLeft(){
   return center_x - w/2;
 }
 public void setRight(float right){
  center_x = right - w/2;
 }
 public float getRight(){
  return center_x + w/2;
 }
 public void setTop(float top){
   center_y = top + h/2;
 }
 public float getTop(){
  return center_y - h/2; 
 }
 public void setBottom(float bottom){
  center_y = bottom - h/2; 
 }
 public float getBottom(){
  return center_y + h/2; 
 }
 public void setImage(PImage img){
  image = img; 
 }
}

void setup(){
  size (800,600);
  imageMode(CENTER);
  player = new Sprite("bowser facing.png", .75, 100, 300);
  player.center_x = 100;
  player.center_y = 200;
  
  isGameOver = false;
  
  platforms = new ArrayList <Sprite>();
  path = loadImage("path.png");
  stone = loadImage("stone2.png");
  bricks = loadImage("bricks copy.png");
  lava = loadImage("lava1.png");
  flag = loadImage("flag.png");
  createPlatforms("map.csv");
}

void draw() {
  background(225);
  scroll();
  player.display();
  resolvePlatformCollisions(player, platforms);
  displayAll();
  checkDeath();
  if(!isGameOver){
   updateAll(); 
   checkDeath();
  }
}

void displayAll(){
 for(Sprite s: platforms){
    s.display();
  }
  fill (225, 0, 0);
  textSize(32);
  text("Lives:" + player.lives, view_x + 50, view_y + 100);
  
  if(isGameOver){
   fill(0, 0, 225);
   text("GAME OVER", view_x + width/2 - 100, view_y + height/2);
   if(player.lives == 0){
   text("You lose", view_x + width/2 - 100, view_y + height/2 + 50);
   }
   else{
   text("You win", view_x + width/2 - 100, view_y + height/2 + 50);
   }
   text("Press SPACE to restart!", view_x + width/2 - 100, view_y + height/2 + 100);
  }
}

void updateAll(){
  resolvePlatformCollisions(player, platforms);
  checkDeath();
}

void checkDeath(){
  boolean fallOffEdge = player.getBottom() > GROUND_LEVEL;
  if(fallOffEdge){
   player.lives--;
  if(player.lives == 0){
   isGameOver = true; 
  }
  else{
    player.center_x = 100;
    player.setBottom(GROUND_LEVEL);
  }
  }
}
void scroll(){
 float right_boundary = view_x + width - RIGHT_MARGIN;
 if(player.getRight() > right_boundary){
  view_x += player.getRight() - right_boundary;
 }
 float left_boundary = view_x + LEFT_MARGIN;
 if(player.getLeft() < left_boundary){
   view_x -= left_boundary - player.getLeft();
 }
 float bottom_boundary = view_y + height - VERTICAL_MARGIN;
 if(player.getBottom() > bottom_boundary){
  view_y += player.getBottom() - bottom_boundary; 
 }
 float top_boundary = view_y + VERTICAL_MARGIN;
 if(player.getTop() < top_boundary){
  view_y -= top_boundary - player.getTop(); 
 }
 translate(-view_x, -view_y);
}

public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls){
 s.center_y += 5;
 ArrayList<Sprite> col_list = checkCollisionList(s, walls);
 s.center_y -= 5;
 if(col_list.size() > 0){
  return true;
 }
 else{
  return false; 
 }
}

public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> sprites){
  ArrayList<Sprite> collidedSprites = new ArrayList<Sprite>();
  for(Sprite sprite : sprites){
    if(checkCollision(s, sprite)){
      collidedSprites.add(sprite);
    }
  }
  return collidedSprites;
}

public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls){
  s.change_y += GRAVITY;
  
  s.center_y += s.change_y;
  ArrayList<Sprite> col_list_y = checkCollisionList(s, walls);
  if(col_list_y.size() > 0){
   Sprite collided = col_list_y.get(0);
   if(s.change_y > 0){
    s.setBottom(collided.getTop()); 
   }
   else if(s.change_y < 0){
    s.setTop(collided.getBottom()); 
   }
   s.change_y = 0;
  }
  s.center_x += s.change_x;
  ArrayList<Sprite> col_list_x = checkCollisionList(s, walls);
  if(col_list_x.size() > 0){
   Sprite collided = col_list_x.get(0);
   if(s.change_x > 0){
    s.setRight(collided.getLeft()); 
   }
   else if(s.change_x < 0){
    s.setLeft(collided.getRight()); 
   }
   s.change_x = 0;
  }
}

boolean checkCollision(Sprite s1, Sprite s2){
 boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
 boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
if(noXOverlap || noYOverlap){
 return false; 
}
else{
 return true; 
}

}
void keyPressed(){
  if(keyCode == RIGHT){
   player.change_x = MOVE_SPEED; 
  }
  else if(keyCode == LEFT){
   player.change_x = -MOVE_SPEED;
  }
  else if(keyCode == UP && isOnPlatforms(player, platforms)){
   player.change_y = -JUMP_SPEED;
  }
  else if(isGameOver && key == ' '){
    setup();
  }
}
void keyReleased(){
  if(keyCode == RIGHT){
   player.change_x = 0; 
  }
  if(keyCode == LEFT){
   player.change_x = 0;
  }
  if(keyCode == UP){
   player.change_y = 0;
  }
  if(keyCode == DOWN){
   player.change_y = 0;
  }
}

void createPlatforms(String filename){
  String[] lines = loadStrings(filename);
  for(int row = 0; row < lines.length; row++){
    String[] values = lines[row].split(",");
    for(int col = 0; col < values.length; col++){
      if(values[col].equals("1")){
        Sprite s = new Sprite(path, 3.15);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("2")){
        Sprite s = new Sprite(stone, 3.15);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("3")){
        Sprite s = new Sprite(bricks, 3.15);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("4")){
        Sprite s = new Sprite(lava, 3.15);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        s.image = lava;
        platforms.add(s);
      }
      else if(values[col].equals("5")){
       Sprite s = new Sprite(flag, 3.15);
       s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
       s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
       platforms.add(s);
      }
    }
  }
}
