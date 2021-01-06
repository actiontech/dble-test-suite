/*
 * Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech;

import java.io.*;
import java.sql.*;
import java.util.*;


public class testJDBC {

    public static void main(String[] args) {
        String dbleURL;
        String dblemanagerURL;
        String mysqlURL;
        String sqlfileClient;
        String sqlfileManager = null;
        String dblemanageruserName;
        String dblemanageruserPwd;
        String dbleuserName;
        String dbleuserPwd;
        String msqluserName;
        String mysqluserPwd;
        String logpath = System.getProperty("user.dir");
        
        if (args[0].equals("test")){
            dbleURL = "jdbc:mysql://10.186.60.61:7131/schema1?characterEncoding=utf8&useAffectedRows=true";
            dblemanagerURL = "jdbc:mysql://10.186.60.61:7171/schema1?characterEncoding=utf8&useAffectedRows=true";
            mysqlURL = "jdbc:mysql://10.186.60.61:7144/schema1?characterEncoding=utf8&useAffectedRows=true";
            sqlfileClient = "D:\\branch\\dble\\drivers\\Connector-J\\assets\\sql\\driver_test_client.sql&useAffectedRows=true";
            dblemanageruserName = "root";
            dblemanageruserPwd = "111111";
            dbleuserName = "test";
            dbleuserPwd = "111111";
            msqluserName = "test";
            mysqluserPwd = "111111";
        }else{
            System.out.println("run in online mode!");
            Config cfg = com.actiontech.yamlParser.getConfig(args[1]);
            dbleURL = "jdbc:mysql://" + cfg.dble_server + ":" + cfg.dble_port + "/" + cfg.db + "?characterEncoding=utf8&useAffectedRows=true";
            dblemanagerURL = "jdbc:mysql://" + cfg.dbleM_server + ":" + cfg.dbleM_port + "/" + cfg.managerDb + "?characterEncoding=utf8&useAffectedRows=true";
            mysqlURL = "jdbc:mysql://" + cfg.mysql_server + ":" + cfg.mysql_port + "/" + cfg.db + "?characterEncoding=utf8&useAffectedRows=true";
            sqlfileClient = cfg.sqlpath + File.separator + args[2];
            sqlfileManager = cfg.sqlpath + File.separator + args[3];
            dblemanageruserName = cfg.dbleM_user;
            dblemanageruserPwd = cfg.dbleM_password;
            dbleuserName = cfg.dble_user;
            dbleuserPwd = cfg.dble_password;
            msqluserName = cfg.mysql_user;
            mysqluserPwd = cfg.mysql_password;
            System.out.println("init connection parameters over!");
        }


         Connection dblemanagerconn = null;
         Connection dbleconn = null;
         Connection mysqlconn = null;
         dbleconn = conn.DBconn(dbleURL, dbleuserName, dbleuserPwd);
         mysqlconn = conn.DBconn(mysqlURL, msqluserName, mysqluserPwd);
         dblemanagerconn = conn.DBconn(dblemanagerURL, dblemanageruserName, dblemanageruserPwd);
         if (dbleconn != null && mysqlconn != null &&dblemanagerconn != null) {
                Statement dblestmt = null;
                Statement mysqlstmt = null;
                Statement dblemanagerstmt = null;
                boolean stmterr = false;
                boolean dblestmterr = false;
                boolean mysqlstmterr = false;
                try {
                    dblestmt = dbleconn.createStatement();
                } catch (SQLException e) {
                    System.out.println("dble create statement failed!");
                    e.printStackTrace();
                    dblestmterr = true;
                } finally {
                    if (dblestmterr == true) {
                        cleanUp.closeStmt(dblestmt);
                        cleanUp.closeConn(mysqlconn);
                        cleanUp.closeConn(dbleconn);
                        cleanUp.closeConn(dblemanagerconn);
                        System.exit(-1);
                    }
                }
                try {
                    mysqlstmt = mysqlconn.createStatement();
                } catch (SQLException e) {
                    System.out.println("mysql create statement failed!");
                    e.printStackTrace();
                    mysqlstmterr = true;
                } finally {
                    if (mysqlstmterr == true) {
                        cleanUp.closeStmt(mysqlstmt);
                        cleanUp.closeStmt(dblestmt);
                        cleanUp.closeConn(mysqlconn);
                        cleanUp.closeConn(dbleconn);
                        cleanUp.closeConn(dblemanagerconn);
                        System.exit(-1);
                    }
                }
                try {
                    dblemanagerstmt = dblemanagerconn.createStatement();
                } catch (SQLException e) {
                    System.out.println("dble create statement failed!");
                    e.printStackTrace();
                    stmterr = true;
                } finally {
                    if (stmterr == true) {
                    	cleanUp.closeStmt(mysqlstmt);
                        cleanUp.closeStmt(dblestmt);
                        cleanUp.closeStmt(dblemanagerstmt);
                        cleanUp.closeConn(mysqlconn);
                        cleanUp.closeConn(dbleconn);
                        cleanUp.closeConn(dblemanagerconn);
                        System.exit(-1);
                    }
                }
                com.actiontech.execandCompare.execandCompare(logpath, sqlfileClient, dblestmt, mysqlstmt);

                cleanUp.closeStmt(mysqlstmt);
                cleanUp.closeStmt(dblestmt);
                cleanUp.closeConn(mysqlconn);
                cleanUp.closeConn(dbleconn);

                com.actiontech.executeManager.execute(logpath, sqlfileManager,dblemanagerstmt);

                cleanUp.closeStmt(dblemanagerstmt);
                cleanUp.closeConn(dblemanagerconn);
            }

        com.actiontech.cleanUp.rmfile("test1.txt");
    }
}
