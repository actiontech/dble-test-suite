/* Copyright (C) 2016-2022 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package actiontech.dble;

import java.sql.Blob;
import java.sql.CallableStatement;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.sql.Statement;
import java.sql.Types;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * @author janey uncovered:
 * #.Array createArrayOf(String typeName, Object[] elements)
 * #.NClob createNClob()
 * #.SQLXML createSQLXML()
 * #.Struct createStruct(String typeName, Object[] attributes)
 * #.void setTypeMap(Map<String,Class<?>> map)
 */
public class ConnectionTest extends InterfaceTest {
	public ConnectionTest(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
	}

	protected void start() throws SQLException {
		itf_abort();
		itf_clearWarnings();
		itf_commit();
		itf_createDType();
		itf_createStmt();
		itf_getMethod();
		itf_isMethod();
		itf_nativeSql();
		//itf_CallableStatement();
		itf_prepareStatement();
		//itf_savePoint();
	}

	/**
	 * void clearWarnings() SQLWarning getWarnings()
	 */
	private void itf_clearWarnings() throws SQLException {
		dbleConn.clearWarnings();
		if (dbleConn.getWarnings() != null) {
			on_assert_fail("fail! getWarnings() expect return null after clearWarnings()");
		}
		System.out.println("pass! clearWarnings()!");
		System.out.println("pass! getWarnings()!");
	}

	/**
	 * void commit() void rollback() void setAutoCommit(boolean autoCommit)
	 * Statement createStatement()
	 */
	private void itf_commit() throws SQLException {
		//String sql = "drop table if exists tb; create table tb(id int)";
		String sql1 = "drop table if exists mytest_test1";
		String sql2 = "create table mytest_test1(id int)";

		mysqlConn.setAutoCommit(false);
		dbleConn.setAutoCommit(false);

		Statement mysql_s = this.mysqlConn.createStatement();
		Statement dble_s = this.dbleConn.createStatement();

		mysql_s.executeUpdate(sql1);
		dble_s.executeUpdate(sql1);
		mysql_s.executeUpdate(sql2);
		dble_s.executeUpdate(sql2);

		mysqlConn.rollback();
		dbleConn.rollback();

		sql1 = "desc mytest_test1;";

		ResultSet mysql_rs = mysql_s.executeQuery(sql1);
		ResultSet dble_rs = dble_s.executeQuery(sql1);

		print_debug("compare_result: "+sql1);
		compare_result(mysql_rs, dble_rs);
		mysql_rs.close();
		dble_rs.close();

		mysql_s.executeUpdate(sql1);
		dble_s.executeUpdate(sql1);

		mysqlConn.commit();
		dbleConn.commit();

		mysql_rs = mysql_s.executeQuery(sql1);
		dble_rs = dble_s.executeQuery(sql1);

		print_debug("compare_result: "+sql1);
		compare_result(mysql_rs, dble_rs);
		mysql_rs.close();
		dble_rs.close();

		mysqlConn.setAutoCommit(true);
		dbleConn.setAutoCommit(true);
		System.out.println("pass! commit()");
	}

