File file;
String filePath= "";

boolean hasMostRecent() {
  version = parseInt(loadStrings(LATEST_NUM_URL)[0]);
  log("latest version: " + version);
  try {
    file = new File(sketchPath() + File.separator + "data" + File.separator + "mbe_" + version + ".jar");
    filePath = file.getCanonicalPath();
    if (file.exists()) { /* delete file if nonmatching filesize */
      URL url = new URL(FILE_URL);
      URLConnection connection = url.openConnection();
      connection.connect();
      if (connection.getContentLength() != file.length()) {
        log("deleting corrupt jar");
        file.delete();
      }
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  return file.exists();
}

void downloadJar() {
  try {
    URL url = new URL(FILE_URL);
    URLConnection connection = url.openConnection();
    connection.connect();
    int fileLength = connection.getContentLength(), bytesRead, fileProgress = 0;
    byte dataBuffer[] = new byte[1024]; 
    BufferedInputStream in = new BufferedInputStream(url.openStream());
    FileOutputStream out = new FileOutputStream(filePath);
    log("#" + version + " downloading");
    while ((bytesRead = in.read(dataBuffer, 0, 1024)) != -1) {
      fileProgress += bytesRead;
      out.write(dataBuffer, 0, bytesRead);
      dlProgress =  fileProgress*100.0 / (fileLength);
      println(dlProgress);
    }
    log("downloaded file " + filePath);
    out.close();
    in.close();
    removeOldBuilds();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
}

void removeOldBuilds() {
  File folder = new File(sketchPath()+File.separator + "data"+ File.separator);
  File[] listOfFiles = folder.listFiles();
  for (int i = 0; i < listOfFiles.length; i++) {
    if (listOfFiles[i].isFile()) {
      String name = listOfFiles[i].getName();
      if (name.contains("mbe_") && name.contains(".jar") && !name.contains(str(version))) {
        log("deleting " + name);
        listOfFiles[i].delete();
      }
    }
  }
}