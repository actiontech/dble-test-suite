package com.actiontech;

import java.io.*;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class executeManager {
    public static void execute(String rtPath_value, String sqPath_value, Statement dblemanagerstmt){
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
        //打开log文件
        FileWriter passfw = null;
        BufferedWriter passbw = null;
        FileWriter failfw = null;
        BufferedWriter failbw = null;
        try {
            passfw = new FileWriter(rspaths.get(0), true);
            passbw = new BufferedWriter(passfw);
            failfw = new FileWriter(rspaths.get(1), true);
            failbw = new BufferedWriter(failfw);
        } catch (Exception fe) {
            fe.printStackTrace();
            return;
        }
        //循环执行sql文件内的语句
        FileReader fr = null;
        BufferedReader br = null;
        try {
            fr = new FileReader(sqPath_value);
            br = new BufferedReader(fr);

            String line = null;
            int idNum = 1;
            try {
                //line = br.readLine();
                System.out.println(idNum);
                while ((line = br.readLine()) != null) {
                    if (line.startsWith("#") == false) {
                        String exec = "===File:" + sqPath_value + ",id:" + idNum + ",sql:" + line + "===" + "\r\n";
                        //dble执行sql
                        //判断语句类型，按不同函数执行 todo 大小写
                        ArrayList<String> dblerslist = new ArrayList<String>();
                        //sql转化为小写
                        line = line.toLowerCase();
                        try {
                            if (line.startsWith("select")|| line.startsWith("show")|| line.startsWith("check")) {
                                ResultSet dblers = dblemanagerstmt.executeQuery(line);
                                dblerslist = publicFunc.convertList(dblers);
                                String passstr = dblerslist.toString() + "\r\n" ;
                                passbw.write(exec);
                                passbw.write(passstr);
//                            } else if (line.startsWith("update") || line.startsWith("insert") || line.startsWith("delete")) {
//                                int dbleint = dblemanagerstmt.executeUpdate(line);
//                                String dbleintstr = String.valueOf(dbleint);
//                                dblerslist.add(dbleintstr);
//                                String passstr = dblerslist.toString() + "\r\n" ;
//                                passbw.write(exec);
//                                passbw.write(passstr);
                            } else {
                                boolean dbleboolean = dblemanagerstmt.execute(line);
                                String dbleboolstr = String.valueOf(dbleboolean);
                                dblerslist.add(dbleboolstr);
                                String passstr = dblerslist.toString() + "\r\n" ;
                                passbw.write(exec);
                                passbw.write(passstr);
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                            String dbleErrorMsg = "(" + e.getErrorCode() + "): " + e.getMessage();
                            dblerslist.add(dbleErrorMsg);
                            String failstr = dblerslist + "\r\n" ;
                            failbw.write(exec);
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
            return;
        } finally {
            //关闭sql文件读取流
            try {
                br.close();
            } catch (Exception fe) {
                fe.printStackTrace();
            }
            try {
                fr.close();
            } catch (Exception fe) {
                fe.printStackTrace();
            }
        }

        // 关闭打开的流

        try {
            failbw.close();
        } catch (Exception fe) {
            fe.printStackTrace();
        }
        try {
            failfw.close();
        } catch (Exception fe) {
            fe.printStackTrace();
        }
        try {
            passbw.close();
        } catch (Exception fe) {
            fe.printStackTrace();
        }
        try {
            passfw.close();
        } catch (Exception fe) {
            fe.printStackTrace();
        }

    }
}
