/* Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech.dble;

import java.sql.*;
import java.util.Vector;

/**
 * @author wangjuan
 * @date 2020/12/21 10:20
 * @description TODO
 * @modifiedBy
 * @version 1.0
 */
public class CapClientFoundRowsTest extends InterfaceTest {

    public CapClientFoundRowsTest(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
        super(mysqlProp, dbleProp);
    }

    protected void start() throws SQLException {
        try {
            testCapClientFoundRows();
        } catch (Exception e) {
            System.out.println("throw exception ====> " + e.getMessage());
            e.printStackTrace();
        }finally {
            System.out.println("reset capClientFoundRows=true in bootstrap.cnf => start");
            resetDbleConfig(false);
            System.out.println("reset capClientFoundRows=true in bootstrap.cnf => end");
        }
    }

    private void testCapClientFoundRows() throws Exception {
        Main.print_debug("start :" + this.getClass() + " -> testCapClientFoundRows()");

        String trueLogStr = "the client requested CLIENT_FOUND_ROWS capabilities is 'affect rows', dble is configured as 'found rows',pls set the same.";
        String falseLogStr = "the client requested CLIENT_FOUND_ROWS capabilities is 'found rows', dble is configured as 'affect rows',pls set the same.";


        System.out.println("step 1:----> capClientFoundRows=true, useAffectedRows=true, return found rows and check logs");
        checkCapClientFoundRows(true, null, true, trueLogStr, 1);

        System.out.println("step 2:----> capClientFoundRows=true, useAffectedRows=false, return found rows");
        checkCapClientFoundRows(null, null, false, null, 1);

        //reset capClientFoundRows to default
        resetDbleConfig(false);
        System.out.println("step 3:----> capClientFoundRows=false, useAffectedRows=true, return found rows");
        checkCapClientFoundRows(false, null, true, null, 0);

        System.out.println("step 4:----> capClientFoundRows=false, useAffectedRows=false, return found rows and check logs");
        checkCapClientFoundRows(null, null, false, falseLogStr, 0);

        System.out.println("step 5:----> enable @@cap_client_found_rows, useAffectedRows=true, return found rows and check logs");
        checkCapClientFoundRows(null, true, true, trueLogStr, 1);

        System.out.println("step 6:----> enable @@cap_client_found_rows, useAffectedRows=false, return found rows");
        checkCapClientFoundRows(null, true, false, null, 1);

        System.out.println("step 7:----> disable @@cap_client_found_rows, useAffectedRows=true, return found rows");
        checkCapClientFoundRows(null, false, true, null, 0);

        System.out.println("step 8:----> disable @@cap_client_found_rows, useAffectedRows=false, return found rows and check logs");
        checkCapClientFoundRows(null, false, false, falseLogStr, 0);

        Main.print_debug("end :" + this.getClass() + " -> testCapClientFoundRows()");
    }

    /**
     * check capClientFoundRows
     * @throws SQLException
     */
    private void checkCapClientFoundRows(Boolean capClientFoundRows, Boolean capClientFoundRowsStatus,
                                         Boolean useAffectedRows, String logStr, Integer expectResult) throws Exception {

        if (capClientFoundRows != null){
            String cmd = "sed -i -e '/-DcapClientFoundRows/d' -e '$a -DcapClientFoundRows=" + capClientFoundRows
                    + "' /opt/dble/conf/bootstrap.cnf && /opt/dble/bin/dble restart";
            executeCommand(cmd);
            Thread.sleep(5000);
        }

        if(capClientFoundRowsStatus != null){
            String cmd;
            if (capClientFoundRowsStatus){
                cmd = Config.getdbleAdminCmd("enable @@cap_client_found_rows");
            }else{
                cmd = Config.getdbleAdminCmd("disable @@cap_client_found_rows");
            }
            executeCommand(cmd);

            //fresh connection command
            String freshCmd = Config.getdbleAdminCmd("fresh conn where dbGroup ='ha_group1';fresh conn where dbGroup ='ha_group2';");
            executeCommand(freshCmd);
        }

        Connection connection = null;
        try {
            connection = getDbleClientConnection(useAffectedRows);
            executeSpecialSql(connection, expectResult);
            if (logStr != null && !logStr.trim().equals("")) {
                checkLogs(logStr);
            }

        }catch (Exception e){
            e.printStackTrace();
        }finally {
            if (connection != null) {
                connection.close();
            }
        }
    }

