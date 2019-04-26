package com.demo.jdbc;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public class Setup {

	public static String TEST_LOG = null;

	private static Setup instance = null;

	private Setup() {

		// TODO Auto-generated constructor stub
	}

	public static Setup getInstance() {
		if (instance == null)
			instance = new Setup();
		return instance;
	}

	public ArrayList<String> getSqlFiles(String fileName) {
		System.out.println(fileName);
		ArrayList<String> sqlFiles = new ArrayList<>();
		File file = new File(fileName);
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new FileReader(file));
			String tempString = null;
			boolean sqlFileBegin = false;
			while ((tempString = reader.readLine()) != null) {
				tempString = tempString.trim();
				if (tempString.startsWith("Examples:Types")) {
					reader.readLine();// skip instruction line
					sqlFileBegin = true;
					continue;
				}

				if (sqlFileBegin) {
					if (tempString.startsWith("#"))
						continue;
					if (tempString.length() > 0) {
						String sqlFile = tempString.replace("|", "").trim();
						sqlFiles.add(sqlFile);
						System.out.println("sql file added: " + sqlFile);
					} else {
						break;
					}
				}
			}
			reader.close();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (reader != null) {
				try {
					reader.close();
				} catch (IOException e1) {
				}
			}
		}

		return sqlFiles;
	}

	public void createTestDB() {
//		doCreateTestDB(Config.Host_Test, Config.TEST_USER, Config.TEST_USER_PASSWD, "", Config.TEST_PORT);
		doCreateTestDB(Config.Host_Single_MySQL, Config.TEST_USER, Config.TEST_USER_PASSWD, "", Config.MYSQL_PORT);
	}

	private void doCreateTestDB(String host, String user, String password, String db, int port) {
		JDBCConn conn = new JDBCConn(host, user, password, db, port);
		conn.execute("drop database if exists " + Config.TEST_DB);
		conn.execute("create database " + Config.TEST_DB);
		conn.close();
	}

	public void clearDirtyFiles() {
		String cmd = "rm -rf /tmp/outfile*.txt /tmp/dumpfile.txt";
		for (int i = 0; i < Config.mysql_hosts.length; ++i) {
			SSHCommandExecutor sshExecutor = new SSHCommandExecutor(Config.mysql_hosts[i], Config.SSH_USER,
					Config.SSH_PASSWORD);
			sshExecutor.execute(cmd);
		}
	}

	public void prepare() {
//		clearDirtyFiles();
		resetLog();

//		restart();
//		addGroupAndMysqld();
	}

	public void reset() {
		restart();
//		addGroupAndMysqld();
	}

	private void resetLog() {
		File file = new File("result");
		Config.deleteDir(file);
		file.mkdir();
	}

	private void restart() {
		// stop dble
		String cmd = "sh " + Config.TEST_INSTALL_PATH + Config.TEST_SETVER_NAME + "/bin/" + Config.TEST_SETVER_NAME + " stop";
		SSHCommandExecutor sshExecutor = new SSHCommandExecutor(Config.Host_Test, Config.SSH_USER,
				Config.SSH_PASSWORD);
		sshExecutor.execute(cmd);
		Config.sleep(10);

		// start dble
		TEST_LOG = Config.getTestLogName();

//		String start_cmd = "cd " + Config.TEST_INSTALL_PATH + " && mkdir -p logs && (./uproxy >> logs/" + UPROXY_LOG
//				+ " 2>&1 &)";
		String start_cmd = "sh " + Config.TEST_INSTALL_PATH + Config.TEST_SETVER_NAME + "/bin/" + Config.TEST_SETVER_NAME + " start";
		sshExecutor.execute(start_cmd);

		Config.sleep(10);
	}

//	private void addGroupAndMysqld() {
//		String precmd = Config.getUproxyAdminCmd();
//		String cmd1 = precmd + "uproxy add_group '" + Config.TEST_USER + "' '" + Config.TEST_USER_PASSWD + "'\"";
//		String cmd2 = precmd + "uproxy add_mysqlds '" + Config.TEST_USER + "' masters '" + Config.HOST_MASTER + ":"
//				+ Config.MYSQL_PORT + "'\"";
//		String cmd3 = precmd + "uproxy add_mysqlds '" + Config.TEST_USER + "' slaves '" + Config.Host_Slave1 + ":"
//				+ Config.MYSQL_PORT + "' '" + Config.Host_Slave2 + ":" + Config.MYSQL_PORT + "'\"";
//		SSHCommandExecutor sshExecutor = new SSHCommandExecutor(Config.Host_Test, Config.SSH_USER,
//				Config.SSH_PASSWORD);
//
//		sshExecutor.execute(cmd1);
//		sshExecutor.execute(cmd2);
//		sshExecutor.execute(cmd3);
//	}
}
