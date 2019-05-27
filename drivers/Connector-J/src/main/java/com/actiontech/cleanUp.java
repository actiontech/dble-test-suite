/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech;

import java.io.*;
import java.sql.Connection;
import java.sql.Statement;

public class cleanUp {

    public static void rmfile(String filename){
        String curpath = System.getProperty("user.dir");
        String path = curpath + "\\" + filename;
        File loadfile = new File(path);
        if(loadfile.exists()){
            loadfile.delete();
        }
    }

    public static void closeFileWriter(FileWriter fw){
        if(fw!=null){
            try {
                fw.close();

            } catch (Exception fe) {
                //fe.printStackTrace();
                System.out.println("close：" + fw + "failed！");
            }
        }
        fw = null;
    }

    public static void closeBufferedWriter(BufferedWriter bw){
        if(bw!=null){
            try {
                bw.close();

            } catch (Exception fe) {
                fe.printStackTrace();
                System.out.println("close：" + bw + "failed！");
            }
        }
        bw = null;
    }

    public static void closeFileReader(FileReader fr){
        if(fr!=null){
            try {
                fr.close();

            } catch (Exception fe) {
                fe.printStackTrace();
                System.out.println("close：" + fr + "failed！");
            }
        }
        fr = null;
    }

    public static void closeBufferedReader(BufferedReader br){
        if(br!=null){
            try {
                br.close();

            } catch (Exception fe) {
                fe.printStackTrace();
                System.out.println("close：" + br + "failed！");
            }
        }
        br = null;
    }

    public static void closeConn(Connection conn){
        if(conn!=null){
            try {
                conn.close();

            } catch (Exception fe) {
                fe.printStackTrace();
                System.out.println("close：" + conn + "failed！");
            }
        }
        conn = null;
    }

    public static void closeStmt(Statement stmt){
        if(stmt!=null){
            try {
                stmt.close();

            } catch (Exception fe) {
                fe.printStackTrace();
                System.out.println("close：" + stmt + "failed！");
            }
        }
        stmt = null;
    }

}
