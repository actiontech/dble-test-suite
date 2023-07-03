/* Copyright (C) 2016-2023 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech.dble;

import java.sql.SQLException;

public class Main {
	public static boolean isDebug = false;
	public static boolean showDebug = false;

	public Main() {
		// TODO Auto-generated constructor stub
	}

	public static  void print_debug(String info){
		if(showDebug)
			System.out.println(info);
	}

	public static void main(String[] args) throws Exception{
		ConnProperties mysqlProp = null, testProp = null;
		System.out.println("args num:"+args.length);

		if(args.length>0) {
			if(args[0].equals("debug")){
				Main.isDebug=true;
				showDebug = true;
			}else if(args[0].equals("showdebug")){
				showDebug = true;
			}
			System.out.println("isDebug:"+Main.isDebug);
			System.out.println("show debug:"+showDebug);
		}

		try {
			System.out.println("Reading properties file");
			mysqlProp = new ConnProperties("mysql");
			testProp = new ConnProperties("test");

			ConnectionTest connTest = new ConnectionTest(mysqlProp, testProp, true);
			connTest.start_test();

			StatementTest mysql_stmt = new StatementTest(mysqlProp, testProp, true);
			mysql_stmt.start_test();

//			StatementTest mariadb_stmt = new StatementTest(mysqlProp, testProp, false);
//			mariadb_stmt.start_test();

			JDBCTutorialUtilities tu = new JDBCTutorialUtilities(mysqlProp, testProp, true);
			tu.start_test();

			CachedRowSetSample myCachedRowSetSample = new CachedRowSetSample(mysqlProp, testProp, true);
			myCachedRowSetSample.start_test();

			ClobSample myClobSample = new ClobSample(mysqlProp, testProp, true);
			myClobSample.start_test();

			FilteredRowSetSample myFilteredRowSetSample = new FilteredRowSetSample(mysqlProp, testProp, true);
			myFilteredRowSetSample.start_test();

			JdbcRowSetSample myJdbcRowSetSample = new JdbcRowSetSample(mysqlProp, testProp, true);
		    myJdbcRowSetSample.start_test();

		    CoffeesTable coffeesTable = new CoffeesTable(mysqlProp, testProp, true);
		    coffeesTable.start_test();

			JoinSample myJoinSample = new JoinSample(mysqlProp, testProp, true);
			myJoinSample.start_test();

			//not support
//			StoredProcedureMySQLSample myStoredProcedureSample = new StoredProcedureMySQLSample(mysqlProp, testProp, true);
//			myStoredProcedureSample.start_test();

			WebRowSetSample myWebRowSetSample = new WebRowSetSample(mysqlProp, testProp, true);
			myWebRowSetSample.start_test();

			DriverManagerTest dmt = new DriverManagerTest(mysqlProp, testProp, true);
			dmt.start_test();

//			GeneralLogTest generalLogTest = new GeneralLogTest(mysqlProp, testProp, true);
//			generalLogTest.start_test();

			System.out.println("Congratulations, all interfaces passed!");
//			CoffeesFrame qf = new CoffeesFrame(mysqlProp, dbleProp);
//		    qf.pack();
//		    qf.setVisible(true);

		}catch(SQLException sqlEx){
			TestUtilities.printSQLException(sqlEx);
		}catch (Exception e) {
			System.err.println("Problem reading properties file");
			e.printStackTrace();
		}
	}

}
