package actiontech.dble;

import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.rowset.JdbcRowSet;

import com.sun.rowset.JdbcRowSetImpl;

public class JdbcRowSetSample extends InterfaceTest{

	public JdbcRowSetSample(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
	}

	private void updateRow(JdbcRowSet jdbcRs)throws SQLException{
		jdbcRs.setCommand("select * from COFFEES");
		jdbcRs.execute();

		jdbcRs.absolute(3);
		jdbcRs.updateFloat("PRICE", 10.99f);
		jdbcRs.updateRow();
	}
	
	private void insertRows(JdbcRowSet jdbcRs)throws SQLException{
		jdbcRs.moveToInsertRow();
		jdbcRs.updateString("COF_NAME", "HouseBlend");
		jdbcRs.updateInt("SUP_ID", 49);
		jdbcRs.updateFloat("PRICE", 7.99f);
		jdbcRs.updateInt("SALES", 0);
		jdbcRs.updateInt("TOTAL", 0);
		jdbcRs.insertRow();

		jdbcRs.moveToInsertRow();
		jdbcRs.updateString("COF_NAME", "HouseDecaf");
		jdbcRs.updateInt("SUP_ID", 49);
		jdbcRs.updateFloat("PRICE", 8.99f);
		jdbcRs.updateInt("SALES", 0);
		jdbcRs.updateInt("TOTAL", 0);
		jdbcRs.insertRow();
	}
	 
	public void testJdbcRowSet() throws SQLException {
		JdbcRowSet jdbcRs_dble = null, jdbcRs_mysql=null;
		Statement stmt = null;

		try {
			jdbcRs_dble = new JdbcRowSetImpl(dbleConn);
			jdbcRs_mysql = new JdbcRowSetImpl(mysqlConn);
			updateRow(jdbcRs_dble);
			updateRow(jdbcRs_mysql);
			
			print_debug("\nAfter updating the third row:");
			CoffeesTable.viewTable(mysqlConn, dbleConn);
			System.out.println("dble is the same with mysql after updateRow!");

			insertRows(jdbcRs_mysql);
			insertRows(jdbcRs_dble);
			print_debug("\nAfter inserting two rows:");
			CoffeesTable.viewTable(mysqlConn, dbleConn);
			System.out.println("dble is the same with mysql after inserting two rows!");

			jdbcRs_dble.last();
			jdbcRs_dble.deleteRow();

			print_debug("\nAfter deleting last row:");
			CoffeesTable.viewTable(mysqlConn, dbleConn);
			System.out.println("dble is the same with mysql after deleting last row!");
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
			on_assert_fail("fail! unexpected exception!");
		}

		finally {
			if (stmt != null) stmt.close();
		}
	}

	public void start()throws SQLException{
		createTable();
		populateTable();

		testJdbcRowSet();
		System.out.println("pass! test jdbc row set.");
	}
}
