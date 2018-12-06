package com.actiontech;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.sql.*;
import java.io.*;
import java.util.*;


public class testJDBC {

    public static void main(String[] args) {
        //获取配置文件路径
        String config_path = "D:\\Jconnector\\src\\configs.yaml";
        Object cfg_path = com.actiontech.yamlParser.getConfig(config_path, "cfg_path");
        // object -> Map
        ObjectMapper oMapper = new ObjectMapper();
        Map<String, Object> path = oMapper.convertValue(cfg_path, Map.class);
        Object yaml_path = path.get("yaml_path");
        String ylPath_value = yaml_path.toString();
        Object result_path = path.get("result_path");
        String rtPath_value = result_path.toString();
        Object sqlfile_path = path.get("sqlfile_path");
        String sqPath_value = sqlfile_path.toString();

        //获取dble链接参数
        Object cfg_dble = com.actiontech.yamlParser.getConfig(ylPath_value, "cfg_dble");
        ObjectMapper oMapperdble = new ObjectMapper();
        Map<String, Object> cdble = oMapperdble.convertValue(cfg_dble, Map.class);
        Object client_user = cdble.get("client_user");
        String dbleuserName = client_user.toString();
        Object client_password = cdble.get("client_password");
        String dbleuserPwd = client_password.toString();
        String dbleURL = "jdbc:mysql://10.186.60.61:7131/mytest?characterEncoding=utf8";
        //manager
        Object manager_user = cdble.get("manager_user");
        String dblemanageruserName = manager_user.toString();
        Object manager_password = cdble.get("manager_password");
        String dblemanageruserPwd = manager_password.toString();
        String dblemanagerURL = "jdbc:mysql://10.186.60.61:7171/mytest?characterEncoding=utf8";

        //获取mysql链接参数
        Object cfg_mysql = com.actiontech.yamlParser.getConfig(ylPath_value, "cfg_mysql");
        ObjectMapper oMappermysql = new ObjectMapper();
        Map<String, Object> cmysql = oMappermysql.convertValue(cfg_mysql, Map.class);
        Object user = cmysql.get("user");
        Object password = cmysql.get("password");
        String msqluserName = user.toString();
        String mysqluserPwd = password.toString();
        String mysqlURL = "jdbc:mysql://10.186.60.61:7144/mytest?characterEncoding=utf8";
        if (sqPath_value.contains("manager")) {
            Connection dblemanagerconn = null;
            dblemanagerconn = conn.DBconn(dblemanagerURL, dblemanageruserName, dblemanageruserPwd);
            if (dblemanagerconn != null) {
                Statement dblemanagerstmt = null;
                boolean stmterr = false;
                try {
                    dblemanagerstmt = dblemanagerconn.createStatement();
                } catch (SQLException e) {
                    e.printStackTrace();
                    System.out.println("dble创建statement失败");
                    stmterr = true;
                } finally {
                    if (stmterr == true) {
                        cleanUp.closeStmt(dblemanagerstmt);
                        cleanUp.closeConn(dblemanagerconn);
                        return;
                    }
                }
                com.actiontech.executeManager.execute(rtPath_value, sqPath_value, dblemanagerstmt);
                //关闭statement链接
                cleanUp.closeStmt(dblemanagerstmt);
                cleanUp.closeConn(dblemanagerconn);
            }
        } else {
            Connection dbleconn = null;
            Connection mysqlconn = null;
            dbleconn = conn.DBconn(dbleURL, dbleuserName, dbleuserPwd);
            mysqlconn = conn.DBconn(mysqlURL, msqluserName, mysqluserPwd);
            if (dbleconn != null && mysqlconn != null) {
                Statement dblestmt = null;
                Statement mysqlstmt = null;
                boolean dblestmterr = false;
                boolean mysqlstmterr = false;
                try {
                    dblestmt = dbleconn.createStatement();
                } catch (SQLException e) {
                    e.printStackTrace();
                    System.out.println("dble创建statement失败");
                    dblestmterr = true;
                } finally {
                    if (dblestmterr == true) {
                        cleanUp.closeStmt(dblestmt);
                        cleanUp.closeConn(mysqlconn);
                        cleanUp.closeConn(dbleconn);
                        return;
                    }
                }
                try {
                    mysqlstmt = mysqlconn.createStatement();
                } catch (SQLException e) {
                    e.printStackTrace();
                    System.out.println("mysql创建statement失败");
                    mysqlstmterr = true;
                } finally {
                    if (mysqlstmterr == true) {
                        cleanUp.closeStmt(mysqlstmt);
                        cleanUp.closeStmt(dblestmt);
                        cleanUp.closeConn(mysqlconn);
                        cleanUp.closeConn(dbleconn);
                        return;
                    }
                }
                com.actiontech.execandCompare.execandCompare(rtPath_value, sqPath_value, dblestmt, mysqlstmt);
                //关闭statement链接及connection链接
                cleanUp.closeStmt(mysqlstmt);
                cleanUp.closeStmt(dblestmt);
                cleanUp.closeConn(mysqlconn);
                cleanUp.closeConn(dbleconn);
            }
        }
        com.actiontech.cleanUp.rmfile("test1.txt");
    }
}
