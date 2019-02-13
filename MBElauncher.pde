import java.io.*;
import java.net.*;
import java.nio.file.FileSystem.*;
/* Mindustry bleeding edge autoupdate and launcher by Desktop aka indielm
 Source for Processing 3.3.6 */
PImage logo;
String JENKINS_URL =  "https://jenkins.hellomouse.net/job/mindustry/", 
  LATEST_URL = JENKINS_URL + "lastStableBuild/", 
  LATEST_NUM_URL = LATEST_URL + "buildNumber", 
  FILE_URL = LATEST_URL + "artifact/artifacts/desktop.jar", 
  RSS_URL = JENKINS_URL + "rssAll", 
  CHANGES_URL = LATEST_URL + "changes";

int version = 0;
float dlProgress = 0;
PShader shader;
PFont font;
color accent = color(255, 211, 127);
boolean tweak = false;
ArrayList<Info> infos = new ArrayList<Info>();
//PShape svglogo;
PShape router;
float dlProgressSmooth = 0;

void settings(){
  size(600, 240, P3D);
}

void setup() {
  logo = requestImage("logotext.png");
  shader = loadShader("menu.glsl");
  shader.set("resolution", float(width), float(height));  
  font = createFont("pixel_UNEDITED.ttf", 36);
  ((PGraphicsOpenGL)g).textureSampling(3);
  //svglogo = loadShape("banner.svg");
  router = texturedCube(requestImage("router.png"));

  //String [] data = loadStrings(CHANGES_URL);
  //int i = 0;
  //println(data[12]);
  // String line = data[12];
}

void bgShader() {
  background(25);
  shader.set("time", frameCount*0.5);
  shader(shader);
  rect(0, 0, width, height);
  resetShader();
}


void draw() {
  bgShader();
  ortho();
  lights();
  //translate(0,0,8);
  imageMode(CENTER);
  textFont(font);
  fill(255);
  textAlign(CENTER);
  if (tweak && (dlProgress+=0.1) >= 100) dlProgress = 0;
  if (dlProgress!=0) {
    text("Downloading #" + version, width/2, 200);
    stroke(accent);
    noFill();
    rect(150, 212, 300, 22);
    noStroke();
    fill(accent);
    rect(150, 212, dlProgress*3, 22);
    fill(255);
    pushMatrix();
    translate(150+dlProgress*3, 212+10, 4);
    scale(12, 12);
    rotateX(frameCount*0.010);
    rotateY(frameCount*0.008);
    shape(router);
    popMatrix();
    translate(0, 0, 8);
    dlProgressSmooth = (dlProgress + 3*dlProgressSmooth)/4;
    text(floor(dlProgressSmooth) + "%", width/2, 230);
  } else text("Checking latest version...", width/2, 200);
  image(logo, width/2, height/4.2);
  /*translate(14,11);
   scale(0.75,0.75);
   shape(svglogo);*/
  Info removeInfo = null;
  int q = 0;
  for (Info i : infos) {
    fill(255, 255*sin(i.age/100.0));
    text(i.text, width/2, height/2 + 74 - i.age/2 + q*10);
    if ((i.age-=0.4)<=0) removeInfo=i;
  }
  if (removeInfo!=null) infos.remove(removeInfo);
  if (frameCount == (tweak ? 1000000:4)) thread("checkGetLaunch");
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
      if (last>110) age = last+40;
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
