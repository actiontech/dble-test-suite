package actiontech.dble;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.rowset.CachedRowSet;
import javax.sql.rowset.FilteredRowSet;

import com.sun.rowset.FilteredRowSetImpl;

public class FilteredRowSetSample extends InterfaceTest {

	public FilteredRowSetSample(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
	}

	public void start()throws SQLException{
		createTable();
		populateTable();
		
		testFilteredRowSet();
		System.out.println("pass! filtered row set!");
	}

	private void viewFilteredRowSet(FilteredRowSet frs_mysql,FilteredRowSet frs_dble) throws SQLException {
		if (frs_mysql == null || frs_dble == null) {
			if(frs_mysql != frs_dble){
				on_assert_fail("dble has different result with mysql on FilteredRowSet");
			}
			return;
		}

		CachedRowSet crs_mysql = (CachedRowSet)frs_mysql;
		CachedRowSet crs_dble = (CachedRowSet)frs_dble;

		compare_result(crs_mysql, crs_dble);
		while (crs_mysql.next() && crs_dble.next()) {
			if (crs_mysql == null || crs_dble ==null) {
				if(crs_mysql != crs_dble){
					on_assert_fail("dble has different result with mysql on CachedRowSet");
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
		Statement stmt_mysql = null, stmt_dble=null;
		String query = "select * from COFFEE_HOUSES";

		stmt_mysql = mysqlConn.createStatement();
		stmt_dble = dbleConn.createStatement();

		ResultSet rs_mysql = stmt_mysql.executeQuery(query);
		ResultSet rs_dble = stmt_dble.executeQuery(query);

		compare_result(rs_mysql, rs_dble);
		while (rs_mysql.next()) {
			print_debug(rs_mysql.getInt("STORE_ID") + ", " +
					rs_mysql.getString("CITY") + ", " + rs_mysql.getInt("COFFEE") +
					", " + rs_mysql.getInt("MERCH") + ", " +
					rs_mysql.getInt("TOTAL"));
		}

		close_stmt(stmt_mysql);
		close_stmt(stmt_dble);
	}

	public void testFilteredRowSet()throws SQLException {
		FilteredRowSet frs_dble = null, frs_mysql=null;
		StateFilter myStateFilter = new StateFilter(10000, 10999, 1);
		String[] cityArray = { "SF", "LA" };

		CityFilter myCityFilter = new CityFilter(cityArray, 2);

		frs_mysql = new FilteredRowSetImpl();

		frs_mysql.setCommand("SELECT * FROM COFFEE_HOUSES");
		frs_mysql.setUsername(mysqlProp.userName);
		frs_mysql.setPassword(mysqlProp.password);
		frs_mysql.setUrl(mysqlProp.urlString + "/" + mysqlProp.dbName+"?useSSL=false&&relaxAutoCommit=true");
		frs_mysql.execute();

		frs_dble = new FilteredRowSetImpl();

		frs_dble.setCommand("SELECT * FROM COFFEE_HOUSES");
		frs_dble.setUsername(dbleProp.userName);
		frs_dble.setPassword(dbleProp.password);
		frs_dble.setUrl(dbleProp.urlString + "/" + dbleProp.dbName+"?useSSL=false&&relaxAutoCommit=true");
		frs_dble.execute();

		print_debug("\nBefore filter:");
		viewTable();
		System.out.println("dble is same with mysql before filter!");

		
		print_debug("\nSetting state filter:");
		frs_mysql.beforeFirst();
		frs_mysql.setFilter(myStateFilter);
		
		frs_dble.beforeFirst();
		frs_dble.setFilter(myStateFilter);
		this.viewFilteredRowSet(frs_mysql, frs_dble);
		System.out.println("dble is same with mysql after set filter at first time!");
		
		print_debug("\nSetting city filter:");
		frs_mysql.beforeFirst();
		frs_mysql.setFilter(myCityFilter);
		
		frs_dble.beforeFirst();
		frs_dble.setFilter(myCityFilter);
		
		this.viewFilteredRowSet(frs_mysql, frs_dble);
		System.out.println("dble is same with mysql after set filter at second time!");
	}
}
