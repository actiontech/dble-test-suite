package actiontech.dble;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.InvalidPropertiesFormatException;
import java.util.Properties;

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
		}else{//uproxy
			this.serverName = Config.Host_Test;
			this.portNumber = Config.TEST_PORT;
			//this.master = Config.HOST_MASTER;
			//this.slave1 = Config.Host_Slave1;
			this.defaultPort = Config.MYSQL_PORT;
		}

		this.dbName = Config.TEST_DB;
		this.userName = Config.TEST_USER;
		this.password = Config.TEST_USER_PASSWD;

		System.out.println("======== Set the following connection properties: =======");
		System.out.println("dbName: " + dbName);
		System.out.println("userName: " + userName);
		System.out.println("serverName: " + serverName);
		System.out.println("portNumber: " + portNumber);
	}

}
