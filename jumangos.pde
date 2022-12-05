// jumangos by jumango
// chaos video player system written in processing-java
import processing.video.*;

// quick parformance tuning variables
int fps = 60;

// window
int windowWidth = 850;
int windowHeight = 600;
PGraphics canvas;
int clock = 0;

// iosevka font
PFont iosevkaFont;

// mouse
int mouseXpos = mouseX;

// videos
int videoCount;
int homeIndex = 13;
int videoIndex = homeIndex;
ArrayList<Movie> videos = new ArrayList<Movie>();
double speed;
double speedMin = 0.01;
double speedMax = 2.0;
double illegalSpeed = 10.0;

// imgs
int imgCount;
int imgIndex;
ArrayList<PImage> imgs = new ArrayList<PImage>();

// wait screen
boolean waitSc = true;
double waitScAlpha = 0.0;
Movie waitScVideo;

// debugger
boolean isDebug = true;
String fuzzyInput = "";
ArrayList<HashMap<String, String>> fuzzyMap = new ArrayList<HashMap<String, String>>();
ArrayList<HashMap<String, String>> fuzzySearchResultPool = new ArrayList<HashMap<String, String>>();
ArrayList<Integer> fuzzyTargetIndexiedParsed = new ArrayList<Integer>();
float cooler = 1.0;

void viewInit() {
  videoIndex = homeIndex;
  imgIndex = 0;
  speed = 1.0;
}

void debugerInit() {
  fuzzyInput = "";
  fuzzySearchResultPool.clear();
}

int getFolderCount(String folderName) {
  String currentPath = sketchPath();
  File file = new File(currentPath + "/" + folderName);
  if (!file.exists()) {
    println("videos folder not found");
    exit();
  }
  return file.list().length - 1;
}

void setup() {
  // fotn
  iosevkaFont = createFont("Iosevka", 12);
  // video image folder check
  videoCount = getFolderCount("videos");
  imgCount = getFolderCount("imgs") + 1;
  size(850, 600);
  frameRate(fps);
  // fullScreen();
  noCursor();
  canvas = createGraphics(windowWidth, windowHeight);
  //init videos
  String programPath = sketchPath();
  for (int i = 1; i < videoCount + 1; i++) {
    String videoPath = programPath + "/videos/vj" + i + ".mp4";
    Movie video = new Movie(this, videoPath);
    video.volume(0);
    video.frameRate(fps);
    videos.add(video);
  }
  //init imgs
  imgs.add(new PImage());
  for (int i = 1; i < imgCount + 1; i++) {
    String imgPath = programPath + "/imgs/vj" + i + ".png";
    PImage img = loadImage(imgPath);
    imgs.add(img);
  }
  viewInit();
  //play init video
  videos.get(videoIndex).volume(0.0);
  videos.get(videoIndex).speed((float)speed);
  videos.get(videoIndex).play();
  // init waitScVideo
  waitScVideo = new Movie(this, programPath + "/waitSc.mp4");
  waitScVideo.volume(0);
  waitScVideo.speed(1.2);
  waitScVideo.play();
  
  //fazzy debugger
  //import json file
  String jsonPath = programPath + "/linker.json";
  JSONObject json = loadJSONObject(jsonPath);
  JSONArray fuzzyArray = json.getJSONArray("data");
  for (int i = 0; i < fuzzyArray.size(); i++) {
    JSONObject fuzzy = fuzzyArray.getJSONObject(i);
    HashMap<String, String> fuzzyMapItem = new HashMap<String, String>();
    //we have name(string) and indexies(array of numbers)
    fuzzyMapItem.put("name", fuzzy.getString("name"));
    JSONArray indexies = fuzzy.getJSONArray("indexies");
    fuzzyMapItem.put("indexies", indexies.join(","));
    fuzzyMap.add(fuzzyMapItem);
  }
}

void draw() {
  clock++;
  // movie playbacks
  float espaceNum = 0.15;
  if (speed == illegalSpeed) {
    espaceNum = 0.5;
  }
  if (videos.get(videoIndex).time() >= (videos.get(videoIndex).duration() - espaceNum)) {
    videos.get(videoIndex).jump(0);
  }
  //track mouse and change speed
  canvas.beginDraw();
  canvas.image(videos.get(videoIndex), 0, 0, windowWidth, windowHeight);
  //overlay image
  if (imgIndex != 0) canvas.image(imgs.get(imgIndex), 0, 0, windowWidth, windowHeight);
  waitScCan(canvas);
  if (isDebug) debugger(canvas);
  canvas.endDraw();
  image(canvas, 0, 0, width, height);
}

