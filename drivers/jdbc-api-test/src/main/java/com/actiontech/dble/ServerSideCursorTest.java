/* Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech.dble;

import java.sql.*;

/**
 * @author wangjuan
 * @version 1.0
 * @date 2021/2/1 17:44
 **/
public class ServerSideCursorTest extends InterfaceTest {

    public ServerSideCursorTest(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
        super(mysqlProp, dbleProp);
    }

    public void start() throws SQLException {
        testCursor();
    }

    private void testCursor() throws SQLException {
        SSHCommandExecutor sshExecutor = new SSHCommandExecutor(dbleProp.serverName, Config.SSH_USER,
                Config.SSH_PASSWORD);

        //check enableCursor
        String adminCmd = Config.getdbleAdminCmd("select variable_value from dble_information.dble_variables where variable_name like '%enableCursor%';");
        sshExecutor.execute(adminCmd);
        System.out.println("current enableCursor is : " + sshExecutor.getStandardOutput().lastElement().trim().split("\n")[1]);

        //enableCursor default value is false
        executeCursor(true);
        executeCursor(false);

        //set enableCursor=true
        String cmd = "sed -i -e '/-DenableCursor/d' -e '$a -DenableCursor=true' /opt/dble/conf/bootstrap.cnf && /opt/dble/bin/dble restart";
        sshExecutor.execute(cmd);
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        //check enableCursor
        sshExecutor.execute(adminCmd);
        System.out.println("current enableCursor is : " + sshExecutor.getStandardOutput().lastElement().trim().split("\n")[1]);

        executeCursor(true);
        executeCursor(false);

        //reset enableCursor=false
        cmd = "sed -i -e '/-DenableCursor/d' /opt/dble/conf/bootstrap.cnf && /opt/dble/bin/dble restart";
        sshExecutor.execute(cmd);
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    private void executeCursor(boolean useCursorFetch) throws SQLException {
        Connection connection = null;
        try {
            connection = getConnection(useCursorFetch);
            //create table
            createTable(connection);
            //insert table
            insertTable(connection);

            //no sharding table
            testForTable(connection, "no_sharding_t1", "test");

            //sharding table
            testForTable(connection, "sharding_4_t1", "test");

            //global table
            testForTable(connection, "test", "no_sharding_t1");

            System.out.println("pass! server side cursor test success, useCursorFetch = " + useCursorFetch);

        } catch (Exception exception) {
            System.out.println("failed! server side cursor test failed => " + exception.getMessage());
            exception.printStackTrace(System.err);
        }finally {
            if(connection != null){
                dropTable(connection);
                connection.close();
            }
        }
    }

    private void testForTable(Connection connection, String table1, String table2) throws SQLException {
        String noParamSql = "select * from " + table1 + " limit 2000";
        String paramSql = "select * from " + table1 + " where sex = ? order by id desc limit 2000";
        String groupBySql = "select id from " + table1 + " where id < ? group by id limit 2000";
        String joinSql = "select t1.* from " + table1 + " t1 join " + table2 + " t2 on t1.id = t2.id where t1.id > ? order by t1.id desc limit 2000";
        String joinSql2 = "select t1.* from " + table1 + " t1," + table2 + " t2 where t1.id = t2.id and t1.sex < ? order by t1.id desc limit 2000";

        executeSql(connection, noParamSql, 1, null, table1);
        executeSql(connection, noParamSql, 500, null, table1);

        executeSql(connection, paramSql, 1, 1, table1);
        executeSql(connection, paramSql, 500, 1, table1);

        executeSql(connection, groupBySql, 1, 100, null);
        executeSql(connection, groupBySql, 500, 100, null);

        executeSql(connection, joinSql, 1, 0, table1);
        executeSql(connection, joinSql, 500, 0, table1);

        executeSql(connection, joinSql2, 1, 2, table1);
        executeSql(connection, joinSql2, 500, 2, table1);
    }

    private void executeSql(Connection connection, String sql, int fetchSize, Integer paramValue, String leftTable) throws SQLException {

        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            stmt = connection.prepareStatement(sql);
            stmt.setFetchSize(fetchSize);
            if (paramValue != null) {
                stmt.setInt(1, paramValue);
            }

            rs = stmt.executeQuery();

            //check temp file and bootstrap parameter
            int count = 0;
            while(rs.next()){
                ++count;
                if (leftTable == null || leftTable.isEmpty()){
                    String resultStr = " column1 : " + rs.getString(1);
                }else {
                    String resultStr = " column1 : " + rs.getInt(1) +
                            " column2 : " + rs.getString(2) +
                            " column3 : " + rs.getByte(3);
                    if (!leftTable.equals("test")) {
                        resultStr += " column4 : " + rs.getBlob(4).toString() +
                                " column5 : " + rs.getClob(5);
                    }
                }
            }
            print_debug("sql : " + sql + ", total count is : " + count);

        } catch (SQLException exception) {
            exception.printStackTrace();
        }finally {
            if(rs != null){
                rs.close();
            }
            if(stmt != null){
                stmt.close();
            }
        }

    }

