/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
package com.actiontech;

import java.io.File;
import java.io.IOException;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;
//import java.io.InputStream;
//import java.io.OutputStream;
//import java.util.ArrayList;

public class createFileUtil {

    public static boolean createDir(String destDirName) {
        File dir = new File(destDirName);
        if (dir.exists()) {
            System.out.println("Create failed! " + destDirName + " existed");
            return true;
        }
        if (!destDirName.endsWith(File.separator)) {
            destDirName = destDirName + File.separator;
        }

        if (dir.mkdirs()) {
            System.out.println("create " + destDirName + " success！");
            return true;
        } else {
            System.out.println("create " + destDirName + " success！");
            return false;
        }
    }

    public static ArrayList<String> createFile(String filePath, String[] destFileNames) {
        ArrayList<String> newfiles = new ArrayList<String>();
        File dir = new File(filePath);
        if (!dir.exists() && !dir.isDirectory()) {
            if (!createDir(filePath)) {
                System.out.println("create failed！");
                //return null;
                System.exit(-1);
            }
        }
        for (int i = 0; i < destFileNames.length; i++) {
            String fpath = filePath + File.separator + destFileNames[i];
//            String fpath;
//            Path path = Paths.get(filePath,destFileNames[i]);
//            fpath = path.toString();
            File file = new File(fpath);
            if (file.exists()) {
                file.delete();
            }

            try {
                if (file.createNewFile()) {
                    System.out.println("create " + destFileNames[i] + " success！");
                    newfiles.add(fpath);
                } else {
                    System.out.println("create" + destFileNames[i] + " failed！");
                    //return null;
                    System.exit(-1);
                }
            } catch (IOException e) {
                e.printStackTrace();
                System.out.println("create " + destFileNames[i] + " failed！" + e.getMessage());
                //return null;
                System.exit(-1);
            }
        }
        return newfiles;
    }

}
