package actiontech.dble;

import com.sun.rowset.CachedRowSetImpl;

import com.sun.rowset.JoinRowSetImpl;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.rowset.CachedRowSet;
import javax.sql.rowset.JoinRowSet;

public class JoinSample extends InterfaceTest {

	public JoinSample(ConnProperties mysqlProp, ConnProperties uproxyProp) throws SQLException {
		super(mysqlProp, uproxyProp);
	}

	public static void getCoffeesBoughtBySupplier(String supplierName,
			Connection con) throws SQLException {
		Statement stmt = null;
		String query =
				"SELECT COFFEES.COF_NAME " + "FROM COFFEES, SUPPLIERS " + "WHERE SUPPLIERS.SUP_NAME LIKE '" +
						supplierName + "' " + "and SUPPLIERS.SUP_ID = COFFEES.SUP_ID";

		try {
			stmt = con.createStatement();
			ResultSet rs = stmt.executeQuery(query);
			System.out.println("Coffees bought from " + supplierName + ": ");
			while (rs.next()) {
				String coffeeName = rs.getString(1);
				System.out.println("     " + coffeeName);
			}
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt != null) { stmt.close(); }
		}
	}

	public void testJoinRowSet(String supplierName) throws SQLException {
		CachedRowSet coffees_uproxy = null,coffees_mysql = null;
		CachedRowSet suppliers_uproxy = null, suppliers_mysql = null;
		JoinRowSet jrs_uproxy = null, jrs_mysql = null;

		try {
			//prepare jrs for uproxy
			coffees_uproxy = new CachedRowSetImpl();
			coffees_uproxy.setCommand("SELECT * FROM COFFEES");
			coffees_uproxy.setUsername(uproxyProp.userName);
			coffees_uproxy.setPassword(uproxyProp.password);
			coffees_uproxy.setUrl(uproxyProp.urlString+ "/" + uproxyProp.dbName+"?useSSL=false");
			coffees_uproxy.execute();
			
			suppliers_uproxy = new CachedRowSetImpl();
			suppliers_uproxy.setCommand("SELECT * FROM SUPPLIERS");
			suppliers_uproxy.setUsername(uproxyProp.userName);
			suppliers_uproxy.setPassword(uproxyProp.password);
			suppliers_uproxy.setUrl(uproxyProp.urlString+ "/" + uproxyProp.dbName+"?useSSL=false");
			suppliers_uproxy.execute();      
			
			jrs_uproxy = new JoinRowSetImpl();
			jrs_uproxy.addRowSet(coffees_uproxy, "SUP_ID");
			jrs_uproxy.addRowSet(suppliers_uproxy, "SUP_ID");
			
			//prepare jrs for mysql
			coffees_mysql = new CachedRowSetImpl();
			coffees_mysql.setCommand("SELECT * FROM COFFEES");
			coffees_mysql.setUsername(mysqlProp.userName);
			coffees_mysql.setPassword(mysqlProp.password);
			coffees_mysql.setUrl(mysqlProp.urlString+ "/" + mysqlProp.dbName+"?useSSL=false");
			coffees_mysql.execute();

			suppliers_mysql = new CachedRowSetImpl();
			suppliers_mysql.setCommand("SELECT * FROM SUPPLIERS");
			suppliers_mysql.setUsername(mysqlProp.userName);
			suppliers_mysql.setPassword(mysqlProp.password);
			suppliers_mysql.setUrl(mysqlProp.urlString+ "/" + mysqlProp.dbName+"?useSSL=false");
			suppliers_mysql.execute();      

			jrs_mysql = new JoinRowSetImpl();
			jrs_mysql.addRowSet(coffees_mysql, "SUP_ID");
			jrs_mysql.addRowSet(suppliers_mysql, "SUP_ID");


			compare_result(jrs_mysql, jrs_uproxy);
			System.out.println("Join result set of uproxy is the same with mysql");
			print_debug("Coffees bought from " + supplierName + ": ");
			while (jrs_uproxy.next()) {
				if (jrs_uproxy.getString("SUP_NAME").equals(supplierName)) { 
					String coffeeName = jrs_uproxy.getString(1);
					print_debug("     " + coffeeName);
				}
			}
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (jrs_uproxy != null) { jrs_uproxy.close(); }
			if (suppliers_uproxy != null) { suppliers_uproxy.close(); }
			if (coffees_uproxy != null) { coffees_uproxy.close(); }
			
			if (jrs_mysql != null) { jrs_mysql.close(); }
			if (suppliers_mysql != null) { suppliers_mysql.close(); }
			if (coffees_mysql != null) { coffees_mysql.close(); }
		}
	}

	public void start()throws SQLException{
		createTable();
		populateTable();

		testJoinRowSet("Acme, Inc.");
		System.out.println("pass! join row set!");
	}
}
