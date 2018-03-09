package actiontech.dble;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

public class StoredProcedureMySQLSample extends InterfaceTest {

	public StoredProcedureMySQLSample(ConnProperties mysqlProp, ConnProperties uproxyProp) throws SQLException {
		super(mysqlProp, uproxyProp);
	}

	public void start()throws SQLException{
		createTable();
		populateTable();
//		System.out.println("test tables prepare passed!");

		System.out.println("pass! Creating SHOW_SUPPLIERS stored procedure");
		createProcedureShowSuppliers();

		System.out.println("pass! Creating GET_SUPPLIER_OF_COFFEE stored procedure");
		createProcedureGetSupplierOfCoffee();

		System.out.println("pass! Creating RAISE_PRICE stored procedure");
		createProcedureRaisePrice();

		System.out.println("pass! Calling all stored procedures:");
		runStoredProcedures("Colombian", 0.10f, 19.99f);
	}

	public void createProcedureRaisePrice() throws SQLException {

		String createProcedure = null;

		String queryDrop = "DROP PROCEDURE IF EXISTS RAISE_PRICE";

		createProcedure =
				"create procedure RAISE_PRICE(IN coffeeName varchar(32), IN maximumPercentage float, INOUT newPrice numeric(10,2)) " +
						"begin " +
						"main: BEGIN " +
						"declare maximumNewPrice numeric(10,2); " +
						"declare oldPrice numeric(10,2); " +
						"select COFFEES.PRICE into oldPrice " +
						"from COFFEES " +
						"where COFFEES.COF_NAME = coffeeName; " +
						"set maximumNewPrice = oldPrice * (1 + maximumPercentage); " +
						"if (newPrice > maximumNewPrice) " +
						"then set newPrice = maximumNewPrice; " +
						"end if; " +
						"if (newPrice <= oldPrice) " +
						"then set newPrice = oldPrice;" +
						"leave main; " +
						"end if; " +
						"update COFFEES " +
						"set COFFEES.PRICE = newPrice " +
						"where COFFEES.COF_NAME = coffeeName; " +
						"select newPrice; " +
						"END main; " +
						"end";

		Statement stmt_uproxy = null, stmt_mysql=null;
		Statement stmtDrop_uproxy = null, stmtDrop_mysql=null;

		try {
			System.out.println("Calling DROP PROCEDURE");
			stmtDrop_uproxy = uproxyConn.createStatement();
			stmtDrop_uproxy.execute(queryDrop);
			stmtDrop_mysql = mysqlConn.createStatement();
			stmtDrop_mysql.execute(queryDrop);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmtDrop_uproxy != null) { stmtDrop_uproxy.close(); }
			if (stmtDrop_mysql != null) { stmtDrop_mysql.close(); }
		}

