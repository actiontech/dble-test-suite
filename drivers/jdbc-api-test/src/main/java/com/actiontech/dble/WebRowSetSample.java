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

import com.sun.rowset.WebRowSetImpl;

import java.io.FileReader;

import java.io.FileWriter;

import java.io.IOException;

import java.sql.Connection;
import java.sql.SQLException;

import javax.sql.rowset.WebRowSet;

public class WebRowSetSample extends InterfaceTest {

	public WebRowSetSample(ConnProperties mysqlProp, ConnProperties dbleProp) throws SQLException {
		super(mysqlProp, dbleProp);
	}

	public void start()throws SQLException{
		createTable();
		populateTable();
		
		try{
			testWebRowSet();
			System.out.println("pass! WebRowSet()!");
		}catch(IOException ex){
			ex.printStackTrace();
			System.exit(-1);
		}
	}

	public void testWebRowSet() throws SQLException, IOException {
		FileReader fReader = null;
		FileWriter fWriter = null;
		String priceListFileName = "pricelist.xml";
		int [] keyCols = {1};
		WebRowSet priceList = new WebRowSetImpl();

		priceList.setUsername(dbleProp.userName);
		priceList.setPassword(dbleProp.password);
		priceList.setUrl(dbleProp.urlString + "/" + dbleProp.dbName+"?useSSL=false");
		priceList.setCommand("select COF_NAME, PRICE from COFFEES");
		priceList.setKeyColumns(keyCols);

		// Populate the WebRowSet
		priceList.execute();
		System.out.println("Size of the WebRowSet is: " + priceList.size());

		// Insert a new row
		priceList.moveToInsertRow();
		priceList.updateString("COF_NAME", "Kona");
		priceList.updateFloat("PRICE", 8.99f);
		priceList.insertRow();
		priceList.moveToCurrentRow();
		System.out.println("New row inserted");
		System.out.println("Size of the WebRowSet is: "+priceList.size());

		//Delete the row with "Espresso"
		priceList.beforeFirst();
		while(priceList.next()) {
			if(priceList.getString(1).equals( "Espresso" )) {
				System.out.println( "Deleting row with Espresso..." );
				priceList.deleteRow();
				break;
			}
		}

		// Update price of Colombian
		priceList.beforeFirst();
		while(priceList.next()) {
			if(priceList.getString(1).equals("Colombian")) {
				System.out.println("Updating row with Colombian...");
				priceList.updateFloat(2, 6.99f);
				priceList.updateRow();
				break;
			}
		}

		int size1 = priceList.size();
		fWriter = new FileWriter( priceListFileName );
		priceList.writeXml(fWriter);
		fWriter.flush();
		fWriter.close();

		// Create the receiving WebRowSet object
		WebRowSet receiver = new WebRowSetImpl();
		receiver.setUrl(dbleProp.urlString + "/" + dbleProp.dbName+"?useSSL=false");
		receiver.setUsername(dbleProp.userName);
		receiver.setPassword(dbleProp.password);

		//Now read the XML file.
		fReader = new FileReader( priceListFileName );
		receiver.readXml(fReader);
		int size2 = receiver.size();
		if (size1 == size2) {
			System.out.println( "WebRowSet serialized and " +
					"deserialiazed properly" );
		} else {
			System.out.println("Error....serializing/deserializng the WebRowSet");
		}
	}
}
