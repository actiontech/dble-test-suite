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

import java.io.StringWriter;
import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.sql.Statement;
import java.util.Properties;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;

public class TestUtilities {

	public TestUtilities() {
		super();
	}

	public static void getWarningsFromResultSet(ResultSet rs) throws SQLException {
		TestUtilities.printWarnings(rs.getWarnings());
	}

	public static void getWarningsFromStatement(Statement stmt) throws SQLException {
		TestUtilities.printWarnings(stmt.getWarnings());
	}

	public static void printWarnings(SQLWarning warning) throws SQLException {
		if (warning != null) {
			System.out.println("\n---Warning---\n");
			while (warning != null) {
				System.out.println("Message: " + warning.getMessage());
				System.out.println("SQLState: " + warning.getSQLState());
				System.out.print("Vendor error code: ");
				System.out.println(warning.getErrorCode());
				System.out.println("");
				warning = warning.getNextWarning();
			}
		}
	}

	public static boolean ignoreSQLException(String sqlState) {
		if (sqlState == null) {
			System.out.println("The SQL state is not defined!");
			return false;
		}
		// X0Y32: Jar file already exists in schema
		if (sqlState.equalsIgnoreCase("X0Y32"))
			return true;
		// 42Y55: Table already exists in schema
		if (sqlState.equalsIgnoreCase("42Y55"))
			return true;
		return false;
	}

	public static void printBatchUpdateException(BatchUpdateException b) {
		System.err.println("----BatchUpdateException----");
		System.err.println("SQLState:  " + b.getSQLState());
		System.err.println("Message:  " + b.getMessage());
		System.err.println("Vendor:  " + b.getErrorCode());
		System.err.print("Update counts:  ");
		int[] updateCounts = b.getUpdateCounts();
		for (int i = 0; i < updateCounts.length; i++) {
			System.err.print(updateCounts[i] + "   ");
		}
	}

	public static void printSQLException(SQLException ex) {
		for (Throwable e : ex) {
			if (e instanceof SQLException) {
				if (ignoreSQLException(((SQLException)e).getSQLState()) == false) {
					e.printStackTrace(System.err);
					System.err.println("SQLState: " + ((SQLException)e).getSQLState());
					System.err.println("Error Code: " + ((SQLException)e).getErrorCode());
					System.err.println("Message: " + e.getMessage());
					Throwable t = ex.getCause();
					while (t != null) {
						System.out.println("Cause: " + t);
						t = t.getCause();
					}
				}else {
					System.err.println("Error:"+e.getMessage());
				}
			}
		}
	}

	public static void alternatePrintSQLException(SQLException ex) {
		while (ex != null) {
			System.err.println("SQLState: " + ex.getSQLState());
			System.err.println("Error Code: " + ex.getErrorCode());
			System.err.println("Message: " + ex.getMessage());
			Throwable t = ex.getCause();
			while (t != null) {
				System.out.println("Cause: " + t);
				t = t.getCause();
			}
			ex = ex.getNextException();
		}
	}

	public Connection getConnectionToDatabase(ConnProperties prop) throws SQLException {
		Connection conn = null;
		Properties connectionProps = new Properties();
		connectionProps.put("user", prop.userName);
		connectionProps.put("password", prop.password);

		String url = "jdbc:mysql://" + prop.serverName +
				":" + prop.portNumber + "/" + prop.dbName+"?useSSL=false";
		conn = DriverManager.getConnection(url, connectionProps);
		conn.setCatalog(prop.dbName);

		System.out.println("Connected:"+url);
		return conn;
	}

	public Connection getConnection(ConnProperties prop) throws SQLException {
		Connection conn = null;
		Properties connectionProps = new Properties();
		connectionProps.put("user", prop.userName);
		connectionProps.put("password", prop.password);

		String urlString = "jdbc:mysql://" + prop.serverName +
				":" + prop.portNumber + "";
		String fullUrlString = urlString + "?useSSL=false";
		prop.urlString = urlString;

		Main.print_debug(urlString + ",user "+connectionProps.getProperty("user"));

		conn = DriverManager.getConnection(fullUrlString,
				connectionProps);

		conn.setCatalog(prop.dbName);
		return conn;
	}

	public Connection getConnectionAllowMultiQuery(ConnProperties prop) throws SQLException {
		Connection conn = null;
		Properties connectionProps = new Properties();
		connectionProps.put("user", prop.userName);
		connectionProps.put("password", prop.password);

		String urlString = "jdbc:mysql://" + prop.serverName +
				":" + prop.portNumber + "";
		String fullUrlString = urlString + "?useSSL=false&&allowMultiQueries=true";
		prop.urlString = urlString;

		Main.print_debug(fullUrlString + ",user "+connectionProps.getProperty("user")+", password "+connectionProps.getProperty("password"));

		conn = DriverManager.getConnection(fullUrlString,
				connectionProps);
		System.out.println("connect success!");
		//TestUtilities.executeUpdate(conn, "create database if not exists schema1");
		//conn.setCatalog(prop.dbName);
//		System.out.println("set catalog success!");
		return conn;
	}

	public static int executeUpdate(Connection conn, String sql) {
		int sqlStatus = -1;
		try {
			Statement s = conn.createStatement();
			sqlStatus= s.executeUpdate(sql);
			s.close();
			Main.print_debug("Executed: " + sql);
		} catch (SQLException e) {
			printSQLException(e);
		}
		return sqlStatus;
	}

	public static ResultSet executeQuery(Connection conn, String sql) {
		ResultSet rs = null;
		try {
			Statement s = conn.createStatement();
			rs = s.executeQuery(sql);
			s.close();
			Main.print_debug("Executed: " + sql);
		} catch (SQLException e) {
			printSQLException(e);
		}
		return rs;
	}

	public static void closeConnection(Connection connArg) {
		Main.print_debug("Releasing all open resources ...");
		try {
			if (connArg != null) {
				connArg.close();
				connArg = null;
			}
		} catch (SQLException sqle) {
			printSQLException(sqle);
		}
	}

	public static String convertDocumentToString(Document doc) throws TransformerConfigurationException,
	TransformerException {
		Transformer t = TransformerFactory.newInstance().newTransformer();
		//    t.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
		StringWriter sw = new StringWriter();
		t.transform(new DOMSource(doc), new StreamResult(sw));
		return sw.toString();


	}
}
