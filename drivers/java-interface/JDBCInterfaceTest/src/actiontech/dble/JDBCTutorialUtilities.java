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
