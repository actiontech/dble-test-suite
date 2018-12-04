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
                try {
                    dblemanagerstmt = dblemanagerconn.createStatement();
                } catch (SQLException e) {
                    e.printStackTrace();
                    System.out.println("dble创建statement失败");
                    return;
                }
                com.actiontech.executeManager.execute(rtPath_value, sqPath_value, dblemanagerstmt);
                //关闭statement链接
                if (dblemanagerstmt != null) {
                    try {
                        dblemanagerstmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    dblemanagerstmt = null;
                }
            }
            if (dblemanagerconn != null) {
                try {
                    dblemanagerconn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                dblemanagerconn = null;
            }
        } else {
            Connection dbleconn = null;
            Connection mysqlconn = null;
            dbleconn = conn.DBconn(dbleURL, dbleuserName, dbleuserPwd);
            mysqlconn = conn.DBconn(mysqlURL, msqluserName, mysqluserPwd);
            if (dbleconn != null && mysqlconn != null) {
                Statement dblestmt = null;
                Statement mysqlstmt = null;
                try {
                    dblestmt = dbleconn.createStatement();
                } catch (SQLException e) {
                    e.printStackTrace();
                    System.out.println("dble创建statement失败");
                    return;
                }
                try {
                    mysqlstmt = mysqlconn.createStatement();
                } catch (SQLException e) {
                    e.printStackTrace();
                    System.out.println("mysql创建statement失败");
                    return;
                }
                com.actiontech.execandCompare.execandCompare(rtPath_value, sqPath_value, dblestmt, mysqlstmt);
                //关闭statement链接
                if (dblestmt != null) {
                    try {
                        dblestmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    dblestmt = null;
                }
                if (mysqlstmt != null) {
                    try {
                        mysqlstmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    mysqlstmt = null;
                }
            }
            //关闭connection链接
            if (dbleconn != null) {
                try {
                    dbleconn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                dbleconn = null;
            }
            if (mysqlconn != null) {
                try {
                    mysqlconn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                mysqlconn = null;
            }
        }
        com.actiontech.cleanUp.rmfile("test1.txt");
    }
}
