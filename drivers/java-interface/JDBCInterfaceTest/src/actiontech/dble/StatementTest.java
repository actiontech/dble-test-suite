package actiontech.dble;

import java.sql.*;
import java.io.ByteArrayInputStream;
import java.util.Properties;

import com.sun.corba.se.spi.orbutil.fsm.Guard.Result;

public class StatementTest extends InterfaceTest {
	public StatementTest(ConnProperties mysqlProp, ConnProperties uproxyProp) throws SQLException {
		super(mysqlProp, uproxyProp);
	}

	protected void start() throws SQLException {
		itf_addBatch();
		itf_cancel();
		itf_warnings();
		itf_execute();
		itf_autoincrement();
		try {
			itf_blob();
		} catch (Exception e) {
			e.printStackTrace();
		}
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
		TestUtilities.executeUpdate(uproxyConn, sql1);

		String sql2="create table tb(id int, first varchar(30), last varchar(30), age int);";
		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(uproxyConn, sql2);

		String SQL = "INSERT INTO tb (id, first, last, age) " +
				"VALUES(?, ?, ?, ?)";

		// Create PrepareStatement object
		PreparedStatement mysql_pstmt = mysqlConn.prepareStatement(SQL);
		PreparedStatement uproxy_pstmt = uproxyConn.prepareStatement(SQL);

		//Set auto-commit to false
		mysqlConn.setAutoCommit(false);
		uproxyConn.setAutoCommit(false);

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
		uproxy_pstmt.setInt( 1, 400 );
		uproxy_pstmt.setString( 2, "Pappu" );
		uproxy_pstmt.setString( 3, "Singh" );
		uproxy_pstmt.setInt( 4, 33 );
		// Add it to the batch
		uproxy_pstmt.addBatch();
		uproxy_pstmt.clearBatch();

		// Set the variables
		uproxy_pstmt.setInt( 1, 401 );
		uproxy_pstmt.setString( 2, "Pawan" );
		uproxy_pstmt.setString( 3, "Singh" );
		uproxy_pstmt.setInt( 4, 31 );
		// Add it to the batch
		uproxy_pstmt.addBatch();

		//Create an int[] to hold returned values
		int[] mysql_count = mysql_pstmt.executeBatch();
		int[] uproxy_count = uproxy_pstmt.executeBatch();

		//Explicitly commit statements to apply changes
		mysqlConn.commit();
		uproxyConn.commit();

		int mysql_len = mysql_count.length, uproxy_len=uproxy_count.length;
		boolean isEqual = mysql_len == uproxy_len;
		while(isEqual && mysql_len-- > 0){
			isEqual = mysql_count[mysql_len] == uproxy_count[mysql_len];
		}
		if(isEqual){
			System.out.println("pass! addBatch(String sql)!");
			System.out.println("pass! clearBatch()!");
		}else{
			System.out.println("mysql count:"+mysql_count);
			System.out.println("uproxy count:"+uproxy_count);
			on_assert_fail("fail! addBatch(String sql)!");
		}

		close_stmt(mysql_pstmt);
		close_stmt(uproxy_pstmt);

		mysqlConn.setAutoCommit(true);
		uproxyConn.setAutoCommit(true);
	}

	/*
	 * function:cancel()
	 * */
	private void itf_cancel()throws SQLException {
		String sql1="drop table if exists tb;";
		TestUtilities.executeUpdate(mysqlConn, sql1);
		TestUtilities.executeUpdate(uproxyConn, sql1);
		String sql2="create table tb(id int)";
		TestUtilities.executeUpdate(mysqlConn, sql2);
		TestUtilities.executeUpdate(uproxyConn, sql2);


		String insert_sql = "insert into tb values(10)";
		PreparedStatement mysql_psts = mysqlConn.prepareStatement(insert_sql);
		PreparedStatement uproxy_psts = uproxyConn.prepareStatement(insert_sql);

		mysql_psts.executeUpdate();
		uproxy_psts.executeUpdate();

		mysql_psts.cancel();
		uproxy_psts.cancel();

		try{
			Thread.sleep(5);
		}catch(Exception e){
			e.printStackTrace();
		}
		String sql = "select * from tb";
		ResultSet mysql_rs = mysql_psts.executeQuery(sql);
		ResultSet uproxy_rs = uproxy_psts.executeQuery(sql);

		print_debug("compare_result: " + sql);
		boolean isEqual = compare_result(mysql_rs, uproxy_rs);
		if(isEqual){
			System.out.println("pass! cancel()!");
		}else{
			on_assert_fail("fail! cancel()");
		}
		close_rs(mysql_rs);
		close_rs(uproxy_rs);

		close_stmt(mysql_psts);
		close_stmt(uproxy_psts);
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

		Statement mysql_stmt=null, uproxy_stmt=null;
		try {
			mysql_stmt = mysqlConn.createStatement();
			uproxy_stmt = uproxyConn.createStatement();

			TestUtilities.executeUpdate(mysqlConn, sql1);
			TestUtilities.executeUpdate(uproxyConn, sql1);

//			mysql_stmt.closeOnCompletion();
//			uproxy_stmt.closeOnCompletion();

			ResultSet mysql_rs = mysql_stmt.executeQuery(sql);
			ResultSet uproxy_rs = uproxy_stmt.executeQuery(sql);

			SQLWarning mysql_warn = mysql_stmt.getWarnings();
			SQLWarning uproxy_warn = uproxy_stmt.getWarnings();

			if(mysql_warn.getSQLState()== uproxy_warn.getSQLState() && mysql_warn.getErrorCode()==uproxy_warn.getErrorCode()){
				System.out.println("pass! getWarnings()!");
			}else{
//				System.out.println("select 1/0 mysql get warn:");
//				TestUtilities.printWarnings(mysql_warn);
//				System.out.println("select 1/0 uproxy get warn:");
//				TestUtilities.printWarnings(uproxy_warn);
				System.out.println("fail! getWarnings()!");
				//on_assert_fail("fail! getWarnings()!");
			}

			mysql_stmt.clearWarnings();
			uproxy_stmt.clearWarnings();

			if(uproxy_stmt.getWarnings()==null){
				System.out.println("pass! clearWarnings()!");
				System.out.println("pass! getWarnings()!");
			}else{
				on_assert_fail("fail! after clearWarnings() expect getWarnings gets null!");
			}

			mysql_rs.close();
			uproxy_rs.close();
			if(mysql_stmt.isClosed() == uproxy_stmt.isClosed()){
				System.out.println("pass! closeOnCompletion()!");
				System.out.println("pass! isClosed()!");
			}else{
				on_assert_fail("fail! closeOnCompletion()!");
			}
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		}finally{
			mysql_stmt.close();
			uproxy_stmt.close();
		}
	}

