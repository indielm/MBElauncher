import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.io.*; 
import java.net.*; 
import java.nio.file.FileSystem.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class MBElauncher extends PApplet {





/*
  Mindustry bleeding edge autoupdate and launcher by Desktop aka indielm
  Source for Processing 3.3.6
*/

PImage logo;
String JENKINS_URL =  "https://jenkins.hellomouse.net/job/mindustry/";
String LATEST_URL = JENKINS_URL + "lastStableBuild/";
String LATEST_NUM_URL = LATEST_URL + "buildNumber";
String FILE_URL = LATEST_URL + "artifact/artifacts/desktop.jar";

int version = 0;
int dlProgress = 0;
boolean jarReady = false;

public void setup() {
  logo = imgFromString(logotext);
  
  ((PGraphicsOpenGL)g).textureSampling(2);
}

public boolean hasMostRecent() {
  String latest = loadStrings(LATEST_NUM_URL)[0];
  version = parseInt(latest);
  println("latest version: " + version);
  File f = new File(sketchPath() + File.separator + version + ".jar");
  return f.exists();
}

public void launchJar() {
  println("launching!");
  String cmds[] = {"java","-jar", sketchPath() + File.separator + version + ".jar"};
  try {
    exec(cmds);
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  exit();
}

public void downloadJar() {
  String FILE_NAME = sketchPath() + File.separator + version +".jar";
  try {
    URL url = new URL(FILE_URL);
    URLConnection connection = url.openConnection();
    connection.connect();
    int fileLength = connection.getContentLength();
    
    BufferedInputStream in = new BufferedInputStream(url.openStream());
    FileOutputStream fileOutputStream = new FileOutputStream(FILE_NAME);
    byte dataBuffer[] = new byte[1024];
    int bytesRead;
    print("#" + version + " downloading");
    long downloadedFileSize = 0;
    int k = 0;
    while ((bytesRead = in.read(dataBuffer, 0, 1024)) != -1) {
      downloadedFileSize += bytesRead;
      fileOutputStream.write(dataBuffer, 0, bytesRead);
      k++;
      if (k%50 == 0) {
        dlProgress = (int) ((((double)downloadedFileSize) / ((double)fileLength)) * 100d);
        println(dlProgress + "%");//((float)d)/fileLenth);
      }
    }
    fileOutputStream.close();
    in.close();
    jarReady = true;
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
  println();
  println("downloaded file " + FILE_NAME);
  launchJar();
  exit();
}

public void draw() {
  background(0);
  imageMode(CENTER);
  if (dlProgress!=0) {
    text("Downloading #"+ version + "      " + dlProgress + " %", 100, 40);
    stroke(255);
    noFill();
    rect(150,64,100,14);
    noStroke();
    fill(50,255,50);
    rect(150,64,dlProgress,14);
  }
  else {
    text("Checking latest version...", 100, 40);
  }
  translate(width/2, height/2);
  
  image(logo, 0, 0, logo.width*4, logo.height*4);
  fill(255);

  if (frameCount == 4) { // arbitrary wait time so window displays logo first
    jarReady = hasMostRecent();
    if (jarReady) {
      launchJar();
      exit();
    } else thread("downloadJar");
  }
}

String logotext = "89,21;0,4473924,-12303292,-738706,-1,-2974376,-6776156;0fffffeedda1b2da0a2d0b2ddb0a2eedddb0a2da1b0ddb1a2b3c2a0a2a4b2d4b2a4b2a4b2c4b2a4da2b4b2b4b2a4db2a4db2a4db2a4b2b4b2a0a2a3c2b1a0ddb2b3d2a0a2a4c2b4c2a4b2a4c2b4b2a4db2a4b2b4b2a4db2a4db2a4db2a4b2b4b2a0a2a3d2b0dda2b3d5a2a0a2a4dd2a4b2a4d2a4b2a4b6b4b2a4b2b4b2a4b6d2a6b4b6b2a4b6b4b2a4b2b4b2a0a2a5a3d2b0dd2a3d5b2a0a2a4dd2a4b2a4dc2a4b6b4b2a4b2b4b2a4db2a6b4b6b2a4b6b4b2a4db2a0a2a5b3d2a0dd2a3d5a2b0a2a4b6a4b6a4b2a4b2a4b6a4d2a4b2b4b2a4b2b4b2a4db2c4b2c4db2a4db2a0a2b5a3d2a0dd2a5a3d2b0a2a4b6d4b2a4b2a4b6b4c2a4b2b4b2a4b2b4b2a6d4b2a0a2a4b2a0a2a4da6a2a6b4b6b2a0a2b3d5a2a0dd2a5b3d2a0a2a4b2a6b2a4b2a4b2a4b2a6b4b2a4db2a4db2a4db2a0a2a4b2a0a2a4b6a4c2a6b4b6b2a0a2a3d5b2a0dd2b5b3c2a0a2a4b2d4b2a4b2a4b2b6a4b2a4da6a2a6a4d6a2a4db2a0a2a4b2a0a2a4b6b4b2c4b2c0a2a3c5b2b0dda2b5d2a0a2a6b2a0b2a6b2a6b2a6b2c6b2a6db2a6db2a6db2a0a2a6b2a0a2a6b2a6c2a0a2a6b2a0c2a5d2b0ddb1a2b5c2a0a2a6b2a0b2a6b2a6b2a6b2a0a2a6b2a6da2c6d2b6db2a0a2a6b2a0a2a6b2b6b2a0a2a6b2a0c2a5c2b1a0ddb1b2da0a2d0b2ddb0a2ddb0a2dddb0a2d0a2dd0a2d0c2da1b0fffffffa";
public PImage imgFromString(String data) {
  String segs[] = data.split(";");
  String size[] = segs[0].split(",");
  String prePallet[] = segs[1].split(",");
  String imgData = segs[2];
  imgData = imgData.replace("f", "eeee");
  imgData = imgData.replace("e", "dddd");
  imgData = imgData.replace("d", ",,,,");
  imgData = imgData.replace("c", ",,,");
  imgData = imgData.replace("b", ",,");
  imgData = imgData.replace("a", ",");
  String pix[] = imgData.split(",");
  int pallet[] = new int[prePallet.length];
  for (int i = 0; i < prePallet.length; i++) pallet[i] = Integer.parseInt(prePallet[i]);
  PImage img = createImage(Integer.parseInt(size[0]), Integer.parseInt(size[1]), ARGB);
  img.loadPixels();
  int lastPix = -1000;
  for (int i = 0; i < pix.length; i++) {
    int e;
    if (pix[i].equals("")) e = lastPix;
    else {
      e = pallet[Integer.parseInt(pix[i])];
      lastPix = e;
    }
    img.pixels[i] = e;
  }
  img.updatePixels();
  return img;
}
  public void settings() {  size(360, 240,P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MBElauncher" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
