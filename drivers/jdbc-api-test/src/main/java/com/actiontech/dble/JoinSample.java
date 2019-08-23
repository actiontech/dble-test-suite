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
package com.actiontech.dble;

import com.sun.rowset.CachedRowSetImpl;

import com.sun.rowset.JoinRowSetImpl;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.rowset.CachedRowSet;
import javax.sql.rowset.JoinRowSet;

public class JoinSample extends InterfaceTest {

	public JoinSample(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
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
		CachedRowSet coffees_dble = null,coffees_mysql = null;
		CachedRowSet suppliers_dble = null, suppliers_mysql = null;
		JoinRowSet jrs_dble = null, jrs_mysql = null;

		try {
			//prepare jrs for dble
			coffees_dble = new CachedRowSetImpl();
			coffees_dble.setCommand("SELECT * FROM COFFEES");
			coffees_dble.setUsername(dbleProp.userName);
			coffees_dble.setPassword(dbleProp.password);
			coffees_dble.setUrl(dbleProp.urlString+ "/" + dbleProp.dbName+"?useSSL=false");
			coffees_dble.execute();
			
			suppliers_dble = new CachedRowSetImpl();
			suppliers_dble.setCommand("SELECT * FROM SUPPLIERS");
			suppliers_dble.setUsername(dbleProp.userName);
			suppliers_dble.setPassword(dbleProp.password);
			suppliers_dble.setUrl(dbleProp.urlString+ "/" + dbleProp.dbName+"?useSSL=false");
			suppliers_dble.execute();
			
			jrs_dble = new JoinRowSetImpl();
			jrs_dble.addRowSet(coffees_dble, "SUP_ID");
			jrs_dble.addRowSet(suppliers_dble, "SUP_ID");
			
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


			compare_result(jrs_mysql, jrs_dble);
			System.out.println("Join result set of dble is the same with mysql");
			print_debug("Coffees bought from " + supplierName + ": ");
			while (jrs_dble.next()) {
				if (jrs_dble.getString("SUP_NAME").equals(supplierName)) {
					String coffeeName = jrs_dble.getString(1);
					print_debug("     " + coffeeName);
				}
			}
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (jrs_dble != null) { jrs_dble.close(); }
			if (suppliers_dble != null) { suppliers_dble.close(); }
			if (coffees_dble != null) { coffees_dble.close(); }
			
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