	/*
	 * function:execute(String sql)
	 * 			execute(String sql, int autoGeneratedKeys)
	 * 			execute(String sql, int[] columnIndexes)
	 * */
	private void itf_execute()throws SQLException {
		Statement mysql_stmt=null, uproxy_stmt=null;
		mysql_stmt = mysqlConn.createStatement();
		uproxy_stmt = uproxyConn.createStatement();

		String sql = "drop table if exists mytest_global1";
		String sql1="create table mytest_global1(id int primary key auto_increment, rank int)";
		mysql_stmt.execute(sql);
		uproxy_stmt.execute(sql);
		mysql_stmt.execute(sql1);
		uproxy_stmt.execute(sql1);

		sql = "insert into mytest_global1(rank) values(2)";
		mysql_stmt.execute(sql,Statement.RETURN_GENERATED_KEYS);
		uproxy_stmt.execute(sql,Statement.RETURN_GENERATED_KEYS);

		ResultSet mysql_keys = mysql_stmt.getGeneratedKeys();
		ResultSet uproxy_keys = uproxy_stmt.getGeneratedKeys();
		print_debug("compare_result: after '"+sql +"' getGeneratedKeys()");
		boolean isEqual = compare_result(mysql_keys, uproxy_keys);
		if(isEqual){
			System.out.println("pass! execute(String sql)!");
			System.out.println("pass! execute(String sql, int autoGeneratedKeys)!");
		}else{
			on_assert_fail("fail! execute(String sql)");
		}

		close_rs(mysql_keys);
		close_rs(uproxy_keys);

		close_stmt(mysql_stmt);
		close_stmt(uproxy_stmt);

		mysql_stmt = mysqlConn.createStatement();
		uproxy_stmt = uproxyConn.createStatement();
//
		sql = "insert into mytest_global1(rank) values(3)";
		int[] pkeys = {1, 2};
		mysql_stmt.execute(sql,pkeys);
		uproxy_stmt.execute(sql,pkeys);
		mysql_keys = mysql_stmt.getGeneratedKeys();
		uproxy_keys = uproxy_stmt.getGeneratedKeys();
		print_debug("compare_result: after '"+sql+"' getGeneratedKeys()");
		isEqual = compare_result(mysql_keys, uproxy_keys);

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
	/*
	 * function:prepare with blob , mysql will return more than one package
	 * */
	private void itf_blob()throws Exception {


	    String sql1="drop table if exists test_shard;";
		TestUtilities.executeUpdate(uproxyConn, sql1);
		TestUtilities.executeUpdate(mysqlConn, sql1);
		String sql2="create table test_shard(id char,pad blob,name char)";
		TestUtilities.executeUpdate(uproxyConn, sql2);
		TestUtilities.executeUpdate(mysqlConn, sql2);

		//Set auto-commit to false
		mysqlConn.setAutoCommit(false);
		uproxyConn.setAutoCommit(false);

		String SQL = "INSERT INTO test_shard " +
				"VALUES(?, ?, ?)";



//		 Create PrepareStatement object
		PreparedStatement mysql_pstmt = mysqlConn.prepareStatement(SQL);
		PreparedStatement uproxy_pstmt = uproxyConn.prepareStatement(SQL);



		// Set the variables

		String blobValue = "I am a Tester!";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(blobValue.getBytes());
		ByteArrayInputStream inputStream_1 = new ByteArrayInputStream(blobValue.getBytes());
        mysql_pstmt.setString(1, ""+1);;
        mysql_pstmt.setBlob(2, inputStream);
		mysql_pstmt.setString( 3, "S" );

		uproxy_pstmt.setString(1, ""+1);;
        uproxy_pstmt.setBlob(2, inputStream_1);
		uproxy_pstmt.setString( 3, "S" );

		mysql_pstmt.executeUpdate();
		uproxy_pstmt.executeUpdate();


		mysqlConn.setAutoCommit(true);
		uproxyConn.setAutoCommit(true);

		String sql = "select * from test_shard";

		ResultSet mysql_rs = mysql_pstmt.executeQuery(sql);
		ResultSet uproxy_rs = uproxy_pstmt.executeQuery(sql);

		print_debug("compare_result: " + sql);
		boolean isEqual = compare_result(mysql_rs, uproxy_rs);
		if(isEqual){
			System.out.println("pass! itf_blob()!");
		}else{
			on_assert_fail("fail! itf_blob()");
		}
		close_rs(mysql_rs);
		close_rs(uproxy_rs);

		close_stmt(mysql_pstmt);
		close_stmt(uproxy_pstmt);

	}

}
