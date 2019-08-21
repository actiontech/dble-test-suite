package actiontech.dble;

import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.sql.Statement;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class CoffeesTable extends InterfaceTest {

	public CoffeesTable(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
	}

	public void start()throws SQLException{
		createTable();
		populateTable();
		System.out.println("test tables prepare passed!");

		modifyPrices(1.25f, mysqlConn);
		modifyPrices(1.25f, dbleConn);
		CoffeesTable.viewTable(mysqlConn, dbleConn);
		System.out.println("modifyPrices passed");

		print_debug("\nInserting a new row:");
		insertRow("Kona", 150, 10.99f, 0, 0, mysqlConn);
		insertRow("Kona", 150, 10.99f, 0, 0, dbleConn);
		CoffeesTable.viewTable(mysqlConn, dbleConn);
		System.out.println("dble is the same with mysql after insertRow");

		print_debug("\nUpdating sales of coffee per week:");
		HashMap<String, Integer> salesCoffeeWeek =
				new HashMap<String, Integer>();
		salesCoffeeWeek.put("Colombian", 175);
		salesCoffeeWeek.put("French_Roast", 150);
		salesCoffeeWeek.put("Espresso", 60);
		salesCoffeeWeek.put("Colombian_Decaf", 155);
		salesCoffeeWeek.put("French_Roast_Decaf", 90);
		updateCoffeeSales(salesCoffeeWeek, mysqlConn);
		updateCoffeeSales(salesCoffeeWeek, dbleConn);
		CoffeesTable.viewTable(mysqlConn, dbleConn);
		System.out.println("dble is the same with mysql after Updating sales of coffee per week");

		print_debug("\nModifying prices by percentage");
		modifyPricesByPercentage("Colombian", 0.10f, 9.00f, mysqlConn);
		modifyPricesByPercentage("Colombian", 0.10f, 9.00f, dbleConn);
		CoffeesTable.viewTable(mysqlConn, dbleConn);
		System.out.println("dble is the same with mysql after Modifying prices by percentage");


		print_debug("\nCOFFEES table after modifying prices by percentage:");

		CoffeesTable.viewTable(mysqlConn, dbleConn);

		System.out.println("\nPerforming batch updates; adding new coffees");
		batchUpdate(mysqlConn);
		batchUpdate(dbleConn);
		CoffeesTable.viewTable(mysqlConn, dbleConn);
	}

	public void updateCoffeeSales(HashMap<String, Integer> salesForWeek, Connection con) throws SQLException {

		PreparedStatement updateSales = null;
		PreparedStatement updateTotal = null;

		String updateString =
				"update COFFEES " + "set SALES = ? where COF_NAME = ?";

		String updateStatement =
				"update COFFEES " + "set TOTAL = TOTAL + ? where COF_NAME = ?";

		try {
			con.setAutoCommit(false);
			updateSales = con.prepareStatement(updateString);
			updateTotal = con.prepareStatement(updateStatement);

			for (Map.Entry<String, Integer> e : salesForWeek.entrySet()) {
				updateSales.setInt(1, e.getValue().intValue());
				updateSales.setString(2, e.getKey());
				updateSales.executeUpdate();

				updateTotal.setInt(1, e.getValue().intValue());
				updateTotal.setString(2, e.getKey());
				updateTotal.executeUpdate();
				con.commit();
			}
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
			if (con != null) {
				try {
					System.err.print("Transaction is being rolled back");
					con.rollback();
				} catch (SQLException excep) {
					TestUtilities.printSQLException(excep);
				}
			}
		} finally {
			if (updateSales != null) { updateSales.close(); }
			if (updateTotal != null) { updateTotal.close(); }
			con.setAutoCommit(true);
		}
	}

	public void modifyPrices(float percentage, Connection con) throws SQLException {
		Statement stmt = null;
		try {
			stmt =
					con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
			ResultSet uprs = stmt.executeQuery("SELECT * FROM COFFEES");

			while (uprs.next()) {
				float f = uprs.getFloat("PRICE");
				uprs.updateFloat("PRICE", f * percentage);
				uprs.updateRow();
			}

		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt != null) { stmt.close(); }
		}
	}


	public void modifyPricesByPercentage(String coffeeName, float priceModifier,
			float maximumPrice, Connection con) throws SQLException {
		con.setAutoCommit(false);

		Statement getPrice = null;
		Statement updatePrice = null;
		ResultSet rs = null;
		String query =
				"SELECT COF_NAME, PRICE FROM COFFEES " + "WHERE COF_NAME = '" +
						coffeeName + "'";

		try {
			//Savepoint save1 = con.setSavepoint();
			getPrice =
					con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
			updatePrice = con.createStatement();

			if (!getPrice.execute(query)) {
				System.out.println("Could not find entry for coffee named " +
						coffeeName);
			} else {
				rs = getPrice.getResultSet();
				rs.first();
				float oldPrice = rs.getFloat("PRICE");
				float newPrice = oldPrice + (oldPrice * priceModifier);
				System.out.println("Old price of " + coffeeName + " is " + oldPrice);
				System.out.println("New price of " + coffeeName + " is " + newPrice);
				System.out.println("Performing update...");
				updatePrice.executeUpdate("UPDATE COFFEES SET PRICE = " + newPrice +
						" WHERE COF_NAME = '" + coffeeName + "'");
				System.out.println("\nCOFFEES table after update:");
				if (newPrice > maximumPrice) {
					System.out.println("\nThe new price, " + newPrice +
							", is greater than the maximum " + "price, " +
							maximumPrice +
							". Rolling back the transaction...");
					con.rollback();
					System.out.println("\nCOFFEES table after rollback:");
				}
				con.commit();
			}
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (getPrice != null) { getPrice.close(); }
			if (updatePrice != null) { updatePrice.close(); }
			con.setAutoCommit(true);
		}
	}


	public void insertRow(String coffeeName, int supplierID, float price,
			int sales, int total, Connection con) throws SQLException {
		Statement stmt = null;
		try {
			stmt =
					con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
			ResultSet uprs = stmt.executeQuery("SELECT * FROM COFFEES");

			uprs.moveToInsertRow();

			uprs.updateString("COF_NAME", coffeeName);
			uprs.updateInt("SUP_ID", supplierID);
			uprs.updateFloat("PRICE", price);
			uprs.updateInt("SALES", sales);
			uprs.updateInt("TOTAL", total);

			uprs.insertRow();
			uprs.beforeFirst();

		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt != null) { stmt.close(); }
		}
	}

	public void batchUpdate(Connection con) throws SQLException {

		Statement stmt = null;
		try {

			con.setAutoCommit(false);
			stmt = con.createStatement();

			stmt.addBatch("INSERT INTO COFFEES " +
					"VALUES('Amaretto', 49, 9.99, 0, 0)");
//			stmt.addBatch("INSERT INTO COFFEES " +
//					"VALUES('Hazelnut', 49, 9.99, 0, 0)");
//			stmt.addBatch("INSERT INTO COFFEES " +
//					"VALUES('Amaretto_decaf', 49, 10.99, 0, 0)");
//			stmt.addBatch("INSERT INTO COFFEES " +
//					"VALUES('Hazelnut_decaf', 49, 10.99, 0, 0)");

//			int[] updateCounts =
			stmt.executeBatch();
			con.commit();

		} catch (BatchUpdateException b) {
			TestUtilities.printBatchUpdateException(b);
		} catch (SQLException ex) {
			TestUtilities.printSQLException(ex);
		} finally {
			if (stmt != null) { stmt.close(); }
			con.setAutoCommit(true);
		}
	}

	public static void viewTable(Connection conn_mysql, Connection conn_dble) throws SQLException {
		Statement stmt_mysql = null, stmt_dble = null;
		String query = "select COF_NAME, SUP_ID, PRICE, SALES, TOTAL from COFFEES";
		try {
			stmt_mysql = conn_mysql.createStatement();
			stmt_dble = conn_dble.createStatement();

			ResultSet rs_mysql = stmt_mysql.executeQuery(query);
			ResultSet rs_dble = stmt_dble.executeQuery(query);


			while (rs_mysql.next() && rs_dble.next()) {
				String coffeeName = rs_mysql.getString("COF_NAME");
				int supplierID = rs_mysql.getInt("SUP_ID");
				float price = rs_mysql.getFloat("PRICE");
				int sales = rs_mysql.getInt("SALES");
				int total = rs_mysql.getInt("TOTAL");
				Main.print_debug(coffeeName + ", " + supplierID + ", " + price +
						", " + sales + ", " + total);
			}

		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt_mysql != null) { stmt_mysql.close(); }
			if (stmt_dble != null) { stmt_dble.close(); }
		}
	}

	public static void alternateViewTable(Connection con) throws SQLException {
		Statement stmt = null;
		String query = "select COF_NAME, SUP_ID, PRICE, SALES, TOTAL from COFFEES";
		try {
			stmt = con.createStatement();
			ResultSet rs = stmt.executeQuery(query);
			while (rs.next()) {
				String coffeeName = rs.getString(1);
				int supplierID = rs.getInt(2);
				float price = rs.getFloat(3);
				int sales = rs.getInt(4);
				int total = rs.getInt(5);
				System.out.println(coffeeName + ", " + supplierID + ", " + price +
						", " + sales + ", " + total);
			}
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt != null) { stmt.close(); }
		}
	}

	public Set<String> getKeys(Connection con) throws SQLException {
		HashSet<String> keys = new HashSet<String>();
		Statement stmt = null;
		String query = "select COF_NAME from COFFEES";
		try {
			stmt = con.createStatement();
			ResultSet rs = stmt.executeQuery(query);
			while (rs.next()) {
				keys.add(rs.getString(1));
			}
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt != null) { stmt.close(); }
		}
		return keys;

	}
}
