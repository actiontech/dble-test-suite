/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
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
            //return conn;
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            System.exit(-1);
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
            try {
                if (conn != null) {
                    conn.close();
                    conn = null;
                    System.exit(-1);
                }
            } catch (SQLException ce){
                ce.printStackTrace();
                System.exit(-1);
            }
        }
        return conn;
    }
}