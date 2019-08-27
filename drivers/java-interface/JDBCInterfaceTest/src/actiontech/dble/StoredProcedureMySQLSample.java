/*
 * Copyright (c) 1995, 2011, Oracle and/or its affiliates. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 *   - Neither the name of Oracle or the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package actiontech.dble;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

public class StoredProcedureMySQLSample extends InterfaceTest {

	public StoredProcedureMySQLSample(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
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

		Statement stmt_dble = null, stmt_mysql=null;
		Statement stmtDrop_dble = null, stmtDrop_mysql=null;

		try {
			System.out.println("Calling DROP PROCEDURE");
			stmtDrop_dble = dbleConn.createStatement();
			stmtDrop_dble.execute(queryDrop);
			stmtDrop_mysql = mysqlConn.createStatement();
			stmtDrop_mysql.execute(queryDrop);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmtDrop_dble != null) { stmtDrop_dble.close(); }
			if (stmtDrop_mysql != null) { stmtDrop_mysql.close(); }
		}

		try {
			stmt_dble = dbleConn.createStatement();
			stmt_dble.executeUpdate(createProcedure);
			
			stmt_mysql = mysqlConn.createStatement();
			stmt_mysql.executeUpdate(createProcedure);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt_dble != null) { stmt_dble.close(); }
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
		Statement stmt_dble = null, stmt_mysql=null;
		Statement stmtDrop_dble = null, stmtDrop_mysql=null;

		try {
			System.out.println("Calling DROP PROCEDURE");
			stmtDrop_dble = dbleConn.createStatement();
			stmtDrop_dble.execute(queryDrop);
			
			stmtDrop_mysql = mysqlConn.createStatement();
			stmtDrop_mysql.execute(queryDrop);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmtDrop_dble != null) { stmtDrop_dble.close(); }
			if (stmtDrop_mysql != null) { stmtDrop_mysql.close(); }
		}


		try {
			stmt_dble = dbleConn.createStatement();
			stmt_dble.executeUpdate(createProcedure);
			
			stmt_mysql = mysqlConn.createStatement();
			stmt_mysql.executeUpdate(createProcedure);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt_dble != null) { stmt_dble.close(); }
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
		Statement stmt_dble = null, stmt_mysql=null;
		Statement stmtDrop_dble = null, stmtDrop_mysql=null;

		try {
			System.out.println("Calling DROP PROCEDURE");
			stmtDrop_dble = dbleConn.createStatement();
			stmtDrop_dble.execute(queryDrop);
			
			stmtDrop_mysql = mysqlConn.createStatement();
			stmtDrop_mysql.execute(queryDrop);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmtDrop_dble != null) { stmtDrop_dble.close(); }
			if (stmtDrop_mysql != null) { stmtDrop_mysql.close(); }
		}


		try {
			stmt_dble = dbleConn.createStatement();
			stmt_dble.executeUpdate(createProcedure);
			
			stmt_mysql = mysqlConn.createStatement();
			stmt_mysql.executeUpdate(createProcedure);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (stmt_dble != null) { stmt_dble.close(); }
			if (stmt_mysql != null) { stmt_mysql.close(); }
		}
	}

	public void runStoredProcedures(String coffeeNameArg, float maximumPercentageArg, float newPriceArg) throws SQLException {
		CallableStatement cs_dble = null, cs_mysql = null;

		try {
			System.out.println("\nCalling the procedure GET_SUPPLIER_OF_COFFEE");
			
			cs_dble = this.dbleConn.prepareCall("{call GET_SUPPLIER_OF_COFFEE(?, ?)}");
			cs_dble.setString(1, coffeeNameArg);
			cs_dble.registerOutParameter(2, Types.VARCHAR);
			cs_dble.executeQuery();
			
			cs_mysql = this.mysqlConn.prepareCall("{call GET_SUPPLIER_OF_COFFEE(?, ?)}");
			cs_mysql.setString(1, coffeeNameArg);
			cs_mysql.registerOutParameter(2, Types.VARCHAR);
			cs_mysql.executeQuery();

			String supplierName_dble = cs_dble.getString(2);
			String supplierName_mysql = cs_mysql.getString(2);

			if(!supplierName_dble.equals(supplierName_mysql)){
				on_assert_fail("dble get different result with mysql after execute procedure");
			}
			if(supplierName_dble != null) {
				print_debug("\nSupplier of the coffee " + coffeeNameArg + ": " + supplierName_dble);
			}else{
				print_debug("\nUnable to find the coffee " + coffeeNameArg);        
			}
			cs_dble.close();
			cs_mysql.close();

			System.out.println("\nCalling the procedure SHOW_SUPPLIERS");
			cs_dble = this.dbleConn.prepareCall("{call SHOW_SUPPLIERS}");
			ResultSet rs_dble = cs_dble.executeQuery();
			
			cs_mysql = this.mysqlConn.prepareCall("{call SHOW_SUPPLIERS}");
			ResultSet rs_mysql = cs_mysql.executeQuery();

			compare_result(rs_mysql, rs_dble);
			while (rs_dble.next()) {
				String supplier = rs_dble.getString("SUP_NAME");
				String coffee = rs_dble.getString("COF_NAME");
				print_debug(supplier + ": " + coffee);
			}

			print_debug("\nContents of COFFEES table before calling RAISE_PRICE:");
			CoffeesTable.viewTable(mysqlConn, dbleConn);
			cs_dble.close();
			cs_mysql.close();

			System.out.println("\nCalling the procedure RAISE_PRICE");
			cs_dble = this.dbleConn.prepareCall("{call RAISE_PRICE(?,?,?)}");
			cs_dble.setString(1, coffeeNameArg);
			cs_dble.setFloat(2, maximumPercentageArg);
			cs_dble.registerOutParameter(3, Types.NUMERIC);
			cs_dble.setFloat(3, newPriceArg);
			
			cs_dble.execute();
			
			cs_mysql = this.mysqlConn.prepareCall("{call RAISE_PRICE(?,?,?)}");
			cs_mysql.setString(1, coffeeNameArg);
			cs_mysql.setFloat(2, maximumPercentageArg);
			cs_mysql.registerOutParameter(3, Types.NUMERIC);
			cs_mysql.setFloat(3, newPriceArg);

			cs_mysql.execute();

			float price_dble = cs_dble.getFloat(3);
			float price_mysql = cs_mysql.getFloat(3);
			if(price_dble != price_mysql){
				on_assert_fail("dble get different newPrice with mysql after calling RAISE_PRICE");
			}
			print_debug("\nValue of newPrice after calling RAISE_PRICE: " + price_dble);

			print_debug("\nContents of COFFEES table after calling RAISE_PRICE:");
			CoffeesTable.viewTable(mysqlConn, dbleConn);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (cs_dble != null) { cs_dble.close(); }
			if (cs_mysql != null) { cs_mysql.close(); }
		}
	}
}