		try {
			stmt_uproxy = uproxyConn.createStatement();
			stmt_uproxy.executeUpdate(createProcedure);
			
			stmt_mysql = mysqlConn.createStatement();
			stmt_mysql.executeUpdate(createProcedure);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt_uproxy != null) { stmt_uproxy.close(); }
			if (stmt_mysql != null) { stmt_mysql.close(); }
		}
	}

	public void createProcedureGetSupplierOfCoffee() throws SQLException {

		String createProcedure = null;

		String queryDrop = "DROP PROCEDURE IF EXISTS GET_SUPPLIER_OF_COFFEE";

		createProcedure =
				"create procedure GET_SUPPLIER_OF_COFFEE(IN coffeeName varchar(32), OUT supplierName varchar(40)) " +
						"begin " +
						"select SUPPLIERS.SUP_NAME into supplierName " +
						"from SUPPLIERS, COFFEES " +
						"where SUPPLIERS.SUP_ID = COFFEES.SUP_ID " +
						"and coffeeName = COFFEES.COF_NAME; " +
						"select supplierName; " +
						"end";
		Statement stmt_uproxy = null, stmt_mysql=null;
		Statement stmtDrop_uproxy = null, stmtDrop_mysql=null;

		try {
			System.out.println("Calling DROP PROCEDURE");
			stmtDrop_uproxy = uproxyConn.createStatement();
			stmtDrop_uproxy.execute(queryDrop);
			
			stmtDrop_mysql = mysqlConn.createStatement();
			stmtDrop_mysql.execute(queryDrop);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmtDrop_uproxy != null) { stmtDrop_uproxy.close(); }
			if (stmtDrop_mysql != null) { stmtDrop_mysql.close(); }
		}


		try {
			stmt_uproxy = uproxyConn.createStatement();
			stmt_uproxy.executeUpdate(createProcedure);
			
			stmt_mysql = mysqlConn.createStatement();
			stmt_mysql.executeUpdate(createProcedure);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt_uproxy != null) { stmt_uproxy.close(); }
			if (stmt_mysql != null) { stmt_mysql.close(); }
		}
	}

	public void createProcedureShowSuppliers() throws SQLException {
		String createProcedure = null;

		String queryDrop = "DROP PROCEDURE IF EXISTS SHOW_SUPPLIERS";

		createProcedure =
				"create procedure SHOW_SUPPLIERS() " +
						"begin " +
						"select SUPPLIERS.SUP_NAME, COFFEES.COF_NAME " +
						"from SUPPLIERS, COFFEES " +
						"where SUPPLIERS.SUP_ID = COFFEES.SUP_ID " +
						"order by SUP_NAME; " +
						"end";
		Statement stmt_uproxy = null, stmt_mysql=null;
		Statement stmtDrop_uproxy = null, stmtDrop_mysql=null;

		try {
			System.out.println("Calling DROP PROCEDURE");
			stmtDrop_uproxy = uproxyConn.createStatement();
			stmtDrop_uproxy.execute(queryDrop);
			
			stmtDrop_mysql = mysqlConn.createStatement();
			stmtDrop_mysql.execute(queryDrop);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmtDrop_uproxy != null) { stmtDrop_uproxy.close(); }
			if (stmtDrop_mysql != null) { stmtDrop_mysql.close(); }
		}


		try {
			stmt_uproxy = uproxyConn.createStatement();
			stmt_uproxy.executeUpdate(createProcedure);
			
			stmt_mysql = mysqlConn.createStatement();
			stmt_mysql.executeUpdate(createProcedure);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt_uproxy != null) { stmt_uproxy.close(); }
			if (stmt_mysql != null) { stmt_mysql.close(); }
		}
	}

	public void runStoredProcedures(String coffeeNameArg, float maximumPercentageArg, float newPriceArg) throws SQLException {
		CallableStatement cs_uproxy = null, cs_mysql = null;

		try {
			System.out.println("\nCalling the procedure GET_SUPPLIER_OF_COFFEE");
			
			cs_uproxy = this.uproxyConn.prepareCall("{call GET_SUPPLIER_OF_COFFEE(?, ?)}");
			cs_uproxy.setString(1, coffeeNameArg);
			cs_uproxy.registerOutParameter(2, Types.VARCHAR);
			cs_uproxy.executeQuery();
			
			cs_mysql = this.mysqlConn.prepareCall("{call GET_SUPPLIER_OF_COFFEE(?, ?)}");
			cs_mysql.setString(1, coffeeNameArg);
			cs_mysql.registerOutParameter(2, Types.VARCHAR);
			cs_mysql.executeQuery();

			String supplierName_uproxy = cs_uproxy.getString(2);
			String supplierName_mysql = cs_mysql.getString(2);

			if(!supplierName_uproxy.equals(supplierName_mysql)){
				on_assert_fail("uproxy get different result with mysql after execute procedure");
			}
			if(supplierName_uproxy != null) {
				print_debug("\nSupplier of the coffee " + coffeeNameArg + ": " + supplierName_uproxy);          
			}else{
				print_debug("\nUnable to find the coffee " + coffeeNameArg);        
			}
			cs_uproxy.close();
			cs_mysql.close();

			System.out.println("\nCalling the procedure SHOW_SUPPLIERS");
			cs_uproxy = this.uproxyConn.prepareCall("{call SHOW_SUPPLIERS}");
			ResultSet rs_uproxy = cs_uproxy.executeQuery();
			
			cs_mysql = this.mysqlConn.prepareCall("{call SHOW_SUPPLIERS}");
			ResultSet rs_mysql = cs_mysql.executeQuery();

			compare_result(rs_mysql, rs_uproxy);
			while (rs_uproxy.next()) {
				String supplier = rs_uproxy.getString("SUP_NAME");
				String coffee = rs_uproxy.getString("COF_NAME");
				print_debug(supplier + ": " + coffee);
			}

			print_debug("\nContents of COFFEES table before calling RAISE_PRICE:");
			CoffeesTable.viewTable(mysqlConn, uproxyConn);
			cs_uproxy.close();
			cs_mysql.close();

			System.out.println("\nCalling the procedure RAISE_PRICE");
			cs_uproxy = this.uproxyConn.prepareCall("{call RAISE_PRICE(?,?,?)}");
			cs_uproxy.setString(1, coffeeNameArg);
			cs_uproxy.setFloat(2, maximumPercentageArg);
			cs_uproxy.registerOutParameter(3, Types.NUMERIC);
			cs_uproxy.setFloat(3, newPriceArg);
			
			cs_uproxy.execute();
			
			cs_mysql = this.mysqlConn.prepareCall("{call RAISE_PRICE(?,?,?)}");
			cs_mysql.setString(1, coffeeNameArg);
			cs_mysql.setFloat(2, maximumPercentageArg);
			cs_mysql.registerOutParameter(3, Types.NUMERIC);
			cs_mysql.setFloat(3, newPriceArg);

			cs_mysql.execute();

			float price_uproxy = cs_uproxy.getFloat(3);
			float price_mysql = cs_mysql.getFloat(3);
			if(price_uproxy != price_mysql){
				on_assert_fail("uproxy get different newPrice with mysql after calling RAISE_PRICE");
			}
			print_debug("\nValue of newPrice after calling RAISE_PRICE: " + price_uproxy);

			print_debug("\nContents of COFFEES table after calling RAISE_PRICE:");
			CoffeesTable.viewTable(mysqlConn, uproxyConn);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (cs_uproxy != null) { cs_uproxy.close(); }
			if (cs_mysql != null) { cs_mysql.close(); }
		}
	}
}
