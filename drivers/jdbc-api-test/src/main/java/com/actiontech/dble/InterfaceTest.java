/* Copyright (C) 2016-2020 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech.dble;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

public class InterfaceTest {
	protected Connection mysqlConn;
	protected Connection dbleConn;

	protected ConnProperties mysqlProp;
	protected ConnProperties dbleProp;

	public InterfaceTest(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		this.mysqlProp = mysqlProp;
		this.dbleProp = dbleProp;
		create_compare_conns();
	}

	protected void create_compare_conns(){
		System.out.println("create compare conns:");
		TestUtilities interfaceUtilities;
		try {
			interfaceUtilities = new TestUtilities();
			mysqlConn = interfaceUtilities.getConnectionAllowMultiQuery(mysqlProp);
			//dble not supported allowMultiQuery
			dbleConn = interfaceUtilities.getConnectionAllowMultiQuery(dbleProp);


			String dropDb = "DROP DATABASE IF EXISTS ";
			String createDb = "CREATE DATABASE ";
			TestUtilities.executeUpdate(mysqlConn, dropDb + mysqlProp.dbName);
			//dble not supported CREATE/DROP DATABASE
			//TestUtilities.executeUpdate(dbleConn, dropDb + dbleProp.dbName);
			TestUtilities.executeUpdate(mysqlConn, createDb + mysqlProp.dbName);
			//TestUtilities.executeUpdate(dbleConn, createDb + dbleProp.dbName);
			System.out.println(dbleProp.dbName);
			mysqlConn.setCatalog(mysqlProp.dbName);
			dbleConn.setCatalog(dbleProp.dbName);
		} catch (SQLException e) {
			System.err.println("ERR! SQLException!");
			TestUtilities.printSQLException(e);
		} catch (Exception e) {
			e.printStackTrace(System.err);
		} finally {

		}
	}

	public void createTable() throws SQLException {
		String SUPPLIERS = "create table SUPPLIERS"
				+"(SUP_ID integer NOT NULL,"
				+"SUP_NAME varchar(40) NOT NULL,"
				+"STREET varchar(40) NOT NULL,"
				+"CITY varchar(20) NOT NULL,"
				+"STATE char(2) NOT NULL,"
				+"ZIP char(5),"
				+"PRIMARY KEY (SUP_ID));";

		String MERCH_INVENTORY = "create table MERCH_INVENTORY"
				+"(ITEM_ID integer NOT NULL,"
				+ "   ITEM_NAME varchar(20),"
				+ "   SUP_ID int,   QUAN int,"
				+ "   DATE_VAL timestamp,"
				+ "   PRIMARY KEY (ITEM_ID),"
				+ "   FOREIGN KEY (SUP_ID) REFERENCES SUPPLIERS (SUP_ID));";

		String COFFEES = "create table COFFEES"
				+"(COF_NAME varchar(32) NOT NULL,"
				+" SUP_ID int NOT NULL,"
				+" PRICE numeric(10,2) NOT NULL,"
				+" SALES integer NOT NULL,"
				+" TOTAL integer NOT NULL,"
				+"PRIMARY KEY (COF_NAME),"
				+" FOREIGN KEY (SUP_ID) REFERENCES SUPPLIERS (SUP_ID));";

		String COFFEE_DESCRIPTIONS="create table COFFEE_DESCRIPTIONS"
				+"(COF_NAME varchar(32) NOT NULL,"
				+"COF_DESC blob NOT NULL,"
				+"PRIMARY KEY (COF_NAME),"
				+"FOREIGN KEY (COF_NAME) REFERENCES COFFEES (COF_NAME));";

		String COFFEE_HOUSES = "create table COFFEE_HOUSES"
				+"(STORE_ID integer NOT NULL,"
				+"CITY varchar(32),"
				+"COFFEE int NOT NULL,"
				+"MERCH int NOT NULL,"
				+"TOTAL int NOT NULL,"
				+"PRIMARY KEY (STORE_ID))";

		dropTable("COFFEE_HOUSES");
		dropTable("COFFEE_DESCRIPTIONS");
		dropTable("MERCH_INVENTORY");
		dropTable("COFFEES");
		dropTable("SUPPLIERS");
		doCreateTable(SUPPLIERS);
		doCreateTable(MERCH_INVENTORY);
		doCreateTable(COFFEES);
		doCreateTable(COFFEE_DESCRIPTIONS);
		doCreateTable(COFFEE_HOUSES);
	}

	public void doCreateTable(String sql) throws SQLException {
		TestUtilities.executeUpdate(mysqlConn, sql);
		TestUtilities.executeUpdate(dbleConn, sql);
	}
	public void dropTable(String table_name) throws SQLException {
		String sql = "DROP TABLE IF EXISTS "+table_name;
		TestUtilities.executeUpdate(mysqlConn, sql);
		TestUtilities.executeUpdate(dbleConn, sql);
	}

	public void populateTable() throws SQLException {
		String[] sqls = {
				"insert into SUPPLIERS values(49,  'Superior Coffee', '1 Party Place', 'Mendocino', 'CA', '95460');",
				"insert into SUPPLIERS values(101, 'Acme, Inc.', '99 Market Street', 'Groundsville', 'CA', '95199');",
				"insert into SUPPLIERS values(150, 'The High Ground', '100 Coffee Lane', 'Meadows', 'CA', '93966');",
				"insert into SUPPLIERS values(456, 'Restaurant Supplies, Inc.', '200 Magnolia Street', 'Meadows', 'CA', '93966');",
				"insert into SUPPLIERS values(927, 'Professional Kitchen', '300 Daisy Avenue', 'Groundsville', 'CA', '95199');",
				"insert into MERCH_INVENTORY values(00001234, 'Cup_Large', 456, 28, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00001235, 'Cup_Small', 456, 36, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00001236, 'Saucer', 456, 64, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00001287, 'Carafe', 456, 12, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00006931, 'Carafe', 927, 3, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00006935, 'PotHolder', 927, 88, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00006977, 'Napkin', 927, 108, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00006979, 'Towel', 927, 24, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00004488, 'CofMaker', 456, 5, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00004490, 'CofGrinder', 456, 9, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00004495, 'EspMaker', 456, 4, '2006-04-01');",
				"insert into MERCH_INVENTORY values(00006914, 'Cookbook', 927, 12, '2006-04-01');",
				"insert into COFFEES values('Colombian',          101, 7.99, 0, 0);",
				"insert into COFFEES values('French_Roast',       49,  8.99, 0, 0);",
				"insert into COFFEES values('Espresso',           150, 9.99, 0, 0);",
				"insert into COFFEES values('Colombian_Decaf',    101, 8.99, 0, 0);",
				"insert into COFFEES values('French_Roast_Decaf', 049, 9.99, 0, 0);",
				//				"insert into COF_INVENTORY values(1234, 'Colombian',       101, 0, '2006-04-01');",
				//				"insert into COF_INVENTORY values(1234, 'French_Roast',    49,  0, '2006-04-01');",
				//				"insert into COF_INVENTORY values(1234, 'Espresso',        150, 0, '2006-04-01');",
				//				"insert into COF_INVENTORY values(1234, 'Colombian_Decaf', 101, 0, '2006-04-01');"
				"insert into COFFEE_HOUSES values(10023, 'Mendocino', 3450, 2005, 5455);",
				"insert into COFFEE_HOUSES values(33002, 'Seattle', 4699, 3109, 7808);",
				"insert into COFFEE_HOUSES values(10040, 'SF', 5386, 2841, 8227);",
				"insert into COFFEE_HOUSES values(32001, 'Portland', 3147, 3579, 6726);",
				"insert into COFFEE_HOUSES values(10042, 'SF', 2863, 1874, 4710);",
				"insert into COFFEE_HOUSES values(10024, 'Sacramento', 1987, 2341, 4328);",
				"insert into COFFEE_HOUSES values(10039, 'Carmel', 2691, 1121, 3812);",
				"insert into COFFEE_HOUSES values(10041, 'LA', 1533, 1007, 2540);",
				"insert into COFFEE_HOUSES values(33005, 'Olympia', 2733, 1550, 4283);",
				"insert into COFFEE_HOUSES values(33010, 'Seattle', 3210, 2177, 5387);",
				"insert into COFFEE_HOUSES values(10035, 'SF', 1922, 1056, 2978);",
				"insert into COFFEE_HOUSES values(10037, 'LA', 2143, 1876, 4019);",
				"insert into COFFEE_HOUSES values(10034, 'San_Jose', 1234, 1032, 2266);",
				"insert into COFFEE_HOUSES values(32004, 'Eugene', 1356, 1112, 2468);"
		};

		for(String sql:sqls){
			TestUtilities.executeUpdate(mysqlConn,sql);
			TestUtilities.executeUpdate(dbleConn,sql);
		}
	}

	protected void on_assert_fail(String msg){
		System.out.println("Error:"+msg+"\nexit!!!");
		System.exit(-1);
	}

	protected void print_debug(String info){
		Main.print_debug(info);
	}

	protected void start()throws SQLException{}

	public void start_test(){
		System.out.println("******************** "+this.getClass()+" test *****************************");
		try{
			start();
		}catch (SQLException e) {
			TestUtilities.printSQLException(e);
			System.out.println("fail! SQLException :");
			e.printStackTrace(System.err) ;
			destroy(-1);
		} catch (Exception e) {
			System.out.println("fail! none SQLException Exception:"+e.getMessage());
			e.printStackTrace(System.err) ;
			destroy(-1);
		} finally {
			destroy(0);
		}
	}

	protected void close_rs(ResultSet rs){
		if (rs != null) {
			try {
				rs.close();
			} catch (SQLException sqlEx) {
				sqlEx.printStackTrace();
			} // ignore

			rs = null;
		}
	}

	protected void close_stmt(Statement stmt){
		if(stmt!=null){
			try{
				stmt.close();
			}catch (SQLException e){
				e.printStackTrace();
			}
			stmt = null;
		}
	}

	protected void print_resultset_from_stmt(Statement stmt, boolean hadResults) throws SQLException{
		while (hadResults) {
			ResultSet rs = stmt.getResultSet();
			print_resultset(rs);
			hadResults = stmt.getMoreResults();
		}
	}

	protected boolean compare_result(CallableStatement stmt1, CallableStatement stmt2)throws SQLException {
		boolean hadResults1 = stmt1.execute();
		boolean hadResults2 = stmt2.execute();

		do{
			if(hadResults1 != hadResults2){
				on_assert_fail("expect mysql hadResults: "+ hadResults1 + " equals to dble hadResults: "+hadResults2);
			}
			ResultSet set1 = stmt1.getResultSet();
			ResultSet set2 = stmt2.getResultSet();
			boolean isEqual = compare_result(set1, set2);
			if(!isEqual){
				on_assert_fail("mysql and dble get different result set");
			}

			hadResults1 = stmt1.getMoreResults();
			hadResults2 = stmt2.getMoreResults();

		}while (hadResults1);

		return true;
	}

	protected boolean compare_result(Object set_mysql, Object set_dble) {
		if (set_mysql instanceof ResultSet) {
			return equal((ResultSet) set_mysql, (ResultSet) set_dble);
		}
		print_debug("mysql result:" + set_mysql + ", dble result:" + set_dble);
		boolean b = set_mysql == set_dble;
		if (!b) {
			on_assert_fail("fail! update rows count is not equal:[" + set_mysql + "," + set_dble + "]");
		}
		return b;
	}

	private boolean equal(ResultSet set1, ResultSet set2) {
		try {
			ResultSetMetaData metaData1 = set1.getMetaData();
			ResultSetMetaData metaData2 = set2.getMetaData();
			int columnCount1 = metaData1.getColumnCount() + 1;
			int columnCount2 = metaData2.getColumnCount() + 1;
			if (columnCount1 != columnCount2) {
				on_assert_fail("column count is not equal[" + columnCount1 + "," + columnCount2 + "]");
				return false;
			}
			boolean line2 = set2.next();
			boolean line1 = set1.next();
			boolean tobreak = false;
			print_debug("resultset values of mysql and dble:");
			while (line1 && line2) {
				for (int i = 1; i < columnCount1; i++) {
					String value1 = null, value2 = null;
					try {
						value1 = set1.getString(i);
						print_debug("mysql " + value1);
					} catch (SQLException e) {
						value1 = e.getMessage();
					}
					try {
						value2 = set2.getString(i);
						print_debug("dble " +value2);
					} catch (SQLException e) {
						value2 = e.getMessage();
					}
					if (value1 == null && value2 == null) {
						continue;
					}
					if (value1 == null || value2 == null) {
						print_debug("value is not null,[" + value1 + "," + value2 + "]");
						tobreak = true;
						break;
					}
					if (!value1.equals(value2)) {
						print_debug("value is not null,[" + value1 + "," + value2 + "]");
						tobreak = true;
						break;
					}
				}
				line1 = set1.next();
				line2 = set2.next();
			}

			if(tobreak){
				resetCursor(set1,set2);
				return false;
			}

			if (line1 != line2) {
				System.out.println("mysql has next line: "+line1);
				System.out.println("dble has next line: "+line2);
				on_assert_fail("fail! rows content is not equal");
				resetCursor(set1,set2);
				return false;
			}
			resetCursor(set1, set2);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
			return false;
		}

		return true;
	}

	private void resetCursor(ResultSet set1, ResultSet set2)throws SQLException{
		if(!set1.isBeforeFirst())
			set1.beforeFirst();
		if(!set2.isBeforeFirst())
			set2.beforeFirst();
	}

	protected void print_resultset(ResultSet rs){
		try {
			ResultSetMetaData metaData1 = rs.getMetaData();
			int columnCount1 = metaData1.getColumnCount() + 1;
			while (rs.next()) {
				for (int i = 0; i < columnCount1; i++) {
					String value1 = null;
					try {
						value1 = rs.getString(i);
						System.out.println(value1);
					} catch (SQLException e) {
						value1 = e.getMessage();
					}
				}
			}
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		}
	}

	protected void destroy(int status){
		TestUtilities.closeConnection(mysqlConn);
		TestUtilities.closeConnection(dbleConn);
		if(status==-1) {
			System.exit(status);

		}
	}
}
