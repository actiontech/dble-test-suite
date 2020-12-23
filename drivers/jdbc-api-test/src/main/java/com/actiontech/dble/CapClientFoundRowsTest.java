package com.actiontech.dble;

import java.sql.*;

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
            testCapClientFoundRowsFalse();
        }catch (Exception e){
            System.out.println("throw exception ====> " + e.getMessage());
            e.printStackTrace();
        }finally {
            resetDbleConfig();
        }
    }

    /**
     * set capClientFoundRows=false
     * @throws SQLException
     */
    private void testCapClientFoundRowsFalse() throws SQLException{
        System.out.println("start :" + this.getClass() + " -> testUseAffectedRowsFalse()");

        System.out.println("step 1:---->");
        SSHCommandExecutor sshExecutor = new SSHCommandExecutor(dbleProp.serverName, Config.SSH_USER,
				Config.SSH_PASSWORD);
        String cmd = "sed -i '/capClientFoundRows/s/-DcapClientFoundRows=true/-DcapClientFoundRows=false/g' /opt/dble/conf/bootstrap.cnf && /opt/dble/bin/dble restart";
		sshExecutor.execute(cmd);

        Connection dbleTestConn = null;
        String errorMsg = null;
        try {
            dbleTestConn = getDbleClientConnection(false);
        }catch (SQLException e){
            errorMsg = e.getMessage();
            e.printStackTrace(System.err);
        }finally {
            if (dbleTestConn == null) {
                System.out.println("pass! dble connection error : " + errorMsg);
            }else{
                on_assert_fail("except dble connection error, but connection success");
                dbleTestConn.close();
            }
        }

        System.out.println("step 2:---->");
        //enable @@cap_client_found_rows
        String enableCmd = Config.getdbleAdminCmd("enable @@cap_client_found_rows");
        sshExecutor.execute(enableCmd);
        String freshCmd = Config.getdbleAdminCmd("fresh conn where dbGroup ='ha_group1';fresh conn where dbGroup ='ha_group2';");
        sshExecutor.execute(freshCmd);
        Connection connection = getDbleClientConnection(false);
        executeSpecialSql(connection, 1);

        System.out.println("step 3:---->");
        //disable @@cap_client_found_rows
        String disableCmd = Config.getdbleAdminCmd("disable @@cap_client_found_rows");
        sshExecutor.execute(disableCmd);
        sshExecutor.execute(freshCmd);
        executeSpecialSql(connection, 0);

        System.out.println("step 4:---->");
        //useAffectedRows=true
        Connection trueConn = getDbleClientConnection(true);
        executeSpecialSql(trueConn, 0);

        System.out.println("end :" + this.getClass() + " -> testUseAffectedRowsFalse()");
    }

    /**
     * execute INSERT INTO ... ON DUPLICATE KEY UPDATE ...
     * @param dbleTestConn
     * @param expectResult
     * @throws SQLException
     */
    private void executeSpecialSql(Connection dbleTestConn, int expectResult) throws SQLException{
        System.out.println("start :" + this.getClass() + " -> enableCapClientFoundRows()");

        Statement statement = null;
        ResultSet resultSet = null;

        try {
            dbleTestConn.setCatalog(dbleProp.dbName);
            statement = dbleTestConn.createStatement();
            statement.addBatch("drop table if exists sharding_4_t1");
            statement.addBatch("create table sharding_4_t1(id int, name varchar(10), age int, primary key (id))");
            statement.addBatch("INSERT INTO sharding_4_t1(id, name, age) VALUES(1, 'name1', 20) ON DUPLICATE KEY UPDATE name='name1', age=20");
            statement.addBatch("INSERT INTO sharding_4_t1(id, name, age) VALUES(1, 'name1', 20) ON DUPLICATE KEY UPDATE name='name1', age=20");
            int[] resultAry = statement.executeBatch();

            for (int i = 0; i < resultAry.length; i++){
                print_debug(String.valueOf(resultAry[i]));
            }

            int returnResult = resultAry[3];

            if(expectResult != returnResult) {
                on_assert_fail("INSERT INTO ... ON DUPLICATE KEY UPDATE... expect result : "
                        + expectResult + ", but return : " + returnResult);
            }else{
                System.out.println("pass! INSERT INTO ... ON DUPLICATE KEY UPDATE... return success => " + returnResult);
            }

        }catch (SQLException e){
            System.out.println(e.getMessage());
            e.printStackTrace(System.err);
        }finally {
            if(resultSet != null) {
                resultSet.close();
            }
            if(statement != null) {
                statement.close();
            }
        }

        System.out.println("end :" + this.getClass() + " -> enableCapClientFoundRows()");
    }

    /**
     * reset capClientFoundRows=true in bootstrap.cnf
     */
    private void resetDbleConfig(){
        SSHCommandExecutor sshExecutor = new SSHCommandExecutor(dbleProp.serverName, Config.SSH_USER,
                Config.SSH_PASSWORD);
        String adminCmd = Config.getdbleAdminCmd("enable @@cap_client_found_rows");
        sshExecutor.execute(adminCmd);
        String cmd = "sed -i '/capClientFoundRows/s/-DcapClientFoundRows=false/-DcapClientFoundRows=true/g' /opt/dble/conf/bootstrap.cnf && /opt/dble/bin/dble restart";
        sshExecutor.execute(cmd);
    }

    /**
     * connection to dble client
     * @param useAffectedRows
     * @return
     * @throws SQLException
     */
    private Connection getDbleClientConnection(boolean useAffectedRows) throws SQLException{
        String urlString = "jdbc:mysql://" + dbleProp.serverName + ":" + dbleProp.portNumber + "";
        String fullUrlString = urlString + "??useSSL=false&allowMultiQueries=true&autoReconnect=true&failOverReadOnly=false&useAffectedRows=" + useAffectedRows;
        Main.print_debug(fullUrlString + ",user " + dbleProp.userName + ", password " + dbleProp.password);

        Connection dbleTestConn = DriverManager.getConnection(fullUrlString, dbleProp.userName, dbleProp.password);

        return dbleTestConn;
    }
}
