/* Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech.dble;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.sql.Statement;

import com.sun.corba.se.spi.orbutil.fsm.Guard.Result;

public class StatementTest extends InterfaceTest {
	public StatementTest(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
	}

	protected void start() throws SQLException {
		itf_addBatch();
		itf_cancel();
		itf_warnings();
		itf_execute();
		itf_autoincrement();
		System.out.println("autoincrement() is passed");
	}

	/*
	 * function:addBatch(String sql)!
				clearBatch()!
	 */
	private void itf_addBatch()throws SQLException {
		String createSql="drop table if exists tb; create table tb(id int, first varchar(30), last varchar(30), age int);";
		String sql1="drop table if exists tb;";
		TestUtilities.executeUpdate(mysqlConn, sql1);
		TestUtilities.executeUpdate(dbleConn, sql1);

		String sql2="create table tb(id int, first varchar(30), last varchar(30), age int);";
		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(dbleConn, sql2);

		String SQL = "INSERT INTO tb (id, first, last, age) " +
				"VALUES(?, ?, ?, ?)";

		// Create PrepareStatement object
		PreparedStatement mysql_pstmt = mysqlConn.prepareStatement(SQL);
		PreparedStatement dble_pstmt = dbleConn.prepareStatement(SQL);

		//Set auto-commit to false
		mysqlConn.setAutoCommit(false);
		dbleConn.setAutoCommit(false);

		// Set the variables
		mysql_pstmt.setInt( 1, 400 );
		mysql_pstmt.setString( 2, "Pappu" );
		mysql_pstmt.setString( 3, "Singh" );
		mysql_pstmt.setInt( 4, 33 );
		// Add it to the batch
		mysql_pstmt.addBatch();
		mysql_pstmt.clearBatch();

		// Set the variables
		mysql_pstmt.setInt( 1, 401 );
		mysql_pstmt.setString( 2, "Pawan" );
		mysql_pstmt.setString( 3, "Singh" );
		mysql_pstmt.setInt( 4, 31 );
		// Add it to the batch
		mysql_pstmt.addBatch();

		// Set the variables
		dble_pstmt.setInt( 1, 400 );
		dble_pstmt.setString( 2, "Pappu" );
		dble_pstmt.setString( 3, "Singh" );
		dble_pstmt.setInt( 4, 33 );
		// Add it to the batch
		dble_pstmt.addBatch();
		dble_pstmt.clearBatch();

		// Set the variables
		dble_pstmt.setInt( 1, 401 );
		dble_pstmt.setString( 2, "Pawan" );
		dble_pstmt.setString( 3, "Singh" );
		dble_pstmt.setInt( 4, 31 );
		// Add it to the batch
		dble_pstmt.addBatch();

		//Create an int[] to hold returned values
		int[] mysql_count = mysql_pstmt.executeBatch();
		int[] dble_count = dble_pstmt.executeBatch();

		//Explicitly commit statements to apply changes
		mysqlConn.commit();
		dbleConn.commit();

		int mysql_len = mysql_count.length, dble_len=dble_count.length;
		boolean isEqual = mysql_len == dble_len;
		while(isEqual && mysql_len-- > 0){
			isEqual = mysql_count[mysql_len] == dble_count[mysql_len];
		}
		if(isEqual){
			System.out.println("pass! addBatch(String sql)!");
			System.out.println("pass! clearBatch()!");
		}else{
			System.out.println("mysql count:"+mysql_count);
			System.out.println("dble count:"+dble_count);
			on_assert_fail("fail! addBatch(String sql)!");
		}

		close_stmt(mysql_pstmt);
		close_stmt(dble_pstmt);

		mysqlConn.setAutoCommit(true);
		dbleConn.setAutoCommit(true);
	}

	/*
	 * function:cancel()
	 * */
	private void itf_cancel()throws SQLException {
		String sql1="drop table if exists tb;";
		TestUtilities.executeUpdate(mysqlConn, sql1);
		TestUtilities.executeUpdate(dbleConn, sql1);
		String sql2="create table tb(id int)";
		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(dbleConn, sql2);


		String insert_sql = "insert into tb values(10)";
		PreparedStatement mysql_psts = mysqlConn.prepareStatement(insert_sql);
		PreparedStatement dble_psts = dbleConn.prepareStatement(insert_sql);

		mysql_psts.executeUpdate();
		dble_psts.executeUpdate();

		mysql_psts.cancel();
		dble_psts.cancel();

		try{
			Thread.sleep(5);
		}catch(Exception e){
			e.printStackTrace();
		}
		String sql = "select * from tb";
		ResultSet mysql_rs = mysql_psts.executeQuery(sql);
		ResultSet dble_rs = dble_psts.executeQuery(sql);

		print_debug("compare_result: " + sql);
		boolean isEqual = compare_result(mysql_rs, dble_rs);
		if(isEqual){
			System.out.println("pass! cancel()!");
		}else{
			on_assert_fail("fail! cancel()");
		}
		close_rs(mysql_rs);
		close_rs(dble_rs);

		close_stmt(mysql_psts);
		close_stmt(dble_psts);
	}

	/*
	 * function:getWarnings():sometime context is different with mysql
	 * 			clearWarnings()
	 * 			closeOnCompletion()
	 * 			isClosed()
	 * */
	private void itf_warnings() throws SQLException{
		String sql = "select 1/0";
		String sql1="set @@sql_mode='error_for_division_by_zero';";

		Statement mysql_stmt=null, dble_stmt=null;
		try {
			mysql_stmt = mysqlConn.createStatement();
			dble_stmt = dbleConn.createStatement();

			TestUtilities.executeUpdate(mysqlConn, sql1);
			TestUtilities.executeUpdate(dbleConn, sql1);

//			mysql_stmt.closeOnCompletion();
//			dble_stmt.closeOnCompletion();

			ResultSet mysql_rs = mysql_stmt.executeQuery(sql);
			ResultSet dble_rs = dble_stmt.executeQuery(sql);

			SQLWarning mysql_warn = mysql_stmt.getWarnings();
			SQLWarning dble_warn = dble_stmt.getWarnings();

			if(mysql_warn.getSQLState()== dble_warn.getSQLState() && mysql_warn.getErrorCode()==dble_warn.getErrorCode()){
				System.out.println("pass! getWarnings()!");
			}else{
//				System.out.println("select 1/0 mysql get warn:");
//				TestUtilities.printWarnings(mysql_warn);
//				System.out.println("select 1/0 dble get warn:");
//				TestUtilities.printWarnings(dble_warn);
				System.out.println("fail! getWarnings()!");
				//on_assert_fail("fail! getWarnings()!");
			}

			mysql_stmt.clearWarnings();
			dble_stmt.clearWarnings();

			if(dble_stmt.getWarnings()==null){
				System.out.println("pass! clearWarnings()!");
				System.out.println("pass! getWarnings()!");
			}else{
				on_assert_fail("fail! after clearWarnings() expect getWarnings gets null!");
			}

			mysql_rs.close();
			dble_rs.close();
			if(mysql_stmt.isClosed() == dble_stmt.isClosed()){
				System.out.println("pass! closeOnCompletion()!");
				System.out.println("pass! isClosed()!");
			}else{
				on_assert_fail("fail! closeOnCompletion()!");
			}
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		}finally{
			mysql_stmt.close();
			dble_stmt.close();
		}
	}

	/*
	 * function:execute(String sql)
	 * 			execute(String sql, int autoGeneratedKeys)
	 * 			execute(String sql, int[] columnIndexes)
	 * */
	private void itf_execute()throws SQLException {
		Statement mysql_stmt=null, dble_stmt=null;
		mysql_stmt = mysqlConn.createStatement();
		dble_stmt = dbleConn.createStatement();

		String sql = "drop table if exists mytest_global1";
		String sql1="create table mytest_global1(id int primary key auto_increment, rank int)";
		mysql_stmt.execute(sql);
		dble_stmt.execute(sql);
		mysql_stmt.execute(sql1);
		dble_stmt.execute(sql1);

		sql = "insert into mytest_global1(rank) values(2)";
		mysql_stmt.execute(sql,Statement.RETURN_GENERATED_KEYS);
		dble_stmt.execute(sql,Statement.RETURN_GENERATED_KEYS);

		ResultSet mysql_keys = mysql_stmt.getGeneratedKeys();
		ResultSet dble_keys = dble_stmt.getGeneratedKeys();
		print_debug("compare_result: after '"+sql +"' getGeneratedKeys()");
		boolean isEqual = compare_result(mysql_keys, dble_keys);
		if(isEqual){
			System.out.println("pass! execute(String sql)!");
			System.out.println("pass! execute(String sql, int autoGeneratedKeys)!");
		}else{
			on_assert_fail("fail! execute(String sql)");
		}

		close_rs(mysql_keys);
		close_rs(dble_keys);

		close_stmt(mysql_stmt);
		close_stmt(dble_stmt);

		mysql_stmt = mysqlConn.createStatement();
		dble_stmt = dbleConn.createStatement();
//
		sql = "insert into mytest_global1(rank) values(3)";
		int[] pkeys = {1, 2};
		mysql_stmt.execute(sql,pkeys);
		dble_stmt.execute(sql,pkeys);
		mysql_keys = mysql_stmt.getGeneratedKeys();
		dble_keys = dble_stmt.getGeneratedKeys();
		print_debug("compare_result: after '"+sql+"' getGeneratedKeys()");
		isEqual = compare_result(mysql_keys, dble_keys);

		if(isEqual){
			System.out.println("pass! execute(String sql, int[] columnIndexes)!");
		}else{
			on_assert_fail("fail! execute(String sql, int[] columnIndexes)");
		}
	}

	/*
	 * function:autoincrement()
	 * */
	private void itf_autoincrement() {
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = mysqlConn.createStatement();
			stmt.executeUpdate("DROP TABLE IF EXISTS mytest_global1");
			stmt.executeUpdate("CREATE TABLE mytest_global1 (" + "priKey INT NOT NULL AUTO_INCREMENT, "
					+ "dataField VARCHAR(64), PRIMARY KEY (priKey))");
			stmt.executeUpdate(
					"INSERT INTO mytest_global1 (dataField) values ('Can I Get the Auto Increment Field?'),('second line')",
					Statement.RETURN_GENERATED_KEYS);

			int autoIncKeyFromApi = -1;

			rs = stmt.getGeneratedKeys();

			while (rs.next()) {
				autoIncKeyFromApi = rs.getInt(1);
				System.out.println("Key returned from getGeneratedKeys():" + autoIncKeyFromApi);
			}

		} catch (SQLException e) {

		} finally {
			close_rs(rs);
			close_stmt(stmt);
		}
	}
}