void waitScCan(PGraphics canvas) {
  // waitSc movie playbacks
  float espaceNum = 0.15;
  if (waitScVideo.time() >= (waitScVideo.duration() - espaceNum)) {
    waitScVideo.jump(0);
  }

  if (waitScAlpha < 0.1 && !waitSc) {
    return;
  }
  
  // alpha background controller
  if (waitSc) {
    if (waitScAlpha < 0.9) {
      waitScAlpha += 0.1;

    }
  } else {
    if (waitScAlpha > 0.0) {
      waitScAlpha -= 0.1;
    }
  }

  // draw background light pink
  canvas.fill(200, 200, 200, (int)(waitScAlpha * 255));
  if (isDebug)canvas.rect(0, 0, windowWidth, windowHeight);
  
  // blue back to transparent
  PImage waitScImg = waitScVideo.get();
  for ( int x = 0; x < waitScImg.width; x++ ) {
    for ( int y = 0; y < waitScImg.height; y++ ) {
      int loc = x + y * waitScImg.width;
      int c = waitScImg.pixels[loc];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      if (r < 150 && g < 130 && b > 150) {
        waitScImg.pixels[loc] = color(0, 0, 0, 0);
      } else {
        waitScImg.pixels[loc] = color(r, g, b, (float)(waitScAlpha * 255));
      }
    }
  }
  canvas.image(waitScImg, 0, 0, windowWidth, windowHeight);

  // text, "do not take photos"
  canvas.fill(0, 0, 0, (int)(waitScAlpha * 255));
  canvas.textFont(iosevkaFont);
  canvas.textSize(24);
  canvas.text("( do not take photos )", windowWidth - 280, windowHeight - 30);
}

void debugger(PGraphics canvas) {
  cooler *= 0.7;
  int textsOriginX = (int)(-25 * cooler);
  // jumangos debugger
  canvas.fill(255, 255, 255, 120);
  canvas.noStroke();  
  canvas.rect(10 + textsOriginX, 10, int(200.0 * (1.0 - cooler)), 120);
    canvas.fill(80, 200, 80);
  canvas.textSize(15);
  canvas.textFont(iosevkaFont);
  canvas.text("( :/ jumangos debugger )", 20 + textsOriginX, 30);
  // speed indicator
  canvas.fill((float)(100 * ((float)speed) / speedMax) + 154,(float)(255 * (speedMax - (float)speed) / speedMax),200, 150);
  canvas.rect(20 + textsOriginX, 38,(float)(speed / speedMax) * 50 + 20, 10);
  // video index indicator
  canvas.fill(80, 200, 80);
  canvas.text("video index: " + videoIndex, 20 + textsOriginX, 65);
  // fuzzy input
    canvas.fill(80, 200, 80);
    canvas.text("fuzzy: " + fuzzyInput + (clock % 2 == 0 ? " ?" : ""), 20 + textsOriginX, 80);
  // fuzzy search result
  // which is arr
  for (int i = 0; i < fuzzySearchResultPool.size(); i++) {
    if (i!=0) {canvas.fill(80, 200, 80);} else {
      canvas.fill(80, 200, 80, clock%2==0 ? 80 : 0);
    }
    canvas.text(fuzzySearchResultPool.get(i).get("name") + "+" + fuzzySearchResultPool.get(i).get("indexies"), 20 + textsOriginX, 100 + i * 15);
  }
  if (fuzzySearchResultPool.size() == 1) {
      canvas.fill(80, 200, 80);
    String strPool = "";
    strPool += "[ ";
    for (int i = 0; i < fuzzyTargetIndexiedParsed.size(); i++) {
      strPool += (i + 1) + "..." + fuzzyTargetIndexiedParsed.get(i) + "  ";
    }
    strPool += " ]";
    canvas.text(strPool, 20 + textsOriginX, 100 + fuzzySearchResultPool.size() * 15);
  }
}

