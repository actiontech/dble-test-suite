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

/**
 * @author janey uncovered:
 * #.Array createArrayOf(String typeName, Object[] elements)
 * #.NClob createNClob()
 * #.SQLXML createSQLXML()
 * #.Struct createStruct(String typeName, Object[] attributes)
 * #.void setTypeMap(Map<String,Class<?>> map)
 */
public class ConnectionTest extends InterfaceTest {
	public ConnectionTest(ConnProperties mysqlProp, ConnProperties uproxyProp) throws SQLException {
		super(mysqlProp, uproxyProp);
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
		uproxyConn.clearWarnings();
		if (uproxyConn.getWarnings() != null) {
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
		uproxyConn.setAutoCommit(false);

		Statement mysql_s = this.mysqlConn.createStatement();
		Statement uproxy_s = this.uproxyConn.createStatement();

		mysql_s.executeUpdate(sql1);
		uproxy_s.executeUpdate(sql1);
		mysql_s.executeUpdate(sql2);
		uproxy_s.executeUpdate(sql2);

		mysqlConn.rollback();
		uproxyConn.rollback();

		sql1 = "desc mytest_test1;";

		ResultSet mysql_rs = mysql_s.executeQuery(sql1);
		ResultSet uproxy_rs = uproxy_s.executeQuery(sql1);

		print_debug("compare_result: "+sql1);
		compare_result(mysql_rs, uproxy_rs);
		mysql_rs.close();
		uproxy_rs.close();

		mysql_s.executeUpdate(sql1);
		uproxy_s.executeUpdate(sql1);

		mysqlConn.commit();
		uproxyConn.commit();

		mysql_rs = mysql_s.executeQuery(sql1);
		uproxy_rs = uproxy_s.executeQuery(sql1);

		print_debug("compare_result: "+sql1);
		compare_result(mysql_rs, uproxy_rs);
		mysql_rs.close();
		uproxy_rs.close();

		mysqlConn.setAutoCommit(true);
		uproxyConn.setAutoCommit(true);
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
		TestUtilities.executeUpdate(uproxyConn, sql1);

		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(uproxyConn, sql2);

		PreparedStatement mysql_pstmt = null, uproxy_pstmt = null;
		byte[] blobData = new byte[32];

		for (int i = 0; i < blobData.length; i++) {
			blobData[i] = 1;
		}

		sql1 = "INSERT INTO global_table1 VALUES(?)";
		mysql_pstmt = this.mysqlConn.prepareStatement(sql1);
		uproxy_pstmt = this.uproxyConn.prepareStatement(sql1);

		Statement mysql_s = this.mysqlConn.createStatement();
		Statement uproxy_s = this.uproxyConn.createStatement();
		String trunSql = "truncate table global_table1";

		mysql_s.executeUpdate(trunSql);
		uproxy_s.executeUpdate(trunSql);

		Blob mysql_blob = this.mysqlConn.createBlob();
		Blob uproxy_blob = this.uproxyConn.createBlob();

		mysql_blob.setBytes(1, blobData);
		uproxy_blob.setBytes(1, blobData);

		mysql_pstmt.setBlob(1, mysql_blob);
		uproxy_pstmt.setBlob(1, uproxy_blob);

		mysql_pstmt.executeUpdate();
		uproxy_pstmt.executeUpdate();

		String selSql = "SELECT blobField FROM global_table1";
		ResultSet mysql_rs = mysql_s.executeQuery(selSql);
		ResultSet uproxy_rs = uproxy_s.executeQuery(selSql);

		print_debug("compare_result: " +sql1);
		compare_result(mysql_rs, uproxy_rs);

		uproxy_rs.first();
		mysql_rs.first();
		Blob uproxy_blob2 = uproxy_rs.getBlob(1);

		//
		// Test mid-point insertion
		//
		uproxy_blob2.setBytes(4, new byte[] { 2, 2, 2, 2 });

		byte[] uproxy_newBlobData = uproxy_blob2.getBytes(1L, (int) uproxy_blob2.length());

		if (((uproxy_newBlobData[3] == 2) && (uproxy_newBlobData[4] == 2) && (uproxy_newBlobData[5] == 2)
				&& (uproxy_newBlobData[6] == 2))) {
			print_debug("New data inserted right, new data is:");

			for (int i = 0; i < uproxy_newBlobData.length; i++) {
				print_debug(uproxy_newBlobData[i] + "");
			}
		}

		// pstmt.setBytes(1, blobData);
		// pstmt.executeUpdate();

		close_stmt(uproxy_pstmt);

		System.out.println("pass! prepareStatement(String sql)");
		System.out.println("pass! createDatatype()!");
	}

	/*
	 * function: createStatement()
	*/
	private void itf_createStmt() throws SQLException {
		Statement mysql_stmt = this.mysqlConn.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY,
				ResultSet.HOLD_CURSORS_OVER_COMMIT);
		Statement uproxy_stmt = this.uproxyConn.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY,
				ResultSet.HOLD_CURSORS_OVER_COMMIT);
		String sql = "select 1";
		ResultSet mysql_rs = mysql_stmt.executeQuery(sql);
		ResultSet uproxy_rs = uproxy_stmt.executeQuery(sql);
		print_debug("compare_result: "+sql);
		compare_result(mysql_rs, uproxy_rs);
		System.out.println("pass! createStatement()");
	}

	/*
	 * function: abort()
	 * */
	private void itf_abort() throws SQLException {
		AbortExecutor ae = new AbortExecutor();
		ae.execute(new Runnable() {
			public void run() {
				int i = 0;
				while (true) {
					try {
						Thread.sleep(1000);
					} catch (InterruptedException ie) {
						System.out.println("InterruptedException:"+ie.getMessage());
					}
					if (i == 5)
						break;
					i++;
					System.out.println("run times: "+ i);
				}
			}
		});

		try{
			mysqlConn.abort(ae);
		}catch(SQLException e){
			System.out.println("SQLException:"+e.getMessage());
		}

		try{
			uproxyConn.abort(ae);
		}catch(SQLException e){
			System.out.println("SQLException:"+e.getMessage());
		}

		System.out.println(mysqlConn.isClosed());
		System.out.println(uproxyConn.isClosed());
		if (mysqlConn.isClosed() == uproxyConn.isClosed())
			System.out.println("pass! abort()");
		else {
			on_assert_fail("fail! After abort(), uproxy isClosed() is diff from mysql's");
		}
		try {
			Thread.sleep(6000);
		} catch (InterruptedException e) {
			System.out.println("InterruptedException:"+e.getMessage());
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
		boolean uproxy_autocommit = this.uproxyConn.getAutoCommit();
		if (mysql_autocommit == uproxy_autocommit) {
			System.out.println("pass! getAutoCommit()!");
		} else {
			on_assert_fail("fail! Default autocommit value is diff");
		}

		String mysql_catalog = mysqlConn.getCatalog();
		String uproxy_catalog = uproxyConn.getCatalog();
		if (mysql_catalog.equals(uproxy_catalog)) {
			System.out.println("pass! getCatalog()!");
		} else {
			on_assert_fail("fail! getCatalog()");
		}

		Properties prop = new Properties();
		prop.put("user", mysqlProp.userName);
		prop.put("password", mysqlProp.password);

		mysqlConn.setClientInfo(prop);
		uproxyConn.setClientInfo(prop);
		Properties mysql_clientInfo = mysqlConn.getClientInfo();
		Properties uproxy_clientInfo = uproxyConn.getClientInfo();
		if (mysql_clientInfo.equals(uproxy_clientInfo)) {
			System.out.println("pass! setClientInfo(Properties properties)!");
			System.out.println("pass! getClientInfo()!");
		} else {
			on_assert_fail("fail! getClientInfo()");
		}

		String mysql_clientInfo_user = mysqlConn.getClientInfo("user");
		String uproxy_clientInfo_user = uproxyConn.getClientInfo("user");
		print_debug("mysql clientInfo_user:" + mysql_clientInfo_user);
		print_debug("uproxy clientInfo_user:" + uproxy_clientInfo_user);
		if (mysql_clientInfo_user.equals(uproxy_clientInfo_user)) {
			System.out.println("pass! getClientInfo(String name)!");
		} else {
			on_assert_fail("fail! reusePsBetweenMultiFConns");
		}

		int mysql_holdability = mysqlConn.getHoldability();
		int uproxy_holdability = uproxyConn.getHoldability();
		if (mysql_holdability == uproxy_holdability) {
			System.out.println("pass! getHoldability()!");
		} else {
			on_assert_fail("fail! getHoldability()");
		}

		DatabaseMetaData uproxy_metaData = uproxyConn.getMetaData();
		if (uproxy_metaData != null) {
			System.out.println("pass! getMetaData()!");
		} else {
			on_assert_fail("fail! getMetaData()");
		}

		int mysql_net_timeout = mysqlConn.getNetworkTimeout();
		int uproxy_net_timeout = uproxyConn.getNetworkTimeout();
		if (mysql_net_timeout == uproxy_net_timeout) {
			System.out.println("pass! getNetworkTimeout()!");
		} else {
			on_assert_fail("fail! getNetworkTimeout()");
		}

		String mysql_schema = mysqlConn.getSchema();
		String uproxy_schema = uproxyConn.getSchema();
		if (mysql_schema == uproxy_schema || mysql_schema.equals(uproxy_schema)) {
			System.out.println("pass! getSchema()!");
		} else {
			on_assert_fail("fail! getSchema()");
		}

//		int mysql_tx_isolation = mysqlConn.getTransactionIsolation();
//		int uproxy_tx_isolation = uproxyConn.getTransactionIsolation();
//		if (mysql_tx_isolation == uproxy_tx_isolation) {
//			System.out.println("pass! getTransactionIsolation()!");
//		} else {
//			on_assert_fail("fail! getTransactionIsolation()");
//		}

		Map<String, Class<?>> uproxy_map = uproxyConn.getTypeMap();
		if (uproxy_map != null) {
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
		boolean isClosed = uproxyConn.isClosed();
		if (!isClosed) {
			System.out.println("pass! isClosed()!");
		} else {
			on_assert_fail("fail! isClosed()");
		}

		uproxyConn.setReadOnly(true);

		String sql = "drop table is exists tb";
		try {
			Statement s = uproxyConn.createStatement();
			s.executeUpdate(sql);
			s.close();
			on_assert_fail("fail! setReadOnly()");
		} catch (SQLException ex) {
			if (ex.getSQLState() == "S1009") {
				System.out.println("pass! setReadOnly()!");
			}
		}

		if (uproxyConn.isReadOnly()) {
			System.out.println("pass! isReadOnly()!");
		}

		boolean isValid = uproxyConn.isValid(10);
		if (isValid) {
			System.out.println("pass! isValid()!");
		}

		uproxyConn.setReadOnly(false);
	}

	/*
	 * function: nativeSql()
	 * */
	private void itf_nativeSql() throws SQLException {
		String stmt = "SELECT * FROM employee WHERE hiredate={d '1994-03-29'}";
		String mysql_nativeSql = mysqlConn.nativeSQL(stmt);
		String uproxy_nativeSql = uproxyConn.nativeSQL(stmt);
		if (mysql_nativeSql.equals(uproxy_nativeSql)) {
			System.out.println("pass! nativeSQL()!");
		} else {
			print_debug("mysql nativeSql:" + mysql_nativeSql);
			print_debug("uproxy nativeSql:" + uproxy_nativeSql);
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

		TestUtilities.executeUpdate(uproxyConn, drop_p);
		TestUtilities.executeUpdate(uproxyConn, proc_str);

		CallableStatement mysql_cStmt = mysqlConn.prepareCall("{call demoSp(?, ?)}", ResultSet.TYPE_FORWARD_ONLY,
				ResultSet.CONCUR_READ_ONLY, ResultSet.HOLD_CURSORS_OVER_COMMIT);
		CallableStatement uproxy_cStmt = uproxyConn.prepareCall("{call demoSp(?, ?)}", ResultSet.TYPE_FORWARD_ONLY,
				ResultSet.CONCUR_READ_ONLY, ResultSet.HOLD_CURSORS_OVER_COMMIT);
		// style a
		mysql_cStmt.registerOutParameter(2, Types.INTEGER);
		mysql_cStmt.setString(1, "abc");
		mysql_cStmt.setInt(2, 1);

		uproxy_cStmt.registerOutParameter(2, Types.INTEGER);
		uproxy_cStmt.setString(1, "abc");
		uproxy_cStmt.setInt(2, 1);

		print_debug("compare_result: stmt of {call demoSp(?, ?)}");
		compare_result(mysql_cStmt, uproxy_cStmt);

		int outputValue1 = mysql_cStmt.getInt(2); // index-based
		int outputValue2 = uproxy_cStmt.getInt(2); // index-based
		if (outputValue1 != outputValue2) {
			print_debug("mysql outputValue:" + outputValue1);
			print_debug("uproxy outputValue:" + outputValue2);
			on_assert_fail("fail! getInt()");
		}

		// style b
		mysql_cStmt.registerOutParameter("inOutParam", Types.INTEGER);
		mysql_cStmt.setString("inputParam", "def");
		mysql_cStmt.setInt("inOutParam", 2);

		uproxy_cStmt.registerOutParameter("inOutParam", Types.INTEGER);
		uproxy_cStmt.setString("inputParam", "def");
		uproxy_cStmt.setInt("inOutParam", 2);

		print_debug("compare_result: another style stmt of {call demoSp(?, ?)}");
		compare_result(mysql_cStmt, uproxy_cStmt);

		outputValue1 = mysql_cStmt.getInt("inOutParam"); // name-based
		outputValue2 = uproxy_cStmt.getInt("inOutParam"); // name-based
		if (outputValue1 != outputValue2) {
			print_debug("mysql registerOutParameter outputValue:" + outputValue1);
			print_debug("uproxy registerOutParameter outputValue:" + outputValue2);
			on_assert_fail("fail! registerOutParameter()");
		}

		mysql_cStmt.close();
		uproxy_cStmt.close();

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
		TestUtilities.executeUpdate(uproxyConn, sql1);
		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(uproxyConn, sql2);

		String insert_sql = "insert into global_table1 values(?,?)";
		PreparedStatement mysql_psts = mysqlConn.prepareStatement(insert_sql, Statement.RETURN_GENERATED_KEYS);
		PreparedStatement uproxy_psts = uproxyConn.prepareStatement(insert_sql, Statement.RETURN_GENERATED_KEYS);

		mysql_psts.setInt(1, 1);
		mysql_psts.setInt(2, 10);
		mysql_psts.executeUpdate();
		ResultSet mysql_keys = mysql_psts.getGeneratedKeys();

		uproxy_psts.setInt(1, 1);
		uproxy_psts.setInt(2, 10);
		uproxy_psts.executeUpdate();
		ResultSet uproxy_keys = uproxy_psts.getGeneratedKeys();

		print_debug("compare_result: After '" +insert_sql+"' getGeneratedKeys()" );
		compare_result(mysql_keys,uproxy_keys);
		mysql_psts.close();
		uproxy_psts.close();
		System.out.println("pass! prepareStatement(String sql, int autoGeneratedKeys)!");

		int[] pkeys = { 4 };
		mysql_psts = mysqlConn.prepareStatement(insert_sql, pkeys);
		uproxy_psts = uproxyConn.prepareStatement(insert_sql, pkeys);

		mysql_psts.setInt(1, 2);
		mysql_psts.setInt(2, 11);
		mysql_psts.executeUpdate();
		mysql_keys = mysql_psts.getGeneratedKeys();

		uproxy_psts.setInt(1, 2);
		uproxy_psts.setInt(2, 11);
		uproxy_psts.executeUpdate();
		uproxy_keys = uproxy_psts.getGeneratedKeys();

		print_debug("compare_result: After '" +insert_sql+"' getGeneratedKeys()" );
		compare_result(uproxy_keys, mysql_keys);
		mysql_psts.close();
		uproxy_psts.close();
		System.out.println("pass! prepareStatement(String sql, int[] columnIndexes)!");

		mysql_psts = mysqlConn.prepareStatement(insert_sql, ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE, ResultSet.CLOSE_CURSORS_AT_COMMIT);
		uproxy_psts = uproxyConn.prepareStatement(insert_sql, ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE, ResultSet.CLOSE_CURSORS_AT_COMMIT);

		mysql_psts.setInt(1, 3);
		mysql_psts.setInt(2, 12);
		mysql_psts.executeUpdate();

		uproxy_psts.setInt(1, 3);
		uproxy_psts.setInt(2, 12);
		uproxy_psts.executeUpdate();
		int mysql_rsType = uproxy_psts.getResultSetType();
		int uproxy_rsType = mysql_psts.getResultSetType();
		if (mysql_rsType != uproxy_rsType) {
			print_debug("mysql getResultSetType:" + mysql_rsType);
			print_debug("uproxy getResultSetType:" + uproxy_rsType);
			on_assert_fail("fail! getResultSetType()");
		}
		mysql_psts.close();
		uproxy_psts.close();
		System.out.println(
				"pass! prepareStatement(String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability)!");

		sql1 = "drop table if exists global_table1 ";
		sql2 = "create table global_table1(C11 int, C12 int primary key auto_increment) ";
		TestUtilities.executeUpdate(mysqlConn, sql1);
		TestUtilities.executeUpdate(uproxyConn, sql1);
		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(uproxyConn, sql2);

		insert_sql = "INSERT INTO global_table1 (C11) VALUES (1)";
		String[] colNames = new String[] { "C12" };
		mysql_psts = mysqlConn.prepareStatement(insert_sql, colNames);
		uproxy_psts = uproxyConn.prepareStatement(insert_sql, colNames);

		mysql_psts.executeUpdate();
		mysql_keys = mysql_psts.getGeneratedKeys();

		uproxy_psts.executeUpdate();
		uproxy_keys = uproxy_psts.getGeneratedKeys();

		print_debug("compare_result: After '" +insert_sql+"' getGeneratedKeys()" );
		compare_result(uproxy_keys, mysql_keys);
		mysql_psts.close();
		uproxy_psts.close();
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
		Statement uproxy_stmt = uproxyConn.createStatement();
		String sql1 = "drop table if exists global_table1; ";
		String sql2 = "create table global_table1(id int);";
		String sql3 = "insert into global_table1 values(110),(120);";
		TestUtilities.executeUpdate(mysqlConn, sql1);
		TestUtilities.executeUpdate(uproxyConn, sql1);
		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(uproxyConn, sql2);
		TestUtilities.executeUpdate(mysqlConn, sql3);
		TestUtilities.executeUpdate(uproxyConn, sql3);

		mysqlConn.setAutoCommit(false);
		uproxyConn.setAutoCommit(false);
		String SQL = "DELETE FROM global_table1 WHERE ID = 110";
		uproxy_stmt.executeUpdate(SQL);
		mysql_stmt.executeUpdate(SQL);

		Savepoint mysql_savepoint = mysqlConn.setSavepoint("ROWS_DELETED_1");
		Savepoint uproxy_savepoint = uproxyConn.setSavepoint("ROWS_DELETED_1");

		SQL = "DELETE FROM global_table1 WHERE ID = 120";
		uproxy_stmt.executeUpdate(SQL);
		mysql_stmt.executeUpdate(SQL);

		mysqlConn.rollback(mysql_savepoint);
		uproxyConn.rollback(uproxy_savepoint);

		SQL = "select * from global_table1";
		ResultSet mysql_rs=mysql_stmt.executeQuery(SQL);
		ResultSet uproxy_rs=uproxy_stmt.executeQuery(SQL);
		print_debug("compare_result: "+SQL);
		compare_result(mysql_rs, uproxy_rs);

		mysqlConn.rollback();
		uproxyConn.rollback();

		mysql_rs=mysql_stmt.executeQuery(SQL);
		uproxy_rs=uproxy_stmt.executeQuery(SQL);
		print_debug("compare_result: "+SQL);
		compare_result(mysql_rs, uproxy_rs);

		mysqlConn.releaseSavepoint(mysql_savepoint);
		uproxyConn.releaseSavepoint(uproxy_savepoint);

		mysqlConn.setAutoCommit(true);
		uproxyConn.setAutoCommit(true);

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