	/*
	 * functions: Blob: int setBytes(long pos, byte[] bytes) Connection: Blob
	 * createBlob() PreparedStatement: void setBlob(int parameterIndex, Blob x)
	 * void setBytes(int parameterIndex, byte[] x)
	 */
	public void itf_createDType() throws SQLException {
		String sql1,sql2 = null;
		sql1 = "drop table if exists global_table1";
		sql2 = "create table global_table1(blobField BLOB)";

		TestUtilities.executeUpdate(mysqlConn, sql1);
		TestUtilities.executeUpdate(dbleConn, sql1);

		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(dbleConn, sql2);

		PreparedStatement mysql_pstmt = null, dble_pstmt = null;
		byte[] blobData = new byte[32];

		for (int i = 0; i < blobData.length; i++) {
			blobData[i] = 1;
		}

		sql1 = "INSERT INTO global_table1 VALUES(?)";
		mysql_pstmt = this.mysqlConn.prepareStatement(sql1);
		dble_pstmt = this.dbleConn.prepareStatement(sql1);

		Statement mysql_s = this.mysqlConn.createStatement();
		Statement dble_s = this.dbleConn.createStatement();
		String trunSql = "truncate table global_table1";

		mysql_s.executeUpdate(trunSql);
		dble_s.executeUpdate(trunSql);

		Blob mysql_blob = this.mysqlConn.createBlob();
		Blob dble_blob = this.dbleConn.createBlob();

		mysql_blob.setBytes(1, blobData);
		dble_blob.setBytes(1, blobData);

		mysql_pstmt.setBlob(1, mysql_blob);
		dble_pstmt.setBlob(1, dble_blob);

		mysql_pstmt.executeUpdate();
		dble_pstmt.executeUpdate();

		String selSql = "SELECT blobField FROM global_table1";
		ResultSet mysql_rs = mysql_s.executeQuery(selSql);
		ResultSet dble_rs = dble_s.executeQuery(selSql);

		print_debug("compare_result: " +sql1);
		compare_result(mysql_rs, dble_rs);

		dble_rs.first();
		mysql_rs.first();
		Blob dble_blob2 = dble_rs.getBlob(1);

		//
		// Test mid-point insertion
		//
		dble_blob2.setBytes(4, new byte[] { 2, 2, 2, 2 });

		byte[] dble_newBlobData = dble_blob2.getBytes(1L, (int) dble_blob2.length());

		if (((dble_newBlobData[3] == 2) && (dble_newBlobData[4] == 2) && (dble_newBlobData[5] == 2)
				&& (dble_newBlobData[6] == 2))) {
			print_debug("New data inserted right, new data is:");

			for (int i = 0; i < dble_newBlobData.length; i++) {
				print_debug(dble_newBlobData[i] + "");
			}
		}

		// pstmt.setBytes(1, blobData);
		// pstmt.executeUpdate();

		close_stmt(dble_pstmt);

		System.out.println("pass! prepareStatement(String sql)");
		System.out.println("pass! createDatatype()!");
	}

