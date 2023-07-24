/* Copyright (C) 2016-2023 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech.dble;

import java.sql.*;
import java.util.Vector;

import com.mysql.jdbc.ConnectionImpl;

/**
 * DBLE0REQ-1807 changeUser报文
 * @author wangjuan
 * @date 2023/07/21 10:29
 * @description
 * @modifiedBy
 * @version 1.0
 */
public class RwSplitChangeUserTest extends InterfaceTest {

    private String masterIp = "172.100.9.6";
    private String rwSplitUser = "split33";

    public RwSplitChangeUserTest(ConnProperties mysqlProp, ConnProperties dbleProp, boolean isMysqlDriver) throws SQLException {
        super(mysqlProp, dbleProp, isMysqlDriver);
    }

    protected void start() throws SQLException {
        addRwSplitUserConfig();
        try {
            runRwSplitChangeUserCase();
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    private void addRwSplitUserConfig() {
        Main.print_debug("begin :" + this.getClass() + " -> addRwSplitUserConfig()");

        SSHCommandExecutor sshExecutor = new SSHCommandExecutor(dbleProp.serverName, Config.SSH_USER,
                Config.SSH_PASSWORD);
        //add dbGroup
        String adminCmd = Config.getdbleAdminCmd("insert into dble_information.dble_db_group (name, heartbeat_stmt, rw_split_mode) values ('ha_group33', 'select user()', 0);");
        sshExecutor.execute(adminCmd);
        //add dbInstance
        adminCmd = Config.getdbleAdminCmd("insert into dble_information.dble_db_instance (name, db_group, addr, port, user, password_encrypt, encrypt_configured, primary, min_conn_count, max_conn_count) value ('hostM33', 'ha_group33', '" + masterIp + "', " + mysqlProp.portNumber + ", 'test', '111111', 'false', 'true', 10, 1000);");
        sshExecutor.execute(adminCmd);
        //add rwSplitUser
        adminCmd = Config.getdbleAdminCmd("insert into dble_information.dble_rw_split_entry (username, password_encrypt, encrypt_configured, max_conn_count, db_group) values ('" + rwSplitUser + "','" + dbleProp.password + "', 'false', 0, 'ha_group33');");
        sshExecutor.execute(adminCmd);

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

        Main.print_debug("end :" + this.getClass() + " -> clearRwSplitUserConfig()");
    }

    private void runRwSplitChangeUserCase() throws Exception {
        Main.print_debug("begin :" + this.getClass() + " -> runRwSplitChangeUserCase()");

        Connection rwConn = null;
        Statement statement = null;

        try {
            String urlString = "jdbc:mysql://" + dbleProp.serverName + ":" + dbleProp.portNumber + "?useServerPrepStmts=true&useAffectedRows=true&allowMultiQueries=true";
            Main.print_debug(urlString + ", user " + rwSplitUser + ", password " + dbleProp.password);

            rwConn = DriverManager.getConnection(urlString, rwSplitUser, dbleProp.password);
            ((ConnectionImpl)rwConn).resetServerState();
            statement = rwConn.createStatement();
            statement.execute("select 1;select 2");
            System.out.println("pass! runRwSplitChangeUserCase() -> rwSplitUser execute sql success.");

        }catch (Exception e) {
            System.out.println(e.getMessage());
            e.printStackTrace(System.out);
            System.out.println("fail! runRwSplitChangeUserCase() -> rwSplitUser execute sql failed.");
        }finally {
            clearRwSplitUserConfig();
            if (statement != null){
                statement.close();
            }
            if (rwConn != null){
                rwConn.close();
            }
        }

        SSHCommandExecutor sshExecutor = new SSHCommandExecutor(dbleProp.serverName, Config.SSH_USER, Config.SSH_PASSWORD);
        String checkCmd = "grep -nE 'NullPointerException|caught err|unknown error|exception occurred when the statistics were recorded|Exception processing' /opt/dble/logs/dble.log";
        sshExecutor.execute(checkCmd);
        Vector<String> outVector = sshExecutor.getStandardOutput();
        if (outVector != null && outVector.size() > 0){
            throw new Exception("runRwSplitChangeUserCase() -> except not exist exception, but failed: " + outVector.firstElement());
        }

        Main.print_debug("end :" + this.getClass() + " -> runRwSplitChangeUserCase()");
    }
}