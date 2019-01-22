package com.demo.jdbc;

//import java.awt.List;
import java.util.*;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Comparator;

public class ExecSQLAndCompare {
	static Map<String, JDBCConn> share_conns_test = new HashMap<String, JDBCConn>();
	static Map<String, JDBCConn> share_conns_mysql = new HashMap<String, JDBCConn>();

	String PASS_PRE = "pass";
	String FAIL_PRE = "fail";
	String WARN_PRE = "warn";
	String SERIOUS_PRE = "serious_warn";

	String pass_log;
	String fail_log;
	String warn_log;
	String serious_warn_log;

	private String _sqlFile;

	private JDBCConn _cur_conn_mysql;
	private JDBCConn _cur_conn_test;

	private int requery_count=0;

	public ExecSQLAndCompare(String sqlFile) {
		_sqlFile = sqlFile;
		// TODO Auto-generated constructor stub
//		initData();

	}

	private void initData() {
		String logfile = _sqlFile.replace("/", "_");
		String[] partions = logfile.split("\\.");
		String path = "result/";
		pass_log = path + partions[0] + "_" + PASS_PRE + ".log";
		fail_log = path + partions[0] + "_" + FAIL_PRE + ".log";
		warn_log = path + partions[0] + "_" + WARN_PRE + ".log";
		serious_warn_log = path + partions[0] + "_" + SERIOUS_PRE + ".log";
	}

	public void analyzeSql() {
		String sql = "";
		int line_nu = 0;
		Boolean is_multiline = false;
		Boolean toClose = true;

		String full_path = Config.getSqlPath() + _sqlFile;
		System.out.println("start to compare sql executed result in file [" + full_path + "]");
		File file = new File(full_path);
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new FileReader(file));
			String nextLine = reader.readLine().trim();
			String line = nextLine.trim();
			boolean is_share_conn = false, is_next_line_exist = (nextLine != null);
			String test_conn_name=null, mysql_conn_name=null;
			int step_len = 1;
			while (is_next_line_exist) {
				line = nextLine;
				nextLine = reader.readLine();
				is_next_line_exist = (nextLine != null);
				if (is_next_line_exist) nextLine = nextLine.trim();
				line_nu += step_len;
				step_len = 1;
				while(is_next_line_exist && nextLine.length()==0){
					nextLine = reader.readLine();
					is_next_line_exist = (nextLine != null);
					if (is_next_line_exist) nextLine = nextLine.trim();
					step_len += 1;
				}
				System.out.println("********"+_sqlFile+", line "+line_nu+", "+line+"*********");

				if (line.startsWith("#")) {
					is_share_conn = false;
					if (line.startsWith("#!share_conn")) {
						Pattern p = Pattern.compile("share_conn_?\\d*");
						Matcher m = p.matcher(line);
						m.find();
						test_conn_name = m.group(0);
						mysql_conn_name = test_conn_name + "_mysql";
						if (!share_conns_test.containsKey(test_conn_name)) {
							JDBCConn conn_test = new JDBCConn(Config.Host_Test, Config.TEST_USER,
									Config.TEST_USER_PASSWD, Config.TEST_DB, Config.TEST_PORT);
							JDBCConn conn_mysql = new JDBCConn(Config.Host_Single_MySQL, Config.TEST_USER,
									Config.TEST_USER_PASSWD, Config.TEST_DB, Config.MYSQL_PORT);

							share_conns_test.put(test_conn_name, conn_test);
							share_conns_mysql.put(mysql_conn_name, conn_mysql);
						}
						is_share_conn = true;
					}
//					else if (line.startsWith("#!restart-mysql")) {
//						String[] partitions = line.split("::", 2);
//						String str = partitions[1].trim();
//						String options = str.substring(1, str.length() - 1);
//						restartMysql(options);
//						updateConns();
//						reconnectUproxy();
//					} else if (line.startsWith("#!restart-uproxy")) {
//						String[] partitions = line.split("::", 2);
//						String str = partitions[1].trim();
//						String options = str.substring(1, str.length() - 1);
//						restartUproxy(options);
//					}

					if (line.contains("#!multiline")) {
						is_multiline = true;
					}
					continue;
				}

				if (is_multiline) {
					sql = sql + line + "\n";
				}else{
					sql = line;
				}

				Boolean is_next_line_milestone = !is_next_line_exist || nextLine.startsWith("#");
//			 not multiline and sqls is not null
				if ((!is_multiline || is_next_line_milestone) && sql.length()>0) {
					if(is_share_conn){
						_cur_conn_mysql = share_conns_mysql.get(mysql_conn_name);
						_cur_conn_test = share_conns_test.get(test_conn_name);
						toClose = is_next_line_milestone && test_conn_name.equals("share_conn");
					}else{
						_cur_conn_test = new JDBCConn(Config.Host_Test, Config.TEST_USER,
								Config.TEST_USER_PASSWD, Config.TEST_DB, Config.TEST_PORT);
						_cur_conn_mysql = new JDBCConn(Config.Host_Single_MySQL, Config.TEST_USER,
								Config.TEST_USER_PASSWD, Config.TEST_DB, Config.MYSQL_PORT);
						toClose = true;
					}
					System.out.println("debug:do query, is_share_conn:"+is_share_conn+",toClose:"+toClose);
					do_query(line_nu, sql, toClose);
					if (is_share_conn && toClose){
						share_conns_mysql.remove(mysql_conn_name);
						share_conns_test.remove(test_conn_name);
						System.out.println("debug:remove share_conn!");
					}
					sql = "";
					is_multiline = false;
				}
			}
			reader.close();
			System.out.println("sqls in file [" + full_path + "] executed over!");
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
		destroy_share_n_conn();
	}

	private void destroy_share_n_conn() {
		share_conns_test.forEach((k, v) -> v.close());
		share_conns_mysql.forEach((k, v) -> v.close());
		share_conns_mysql.clear();
		share_conns_test.clear();
	}

	private void restartMysql(String options) {
		String stop_cmd = Config.MYSQL_INSTALL_PATH + "/support-files/mysql.server stop";
		String start_cmd = Config.MYSQL_INSTALL_PATH + "/support-files/mysql.server start " + options;

		for (int i = 0; i < Config.mysql_hosts.length; ++i) {
			SSHCommandExecutor sshExecutor = new SSHCommandExecutor(Config.mysql_hosts[i], Config.SSH_USER,
					Config.SSH_PASSWORD);
			sshExecutor.execute(stop_cmd);

			Vector<String> stdout = sshExecutor.getStandardOutput();
			for (String str : stdout) {
				System.out.println(str);
			}
		}
		for (int i = 0; i < Config.mysql_hosts.length; ++i) {
			SSHCommandExecutor sshExecutor = new SSHCommandExecutor(Config.mysql_hosts[i], Config.SSH_USER,
					Config.SSH_PASSWORD);
			sshExecutor.execute(start_cmd);

			Vector<String> stdout = sshExecutor.getStandardOutput();
			for (String str : stdout) {
				System.out.println(str);
			}
		}
	}