    /**
     * execute INSERT INTO ... ON DUPLICATE KEY UPDATE ...
     * @param dbleTestConn
     * @param expectResult
     * @throws SQLException
     */
    private void executeSpecialSql(Connection dbleTestConn, int expectResult) throws SQLException{
        Main.print_debug("start :" + this.getClass() + " -> executeSpecialSql()");

        Statement statement = null;

        try {
            dbleTestConn.setCatalog(dbleProp.dbName);
            statement = dbleTestConn.createStatement();
            statement.addBatch("drop table if exists sharding_4_t1");
            statement.addBatch("create table sharding_4_t1(id int, name varchar(10), age int, primary key (id))");
            statement.addBatch("INSERT INTO sharding_4_t1(id, name, age) VALUES(1, 'name1', 20) ON DUPLICATE KEY UPDATE name='name1', age=20");
            statement.addBatch("INSERT INTO sharding_4_t1(id, name, age) VALUES(1, 'name1', 20) ON DUPLICATE KEY UPDATE name='name1', age=20");
            statement.addBatch("drop table if exists sharding_4_t1");
            int[] resultAry = statement.executeBatch();

            for (int i = 0; i < resultAry.length; i++){
                print_debug(String.valueOf(resultAry[i]));
            }

            int returnResult = resultAry[3];

            if(expectResult != returnResult) {
                on_assert_fail("failed! INSERT INTO ... ON DUPLICATE KEY UPDATE... expect result : "
                        + expectResult + ", but return : " + returnResult);
            }else{
                System.out.println("pass! return => " + returnResult);
            }

        }catch (SQLException e){
            System.out.println(e.getMessage());
            e.printStackTrace();
        }finally {
            if(statement != null) {
                statement.close();
            }
        }

        Main.print_debug("end :" + this.getClass() + " -> executeSpecialSql()");
    }

    /**
     * reset capClientFoundRows in bootstrap.cnf
     */
    private void resetDbleConfig(boolean resetType){
        String adminCmd;
        if(resetType){
            adminCmd = Config.getdbleAdminCmd("enable @@cap_client_found_rows");
        } else {
            adminCmd = Config.getdbleAdminCmd("disable @@cap_client_found_rows");
        }
        executeCommand(adminCmd);
        String cmd = "sed -i -e '/-DcapClientFoundRows/d' -e '$a -DcapClientFoundRows="+ resetType
                + "' /opt/dble/conf/bootstrap.cnf && /opt/dble/bin/dble restart";
        executeCommand(cmd);
    }

    /**
     * connection to dble client
     * @param useAffectedRows
     * @return
     * @throws SQLException
     */
    private Connection getDbleClientConnection(Boolean useAffectedRows) throws SQLException{
        String urlString = "jdbc:mysql://" + dbleProp.serverName + ":" + dbleProp.portNumber + "";
        String fullUrlString = urlString + "?useSSL=false";
        if(useAffectedRows != null){
            fullUrlString += "&useAffectedRows=" + useAffectedRows;
        }
        Main.print_debug(fullUrlString + ",user " + dbleProp.userName + ", password " + dbleProp.password);

        Connection dbleTestConn = DriverManager.getConnection(fullUrlString, dbleProp.userName, dbleProp.password);

        return dbleTestConn;
    }

    /**
     * count str display times
     * @param str
     * @return
     */
    private String countStrTime(String str){
        SSHCommandExecutor sshExecutor = new SSHCommandExecutor(dbleProp.serverName, Config.SSH_USER,
                Config.SSH_PASSWORD);
        String countCmd = "tail -n +0 " + Config.DBLE_LOG + " | grep -n \"" + str + "\" | wc -l";
        sshExecutor.execute(countCmd);
        Vector<String> outVector = sshExecutor.getStandardOutput();

        String result = "";
        if (outVector != null){
            result = outVector.firstElement();
        }
        Main.print_debug("str count result : " + result);
        return result;
    }

    /**
     * check dble.log
     * @param logStr
     */
    private void checkLogs(String logStr){
        String falseResult = countStrTime(logStr);
        if(falseResult != null && Integer.parseInt(falseResult.trim())> 0){
            System.out.println("pass! dble.log check success.");
        }else{
            on_assert_fail("failed! except dble.log records inconsistent logs, but cannot find " + logStr + "in dble.log");
        }
    }

    /**
     * execute command on dble
     */
    private void executeCommand(String cmd){
        SSHCommandExecutor sshExecutor = new SSHCommandExecutor(dbleProp.serverName, Config.SSH_USER,
                Config.SSH_PASSWORD);
		sshExecutor.execute(cmd);
    }
}