	/*
	 * function: createStatement()
	*/
	private void itf_createStmt() throws SQLException {
		Statement mysql_stmt = this.mysqlConn.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY,
				ResultSet.HOLD_CURSORS_OVER_COMMIT);
		Statement dble_stmt = this.dbleConn.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY,
				ResultSet.HOLD_CURSORS_OVER_COMMIT);
		String sql = "select 1";
		ResultSet mysql_rs = mysql_stmt.executeQuery(sql);
		ResultSet dble_rs = dble_stmt.executeQuery(sql);
		print_debug("compare_result: "+sql);
		compare_result(mysql_rs, dble_rs);
		System.out.println("pass! createStatement()");
	}

	/*
	 * function: abort()
	 * */
	private void itf_abort() throws SQLException {
		 ExecutorService ae = Executors.newFixedThreadPool(2);

        try{
            mysqlConn.abort(ae);
            dbleConn.abort(ae);
            ae.shutdown();

            while (!ae.awaitTermination(1, TimeUnit.SECONDS)) {
                System.out.println("waiting abort finish..." );
            }

			boolean isMySQLClosed = mysqlConn.isClosed();
			boolean isDbleClosed = dbleConn.isClosed();

			if (isMySQLClosed == isDbleClosed)
				System.out.println("pass! abort()");
			else {
				on_assert_fail("fail! After abort(), dble isClosed() is:"+isDbleClosed+", but mysql isClosed is:"+isMySQLClosed);
			}
		}catch(SQLException e){
			System.out.println("SQLException:"+e.getMessage());
		}catch(InterruptedException ie) {
			System.out.println("InterruptedException:"+ie.getMessage());
		}

		create_compare_conns();
	}

	/*
	 * function: getAutoCommit(); getCatalog();setClientInfo(Properties properties);
	 * function: getClientInfo(); getClientInfo(String name)
	 * function: getHoldability();  getMetaData(); getNetworkTimeout(); getSchema();
	 * function: getTypeMap(); getMethod()
	 * not supported: getTransactionIsolation()
	 * */
	private void itf_getMethod() throws SQLException {
		boolean mysql_autocommit = this.mysqlConn.getAutoCommit();
		boolean dble_autocommit = this.dbleConn.getAutoCommit();
		if (mysql_autocommit == dble_autocommit) {
			System.out.println("pass! getAutoCommit()!");
		} else {
			on_assert_fail("fail! Default autocommit value is diff");
		}

		String mysql_catalog = mysqlConn.getCatalog();
		String dble_catalog = dbleConn.getCatalog();
		if (mysql_catalog.equals(dble_catalog)) {
			System.out.println("pass! getCatalog()!");
		} else {
			on_assert_fail("fail! getCatalog()");
		}

		Properties prop = new Properties();
		prop.put("user", mysqlProp.userName);
		prop.put("password", mysqlProp.password);

		mysqlConn.setClientInfo(prop);
		dbleConn.setClientInfo(prop);
		Properties mysql_clientInfo = mysqlConn.getClientInfo();
		Properties dble_clientInfo = dbleConn.getClientInfo();
		if (mysql_clientInfo.equals(dble_clientInfo)) {
			System.out.println("pass! setClientInfo(Properties properties)!");
			System.out.println("pass! getClientInfo()!");
		} else {
			on_assert_fail("fail! getClientInfo()");
		}

		String mysql_clientInfo_user = mysqlConn.getClientInfo("user");
		String dble_clientInfo_user = dbleConn.getClientInfo("user");
		print_debug("mysql clientInfo_user:" + mysql_clientInfo_user);
		print_debug("dble clientInfo_user:" + dble_clientInfo_user);
		if (mysql_clientInfo_user.equals(dble_clientInfo_user)) {
			System.out.println("pass! getClientInfo(String name)!");
		} else {
			on_assert_fail("fail! reusePsBetweenMultiFConns");
		}

		int mysql_holdability = mysqlConn.getHoldability();
		int dble_holdability = dbleConn.getHoldability();
		if (mysql_holdability == dble_holdability) {
			System.out.println("pass! getHoldability()!");
		} else {
			on_assert_fail("fail! getHoldability()");
		}

		DatabaseMetaData dble_metaData = dbleConn.getMetaData();
		if (dble_metaData != null) {
			System.out.println("pass! getMetaData()!");
		} else {
			on_assert_fail("fail! getMetaData()");
		}

		int mysql_net_timeout = mysqlConn.getNetworkTimeout();
		int dble_net_timeout = dbleConn.getNetworkTimeout();
		if (mysql_net_timeout == dble_net_timeout) {
			System.out.println("pass! getNetworkTimeout()!");
		} else {
			on_assert_fail("fail! getNetworkTimeout()");
		}

		String mysql_schema = mysqlConn.getSchema();
		String dble_schema = dbleConn.getSchema();
		if (mysql_schema == dble_schema || mysql_schema.equals(dble_schema)) {
			System.out.println("pass! getSchema()!");
		} else {
			on_assert_fail("fail! getSchema()");
		}

//		int mysql_tx_isolation = mysqlConn.getTransactionIsolation();
//		int dble_tx_isolation = dbleConn.getTransactionIsolation();
//		if (mysql_tx_isolation == dble_tx_isolation) {
//			System.out.println("pass! getTransactionIsolation()!");
//		} else {
//			on_assert_fail("fail! getTransactionIsolation()");
//		}

		Map<String, Class<?>> dble_map = dbleConn.getTypeMap();
		if (dble_map != null) {
			System.out.println("pass! getTypeMap()!");
		} else {
			on_assert_fail("fail! getTypeMap()");
		}

		System.out.println("pass! getMethod()");
	}

	/*
	 * function: isClosed(); setReadOnly(); isReadOnly(); isValid();
	 * */
	private void itf_isMethod() throws SQLException {
		boolean isClosed = dbleConn.isClosed();
		if (!isClosed) {
			System.out.println("pass! isClosed()!");
		} else {
			on_assert_fail("fail! isClosed()");
		}

		dbleConn.setReadOnly(true);

		String sql = "drop table is exists tb";
		try {
			Statement s = dbleConn.createStatement();
			s.executeUpdate(sql);
			s.close();
			on_assert_fail("fail! setReadOnly()");
		} catch (SQLException ex) {
			if (ex.getSQLState() == "S1009") {
				System.out.println("pass! setReadOnly()!");
			}
		}

		if (dbleConn.isReadOnly()) {
			System.out.println("pass! isReadOnly()!");
		}

		boolean isValid = dbleConn.isValid(10);
		if (isValid) {
			System.out.println("pass! isValid()!");
		}

		dbleConn.setReadOnly(false);
	}

	/*
	 * function: nativeSql()
	 * */
	private void itf_nativeSql() throws SQLException {
		String stmt = "SELECT * FROM employee WHERE hiredate={d '1994-03-29'}";
		String mysql_nativeSql = mysqlConn.nativeSQL(stmt);
		String dble_nativeSql = dbleConn.nativeSQL(stmt);
		if (mysql_nativeSql.equals(dble_nativeSql)) {
			System.out.println("pass! nativeSQL()!");
		} else {
			print_debug("mysql nativeSql:" + mysql_nativeSql);
			print_debug("dble nativeSql:" + dble_nativeSql);
			on_assert_fail("fail! nativeSQL()");
		}
	}

	/*
	 * Not measured because the stored procedure does not support
	 * */
	private void itf_CallableStatement() throws SQLException {
		String proc_str = "CREATE PROCEDURE demoSp(IN inputParam VARCHAR(255),INOUT inOutParam INT)" + "BEGIN"
				+ "    DECLARE z INT;" + "    SET z = inOutParam + 1;" + "    SET inOutParam = z;"
				+ "    SELECT inputParam;" + "    SELECT CONCAT('zyxw', inputParam);" + "END";

		String drop_p = "drop procedure if exists demoSp";
		TestUtilities.executeUpdate(mysqlConn, drop_p);
		TestUtilities.executeUpdate(mysqlConn, proc_str);

		TestUtilities.executeUpdate(dbleConn, drop_p);
		TestUtilities.executeUpdate(dbleConn, proc_str);

		CallableStatement mysql_cStmt = mysqlConn.prepareCall("{call demoSp(?, ?)}", ResultSet.TYPE_FORWARD_ONLY,
				ResultSet.CONCUR_READ_ONLY, ResultSet.HOLD_CURSORS_OVER_COMMIT);
		CallableStatement dble_cStmt = dbleConn.prepareCall("{call demoSp(?, ?)}", ResultSet.TYPE_FORWARD_ONLY,
				ResultSet.CONCUR_READ_ONLY, ResultSet.HOLD_CURSORS_OVER_COMMIT);
		// style a
		mysql_cStmt.registerOutParameter(2, Types.INTEGER);
		mysql_cStmt.setString(1, "abc");
		mysql_cStmt.setInt(2, 1);

		dble_cStmt.registerOutParameter(2, Types.INTEGER);
		dble_cStmt.setString(1, "abc");
		dble_cStmt.setInt(2, 1);

		print_debug("compare_result: stmt of {call demoSp(?, ?)}");
		compare_result(mysql_cStmt, dble_cStmt);

		int outputValue1 = mysql_cStmt.getInt(2); // index-based
		int outputValue2 = dble_cStmt.getInt(2); // index-based
		if (outputValue1 != outputValue2) {
			print_debug("mysql outputValue:" + outputValue1);
			print_debug("dble outputValue:" + outputValue2);
			on_assert_fail("fail! getInt()");
		}

		// style b
		mysql_cStmt.registerOutParameter("inOutParam", Types.INTEGER);
		mysql_cStmt.setString("inputParam", "def");
		mysql_cStmt.setInt("inOutParam", 2);

		dble_cStmt.registerOutParameter("inOutParam", Types.INTEGER);
		dble_cStmt.setString("inputParam", "def");
		dble_cStmt.setInt("inOutParam", 2);

		print_debug("compare_result: another style stmt of {call demoSp(?, ?)}");
		compare_result(mysql_cStmt, dble_cStmt);

		outputValue1 = mysql_cStmt.getInt("inOutParam"); // name-based
		outputValue2 = dble_cStmt.getInt("inOutParam"); // name-based
		if (outputValue1 != outputValue2) {
			print_debug("mysql registerOutParameter outputValue:" + outputValue1);
			print_debug("dble registerOutParameter outputValue:" + outputValue2);
			on_assert_fail("fail! registerOutParameter()");
		}

		mysql_cStmt.close();
		dble_cStmt.close();

		System.out.println(
				"pass! prepareCall(String sql,int resultSetType,int resultSetConcurrency,int resultSetHoldability)!");
	}

	/*
	 * function: prepareStatement(String sql, int autoGeneratedKeys)
	 * 			 prepareStatement(String sql, int[] columnIndexes)
	 *  		 prepareStatement(String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability)
	 *  		 prepareStatement(String sql, String[] columnNames)
	 * */
	private void itf_prepareStatement() throws SQLException {
		String sql1 = "drop table if exists global_table1 ";
		String sql2 = "create table global_table1(id int primary key auto_increment, rank int)";
		TestUtilities.executeUpdate(mysqlConn, sql1);
		TestUtilities.executeUpdate(dbleConn, sql1);
		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(dbleConn, sql2);

		String insert_sql = "insert into global_table1 values(?,?)";
		PreparedStatement mysql_psts = mysqlConn.prepareStatement(insert_sql, Statement.RETURN_GENERATED_KEYS);
		PreparedStatement dble_psts = dbleConn.prepareStatement(insert_sql, Statement.RETURN_GENERATED_KEYS);

		mysql_psts.setInt(1, 1);
		mysql_psts.setInt(2, 10);
		mysql_psts.executeUpdate();
		ResultSet mysql_keys = mysql_psts.getGeneratedKeys();

		dble_psts.setInt(1, 1);
		dble_psts.setInt(2, 10);
		dble_psts.executeUpdate();
		ResultSet dble_keys = dble_psts.getGeneratedKeys();

		print_debug("compare_result: After '" +insert_sql+"' getGeneratedKeys()" );
		compare_result(mysql_keys,dble_keys);
		mysql_psts.close();
		dble_psts.close();
		System.out.println("pass! prepareStatement(String sql, int autoGeneratedKeys)!");

		int[] pkeys = { 4 };
		mysql_psts = mysqlConn.prepareStatement(insert_sql, pkeys);
		dble_psts = dbleConn.prepareStatement(insert_sql, pkeys);

		mysql_psts.setInt(1, 2);
		mysql_psts.setInt(2, 11);
		mysql_psts.executeUpdate();
		mysql_keys = mysql_psts.getGeneratedKeys();

		dble_psts.setInt(1, 2);
		dble_psts.setInt(2, 11);
		dble_psts.executeUpdate();
		dble_keys = dble_psts.getGeneratedKeys();

		print_debug("compare_result: After '" +insert_sql+"' getGeneratedKeys()" );
		compare_result(dble_keys, mysql_keys);
		mysql_psts.close();
		dble_psts.close();
		System.out.println("pass! prepareStatement(String sql, int[] columnIndexes)!");

		mysql_psts = mysqlConn.prepareStatement(insert_sql, ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE, ResultSet.CLOSE_CURSORS_AT_COMMIT);
		dble_psts = dbleConn.prepareStatement(insert_sql, ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE, ResultSet.CLOSE_CURSORS_AT_COMMIT);

		mysql_psts.setInt(1, 3);
		mysql_psts.setInt(2, 12);
		mysql_psts.executeUpdate();

		dble_psts.setInt(1, 3);
		dble_psts.setInt(2, 12);
		dble_psts.executeUpdate();
		int mysql_rsType = dble_psts.getResultSetType();
		int dble_rsType = mysql_psts.getResultSetType();
		if (mysql_rsType != dble_rsType) {
			print_debug("mysql getResultSetType:" + mysql_rsType);
			print_debug("dble getResultSetType:" + dble_rsType);
			on_assert_fail("fail! getResultSetType()");
		}
		mysql_psts.close();
		dble_psts.close();
		System.out.println(
				"pass! prepareStatement(String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability)!");

		sql1 = "drop table if exists global_table1 ";
		sql2 = "create table global_table1(C11 int, C12 int primary key auto_increment) ";
		TestUtilities.executeUpdate(mysqlConn, sql1);
		TestUtilities.executeUpdate(dbleConn, sql1);
		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(dbleConn, sql2);

		insert_sql = "INSERT INTO global_table1 (C11) VALUES (1)";
		String[] colNames = new String[] { "C12" };
		mysql_psts = mysqlConn.prepareStatement(insert_sql, colNames);
		dble_psts = dbleConn.prepareStatement(insert_sql, colNames);

		mysql_psts.executeUpdate();
		mysql_keys = mysql_psts.getGeneratedKeys();

		dble_psts.executeUpdate();
		dble_keys = dble_psts.getGeneratedKeys();

		print_debug("compare_result: After '" +insert_sql+"' getGeneratedKeys()" );
		compare_result(dble_keys, mysql_keys);
		mysql_psts.close();
		dble_psts.close();
		System.out.println("pass! prepareStatement(String sql, String[] columnNames)!");
	}

	/*
	 * function:setSavepoint(String name)
	 * 			releaseSavepoint()
	 * 			rollback(Savepoint savepoint)
	 * 			rollback()
	 * NOT supported:setSavepoint(String name),releaseSavepoint(),rollback(Savepoint savepoint)
	 * */
	private void itf_savePoint() throws SQLException {
		Statement mysql_stmt = mysqlConn.createStatement();
		Statement dble_stmt = dbleConn.createStatement();
		String sql1 = "drop table if exists global_table1; ";
		String sql2 = "create table global_table1(id int);";
		String sql3 = "insert into global_table1 values(110),(120);";
		TestUtilities.executeUpdate(mysqlConn, sql1);
		TestUtilities.executeUpdate(dbleConn, sql1);
		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(dbleConn, sql2);
		TestUtilities.executeUpdate(mysqlConn, sql3);
		TestUtilities.executeUpdate(dbleConn, sql3);

		mysqlConn.setAutoCommit(false);
		dbleConn.setAutoCommit(false);
		String SQL = "DELETE FROM global_table1 WHERE ID = 110";
		dble_stmt.executeUpdate(SQL);
		mysql_stmt.executeUpdate(SQL);

		Savepoint mysql_savepoint = mysqlConn.setSavepoint("ROWS_DELETED_1");
		Savepoint dble_savepoint = dbleConn.setSavepoint("ROWS_DELETED_1");

		SQL = "DELETE FROM global_table1 WHERE ID = 120";
		dble_stmt.executeUpdate(SQL);
		mysql_stmt.executeUpdate(SQL);

		mysqlConn.rollback(mysql_savepoint);
		dbleConn.rollback(dble_savepoint);

		SQL = "select * from global_table1";
		ResultSet mysql_rs=mysql_stmt.executeQuery(SQL);
		ResultSet dble_rs=dble_stmt.executeQuery(SQL);
		print_debug("compare_result: "+SQL);
		compare_result(mysql_rs, dble_rs);

		mysqlConn.rollback();
		dbleConn.rollback();

		mysql_rs=mysql_stmt.executeQuery(SQL);
		dble_rs=dble_stmt.executeQuery(SQL);
		print_debug("compare_result: "+SQL);
		compare_result(mysql_rs, dble_rs);

		mysqlConn.releaseSavepoint(mysql_savepoint);
		dbleConn.releaseSavepoint(dble_savepoint);

		mysqlConn.setAutoCommit(true);
		dbleConn.setAutoCommit(true);

		System.out.println("pass! setSavepoint(String name)!");
		System.out.println("pass! releaseSavepoint()!");
		System.out.println("pass! rollback(Savepoint savepoint)!");
		System.out.println("pass! rollback()!");
	}
}

class AbortExecutor implements Executor {
	public void execute(Runnable r) {
		new Thread(r).start();
	}
}