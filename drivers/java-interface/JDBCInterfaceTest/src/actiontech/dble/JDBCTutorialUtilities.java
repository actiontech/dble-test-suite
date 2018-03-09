package actiontech.dble;

import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.RowIdLifetime;
import java.sql.SQLException;

public class JDBCTutorialUtilities extends InterfaceTest {

	public JDBCTutorialUtilities(ConnProperties mysqlProp, ConnProperties uproxyProp) throws SQLException {
		super(mysqlProp, uproxyProp);
	}

	protected void start()throws SQLException{
		cursorHoldabilitySupport();
		System.out.println("pass! cursorHoldabilitySupport()!");
		rowIdLifetime();
		System.out.println("pass! rowIdLifetime()!");
	}

	private void cursorHoldabilitySupport() throws SQLException {
		DatabaseMetaData mysql_dbMetaData = mysqlConn.getMetaData();
		DatabaseMetaData uproxy_dbMetaData = uproxyConn.getMetaData();

		print_debug("ResultSet.HOLD_CURSORS_OVER_COMMIT = " +
				ResultSet.HOLD_CURSORS_OVER_COMMIT);
		print_debug("ResultSet.CLOSE_CURSORS_AT_COMMIT = " +
				ResultSet.CLOSE_CURSORS_AT_COMMIT);

		if(mysql_dbMetaData.getResultSetHoldability() != uproxy_dbMetaData.getResultSetHoldability()){
			print_debug("mysql Default cursor holdability: " + mysql_dbMetaData.getResultSetHoldability());
			print_debug("uproxy Default cursor holdability: " + uproxy_dbMetaData.getResultSetHoldability());
			on_assert_fail("fail! Default cursor holdability is diff");
		}

		boolean mysql_supports = mysql_dbMetaData.supportsResultSetHoldability(ResultSet.HOLD_CURSORS_OVER_COMMIT);
		boolean uproxy_supports = uproxy_dbMetaData.supportsResultSetHoldability(ResultSet.HOLD_CURSORS_OVER_COMMIT);

		if(mysql_supports != uproxy_supports)
		{
			print_debug("Supports HOLD_CURSORS_OVER_COMMIT? " +	mysql_supports);
			print_debug("Supports HOLD_CURSORS_OVER_COMMIT? " +	uproxy_supports);
			on_assert_fail("fail! HOLD_CURSORS_OVER_COMMIT is diff");
		}
 
		mysql_supports = mysql_dbMetaData.supportsResultSetHoldability(ResultSet.CLOSE_CURSORS_AT_COMMIT);
		uproxy_supports = uproxy_dbMetaData.supportsResultSetHoldability(ResultSet.CLOSE_CURSORS_AT_COMMIT);

		if(mysql_supports != uproxy_supports)
		{
			print_debug("Supports CLOSE_CURSORS_AT_COMMIT? " +	mysql_supports);
			print_debug("Supports CLOSE_CURSORS_AT_COMMIT? " +	uproxy_supports);
			on_assert_fail("fail! CLOSE_CURSORS_AT_COMMIT is diff");
		}
	}

	private void rowIdLifetime() throws SQLException {
		DatabaseMetaData mysql_dbMetaData = mysqlConn.getMetaData();
		RowIdLifetime mysql_lifetime = mysql_dbMetaData.getRowIdLifetime();

		DatabaseMetaData uproxy_dbMetaData = mysqlConn.getMetaData();
		RowIdLifetime uproxy_lifetime = uproxy_dbMetaData.getRowIdLifetime();

		if(mysql_lifetime != uproxy_lifetime){
			System.out.println("mysql ROWID type: " + mysql_lifetime);
			System.out.println("uproxy ROWID type: " + uproxy_lifetime);
			on_assert_fail("fail! ROWID type is diff");
		}
	}
}
