/*
 * Copyright (C) 2016-2023 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
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
                rowData.put(md.getColumnLabel(i), rs.getObject(i));//get key and name
            }
            list.add(rowData);
        }
        return list;
    }
// 使用md.getColumnLabel的原因：当列有别名时getColumnLabel返回值是别名，列无别名时和getColumnName返回值相同
// dble和mysql返回的结果是一样的，但mysql的metadata里originalColumnName无值，所以getColumnName方法返回了columnName的值，dble的metadata里originalColumnName有值，getColumnName返回的值就是originalColumnName
// 又因hashMap是无序的，dble中将count转换成了大写，hashMap取出的值count放到了第一列
// select pad,count(id) t from schema2.test2 group by pad having t>1;
// dble-------------com.mysql.jdbc.ResultSetMetaData@3caeaf62 - Field level information:
//	com.mysql.jdbc.Field@e6ea0c6[catalog=schema2,tableName=test2,originalTableName=test2,columnName=pad,originalColumnName=,mysqlType=3(FIELD_TYPE_LONG),flags=, charsetIndex=63, charsetName=US-ASCII]
//	com.mysql.jdbc.Field@6a38e57f[catalog=schema2,tableName=test2,originalTableName=test2,columnName=t,originalColumnName=COUNT(id),mysqlType=8(FIELD_TYPE_LONGLONG),flags=, charsetIndex=63, charsetName=US-ASCII]
// mysql============com.mysql.jdbc.ResultSetMetaData@5577140b - Field level information:
//	com.mysql.jdbc.Field@1c6b6478[catalog=schema2,tableName=test2,originalTableName=test2,columnName=pad,originalColumnName=pad,mysqlType=3(FIELD_TYPE_LONG),flags=, charsetIndex=63, charsetName=US-ASCII]
//	com.mysql.jdbc.Field@67f89fa3[catalog=,tableName=,originalTableName=,columnName=t,originalColumnName=,mysqlType=8(FIELD_TYPE_LONGLONG),flags=, charsetIndex=63, charsetName=US-ASCII]

}
