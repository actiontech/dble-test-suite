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

import java.io.*;
import java.sql.Clob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ClobSample extends InterfaceTest{

	public ClobSample(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
	}

	protected void start()throws SQLException {
		createTable();
		populateTable();
		addRowToCoffeeDescriptions("Colombian", "txt/colombian-description.txt");
		retrieveExcerpt("Colombian", 10);
		System.out.println("pass! Clob getClob(), setClob() !");
	}

	/**
	 * getClob()
	 */
	public void retrieveExcerpt(String coffeeName,
			int numChar) throws SQLException {

		Clob mysql_clob = null,dble_clob=null;
		PreparedStatement mysql_pstmt = null, dble_pstmt=null;

		try {
			String sql = "select COF_DESC from COFFEE_DESCRIPTIONS " + "where COF_NAME = ?";
			mysql_pstmt = this.mysqlConn.prepareStatement(sql);
			mysql_pstmt.setString(1, coffeeName);
			ResultSet mysql_rs = mysql_pstmt.executeQuery();
			dble_pstmt = this.dbleConn.prepareStatement(sql);
			dble_pstmt.setString(1, coffeeName);
			ResultSet dble_rs = dble_pstmt.executeQuery();
			if (mysql_rs.next()) {
				dble_rs.next();
				mysql_clob = mysql_rs.getClob(1);
				dble_clob = dble_rs.getClob(1);
				String mysql_str = mysql_clob.getSubString(1, (int)mysql_clob.length());
				String dble_str = dble_clob.getSubString(1, (int)dble_clob.length());
				if(!mysql_str.equals(dble_str)){
					print_debug("mysql:"+mysql_str);
					print_debug("dble:"+dble_str);
					on_assert_fail("fail! after insert blob, the value is different.");
				}
			}
		} catch (SQLException sqlex) {
			TestUtilities.printSQLException(sqlex);
		} catch (Exception ex) {
			System.out.println("Unexpected exception: " + ex.toString());
			on_assert_fail("fail!");
		} finally {
			if (mysql_pstmt != null) mysql_pstmt.close();
			if (dble_pstmt != null) dble_pstmt.close();
		}
	}


	/**
	 * setClob()
	 * Connection#Clob	createClob()
	 */
	public void addRowToCoffeeDescriptions(String coffeeName,
			String fileName) throws SQLException {
		PreparedStatement mysql_pstmt = null, dble_pstmt = null;
		try {
			Clob myClob = this.mysqlConn.createClob();

			Writer clobWriter = myClob.setCharacterStream(1);
			String str = this.readFile(fileName, clobWriter);
			print_debug("Wrote the following: " + clobWriter.toString());
			print_debug("MySQL, setting String in Clob object with setString method");
			myClob.setString(1, str);
			print_debug("Length of Clob: " + myClob.length());
			String sql = "INSERT INTO COFFEE_DESCRIPTIONS VALUES(?,?)";
			mysql_pstmt = this.mysqlConn.prepareStatement(sql);
			mysql_pstmt.setString(1, coffeeName);
			mysql_pstmt.setClob(2, myClob);
			mysql_pstmt.executeUpdate();

			dble_pstmt = this.dbleConn.prepareStatement(sql);
			dble_pstmt.setString(1, coffeeName);
			dble_pstmt.setClob(2, myClob);
			dble_pstmt.executeUpdate();
		} catch (SQLException sqlex) {
			TestUtilities.printSQLException(sqlex);
		} catch (Exception ex) {
			System.out.println("Unexpected exception: " + ex.toString());
		} finally {
			if (mysql_pstmt != null) { mysql_pstmt.close(); }
			if (dble_pstmt != null) { dble_pstmt.close(); }
		}
	}

	private String readFile(String fileName, Writer writerArg) throws IOException {

		ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
		InputStream resourceAsStream = classLoader.getResourceAsStream(fileName);
		assert resourceAsStream != null;
		InputStreamReader inputStreamReader = new InputStreamReader(resourceAsStream);
		BufferedReader br = new BufferedReader(inputStreamReader);

		String nextLine = "";
		StringBuffer sb = new StringBuffer();
		while ((nextLine = br.readLine()) != null) {
			print_debug("Writing: " + nextLine);
			writerArg.write(nextLine);
			sb.append(nextLine);
		}
		// Convert the content into to a string
		String clobData = sb.toString();

		br.close();
		// Return the data.
		return clobData;
	}

}
