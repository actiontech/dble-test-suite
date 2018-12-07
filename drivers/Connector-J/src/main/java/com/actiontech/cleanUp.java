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
                fe.printStackTrace();
                System.out.println("关闭：" + fw + "失败！");
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
                System.out.println("关闭：" + bw + "失败！");
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
                System.out.println("关闭：" + fr + "失败！");
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
                System.out.println("关闭：" + br + "失败！");
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
                System.out.println("关闭：" + conn + "失败！");
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
                System.out.println("关闭：" + stmt + "失败！");
            }
        }
        stmt = null;
    }

}
