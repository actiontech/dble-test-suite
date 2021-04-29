package com.actiontech.dble;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;

/**
 * @author wangjuan
 * @version 1.0
 * @date 2021/4/25 17:21
 * @description general log test case
 * @modifiedBy
 **/
public class GeneralLogTest extends InterfaceTest {
    public GeneralLogTest(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
        super(mysqlProp, dbleProp);
    }

    protected void start() throws SQLException {
        try {
            testGeneralLog();
        } catch (Exception e) {
            System.out.println("GeneralLogTest throw exception ====> " + e.getMessage());
        }
    }

    private void testGeneralLog() throws SQLException {
        //get general log file path
        String generalLogFile = getGeneralLogFile();

        //delete old general log file
        SSHCommandExecutor sshExecutor = new SSHCommandExecutor(dbleProp.serverName, Config.SSH_USER,
                Config.SSH_PASSWORD);
        sshExecutor.execute("rm -f " + generalLogFile);

        //enable general log
        String cmd = Config.getdbleAdminCmd("enable @@general_log");
        sshExecutor.execute(cmd);

        //execute sql
        executeClientSql();

        //check values
        Map<String, Integer> sqlMap = new HashMap<>();
        sqlMap.put("drop table if exists sharding_4_t1", 2);
        sqlMap.put("drop table if exists sharding_2_t1", 2);
        sqlMap.put("create table sharding_4_t1(id int, name varchar(10), age int, primary key (id))", 1);
        sqlMap.put("create table sharding_2_t1(id int, name varchar(10)", 1);
        for (int i = 1; i < 5; i++) {
            sqlMap.put("INSERT INTO sharding_4_t1(id, name, age) VALUES(" + i + ", 'name" + i +"', " + i * 10 + ")", 1);
        }
        sqlMap.put("INSERT INTO sharding_2_t1(id, name) VALUES(1, 'name1'),(2, 'name2')", 1);
        sqlMap.put("Quit", 2);
        boolean flag = checkGeneralLog(sshExecutor, generalLogFile, sqlMap);

        //delete general log file
        sshExecutor.execute("rm -f " + generalLogFile);
        //reset general log
        sshExecutor.execute(Config.getdbleAdminCmd("disable @@general_log"));

        if (flag) {
            System.out.println("pass! general log case success.");
        }else {
            on_assert_fail("failed! general log case failed");
        }
    }

    private String getGeneralLogFile() throws SQLException {
        String urlString = "jdbc:mysql://" + dbleProp.serverName + ":" + Config.TEST_ADMIN_PORT + "?useSSL=false";
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(urlString, Config.TEST_ADMIN, Config.TEST_ADMIN_PASSWD);
            statement = conn.prepareStatement("select variable_value from dble_information.dble_variables where variable_name ='generalLogFile'");
            resultSet = statement.executeQuery();
            if (resultSet.next()){
                return resultSet.getString(1);
            }

        }catch (SQLException e){
            on_assert_fail("failed! general log case failed, at getGeneralLogFile() : " + e.getMessage());
        }finally {
            if (resultSet != null){
                resultSet.close();
            }
            if (statement != null){
                statement.close();
            }
            if (conn != null){
                conn.close();
            }
        }
        return null;
    }

    private void executeClientSql() throws SQLException {

        Connection conn = null;
        Statement statement = null;
        PreparedStatement preparedStatement = null;

        try {
            String urlString = "jdbc:mysql://" + dbleProp.serverName + ":" + dbleProp.portNumber + "?useSSL=false";
            conn = DriverManager.getConnection(urlString, Config.TEST_USER, Config.TEST_USER_PASSWD);
            conn.setCatalog(dbleProp.dbName);
            statement = conn.createStatement();
            statement.addBatch("drop table if exists sharding_4_t1");
            statement.addBatch("drop table if exists sharding_2_t1");
            statement.addBatch("create table sharding_4_t1(id int, name varchar(10), age int, primary key (id))");
            statement.addBatch("create table sharding_2_t1(id int, name varchar(10))");
            statement.executeBatch();

            preparedStatement = dbleConn.prepareStatement("INSERT INTO sharding_4_t1(id, name, age) VALUES(?, ?, ?)");
            for (int i = 1; i < 5; i++) {
                preparedStatement.setInt(1, i);
                preparedStatement.setString(2, "name" + i);
                preparedStatement.setInt(3, i * 10);
                preparedStatement.addBatch();
            }
            preparedStatement.executeBatch();

            preparedStatement = dbleConn.prepareStatement("INSERT INTO sharding_2_t1(id, name) VALUES(1, 'name1'),(2, 'name2')");
            preparedStatement.execute();

            statement.execute("drop table if exists sharding_4_t1");
            statement.execute("drop table if exists sharding_2_t1");

        } catch (SQLException exception) {
            on_assert_fail("failed! general log case failed, at executeClientSql() : " + exception.getMessage());
        }finally {
            if (statement != null){
                statement.close();
            }
            if (preparedStatement != null){
                preparedStatement.close();
            }
            if (conn != null){
                conn.close();
            }
        }
    }

    private boolean checkGeneralLog(SSHCommandExecutor sshExecutor, String generalLogFile, Map<String, Integer> sqlMap){
        boolean flag = true;
        if (sqlMap != null && !sqlMap.isEmpty()) {
            for (String sql : sqlMap.keySet()) {
                String catCmd = "cat " + generalLogFile + " | grep \"" + sql + "\" | wc -l";
                sshExecutor.execute(catCmd);
                Vector<String> outVector = sshExecutor.getStandardOutput();

                if (outVector != null) {
                    Integer result = Integer.parseInt(outVector.lastElement().trim());
                    Integer expect = sqlMap.get(sql);
                    if(result == null || result != expect){
                        System.out.println(sql + ", expected : " + expect + ", result : " + result);
                        flag = false;
                    }
                }else{
                    flag = false;
                }
            }
        }

        return flag;
    }
}
