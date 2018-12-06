package com.actiontech;

import java.io.File;

public class cleanUp {
    public static void rmfile(String filename){
        String curpath = System.getProperty("user.dir");
        String path = curpath + "\\" + filename;
        File loadfile = new File(path);
        if(loadfile.exists()){
            loadfile.delete();
        }
    }
}
