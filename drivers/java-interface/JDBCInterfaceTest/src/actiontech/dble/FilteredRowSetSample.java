package actiontech.dble;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.rowset.CachedRowSet;
import javax.sql.rowset.FilteredRowSet;

import com.sun.rowset.FilteredRowSetImpl;

public class FilteredRowSetSample extends InterfaceTest {

	public FilteredRowSetSample(ConnProperties mysqlProp, ConnProperties uproxyProp) throws SQLException {
		super(mysqlProp, uproxyProp);
	}

	public void start()throws SQLException{
		createTable();
		populateTable();
		
		testFilteredRowSet();
		System.out.println("pass! filtered row set!");
	}

	private void viewFilteredRowSet(FilteredRowSet frs_mysql,FilteredRowSet frs_uproxy) throws SQLException {
		if (frs_mysql == null || frs_uproxy == null) {
			if(frs_mysql != frs_uproxy){
				on_assert_fail("uproxy has different result with mysql on FilteredRowSet");
			}
			return;
		}

		CachedRowSet crs_mysql = (CachedRowSet)frs_mysql;
		CachedRowSet crs_uproxy = (CachedRowSet)frs_uproxy;

		compare_result(crs_mysql, crs_uproxy);
		while (crs_mysql.next() && crs_uproxy.next()) {
			if (crs_mysql == null || crs_uproxy ==null) {
				if(crs_mysql != crs_uproxy){
					on_assert_fail("uproxy has different result with mysql on CachedRowSet");
				}
				break;
			}
			
			print_debug(
					crs_mysql.getInt("STORE_ID") + ", " +
							crs_mysql.getString("CITY") + ", " +
							crs_mysql.getInt("COFFEE") + ", " +
							crs_mysql.getInt("MERCH") + ", " +
							crs_mysql.getInt("TOTAL"));
		}
	}

	public void viewTable() throws SQLException {
		Statement stmt_mysql = null, stmt_uproxy=null;
		String query = "select * from COFFEE_HOUSES";

		stmt_mysql = mysqlConn.createStatement();
		stmt_uproxy = uproxyConn.createStatement();

		ResultSet rs_mysql = stmt_mysql.executeQuery(query);
		ResultSet rs_uproxy = stmt_uproxy.executeQuery(query);

		compare_result(rs_mysql, rs_uproxy);
		while (rs_mysql.next()) {
			print_debug(rs_mysql.getInt("STORE_ID") + ", " +
					rs_mysql.getString("CITY") + ", " + rs_mysql.getInt("COFFEE") +
					", " + rs_mysql.getInt("MERCH") + ", " +
					rs_mysql.getInt("TOTAL"));
		}

		close_stmt(stmt_mysql);
		close_stmt(stmt_uproxy);
	}

	public void testFilteredRowSet()throws SQLException {
		FilteredRowSet frs_uproxy = null, frs_mysql=null;
		StateFilter myStateFilter = new StateFilter(10000, 10999, 1);
		String[] cityArray = { "SF", "LA" };

		CityFilter myCityFilter = new CityFilter(cityArray, 2);

		frs_mysql = new FilteredRowSetImpl();

		frs_mysql.setCommand("SELECT * FROM COFFEE_HOUSES");
		frs_mysql.setUsername(mysqlProp.userName);
		frs_mysql.setPassword(mysqlProp.password);
		frs_mysql.setUrl(mysqlProp.urlString + "/" + mysqlProp.dbName+"?useSSL=false&&relaxAutoCommit=true");
		frs_mysql.execute();

		frs_uproxy = new FilteredRowSetImpl();

		frs_uproxy.setCommand("SELECT * FROM COFFEE_HOUSES");
		frs_uproxy.setUsername(uproxyProp.userName);
		frs_uproxy.setPassword(uproxyProp.password);
		frs_uproxy.setUrl(uproxyProp.urlString + "/" + uproxyProp.dbName+"?useSSL=false&&relaxAutoCommit=true");
		frs_uproxy.execute();

		print_debug("\nBefore filter:");
		viewTable();
		System.out.println("uproxy is same with mysql before filter!");

		
		print_debug("\nSetting state filter:");
		frs_mysql.beforeFirst();
		frs_mysql.setFilter(myStateFilter);
		
		frs_uproxy.beforeFirst();
		frs_uproxy.setFilter(myStateFilter);
		this.viewFilteredRowSet(frs_mysql, frs_uproxy);
		System.out.println("uproxy is same with mysql after set filter at first time!");
		
		print_debug("\nSetting city filter:");
		frs_mysql.beforeFirst();
		frs_mysql.setFilter(myCityFilter);
		
		frs_uproxy.beforeFirst();
		frs_uproxy.setFilter(myCityFilter);
		
		this.viewFilteredRowSet(frs_mysql, frs_uproxy);
		System.out.println("uproxy is same with mysql after set filter at second time!");		
	}
}
