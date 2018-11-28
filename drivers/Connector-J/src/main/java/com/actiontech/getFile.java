package com.actiontech;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class getFile {

    public static ArrayList<String> getFiles(String path) {
        ArrayList<String> filelist = new ArrayList<String>();
        File files = new File(path);
        File[] array = files.listFiles();
        for (int i = 0; i < array.length; i++) {
            if (array[i].isFile()) {
                String sqlpathname = array[i].getAbsolutePath();
                String sqlpath = array[i].getPath();
                String sqlname = array[i].getName();
                filelist.add(sqlpathname);
            } else {
                if (array[i].isDirectory()) {
                    getFiles(array[i].getPath());
                }
            }
        }
        return filelist;
    }
}

