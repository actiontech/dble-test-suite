package actiontech.dble;

import java.net.MalformedURLException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.GregorianCalendar;

import javax.sql.rowset.CachedRowSet;
import javax.sql.rowset.spi.SyncProviderException;
import javax.sql.rowset.spi.SyncResolver;

import com.sun.rowset.CachedRowSetImpl;


public class CachedRowSetSample extends InterfaceTest {

	public CachedRowSetSample(ConnProperties mysqlProp, ConnProperties uproxyProp) throws SQLException {
		super(mysqlProp, uproxyProp);
	}

	protected void start()throws SQLException{
		createTable();
		populateTable();
		
		viewTable();
		try{
			testPaging();
			System.out.println("pass! testPaging()");
		}catch(MalformedURLException ex){
			ex.printStackTrace();
			on_assert_fail("fail! testPaging err");
		}
	}

	private void testPaging() throws SQLException, MalformedURLException {
		CachedRowSet mysql_crs = null;
		this.mysqlConn.setAutoCommit(false);
		
		CachedRowSet uproxy_crs = null;
		this.uproxyConn.setAutoCommit(false);

		try {
			mysql_crs = new CachedRowSetImpl();
			mysql_crs.setUsername(mysqlProp.userName);
			mysql_crs.setPassword(mysqlProp.password);
			
			uproxy_crs = new CachedRowSetImpl();
			uproxy_crs.setUsername(uproxyProp.userName);
			uproxy_crs.setPassword(uproxyProp.password);

			mysql_crs.setUrl(mysqlProp.urlString + "/" + mysqlProp.dbName+"?useSSL=false&&relaxAutoCommit=true");
			uproxy_crs.setUrl(uproxyProp.urlString + "/" + uproxyProp.dbName+"?useSSL=false&&relaxAutoCommit=true");

			mysql_crs.setCommand("select * from MERCH_INVENTORY");
			uproxy_crs.setCommand("select * from MERCH_INVENTORY");

			// Setting the page size to 4, such that we
			// get the data in chunks of 4 rows @ a time.
			mysql_crs.setPageSize(4);
			uproxy_crs.setPageSize(4);

			// Now get the first set of data
			mysql_crs.execute();
			uproxy_crs.execute();

			mysql_crs.addRowSetListener(new ExampleRowSetListener());
			uproxy_crs.addRowSetListener(new ExampleRowSetListener());

			// Keep on getting data in chunks until done.

			int i = 1;
			do {
				print_debug("Page number: " + i);
				while (mysql_crs.next()) {
					uproxy_crs.next();
					
					int itemId_uproxy=uproxy_crs.getInt("ITEM_ID");
					int itemId_mysql=mysql_crs.getInt("ITEM_ID");
					
					String itemName_uproxy=uproxy_crs.getString("ITEM_NAME");
					String itemName_mysql=mysql_crs.getString("ITEM_NAME");
					
					print_debug("mysql Found item " + itemId_mysql + ": " +itemName_mysql);
					print_debug("uproxy Found item " + itemId_uproxy + ": " +itemName_uproxy);
					
					if(!(itemId_uproxy==itemId_mysql && itemName_uproxy.equals(itemName_mysql))){
						on_assert_fail("Uproxy get different with mysql");
					}
					
					if (itemId_mysql == 1235) {
						int currentQuantity = mysql_crs.getInt("QUAN") + 1;
						print_debug("Updating quantity to " + currentQuantity);
						mysql_crs.updateInt("QUAN", currentQuantity + 1);
						uproxy_crs.updateInt("QUAN", currentQuantity + 1);
						mysql_crs.updateRow();
						uproxy_crs.updateRow();
						// Syncing the row back to the DB
						mysql_crs.acceptChanges(mysqlConn);
						uproxy_crs.acceptChanges(uproxyConn);
					}
				} // End of inner while
				i++;
			} while (mysql_crs.nextPage()&&uproxy_crs.nextPage());
			// End of outer while


			// Inserting a new row
			// Doing a previous page to come back to the last page
			// as we ll be after the last page.

			int newItemId = 123456;

			if (this.doesItemIdExist(newItemId)) {
				print_debug("Item ID " + newItemId + " already exists");
			} else {
				addNewRow(mysql_crs, newItemId);
				addNewRow(uproxy_crs, newItemId);
				
				this.viewTable();
			}
		} catch (SyncProviderException spe) {

			SyncResolver resolver = spe.getSyncResolver();

			Object crsValue; // value in the RowSet object
			Object resolverValue; // value in the SyncResolver object
			Object resolvedValue; // value to be persisted

			while (resolver.nextConflict()) {

				if (resolver.getStatus() == SyncResolver.INSERT_ROW_CONFLICT) {
					int row = resolver.getRow();
					mysql_crs.absolute(row);

					int colCount = mysql_crs.getMetaData().getColumnCount();
					for (int j = 1; j <= colCount; j++) {
						if (resolver.getConflictValue(j) != null) {
							crsValue = mysql_crs.getObject(j);
							resolverValue = resolver.getConflictValue(j);

							// Compare crsValue and resolverValue to determine
							// which should be the resolved value (the value to persist)
							//
							// This example choses the value in the RowSet object,
							// crsValue, to persist.,

							resolvedValue = crsValue;

							resolver.setResolvedValue(j, resolvedValue);
						}
					}
				}
			}
		} catch (SQLException sqle) {
			TestUtilities.printSQLException(sqle);
		} finally {
			if (mysql_crs != null) mysql_crs.close();
			this.mysqlConn.setAutoCommit(true);
		}

	}
	
	private void addNewRow(CachedRowSet crs,int newItemId)throws SQLException{
		crs.previousPage();
		crs.moveToInsertRow();
		crs.updateInt("ITEM_ID", newItemId);
		crs.updateString("ITEM_NAME", "TableCloth");
		crs.updateInt("SUP_ID", 927);
		crs.updateInt("QUAN", 14);
		Calendar timeStamp;
		timeStamp = new GregorianCalendar();
		timeStamp.set(2006, 4, 1);
		crs.updateTimestamp("DATE_VAL", new Timestamp(timeStamp.getTimeInMillis()));
		crs.insertRow();
		crs.moveToCurrentRow();

		// Syncing the new row back to the database.
		print_debug("About to add a new row...");
		crs.acceptChanges(mysqlConn);
		print_debug("Added a row...");
	}

	private boolean doesItemIdExist(int id) throws SQLException {
		Statement mysql_stmt = null;
		String query = "select ITEM_ID from MERCH_INVENTORY where ITEM_ID = " + id;
		try {
			mysql_stmt = mysqlConn.createStatement();
			mysql_stmt = mysqlConn.createStatement();

			ResultSet rs = mysql_stmt.executeQuery(query);

			if (rs.next()) {
				return true;
			}

		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (mysql_stmt != null) { mysql_stmt.close(); }
		}
		return false;

	}

	private void viewTable() throws SQLException {
		Statement mysql_stmt = null,uproxy_stmt = null;
		String query = "select * from MERCH_INVENTORY";
		
		try {
			
			mysql_stmt = mysqlConn.createStatement();
			uproxy_stmt = uproxyConn.createStatement();
			ResultSet set1 = mysql_stmt.executeQuery(query);
			ResultSet set2 = uproxy_stmt.executeQuery(query);

			compare_result(set1, set2);
		} catch (SQLException e) {
			TestUtilities.printSQLException(e);
		} finally {
			if (mysql_stmt != null) { mysql_stmt.close(); }
			if (uproxy_stmt != null) { uproxy_stmt.close(); }
		}
	}
}