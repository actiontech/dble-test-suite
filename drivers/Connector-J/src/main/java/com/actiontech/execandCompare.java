package com.actiontech;

import java.util.*;
import java.io.*;
import java.sql.*;
import java.lang.String;

import com.fasterxml.jackson.databind.ObjectMapper;

public class execandCompare {

    public static void execandCompare(String rtPath_value, String sqPath_value, Statement dblestmt, Statement mysqlstmt) {
        //创建新的文件夹
        long currentTime = System.currentTimeMillis();
        String tst = String.valueOf(currentTime);
        String cfilepath = rtPath_value + "\\" + tst;
        com.actiontech.createFileUtil.createDir(cfilepath);

        File sqlf = new File(sqPath_value);
        String sqln = sqlf.getName().toString();
        String sqlfilename = sqln.substring(0, sqln.length() - 4);
        String sqlfile_pass = sqlfilename + "_pass.log";
        String sqlfile_fail = sqlfilename + "_fail.log";
        String[] rsfiles = {sqlfile_pass, sqlfile_fail};
        ArrayList<String> rspaths = com.actiontech.createFileUtil.createFile(cfilepath, rsfiles);
        //创建load临时文件
        com.actiontech.setUp.iniFile("test1.txt");
        //打开log文件
        FileWriter passfw = null;
        BufferedWriter passbw = null;
        FileWriter failfw = null;
        BufferedWriter failbw = null;
        boolean logwritererr = false;
        try {
            passfw = new FileWriter(rspaths.get(0), true);
            passbw = new BufferedWriter(passfw);
            failfw = new FileWriter(rspaths.get(1), true);
            failbw = new BufferedWriter(failfw);
        } catch (Exception fe) {
            fe.printStackTrace();
            logwritererr = true;
        } finally {
            if (logwritererr == true) {
                cleanUp.closeBufferedWriter(failbw);
                cleanUp.closeFileWriter(failfw);
                cleanUp.closeBufferedWriter(passbw);
                cleanUp.closeFileWriter(failfw);
                return;
            }
        }

        //循环执行sql文件内的语句
        FileReader fr = null;
        BufferedReader br = null;
        boolean sqlfileReaderErr = false;
        try {
            fr = new FileReader(sqPath_value);
            br = new BufferedReader(fr);

            String line = null;
            int idNum = 1;
            try {
                //line = br.readLine();
                while ((line = br.readLine()) != null) {
                    if (line.startsWith("#") == false) {
                        String exec = "===File:" + sqPath_value + ",id:" + idNum + ",sql:" + line + "===" + "\r\n";
                        //dble执行sql
                        //判断语句类型，按不同函数执行 todo 大小写
                        ArrayList<String> dblerslist = new ArrayList<String>();
                        //sql转化为小写
                        line = line.toLowerCase();
                        try {
                            if (line.startsWith("select")) {
                                ResultSet dblers = dblestmt.executeQuery(line);
                                dblerslist = publicFunc.convertList(dblers);
                            } else if (line.startsWith("update") || line.startsWith("insert") || line.startsWith("delete")) {
                                int dbleint = dblestmt.executeUpdate(line);
                                String dbleintstr = String.valueOf(dbleint);
                                dblerslist.add(dbleintstr);
                            } else {
                                boolean dbleboolean = dblestmt.execute(line);
                                String dbleboolstr = String.valueOf(dbleboolean);
                                dblerslist.add(dbleboolstr);
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                            //String dbleErrorMsg = e.getErrorCode() + e.getMessage();
                            String dbleErrorMsg = "(" + e.getErrorCode() + "): " + e.getMessage();
                            dblerslist.add(dbleErrorMsg);
                        }
                        //mysql执行sql
                        ArrayList<String> mysqlrslist = new ArrayList<String>();
                        try {
                            if (line.startsWith("select")) {
                                ResultSet mysqlrs = mysqlstmt.executeQuery(line);
                                mysqlrslist = publicFunc.convertList(mysqlrs);
                            } else if (line.startsWith("update") || line.startsWith("insert") || line.startsWith("delete")) {
                                int mysqlint = mysqlstmt.executeUpdate(line);
                                String mysqlintstr = String.valueOf(mysqlint);
                                mysqlrslist.add(mysqlintstr);
                            } else {
                                boolean mysqlboolean = mysqlstmt.execute(line);
                                String mysqlboolstr = String.valueOf(mysqlboolean);
                                mysqlrslist.add(mysqlboolstr);
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                            String mysqlErrorMsg = "(" + e.getErrorCode() + "): " + e.getMessage();
                            mysqlrslist.add(mysqlErrorMsg);
                        }
                        //比较结果集及错误是否一致，不一致写入fai.logl文件，一致写入pass.log
                        boolean same;
                        same = compare.compareList(dblerslist, mysqlrslist);
                        if (same) {
                            passbw.write(exec);
                            //String passstr = String.join(",", dblerslist);
                            String passstr = dblerslist.toString() + "\r\n";
                            passbw.write(passstr);
                        } else {
                            failbw.write(exec);
                            //String dblefailstr = String.join(",", dblerslist);
                            //String mysqlfailstr = String.join(",", mysqlrslist);
                            String dblefailstr = dblerslist.toString();
                            String mysqlfailstr = mysqlrslist.toString();
                            String failstr = "dble: " + dblefailstr + "\r\nmysql: " + mysqlfailstr + "\r\n";
                            failbw.write(failstr);
                        }
                    }
                    idNum++;
                }
            } catch (Exception fe) {
                fe.printStackTrace();
                return;
            }
        } catch (Exception fe) {
            fe.printStackTrace();
            sqlfileReaderErr = true;
        } finally {
            //关闭sql文件读取流
            cleanUp.closeBufferedReader(br);
            cleanUp.closeFileReader(fr);
        }

        // 关闭打开的流
        cleanUp.closeBufferedWriter(failbw);
        cleanUp.closeFileWriter(failfw);
        cleanUp.closeBufferedWriter(passbw);
        cleanUp.closeFileWriter(failfw);
    }
}



