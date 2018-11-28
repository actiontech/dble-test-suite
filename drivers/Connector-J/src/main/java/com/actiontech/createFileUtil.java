package com.actiontech;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
//import java.io.InputStream;
//import java.io.OutputStream;
//import java.util.ArrayList;

public class createFileUtil {

    public static boolean createDir(String destDirName) {
        File dir = new File(destDirName);
        if (dir.exists()) {
            System.out.println("创建目录" + destDirName + "失败，目标目录已经存在");
            return true;
        }
        if (!destDirName.endsWith(File.separator)) {
            destDirName = destDirName + File.separator;
        }
        //创建目录
        if (dir.mkdirs()) {
            System.out.println("创建目录" + destDirName + "成功！");
            return true;
        } else {
            System.out.println("创建目录" + destDirName + "失败！");
            return false;
        }
    }

    public static ArrayList<String> createFile(String filePath, String[] destFileNames) {
        ArrayList<String> newfiles = new ArrayList<String>();
        //判断目标文件所在的目录是否存在,不存在则先创建
        File dir = new File(filePath);
        if (!dir.exists() && !dir.isDirectory()) {
            if (!createDir(filePath)) {
                System.out.println("创建文件夹失败！");
                return null;
            }
        }
        for (int i = 0; i < destFileNames.length; i++) {
            String fpath = filePath + "\\" + destFileNames[i];
            File file = new File(fpath);
            if (!file.exists()) {
                //存在则删除重建？
                System.out.println("创建文件" + destFileNames[i] + "失败，目标文件已存在！");
                file.delete();
            }
            //创建目标文件
            try {
                if (file.createNewFile()) {
                    System.out.println("创建文件" + destFileNames[i] + "成功！");
                    newfiles.add(fpath);
                } else {
                    System.out.println("创建文件" + destFileNames[i] + "失败！");
                    return null;
                }
            } catch (IOException e) {
                e.printStackTrace();
                System.out.println("创建文件" + destFileNames[i] + "失败！" + e.getMessage());
                return null;
            }
        }
        return newfiles;
    }

}
