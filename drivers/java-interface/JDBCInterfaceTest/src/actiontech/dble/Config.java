/* Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package actiontech.dble;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Vector;

import org.ini4j.Ini;

public class Config {

	public static String Host_Single_MySQL;
	public static String Host_Test;
	public static String Test_node1;
	public static String Test_node2;
	public static String Test_node3;
	public static String[] mysql_hosts = new String[4];
	public static String TEST_ADMIN;
	public static String TEST_ADMIN_PASSWD;

	public static String TEST_USER;
	public static String MYSQL_USER;
	public static String TEST_USER_PASSWD;
	public static String MYSQL_PASSWD;
	public static String TEST_DB = "schema1";
	public static int TEST_PORT;
	public static int TEST_ADMIN_PORT;
	public static int MYSQL_PORT = 3306;
	public static String TEST_SETVER_NAME;

	public static String SSH_USER;
	public static String SSH_PASSWORD;

	public static String MYSQL_INSTALL_PATH;
	public static String TEST_INSTALL_PATH;
	public static String ROOT_PATH;
	public static String SQLS_CONFIG;

	private static Config _instance;

	public static String GENERAL_LOG = "/var/lib/mysql/mysql-slave1.log";


	public Config() {
		//todo limit create new object
	}

	public static Config getInstance(){
		if(null == _instance){
			_instance = new Config();
		}
		return _instance;
	}

	public void init(String fileName){
		try {
			Ini ini = new Ini(new File(fileName));

			Host_Single_MySQL = ini.get("mysql","ip");

			String sys = ini.get("env", "sys");
		    if (sys.equals("centos7"))
		    	Host_Test = ini.get("dble", "ip");
		    else
		    	Host_Test = ini.get("centos6", "ip");
		    System.out.println("system:"+sys+" test host:"+Host_Test);

//			Test_node1 = ini.get("dnode1","ip");
//			String slave1 = ini.get("group1","slave1");
//			String slave2 = ini.get("group1","slave2");
//
//			Host_Slave1 = slave1.split(":")[0];
//			Host_Slave2 = slave2.split(":")[0];
//
			mysql_hosts[0]=Host_Single_MySQL;
//			mysql_hosts[1]=HOST_MASTER;
//			mysql_hosts[2]=Host_Slave1;
//			mysql_hosts[3]=Host_Slave2;

			TEST_USER = ini.get("dble","user");
			MYSQL_USER = ini.get("mysql", "user");
			TEST_USER_PASSWD = ini.get("dble","passwd");
			MYSQL_PASSWD = ini.get("mysql", "passwd");
			TEST_PORT = Integer.parseInt(ini.get("dble","port"));
			TEST_SETVER_NAME = ini.get("install", "server_name");

			TEST_ADMIN = ini.get("dble", "manager_user");
			TEST_ADMIN_PASSWD = ini.get("dble", "manager_passwd");
			TEST_ADMIN_PORT = Integer.parseInt(ini.get("dble","manager_port"));


			SSH_USER = ini.get("ssh","user");
			SSH_PASSWORD = ini.get("ssh","passwd");

			MYSQL_INSTALL_PATH = ini.get("install","mysql_dir");
			TEST_INSTALL_PATH = ini.get("dble","install_path");
			ROOT_PATH = ini.get("env","root_path");
			SQLS_CONFIG = ROOT_PATH + "features/sql_cover/sql.feature";

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static void initDebug(){
		Config.Host_Single_MySQL = "10.186.60.31";
		Config.Host_Test = Config.Host_Single_MySQL;
//		Config.HOST_MASTER = Config.Host_Single_MySQL;
//		Config.Host_Slave1 = Config.Host_Single_MySQL;
//		Config.Host_Slave2 = Config.Host_Single_MySQL;
		Config.MYSQL_PORT = 7144;
		Config.MYSQL_USER = "test";
		Config.MYSQL_PASSWD = "111111";
		
//		for dble
		Config.Host_Test = "10.186.60.31";
		Config.TEST_PORT = 7131;
		Config.TEST_USER = "test";
		Config.TEST_USER_PASSWD = "111111";
		TEST_DB = "schema1";
	}

	public static String getdbleAdminCmd(String dble_cmd) {
		String cmd = "mysql -u" + Config.TEST_ADMIN + " -p"
				+ Config.TEST_ADMIN_PASSWD + " -h127.0.0.1 -P" + Config.TEST_PORT + " -e \""+dble_cmd + "\"";

		return cmd;
	}

	public static void sleep(int interval) {
		try {
			System.out.print("thread sleep " + interval + " seconds! \n");
			Thread.sleep(1000 * interval);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	public static String getdbleLogName() {
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd_H:m:s", Locale.CHINA);
		String log_name = format.format(new Date());
		return log_name;
	}

	public static String getSqlPath() {
		return ROOT_PATH + "sqls/";
	}

	public static boolean deleteDir(File dir) {
		if (dir.isDirectory()) {
			String[] children = dir.list();
			for (int i = 0; i < children.length; i++) {
				boolean success = deleteDir(new File(dir, children[i]));
				if (!success) {
					return false;
				}
			}
		}
		return dir.delete();
	}

	/**
	 * define this method to replace e.printStackTrace(), because
	 * e.printStackTrace() contents can not be save to log file
	 *
	 * @param
	 */
	public static void printErr(Exception e) {
		System.out.println("================= program err =================");
		StackTraceElement[] traces = e.getStackTrace();
		for (StackTraceElement elem : traces) {
			System.out.println("\t" + elem);
		}
	}
}