void keyPressed() {
  //tabto toggle debug or not
  if (key == TAB) {
       if (isDebug) {
      isDebug = false;
      waitSc = false;
    } else {
      isDebug = true;
      waitSc = true;
           cooler = 1.0;
    }
  }
  
  if (key == '-') {
    RefreshCache();
  }

  if (key == ']') {
    waitSc = false;
  }
  if (key == '`') {
    waitSc = true;
  }

  if (key == '=') {
     isDebug = !isDebug;
     cooler = 1.0;
  }
  
  if (isDebug) {
    if (key >=  '0' &&  key <= '9') {
      if (fuzzyTargetIndexiedParsed.size() == 0) {
        debugerInit();
        return;
      }
      int index = (key - '0');
      if (index == 0) {
        int randomIndexFromFuzzy = (int)random(fuzzyTargetIndexiedParsed.size());
        videos.get(videoIndex).pause();
        videoIndex = fuzzyTargetIndexiedParsed.get(randomIndexFromFuzzy);
        videos.get(videoIndex).play();
        videos.get(videoIndex).volume(0.0);
        videos.get(videoIndex).speed((float)speed);
      } else if (index > 0 && index <= fuzzyTargetIndexiedParsed.size() ) {
        videos.get(videoIndex).pause();
        videoIndex = fuzzyTargetIndexiedParsed.get(index - 1);
        videos.get(videoIndex).play();
        videos.get(videoIndex).volume(0.0);
        videos.get(videoIndex).speed((float)speed);
      }
      
    }
    if (key ==  BACKSPACE) {
      debugerInit();
    }
    if (key == ' ') {
      fuzzyInput = fuzzyInput + " ";
    }
    if (key >= 'a' && key <= 'z') {
      int fuzzyInputLength = fuzzyInput.length();
      if (fuzzyInputLength < 8) {
        fuzzyInput += key;
        FuzzySearchResultRefresher();
      }
    }
    
  } else {
    if (key == '1' || key == '2' || key == '3' || key == '4' || key == '5' || key == '6' || key == '7' || key == '8' || key == '9') {
      int keyIndex = key - '0';
      speed = map(keyIndex, 1, 9,(float)speedMin,(float)speedMax);
      videos.get(videoIndex).speed((float)speed);
    }
    if (key == '0') {
      speed = illegalSpeed;
      videos.get(videoIndex).speed((float)speed);
    }
  }
  
  if (key == '§') {
    //to home video
    videos.get(videoIndex).pause();
    videoIndex = homeIndex;
    videos.get(videoIndex).speed((float)speed);
    videos.get(videoIndex).play();
    
  }
  
  if (key ==  '[') {
    imgIndex = 0;
  }
  
  if (!(key ==  CODED)) {
    return;
  }
  
  if (keyCode ==  LEFT) {
    if (speed == illegalSpeed) {
      speed = speedMax;
    }
    videos.get(videoIndex).pause();
    videoIndex = (videoIndex + videoCount - 1) % videoCount;
    videos.get(videoIndex).play();
    videos.get(videoIndex).volume(0.0);
    videos.get(videoIndex).speed((float)speed);
    
  } else if (keyCode == RIGHT) {
    if (speed == illegalSpeed) {
      speed = speedMax;
    }
    videos.get(videoIndex).pause();
    videoIndex = (videoIndex + 1) % videoCount;
    videos.get(videoIndex).play();
    videos.get(videoIndex).volume(0.0);
    videos.get(videoIndex).speed((float)speed);
  } else if (keyCode == UP) {
    imgIndex = (imgIndex + 1) % (imgCount + 1);
  } else if (keyCode == DOWN) {
    imgIndex = (imgIndex + imgCount) % (imgCount + 1);
  }
}


void movieEvent(Movie m) {
  m.read();
}

// 
void FuzzySearchResultRefresher() {
  fuzzySearchResultPool.clear();
  String fuzzyInputLower = fuzzyInput.toLowerCase();
  // from fuzzyMap find fuzzyInput kinda match
  for (int i = 0; i < fuzzyMap.size(); i++) {
    if (fuzzyMap.get(i).get("name").contains(fuzzyInputLower)) {
      fuzzySearchResultPool.add(fuzzyMap.get(i));
    }
  }
  
  if (fuzzySearchResultPool.size() == 1) {
    // parse indexies into fuzzy
    String[] indexies = split(fuzzySearchResultPool.get(0).get("indexies"), ",");
    ArrayList<Integer> indexiesInt = new ArrayList<Integer>();
    for (int i = 0; i < indexies.length; i++) {
      if (indexies[i].length() > 0) {
        indexiesInt.add(PApplet.parseInt(indexies[i]));
      }
    }
    fuzzyTargetIndexiedParsed = indexiesInt;
  }
}

void RefreshCache() {
  for (int i = 0; i < videoCount; i++) {
    videos.get(i).stop();
  }
  videos = new ArrayList<Movie>();
  // refresh cache
  String programPath = sketchPath();
  for (int i = 1; i < videoCount + 1; i++) {
    String videoPath = programPath + "/videos/vj" + i + ".mp4";
    Movie video = new Movie(this, videoPath);
    video.volume(0);
    videos.add(video);
  }
  // init imgs
  imgs.add(new PImage());
  for (int i = 1; i < imgCount + 1; i++) {
    String imgPath = programPath + "/imgs/vj" + i + ".png";
    PImage img = loadImage(imgPath);
    imgs.add(img);
  }
  
  //play init video
  videos.get(videoIndex).play();
  videos.get(videoIndex).volume(0.0);
  videos.get(videoIndex).speed((float)speed);

  // reload waitSc
  waitScVideo = new Movie(this, programPath + "/waitSc.mp4");
  waitScVideo.volume(0);
  waitScVideo.speed(1.2);
  waitScVideo.play();
  
  
  // nuke memory
  Runtime.getRuntime().gc();
}