//	private void updateConns() {
//		String precmd = Config.getUproxyAdminCmd();
//
//		String cmd1 = precmd + "uproxy update_conns '" + Config.TEST_USER + "' masters '" + Config.Host_Master + ":"
//				+ Config.MYSQL_PORT + "'\"";
//		String cmd2 = precmd + "uproxy update_conns '" + Config.TEST_USER + "' slaves '" + Config.Host_Slave1 + ":"
//				+ Config.MYSQL_PORT + "'\"";
//		String cmd3 = precmd + "uproxy update_conns '" + Config.TEST_USER + "' slaves '" + Config.Host_Slave2 + ":"
//				+ Config.MYSQL_PORT + "'\"";
//
//		SSHCommandExecutor sshExecutor = new SSHCommandExecutor(Config.Host_Test, Config.SSH_USER,
//				Config.SSH_PASSWORD);
//
//		sshExecutor.execute(cmd1);
//		sshExecutor.execute(cmd2);
//		sshExecutor.execute(cmd3);
//	}

	private void reconnectUproxy() {
		JDBCConn conn_uproxy = null;
		int max_try = 5, interval = 30;
		Boolean success = false;
		while (max_try > 0) {
			Config.sleep(interval);
			try {
				conn_uproxy = new JDBCConn(Config.Host_Test, Config.TEST_USER, Config.TEST_USER_PASSWD, "",
						Config.TEST_PORT);
				success = true;
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				if (success) {
					break;
				} else {
					max_try--;
				}
				if (conn_uproxy != null) {
					conn_uproxy.close();
					conn_uproxy = null;
				}
			}
		}

		if (!success)
			System.out.println("can not connect to uproxy after " + max_try * interval + " seconds wait");
	}

	private void restartUproxy(String options) {
		System.out.println("restart uproxy with options:" + options);
		String[] ary = options.split(",", 3);
		Map<String, String> opt_dic = new HashMap<String, String>();
		for (int i = 0; i < ary.length; ++i) {
			String items = ary[i].trim();
			String[] subStr = items.split(":", 2);
			String key = subStr[0];
			opt_dic.put(key.substring(1, key.length() - 1), subStr[1]);
		}

		String full_path = Config.TEST_INSTALL_PATH + "/uproxy.json";
		SSHCommandExecutor sshExecutor = new SSHCommandExecutor(Config.Host_Test, Config.SSH_USER,
				Config.SSH_PASSWORD);
		for (Map.Entry<String, String> entry : opt_dic.entrySet()) {
			String key = entry.getKey();
			String cmd = "sed -i '/\"" + key + "\"/c  \"" + key + "\": " + entry.getValue() + ",' " + full_path;
			sshExecutor.execute(cmd);

			Vector<String> stdout = sshExecutor.getStandardOutput();
			for (String str : stdout) {
				System.out.println(str);
			}
		}
	}

	private void do_query(int line_nu, String sql, Boolean toClose) {
//		sql = sql.replaceFirst("(/*\\s*uproxy_dest\\s*:\\s*)+slave1",
//				"$1 " + Config.Host_Slave1 + ":" + Config.MYSQL_PORT);

		System.out.println(sql);
		Boolean reset_autocommit = false;
		if (sql.endsWith("#!autocommit=False")) {
			reset_autocommit = true;
			sql = sql.replace("#!autocommit=False", "").trim();
			try {
				_cur_conn_mysql.connection.setAutoCommit(false);
				_cur_conn_test.connection.setAutoCommit(false);
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		//whether sql is read query
		Boolean isR = _cur_conn_mysql.execute(sql);
		_cur_conn_test.execute(sql);

		Object result_mysql = null, result_test = null;
		if (null != isR) {
			try {
				if (isR) {
					result_mysql = _cur_conn_mysql.stmt.getResultSet();
					result_test = _cur_conn_test.stmt.getResultSet();
				} else {
					result_mysql = _cur_conn_mysql.stmt.getUpdateCount();
					result_test = _cur_conn_test.stmt.getUpdateCount();
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}

		String err_mysql = _cur_conn_mysql.errMsg;
		String err_test = _cur_conn_test.errMsg;

		compare_result(line_nu, sql, result_test, result_mysql, err_mysql, err_test);

		if (reset_autocommit) {
			try {
				_cur_conn_mysql.connection.setAutoCommit(true);
				_cur_conn_test.connection.setAutoCommit(true);
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}

		if (toClose) {
			_cur_conn_mysql.close();
			_cur_conn_test.close();
			_cur_conn_mysql = null;
			_cur_conn_test = null;
		}
	}

	public boolean equal(Object set1, Object set2) {
		// System.out.println("uproxy ResultSet:" + (set1 instanceof
		// ResultSet));
		// System.out.println("mysql ResultSet:" + (set2 instanceof ResultSet));
		if (set1 instanceof ResultSet) {
			return equal((ResultSet) set1, (ResultSet) set2);
		}
		System.out.println("test result:" + set1 + ", mysql result:" + set2);
		boolean b = set1 == set2;
		if (!b) {
			System.out.println("update rows count is not equal:[" + set1 + "," + set2 + "]");
		}
		return b;
	}

	private boolean equal(ResultSet set1, ResultSet set2) {
		try {
			ResultSetMetaData metaData1 = set1.getMetaData();
			ResultSetMetaData metaData2 = set2.getMetaData();
			int columnCount1 = metaData1.getColumnCount() + 1;
			int columnCount2 = metaData2.getColumnCount() + 1;
			if (columnCount1 != columnCount2) {
				System.out.println("column count is not equal[" + columnCount1 + "," + columnCount2 + "]");
				return false;
			}

			boolean line2 = set2.next();
			boolean line1 = set1.next();
			boolean tobreak = false;
			List list_test = new ArrayList();
			List list_mysql = new ArrayList();

			while (line1 && line2) {
				Map rowData1 = new HashMap();
				Map rowData2 = new HashMap();
				for (int i = 1; i < columnCount1; i++) {
					String value1 = null, value2 = null;
					try {
						value1 = set1.getString(i);
					} catch (SQLException e) {
						value1 = e.getMessage();
					}
					try {
						value2 = set2.getString(i);
					} catch (SQLException e) {
						value2 = e.getMessage();
					}
					rowData1.put(metaData1.getColumnName(i), set1.getObject(i));
					rowData2.put(metaData2.getColumnName(i), set2.getObject(i));
				}
				 for (Object key_test : rowData1.keySet()){
					 Object test = null;
					 Object mysql = null;
						 test =  rowData1.get(key_test);
						 mysql =  rowData1.get(key_test);

						if (test == null && mysql == null) {
							continue;
						}
						if (test == null || mysql == null) {
							System.out.println("value is not null,[" + test + "," + mysql + "]");
							tobreak = true;
							break;
						}
						if (!test.equals(mysql)) {
							System.out.println("value is not null,[" + test + "," + mysql + "]");
							tobreak = true;
							break;
						}
				 }
//				list_test.add(rowData1);
//				list_mysql.add(rowData2);

//				List list_test_sorted = new ArrayList();
//				List list_mysql_sorted = new ArrayList();
//
//				Collections.sort(list_test_sorted);
//				Collections.sort(list_mysql_sorted);
//
//				for ( int i = 1; i < list_test.size(); i++){
//					String value1 = null,value2 = null;
//					value1 = (String) list_test.get(i);
//					value2 = (String) list_mysql.get(i);
//					if (!value1.equals(value2)) {
//						System.out.println("value is not null,[" + value1 + "," + value2 + "]");
//						tobreak = true;
//						break;
//					}
//					if (value1 == null && value2 == null) {
//						continue;
//					}
//					if (value1 == null || value2 == null) {
//						System.out.println("value is not null,[" + value1 + "," + value2 + "]");
//						tobreak = true;
//						break;
//					}

//				}
				line1 = set1.next();
				line2 = set2.next();
			}


			if(tobreak) return false;

			if (line1 != line2) {
				System.out.println("rows count is not equal");
				return false;
			}
		} catch (SQLException e) {
			Config.printErr(e);
			// e.printStackTrace();
			return false;
		}
		return true;
	}


	private void compare_result(int id, String sql, Object result_test, Object result_mysql, String mysql_err,
			String test_err) {
		Pattern p = Pattern.compile("/\\*\\s*allow_diff\\s*\\*/");
		Matcher m = p.matcher(sql);
		boolean isAllowDiff = m.find();
		boolean isResEqual = equal(result_test, result_mysql);
		boolean isNoErr = mysql_err == null && test_err == null;
		Boolean isResultSame = isResEqual || (isAllowDiff && isNoErr);

		if (isResultSame) {
			requery_count = 0;
			System.out.println("isResultSame is true, but err may be different!");
			if (isNoErr) {
				MyWriter writer = new MyWriter(pass_log);
				writer.write("===id:" + id + ", sql:[" + sql + "]===\n");
				printResultSet(result_test, writer);
				writer.close();
				System.out.println("mysql_err == null && test_err == null");
			} else {
				Boolean isMysqlSynErr = null != mysql_err && mysql_err.contains("You have an error in your SQL syntax");
				Boolean isTestSynErr = null != test_err
						&& test_err.contains("You have an error in your SQL syntax");
				MyWriter writer = null;
				if (mysql_err.equals(test_err) || (isMysqlSynErr && isTestSynErr)) {
					writer = new MyWriter(warn_log);
				} else {
					writer = new MyWriter(serious_warn_log);
				}
				writer.write("===id:" + id + ", sql:[" + sql + "]===\n");
				writer.write("mysql err:" + mysql_err + "\n");
				writer.write("test err:" + test_err + "\n");
				writer.close();
				System.out.println("mysql_err != null || test_err != null");
				System.out.println("mysql_err: " + mysql_err);
				System.out.println("test_err: " + test_err);
			}
		} else {
//			if(sql.contains("uproxy_dest_expect:S") && requery_count <3 ){
//				requery_count = requery_count +1;
//				String syn_sql="show master status";
//				_cur_conn_test.execute(syn_sql);
//
//				String binlog=null;
//				int	bin_pos=0;
//				try{
//					ResultSet res_syn = _cur_conn_test.stmt.getResultSet();
//
//					res_syn.next();
//					binlog = res_syn.getString(1);
//					bin_pos=res_syn.getInt(2);
//				} catch (SQLException e) {
//					e.printStackTrace();
//				}
//				System.out.println("binlog file:"+binlog+", bin_pos:"+bin_pos);
//			}else{
				requery_count = 0;
				MyWriter writer = new MyWriter(fail_log);
				writer.write("===id:" + id + ", sql:[" + sql + "]===\n");
				writer.write("test result:");
				printResultSet(result_test, writer);

				writer.write("mysql result:");
				printResultSet(result_mysql, writer);

				if (mysql_err != null)
					writer.write("mysql err:" + mysql_err + "\n");
				if (test_err != null)
					writer.write("test err:" + test_err + "\n");
				writer.close();

				System.out.println("isResultSame false");
//			}
		}
	}

	private void printResultSet(Object result, MyWriter writer) {
		if (result instanceof ResultSet) {
			ResultSet set = (ResultSet) result;
			try {
				//moves cursor back for print result in log file
				set.beforeFirst();
				ResultSetMetaData metaData1 = set.getMetaData();

				int columnCount = metaData1.getColumnCount() + 1;
				while (set.next()) {
					String row = "";
					for (int i = 1; i < columnCount; i++) {
						String col = null;
						try {
							col = set.getString(i);
						} catch (SQLException e) {
							col = "err." + e.getMessage();
						}
						row += col;
					}
					writer.write(row);
				}
			} catch (SQLException e) {
				Config.printErr(e);
			}
		} else {
			String re = null == result ? "null" : result.toString();
			writer.write(re);
		}
		writer.write("\n");
	}
}
