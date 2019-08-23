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
