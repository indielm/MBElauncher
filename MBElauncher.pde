import java.io.*;
import java.net.*;
import java.nio.file.FileSystem.*;
/* Mindustry bleeding edge autoupdate and launcher by Desktop aka indielm
 Source for Processing 3.3.6 */

String JENKINS_URL =  "https://jenkins.hellomouse.net/job/mindustry/", 
  LATEST_URL = JENKINS_URL + "lastStableBuild/", 
  LATEST_NUM_URL = LATEST_URL + "buildNumber", 
  FILE_URL = LATEST_URL + "artifact/artifacts/desktop.jar", 
  RSS_URL = JENKINS_URL + "rssAll", 
  CHANGES_URL = LATEST_URL + "changes";
  
boolean tweak = false;
PImage logo;
PShader shader;
PFont font;
PShape router;
color accent = color(255, 211, 127);
ArrayList<Info> infos = new ArrayList<Info>();
int version = 0;
float dlProgress = 0,  dlProgressSmooth = 0;

void settings() {
  size(600, 240, P3D);
  // PImage icon = loadImage("icon.png");
  PJOGL.setIcon("router.png");
}
 PImage piRouter;
void setup() {
  logo = requestImage("logotext.png");
  shader = loadShader("menu.glsl");
  shader.set("resolution", float(width), float(height));  
  font = createFont("pixel_UNEDITED.ttf", 36);
   piRouter = loadImage("routerb.png");
  

  router = texturedCube(piRouter);
   
  ((PGraphicsOpenGL)g).textureSampling(3);
  ortho();
  lights();
  imageMode(CENTER);
  textFont(font);
  textAlign(CENTER);
}

void changeAppIcon(PImage img) {
  final PGraphics pg = createGraphics(16, 16, JAVA2D);

  pg.beginDraw();
  pg.image(img, 0, 0, 16, 16);
  pg.endDraw();
  pg.loadPixels();
  frame.setIconImage(pg.image);
}


void bgShader() {
  background(25);
  shader.set("time", frameCount*0.5);
  shader(shader);
  rect(0, 0, width, height);
  resetShader();
}

void draw() {
   changeAppIcon(piRouter);
  bgShader();
  fill(255);
  if (tweak && (dlProgress += 0.1) >= 100) dlProgress = 0;
  image(logo, width/2, height/4.2);
  showProgress();
  showInfos();
  if (frameCount == (tweak ? 1000000:4)) thread("checkGetLaunch");
}

void showProgress(){
  if (dlProgress != 0) {
    text("Downloading #" + version, width/2, 200);
    stroke(accent);
    noFill();
    rect(150, 212, 300, 22);
    noStroke();
    fill(accent);
    rect(150, 212, dlProgress*3, 22);
    fill(255);
    drawRouter();
    translate(0, 0, 8);
    dlProgressSmooth = (dlProgress + 3*dlProgressSmooth)/4;
    text(floor(dlProgress) + "%", width/2, 230);
  } else text("Checking latest version...", width/2, 200);
}

void drawRouter() {
  pushMatrix(); 
  translate(150+dlProgressSmooth*3, 212+10, 4);
  scale(12, 12);
  rotateX(frameCount*0.010);
  rotateY(frameCount*0.008);
  shape(router);
  popMatrix();
}

void showInfos() {
  Info removeInfo = null;
  int q = 0;
  for (int w = 0; w < infos.size(); w++){
    Info i = infos.get(w);
    fill(255, 255*sin(i.age/100.0));
    text(i.text, width/2, height/2 + 74 - i.age/2 + q*10);
    if ((i.age-=0.4)<=0) removeInfo=i;
  }
  if (removeInfo!=null) infos.remove(removeInfo);
}

void mousePressed() {
  if (tweak) log("testing");
}

void checkGetLaunch() {
  if (!hasMostRecent()) downloadJar();
  log("launching!");
  exec(new String[] {"java", "-jar", filePath});
  exit();
}

void log(String s) {
  println(s);
  infos.add(new Info(s));
}

class Info { 
  float age = 150;
  String text;
  Info(String s) {
    text = s;
    if (infos.size()>0) {
      float last = infos.get(infos.size()-1).age;
      if (last>110) age = last+48;
    }
  }
}

PShape texturedCube(PImage tex) {
  PShape cube = createShape();
  cube.beginShape(QUADS);
  cube.textureMode(NORMAL);
  cube.texture(tex);
  cube.noStroke();
  cube.vertex(-1, -1, 1, 0, 0);
  cube.vertex( 1, -1, 1, 1, 0);
  cube.vertex( 1, 1, 1, 1, 1);
  cube.vertex(-1, 1, 1, 0, 1);
  // -Z "back" face
  cube.vertex( 1, -1, -1, 0, 0);
  cube.vertex(-1, -1, -1, 1, 0);
  cube.vertex(-1, 1, -1, 1, 1);
  cube.vertex( 1, 1, -1, 0, 1);
  // +Y "bottom" face
  cube.vertex(-1, 1, 1, 0, 0);
  cube.vertex( 1, 1, 1, 1, 0);
  cube.vertex( 1, 1, -1, 1, 1);
  cube.vertex(-1, 1, -1, 0, 1);
  // -Y "top" face
  cube.vertex(-1, -1, -1, 0, 0);
  cube.vertex( 1, -1, -1, 1, 0);
  cube.vertex( 1, -1, 1, 1, 1);
  cube.vertex(-1, -1, 1, 0, 1);
  // +X "right" face
  cube.vertex( 1, -1, 1, 0, 0);
  cube.vertex( 1, -1, -1, 1, 0);
  cube.vertex( 1, 1, -1, 1, 1);
  cube.vertex( 1, 1, 1, 0, 1);
  // -X "left" face
  cube.vertex(-1, -1, -1, 0, 0);
  cube.vertex(-1, -1, 1, 1, 0);
  cube.vertex(-1, 1, 1, 1, 1);
  cube.vertex(-1, 1, -1, 0, 1);

  cube.endShape();
  return cube;
}