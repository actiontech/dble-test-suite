package com.actiontech;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;

public class conn {

    public static Connection DBconn(String dbURL, String userName, String userPwd) {
        Connection conn = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, userName, userPwd);
            System.out.println("Connection Successful!");
            return conn;
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
            try {
                if (conn != null) {
                    conn.close();
                    conn = null;
                }
            } catch (SQLException ce){
                ce.printStackTrace();
                return null;
            }
        }
        return null;
    }
}