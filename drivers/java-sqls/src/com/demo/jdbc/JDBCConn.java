package com.demo.jdbc;

import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

import com.mysql.jdbc.Connection;

public class JDBCConn {
	String errMsg = null;
	Connection connection = null;
	Boolean isSelect = false;
	Statement stmt = null;


	public JDBCConn(String host, String user, String password, String db, int port){
		try{
			Class.forName("com.mysql.jdbc.Driver");
			String url = "jdbc:mysql://"+host+":"+port + "/" + db + "?useSSL=false&&characterEncoding=utf8";
			System.out.println(url);
			System.out.println(user);
			System.out.println(password);
			connection = (Connection) DriverManager.getConnection(url,user,password);
//			connection.setAutoReconnect(true);
		}catch(SQLException ex){
		    System.out.println("SQLException: " + ex.getMessage());
		    System.out.println("SQLState: " + ex.getSQLState());
		    System.out.println("VendorError: " + ex.getErrorCode());

			ex.printStackTrace();
		}catch(ClassNotFoundException e){
			System.out.println("ClassNotFoundException: " + e.getMessage());
		}
	}

	public Boolean execute(String sql){
		errMsg = null;
		try{
			stmt = connection.createStatement();
			isSelect = stmt.execute(sql);
			System.out.println(sql+", isSelect:"+ (isSelect )+", "+connection.getHost());
		}catch(SQLException e){
			errMsg = e.getMessage();
		    System.out.println("SQLException: " + errMsg);
		    System.out.println("SQLState: " + e.getSQLState());
		    System.out.println("VendorError: " + e.getErrorCode());

		    e.printStackTrace();
		}catch(Exception e){
			System.out.println("Exception: " + e.getMessage());
		}
		return isSelect;
	}

	public void close(){
		close_stmt(stmt);
		close_conn(connection);
	}

	/*
	 * interfaces:
	 * executeQuery
	 *
	 */
//	public void testInterface(){
//		Connection conn_uproxy = null;
//		Connection conn_mysql = null;
//
//		try{
//			Class.forName("com.mysql.jdbc.Driver");
//			conn_uproxy = (Connection) DriverManager.getConnection("jdbc:mysql://"+Config.Host_Uproxy+":"+Config.UPROXY_PORT + "/" + Config.TEST_DB + "?useSSL=false",Config.TEST_USER,Config.TEST_USER_PASSWD);
//			conn_mysql = (Connection) DriverManager.getConnection("jdbc:mysql://"+Config.Host_Single_MySQL+":"+Config.MYSQL_PORT + "/" + Config.TEST_DB + "?useSSL=false",Config.TEST_USER,Config.TEST_USER_PASSWD);
//
//			Statement stmt_uproxy = null;
//			Statement stmt_mysql = null;
//
//			ResultSet rs_uproxy = null;
//			ResultSet rs_mysql = null;
//			try{
//				stmt_uproxy = conn_uproxy.createStatement();
//				stmt_mysql = conn_mysql.createStatement();
//
//				int up_uproxy = stmt_uproxy.executeUpdate("create table bar(foo varchar(30))");
//				int up_mysql = stmt_mysql.executeUpdate("create table bar(foo varchar(30))");
//
//				rs_uproxy = stmt_uproxy.executeQuery("SELECT foo FROM bar");
//				rs_mysql = stmt_mysql.executeQuery("SELECT foo FROM bar");
//
//				CallableStatement cStmt = conn_uproxy.prepareCall("{call demoSp(?, ?)}");
//				cStmt.setString(1, "abcdefg");
//				cStmt.registerOutParameter(2, Types.INTEGER);
//				cStmt.registerOutParameter("inOutParam", Types.INTEGER);
//
//				cStmt.setString("inputParam", "abcdefg");
//				cStmt.setInt(2, 1);
//				cStmt.setInt("inOutParam", 1);
//
//				boolean hadResults = cStmt.execute();
//				while (hadResults) {
//			        ResultSet rs = cStmt.getResultSet();
//
//			        // process result set
//
//			        hadResults = cStmt.getMoreResults();
//			    }
//				int outputValue = cStmt.getInt(2); // index-based
//
//			    outputValue = cStmt.getInt("inOutParam"); // name-based
//
//			}catch (SQLException ex){
//			    // handle any errors
//			    System.out.println("SQLException: " + ex.getMessage());
//			    System.out.println("SQLState: " + ex.getSQLState());
//			    System.out.println("VendorError: " + ex.getErrorCode());
//			}finally {
//				close_rs(rs_uproxy);
//				close_rs(rs_mysql);
//				close_stmt(stmt_uproxy);
//				close_stmt(stmt_mysql);
//			}
//		}catch(Exception e){
//			System.out.println("create conn err!");
//			e.printStackTrace();
//		}finally{
//			close_conn(conn_uproxy);
//			close_conn(conn_mysql);
//
//		}
//
//	}

//	private void close_rs(ResultSet rs){
//		if (rs != null) {
//	        try {
//	        	rs.close();
//	        } catch (SQLException sqlEx) {
//	        	sqlEx.printStackTrace();
//	        } // ignore
//
//	        rs = null;
//	    }
//	}

	private void close_stmt(Statement stmt){
		if(stmt!=null){
			try{
				stmt.close();
			}catch (SQLException e){
				e.printStackTrace();
			}
			stmt = null;
		}
	}

	private void close_conn(Connection conn){
		if( conn!=null){
			try{
				conn.close();
			}catch (SQLException e){
				e.printStackTrace();
			}
		}
		conn = null;
	}
}
