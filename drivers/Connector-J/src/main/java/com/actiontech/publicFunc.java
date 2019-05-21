/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
package com.actiontech;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class publicFunc {
    //convert ResultSet to list
    public static ArrayList convertList(ResultSet rs) throws SQLException {
        ArrayList list = new ArrayList();
        ResultSetMetaData md = rs.getMetaData();//get key name
        int columnCount = md.getColumnCount();
        while (rs.next()) {
            Map rowData = new HashMap();
            for (int i = 1; i <= columnCount; i++) {
                rowData.put(md.getColumnName(i), rs.getObject(i));//get key and name
            }
            list.add(rowData);
        }
        return list;
    }

}
