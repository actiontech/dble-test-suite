/*
 * Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
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
        String path = curpath + File.separator + filename;
        File loadfile = new File(path);
        if (loadfile.exists()) {
            loadfile.delete();
        }
        try{
            loadfile.createNewFile();
        }catch(Exception fe){
            System.out.println("create："+ filename + " failed！");
            fe.printStackTrace();
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
                System.out.println("write to ："+ datalist[i] + " failed！");
                e.printStackTrace();
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
