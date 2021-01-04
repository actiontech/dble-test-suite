/* Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package actiontech.dble;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DriverManagerTest extends InterfaceTest{

	public DriverManagerTest(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
	}

	protected void create_compare_conns(){

	}

	public void start()throws SQLException{
		useServerPrepStmts(dbleProp);
		reusePsBetweenFConns(dbleProp);
	}

	private void useServerPrepStmts(ConnProperties prop)throws SQLException{
		String urlString = "jdbc:mysql://" + prop.serverName + ":" + prop.portNumber + "";
		String fullUrlString = urlString + "?useSSL=false&&useServerPrepStmts=true";
		dbleConn = DriverManager.getConnection(fullUrlString, prop.userName, prop.password);
		System.out.println(fullUrlString);

		//clear old log if exists
//		String cmd = "echo> "+Config.GENERAL_LOG;
//		SSHCommandExecutor sshExecutor = new SSHCommandExecutor(prop.slave1, Config.SSH_USER,
//				Config.SSH_PASSWORD);
//		sshExecutor.execute(cmd);

		//1m1s
		//cmd = Config.getdbleAdminCmd("dble remove_mysqlds '"+
		//		Config.TEST_USER+"' slaves '"+Config.Host_Slave2+":"+Config.MYSQL_PORT+"'");
//
//		SSHCommandExecutor sshExecutor2 = new SSHCommandExecutor(prop.serverName, Config.SSH_USER,
//				Config.SSH_PASSWORD);
//		sshExecutor2.execute(cmd);

		//set general-log=on
//		urlString = "jdbc:mysql://" + prop.slave1 + ":" + prop.defaultPort + "";
//		fullUrlString = urlString + "?useSSL=false";
//		System.out.println(fullUrlString);
//		Connection masterConn = DriverManager.getConnection(fullUrlString, prop.userName, prop.password);
//		System.out.println(fullUrlString);
//		Statement stmt = masterConn.createStatement();
//
//		String sql="set @@global.general_log=1";
//		stmt.executeUpdate(sql);
//
//		close_stmt(stmt);
//		masterConn.close();
		//
		PreparedStatement ps_dble = dbleConn.prepareStatement("select ?");
		ps_dble.setInt(1, 13);
		ResultSet rs = ps_dble.executeQuery();
		System.out.println("After set var for prepare statement 13, execute ps, get:");
		print_resultset(rs);
		searchInGenLog(prop, "Prepare.*select ?");

		rs.close();
		ps_dble.close();
		dbleConn.close();

		//cmd = Config.getdbleAdminCmd("dble add_mysqlds '"+
		//		Config.TEST_USER+"' slaves '"+Config.Host_Slave2+":"+Config.MYSQL_PORT+"'");
		//sshExecutor2.execute(cmd);
	}

	private void searchInGenLog(ConnProperties prop, String re){
//		String cmd = "cat "+Config.GENERAL_LOG+" | grep '"+re+"'";
//		SSHCommandExecutor sshExecutor = new SSHCommandExecutor(prop.slave1,Config.SSH_USER,
//				Config.SSH_PASSWORD);
		//sshExecutor.execute(cmd);
		//Vector<String> res = sshExecutor.getStandardOutput();
//		if(res.size() != 1){
//			on_assert_fail("Expect general log has '"+re+"', but get:"+res.toString());
//		}else{
//			System.out.println(re+" is found in general log");
//		}
	}

	private void reusePsBetweenFConns(ConnProperties prop)throws SQLException{
		String urlString = "jdbc:mysql://" + prop.serverName + ":" + prop.portNumber + "";
		String fullUrlString = urlString + "?useSSL=false&&useServerPrepStmts=true&&cachePrepStmts=true";

		Connection conn1 = DriverManager.getConnection(fullUrlString, prop.userName, prop.password);
//		Connection conn2 = DriverManager.getConnection(fullUrlString, prop.userName, prop.password);

		PreparedStatement pstmt1 = conn1.prepareStatement("select ?");
		pstmt1.setInt(1, 13);
		pstmt1.close();

		PreparedStatement pstmt2 = conn1.prepareStatement("select ?");
		pstmt2.setInt(1, 14);
		pstmt2.close();

		if(pstmt1 != pstmt2){
			on_assert_fail("Expect one conn share the same ps instance");
		}else{
			System.out.println("one fconn share the same instance of pstmt if their constructed string is same");
		}
	}
}
