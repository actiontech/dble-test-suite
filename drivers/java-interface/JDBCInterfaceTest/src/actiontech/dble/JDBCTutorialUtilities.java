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

import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.RowIdLifetime;
import java.sql.SQLException;

public class JDBCTutorialUtilities extends InterfaceTest {

	public JDBCTutorialUtilities(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
	}

	protected void start()throws SQLException{
		cursorHoldabilitySupport();
		System.out.println("pass! cursorHoldabilitySupport()!");
		rowIdLifetime();
		System.out.println("pass! rowIdLifetime()!");
	}

	private void cursorHoldabilitySupport() throws SQLException {
		DatabaseMetaData mysql_dbMetaData = mysqlConn.getMetaData();
		DatabaseMetaData dble_dbMetaData = dbleConn.getMetaData();

		print_debug("ResultSet.HOLD_CURSORS_OVER_COMMIT = " +
				ResultSet.HOLD_CURSORS_OVER_COMMIT);
		print_debug("ResultSet.CLOSE_CURSORS_AT_COMMIT = " +
				ResultSet.CLOSE_CURSORS_AT_COMMIT);

		if(mysql_dbMetaData.getResultSetHoldability() != dble_dbMetaData.getResultSetHoldability()){
			print_debug("mysql Default cursor holdability: " + mysql_dbMetaData.getResultSetHoldability());
			print_debug("dble Default cursor holdability: " + dble_dbMetaData.getResultSetHoldability());
			on_assert_fail("fail! Default cursor holdability is diff");
		}

		boolean mysql_supports = mysql_dbMetaData.supportsResultSetHoldability(ResultSet.HOLD_CURSORS_OVER_COMMIT);
		boolean dble_supports = dble_dbMetaData.supportsResultSetHoldability(ResultSet.HOLD_CURSORS_OVER_COMMIT);

		if(mysql_supports != dble_supports)
		{
			print_debug("Supports HOLD_CURSORS_OVER_COMMIT? " +	mysql_supports);
			print_debug("Supports HOLD_CURSORS_OVER_COMMIT? " +	dble_supports);
			on_assert_fail("fail! HOLD_CURSORS_OVER_COMMIT is diff");
		}
 
		mysql_supports = mysql_dbMetaData.supportsResultSetHoldability(ResultSet.CLOSE_CURSORS_AT_COMMIT);
		dble_supports = dble_dbMetaData.supportsResultSetHoldability(ResultSet.CLOSE_CURSORS_AT_COMMIT);

		if(mysql_supports != dble_supports)
		{
			print_debug("Supports CLOSE_CURSORS_AT_COMMIT? " +	mysql_supports);
			print_debug("Supports CLOSE_CURSORS_AT_COMMIT? " +	dble_supports);
			on_assert_fail("fail! CLOSE_CURSORS_AT_COMMIT is diff");
		}
	}

	private void rowIdLifetime() throws SQLException {
		DatabaseMetaData mysql_dbMetaData = mysqlConn.getMetaData();
		RowIdLifetime mysql_lifetime = mysql_dbMetaData.getRowIdLifetime();

		DatabaseMetaData dble_dbMetaData = mysqlConn.getMetaData();
		RowIdLifetime dble_lifetime = dble_dbMetaData.getRowIdLifetime();

		if(mysql_lifetime != dble_lifetime){
			System.out.println("mysql ROWID type: " + mysql_lifetime);
			System.out.println("dble ROWID type: " + dble_lifetime);
			on_assert_fail("fail! ROWID type is diff");
		}
	}
}
