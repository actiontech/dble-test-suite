package com.demo.jdbc;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;

public class Main {
	public static void main(String[] args)  throws Exception{
		boolean isDebug = true;
		if (isDebug) {
			Config.initDebug();
			dotest();
		} else {
			dowork();
		}
	}

	private static void dotest() {
		String[] sqls = {
				"select * from test;"
		};

		JDBCConn conn = new JDBCConn("10.186.65.63", "test", "test", "schema1", 8066);
		System.out.println("==========================dble execute result=========================");
		for (String sql : sqls) {
			boolean isR = conn.execute(sql);
//			showResult(conn, isR, "uproxy execute result");
		}
//		conn.close();

		System.out.println("==========================mysql execute result=========================");

		JDBCConn conn2 = new JDBCConn("10.186.65.4", "test", "test", "schema1", 3306);
		for (String sql : sqls) {
			boolean isR2 = conn2.execute(sql);
//			showResult(conn2, isR2, "mysql execute result");
		}
		try {

			ResultSet re1 = conn.stmt.getResultSet();
			ResultSet re2 = conn2.stmt.getResultSet();


			ExecSQLAndCompare tt = new ExecSQLAndCompare("abc");
			boolean isResEqual = tt.equal(re1, re2);
			System.out.println(isResEqual);
		}catch(SQLException e){
			System.out.println(e.getStackTrace());
		}
		conn.close();
		conn2.close();
	}

	private static void showResult(JDBCConn conn, boolean isResultSet, String msg) {
		if (isResultSet) {
			try {
				ResultSet re = conn.stmt.getResultSet();
				printResult(re);

				boolean isR = conn.stmt.getMoreResults();
				if (isR)
					showResult(conn, isR, "");
			} catch (SQLException e) {
				e.printStackTrace();
			}

		} else {
			try {
				int rows = conn.stmt.getUpdateCount();
				System.out.println("affected rows: " + rows);
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	private static void printResult(ResultSet set1) {
		try {
			ResultSetMetaData metaData1 = set1.getMetaData();
			int columnCount1 = metaData1.getColumnCount();
			System.out.println("cols count:" + columnCount1);
			boolean line1 = set1.next();
			while (line1) {
				for (int i = 1; i <= columnCount1; i++) {
					String value1 = null;
					try {
						value1 = set1.getString(i);
					} catch (SQLException e) {
						value1 = e.getMessage();
					}
					System.out.println(value1);
				}
				line1 = set1.next();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	private static void dowork() {
		Config.getInstance().init("sys.config");

		Setup setter = Setup.getInstance();
		setter.prepare();

		ArrayList<String> sqlFiles = setter.getSqlFiles(Config.SQLS_CONFIG);
		for (String sqlFile : sqlFiles) {
			System.out.println("=====sql file to execute [" + sqlFile + "]=====");
			if (!(sqlFile.equals("insert.sql")||sqlFile.equals("update.sql"))){
				setter.createTestDB();
			}
			ExecSQLAndCompare executer = new ExecSQLAndCompare(sqlFile);
			executer.analyzeSql();
			setter.clearDirtyFiles();
		}
	}
}