    private Connection getConnection(boolean useCursorFetch) throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.jdbc.Driver");
        String url = "jdbc:mysql://" + Config.Host_Test + ":" + Config.TEST_PORT + "/schema1?useCursorFetch=" + useCursorFetch;
        Connection conn = DriverManager.getConnection(url, Config.TEST_USER, Config.TEST_USER_PASSWD);
        conn.setCatalog(Config.TEST_DB);
        return conn;
    }

    private void createTable(Connection connection) throws SQLException {

        Statement statement = connection.createStatement();
        //no sharding table
        statement.addBatch("drop table if exists no_sharding_t1");
        statement.addBatch("create table no_sharding_t1 (id int, name varchar(20), sex smallint, image blob, description text, num_id int)");
        //sharding table
        statement.addBatch("drop table if exists sharding_4_t1");
        statement.addBatch("create table sharding_4_t1 (id int, shard_name varchar(20), sex smallint, shard_image blob, shard_desc text, number_id int)");
        //global table
        statement.addBatch("drop table if exists test");
        statement.addBatch("create table test (id int, global_name varchar(20), sex smallint)");

        statement.executeBatch();
        if (statement != null){
            statement.close();
        }
    }

    private void insertTable(Connection connection) throws SQLException {

        Blob blobInfo = connection.createBlob();
        byte[] blobData = new byte[32];
        for (int i = 0; i < blobData.length; i++) {
            blobData[i] = 1;
        }
        blobInfo.setBytes(1, blobData);

        Clob clobInfo = connection.createClob();
        clobInfo.setString(1, new String(blobData));

        PreparedStatement statement1 = connection.prepareStatement("INSERT INTO no_sharding_t1(id, name, sex, image, description, num_id) VALUES(?, ?, ?, ?, ?, ?)");
        PreparedStatement statement2 = connection.prepareStatement("INSERT INTO sharding_4_t1 (id, shard_name, sex, shard_image, shard_desc, number_id) VALUES(?, ?, ?, ?, ?, ?)");
        PreparedStatement statement3 = connection.prepareStatement("INSERT INTO test (id, global_name, sex) VALUES (?, ?, ?)");

        for (int i = 1; i <= 8; i++) {
            statement1.setInt(1, i);
            statement1.setString(2, "name" + i);
            statement1.setByte(3, (byte) (i%2));
            statement1.setBlob(4, blobInfo);
            statement1.setClob(5, clobInfo);
            statement1.setInt(6, i);
            statement1.addBatch();
            statement1.clearParameters();

            statement2.setInt(1, i);
            statement2.setString(2, "name" + i);
            statement2.setByte(3, (byte) (i%2));
            statement2.setBlob(4, blobInfo);
            statement2.setClob(5, clobInfo);
            statement2.setInt(6, i);
            statement2.addBatch();
            statement2.clearParameters();

            statement3.setInt(1, i);
            statement3.setString(2, "name" + i);
            statement3.setByte(3, (byte) (i%2));
            statement3.addBatch();
            statement3.clearParameters();
        }
        statement1.executeBatch();
        statement2.executeBatch();
        statement3.executeBatch();

        Statement statement = connection.createStatement();
        for (int i = 0; i < 8; i++) {
            statement.addBatch("INSERT INTO no_sharding_t1 select * from no_sharding_t1");
            statement.addBatch("INSERT INTO sharding_4_t1 select * from sharding_4_t1");
            statement.addBatch("INSERT INTO test select * from test");
        }
        statement.executeBatch();

        if (statement != null){
            statement.close();
        }
        if (statement1 != null){
            statement1.close();
        }
        if (statement2 != null){
            statement2.close();
        }
        if (statement3 != null){
            statement3.close();
        }
    }

    private void dropTable(Connection connection) throws SQLException {
        Statement statement = connection.createStatement();
        statement.addBatch("drop table no_sharding_t1");
        statement.addBatch("drop table sharding_4_t1");
        statement.addBatch("drop table test");
        statement.executeBatch();

        if (statement != null){
            statement.close();
        }
    }
}