package com.actiontech;

import java.io.*;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class executeManager {
    public static void execute(String rtPath_value, String sqPath_value, Statement dblemanagerstmt) {
//        long currentTime = System.currentTimeMillis();
        String dirName = "sql_logs";
        String cfilepath = rtPath_value + File.separator + dirName;
        com.actiontech.createFileUtil.createDir(cfilepath);

        File sqlf = new File(sqPath_value);
        String sqln = sqlf.getName().toString();
        String sqlfilename = sqln.substring(0, sqln.length() - 4);
        String sqlfile_pass = sqlfilename + "_pass.log";
        String sqlfile_fail = sqlfilename + "_fail.log";
        String[] rsfiles = {sqlfile_pass, sqlfile_fail};
        ArrayList<String> rspaths = com.actiontech.createFileUtil.createFile(cfilepath, rsfiles);

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
                System.out.println(idNum);
                while ((line = br.readLine()) != null) {
                    if (line.startsWith("#") == false) {
                        String exec = "===file:" + sqPath_value + ",id:" + idNum + ",sql:" + line + "===" + "\r\n";
                        ArrayList<String> dblerslist = new ArrayList<String>();
                        line = line.toLowerCase();
                        try {
                            if (line.startsWith("select") || line.startsWith("show") || line.startsWith("check")) {
                                ResultSet dblers = dblemanagerstmt.executeQuery(line);
                                dblerslist = publicFunc.convertList(dblers);
                                String passstr = dblerslist.toString() + "\r\n";
                                passbw.write(exec);
                                passbw.write(passstr);
                            } else {
                                boolean dbleboolean = dblemanagerstmt.execute(line);
                                String dbleboolstr = String.valueOf(dbleboolean);
                                dblerslist.add(dbleboolstr);
                                String passstr = dblerslist.toString() + "\r\n";
                                passbw.write(exec);
                                passbw.write(passstr);
                            }
                        } catch (SQLException e) {
                            //e.printStackTrace();
                            String dbleErrorMsg = "(" + e.getErrorCode() + "): " + e.getMessage();
                            dblerslist.add(dbleErrorMsg);
                            String failstr = dblerslist + "\r\n";
                            failbw.write(exec);
                            failbw.write(failstr);
                        }
                    }
                    idNum++;
                }
            } catch (Exception fe) {
                fe.printStackTrace();
            }
        } catch (Exception fe) {
            fe.printStackTrace();
            sqlfileReaderErr = true;
        } finally {
            cleanUp.closeBufferedReader(br);
            cleanUp.closeFileReader(fr);
        }

        cleanUp.closeBufferedWriter(failbw);
        cleanUp.closeFileWriter(failfw);
        cleanUp.closeBufferedWriter(passbw);
        cleanUp.closeFileWriter(failfw);
    }
}
