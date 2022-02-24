/* Copyright (C) 2016-2022 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package actiontech.dble;

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

			ConnectionTest connTest = new ConnectionTest(mysqlProp, testProp);
			connTest.start_test();

			StatementTest stmtTest = new StatementTest(mysqlProp, testProp);
			stmtTest.start_test();

			JDBCTutorialUtilities tu = new JDBCTutorialUtilities(mysqlProp, testProp);
			tu.start_test();

			CachedRowSetSample myCachedRowSetSample = new CachedRowSetSample(mysqlProp, testProp);
			myCachedRowSetSample.start_test();

			ClobSample myClobSample = new ClobSample(mysqlProp, testProp);
			myClobSample.start_test();

			FilteredRowSetSample myFilteredRowSetSample = new FilteredRowSetSample(mysqlProp, testProp);
			myFilteredRowSetSample.start_test();

			JdbcRowSetSample myJdbcRowSetSample = new JdbcRowSetSample(mysqlProp, testProp);
		    myJdbcRowSetSample.start_test();

		    CoffeesTable coffeesTable = new CoffeesTable(mysqlProp, testProp);
		    coffeesTable.start_test();

			JoinSample myJoinSample = new JoinSample(mysqlProp, testProp);
			myJoinSample.start_test();

			//not support
//			StoredProcedureMySQLSample myStoredProcedureSample = new StoredProcedureMySQLSample(mysqlProp, testProp);
//			myStoredProcedureSample.start_test();

			WebRowSetSample myWebRowSetSample = new WebRowSetSample(mysqlProp, testProp);
			myWebRowSetSample.start_test();

			DriverManagerTest dmt = new DriverManagerTest(mysqlProp, testProp);
			dmt.start_test();

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
