package com.actiontech;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class setUp {
    public static void iniFile(String filename){
        String[] datalist = {"10,10,'Vicky',10","11,11,'刘家',11"};
        //create file
        String curpath = System.getProperty("user.dir");
        String path = curpath + "\\" + filename;
        File loadfile = new File(path);
        if (loadfile.exists()) {
            loadfile.delete();
        }
        try{
            loadfile.createNewFile();
        }catch(Exception fe){
            fe.printStackTrace();
            System.out.println("创建文件："+ filename + "失败！");
            return;
        }

        //write data to file
        FileWriter fw = null;
        BufferedWriter bw = null;
        try {
            fw = new FileWriter(path, true);
            bw = new BufferedWriter(fw);
        } catch (Exception fe) {
            fe.printStackTrace();
            return;
        }
        for (int i=0;i<datalist.length;i++){
            try {
                bw.write(datalist[i] + '\n');
            }catch (IOException e){
                e.printStackTrace();
                System.out.println("写入数据："+ datalist[i] + "失败！");
            }
        }
        try {
            bw.close();
        } catch (Exception fe) {
            fe.printStackTrace();
        }
        try {
            fw.close();
        } catch (Exception fe) {
            fe.printStackTrace();
        }
    }
}
