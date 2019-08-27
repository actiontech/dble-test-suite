/* Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package actiontech.dble;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.InvalidPropertiesFormatException;

public class ConnProperties {
	public String master;
	public String slave1;
	public String dbName;
	public String userName;
	public String password;
	public String urlString;

	public String serverName;
	public int portNumber;
	public int defaultPort;

	public ConnProperties(String type)throws FileNotFoundException,
	IOException,
	InvalidPropertiesFormatException  {
		if(Main.isDebug){
			Config.initDebug();
		}else{
			Config.getInstance().init("sys.config");
		}
		if(type.equals("mysql")){//mysql
			this.serverName = Config.Host_Single_MySQL;
			this.portNumber = Config.MYSQL_PORT;
			this.userName = Config.MYSQL_USER;
			this.password = Config.MYSQL_PASSWD;
		}else{//dble
			this.serverName = Config.Host_Test;
			this.portNumber = Config.TEST_PORT;
			//this.master = Config.HOST_MASTER;
			//this.slave1 = Config.Host_Slave1;
			this.defaultPort = Config.MYSQL_PORT;
			this.userName = Config.TEST_USER;
			this.password = Config.TEST_USER_PASSWD;
		}

		this.dbName = Config.TEST_DB;
		

		System.out.println("======== Set the following connection properties: =======");
		System.out.println("dbName: " + dbName);
		System.out.println("userName: " + userName);
		System.out.println("serverName: " + serverName);
		System.out.println("portNumber: " + portNumber);
	}

}
