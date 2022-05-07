/* Copyright (C) 2016-2022 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech.dble;

import java.sql.*;

/**
 * @author wangjuan
 * @date 2022/04/25 10:29
 * @description
 * @modifiedBy
 * @version 1.0
 */
public class RwSplitUserPsTest extends InterfaceTest {

    private String slaveIp = "172.100.9.2";
    private String masterIp = "172.100.9.6";
    private String rwSplitUser = "split33";

    public RwSplitUserPsTest(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
        super(mysqlProp, dbleProp);
    }

    protected void start() throws SQLException {
        addRwSplitUserConfig();
        runRwSpliltUserCase();
    }

    private void addRwSplitUserConfig() {
        Main.print_debug("begin :" + this.getClass() + " -> addRwSplitUserConfig()");

        SSHCommandExecutor sshExecutor = new SSHCommandExecutor(dbleProp.serverName, Config.SSH_USER,
                Config.SSH_PASSWORD);
        //add dbGroup
        String adminCmd = Config.getdbleAdminCmd("insert into dble_information.dble_db_group (name, heartbeat_stmt, rw_split_mode) values ('ha_group33', 'select user()', 3);");
        sshExecutor.execute(adminCmd);
        //add dbInstance
        adminCmd = Config.getdbleAdminCmd("insert into dble_information.dble_db_instance (name, db_group, addr, port, user, password_encrypt, encrypt_configured, primary, min_conn_count, max_conn_count) value ('hostM33', 'ha_group33', '" + masterIp + "', " + mysqlProp.portNumber + ", 'test', '111111', 'false', 'true', 10, 1000);");
        sshExecutor.execute(adminCmd);
        adminCmd = Config.getdbleAdminCmd("insert into dble_information.dble_db_instance (name, db_group, addr, port, user, password_encrypt, encrypt_configured, primary, min_conn_count, max_conn_count) value ('hostS33', 'ha_group33', '" + slaveIp + "', " + mysqlProp.portNumber + ", 'test', '111111', 'false', 'false', 10, 1000);");
        sshExecutor.execute(adminCmd);
        //add rwSplitUser
        adminCmd = Config.getdbleAdminCmd("insert into dble_information.dble_rw_split_entry (username, password_encrypt, encrypt_configured, max_conn_count, db_group) values ('" + rwSplitUser + "','" + dbleProp.password + "', 'false', 0, 'ha_group33');");
        sshExecutor.execute(adminCmd);

        //update mysql config
        String slaveCmd = "mysql -u" + Config.MYSQL_USER + " -p"
                + Config.MYSQL_PASSWD + " -h127.0.0.1 -P" + Config.MYSQL_PORT + " -e 'set global super_read_only=on;'";
        sshExecutor = new SSHCommandExecutor(slaveIp, Config.SSH_USER, Config.SSH_PASSWORD);
        sshExecutor.execute(slaveCmd);

        Main.print_debug("end :" + this.getClass() + " -> addRwSplitUserConfig()");
    }

    private void clearRwSplitUserConfig(){
        Main.print_debug("begin :" + this.getClass() + " -> clearRwSplitUserConfig()");

        SSHCommandExecutor sshExecutor = new SSHCommandExecutor(dbleProp.serverName, Config.SSH_USER,
                Config.SSH_PASSWORD);
        //delete rwSplitUser
        String adminCmd = Config.getdbleAdminCmd("delete from dble_information.dble_rw_split_entry where username='" + rwSplitUser + "';");
        sshExecutor.execute(adminCmd);
        //delete dbInstance
        adminCmd = Config.getdbleAdminCmd("delete from dble_information.dble_db_instance where db_group='ha_group33';");
        sshExecutor.execute(adminCmd);
        //delete dbGroup
        adminCmd = Config.getdbleAdminCmd("delete from dble_information.dble_db_group where name='ha_group33';");
        sshExecutor.execute(adminCmd);

        //update mysql config
        String slaveCmd = "mysql -u" + Config.MYSQL_USER + " -p"
                + Config.MYSQL_PASSWD + " -h127.0.0.1 -P" + Config.MYSQL_PORT + " -e 'set global super_read_only=off;'";
        sshExecutor = new SSHCommandExecutor(slaveIp, Config.SSH_USER, Config.SSH_PASSWORD);
        sshExecutor.execute(slaveCmd);

        Main.print_debug("end :" + this.getClass() + " -> clearRwSplitUserConfig()");
    }

    private void runRwSpliltUserCase() throws SQLException {
        Main.print_debug("begin :" + this.getClass() + " -> runRwSpliltUserCase()");

        Connection rwConn = null;
        Statement statement = null;
        PreparedStatement stmt1 = null;
        PreparedStatement stmt2 = null;

        try {
            rwConn = getDbleRwSplitUserConnection();
            rwConn.setCatalog("db1");

            statement = rwConn.createStatement();
            statement.addBatch("drop table if exists test_table1");
            statement.addBatch("create table test_table1(id int, name varchar(10))");
            statement.addBatch("INSERT INTO test_table1 VALUES(1, 'name1'),(2, 'name2')");
            statement.addBatch("drop table if exists test_table2");
            statement.addBatch("create table test_table2(id int, age int)");
            statement.addBatch("INSERT INTO test_table2 VALUES(1, 10),(2, 20)");
            statement.executeBatch();

            stmt1 = rwConn.prepareStatement("SELECT * FROM test_table1 WHERE id=?");
            stmt2 = rwConn.prepareStatement("UPDATE test_table2 SET age=age+1 WHERE id=?");
            stmt1.setInt(1, 1);
            stmt2.setInt(1,2);
            stmt1.executeQuery();
            stmt2.executeUpdate();

            System.out.println("pass! RwSplitUserTest() -> rwSplitUser execute sql success.");

        }catch (SQLException e) {
            System.out.println(e.getMessage());
            e.printStackTrace(System.out);
            System.out.println("fail! RwSplitUserTest() -> rwSplitUser execute sql failed.");
        }finally {
            clearRwSplitUserConfig();
            if (stmt1 != null){
                stmt1.close();
            }
            if (stmt2 != null){
                stmt2.close();
            }
            if (statement != null){
                statement.close();
            }
            if (rwConn != null){
                rwConn.close();
            }
        }

        Main.print_debug("end :" + this.getClass() + " -> runRwSpliltUserCase()");
    }

    private Connection getDbleRwSplitUserConnection() throws SQLException{
        String urlString = "jdbc:mysql://" + dbleProp.serverName + ":" + dbleProp.portNumber + "?useServerPrepStmts=true&useAffectedRows=true";
        Main.print_debug(urlString + ", user " + rwSplitUser + ", password " + dbleProp.password);
        return DriverManager.getConnection(urlString, rwSplitUser, dbleProp.password);
    }
}