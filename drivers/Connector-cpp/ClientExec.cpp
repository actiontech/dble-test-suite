/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <ostream>
#include <string>
#include <algorithm> //transform
#include "mysql_connection.h"
#include "mysql_driver.h"
#include "cppconn/prepared_statement.h"
#include <cppconn/exception.h>
#include <cppconn/resultset.h>
#include <cppconn/statement.h>
#include "cppconn/metadata.h"

//#include <cstdio>
//#include <stdio.h>
#include <list>
#include <vector>
#include <numeric>
#include "ext.h"
using namespace std;
using namespace sql;

typedef list<string> LISTSTRING;

int client_exec(const char *sqlfile, const char *logpath, Connection *dble_conn, Connection *mysql_conn)
{
	ifstream sqls;
	ofstream pass;
	ofstream fail;
	string filename;
	string line;
	int idNum = 1;
	Statement *dble_stmt;
	Statement *mysql_stmt;
	//ResultSetMetaData * 
	//����sql�ļ�����ȡlog�ļ���
	string sqlf = string(sqlfile);
	string sqlfilename = sqlf.substr(sqlf.rfind("/") + 1);
	sqlfilename = sqlfilename.substr(0, sqlfilename.find("."));
	string logpass = string(logpath) + "/" + sqlfilename + "_pass.log";
	string logfail = string(logpath) + "/" + sqlfilename + "_fail.log";
	cout << "logpass: " + logpass << endl;
	cout << "logfail: " + logfail << endl;


	try {
		sqls.open(sqlf, ios::in);
	}
	catch (exception e) {
		cout << "open file " + sqlf + " failed!" << endl;
		//close_fstream(&sqls);
		sqls.close();
		exit(1);
	}

	try {
		pass.open(logpass, ios::out | ios::app);
	}
	catch (exception e) {
		cout << "open file " + logpass + " failed!" << endl;
		pass.close();
		exit(1);
	}
	try {
		fail.open(logfail, ios::out | ios::app);
	}
	catch (exception e) {
		cout << "open file " + logfail + " failed!" << endl;
		fail.close();
		exit(1);
	}


	try {
		dble_stmt = dble_conn->createStatement();
	}
	catch (SQLException &e) {
		cout << e.what() << endl;
		exit(1);
	}

	try {
		mysql_stmt = mysql_conn->createStatement();
	}
	catch (SQLException &e) {
		cout << e.what() << endl;
		exit(1);
	}

	while (getline(sqls, line)) // line�в�����ÿ�еĻ��з�
	{
		if (line.find('#') != 0) {
			cout << line << endl;
			string exec = "===File:" + string(sqlfile) + ",id:" + to_string(idNum) + ",sql:" + line + "==="; 
			bool allow_diff_sequence = false;
			if (findSubstr(line,"allow_diff_sequence"))
			{
				allow_diff_sequence = true;
			}
			transform(line.begin(), line.end(), line.begin(), ::tolower);
			LISTSTRING dblerslist;
			LISTSTRING mysqlrslist;
			//dble&mysql
			dblerslist = exec_sql(dble_stmt, line);
			mysqlrslist = exec_sql(mysql_stmt, line);
			//compare rs
			bool flag = compareList(dblerslist, mysqlrslist, allow_diff_sequence);
			if (flag) {
				string passstr = convertList(dblerslist);
				pass << exec << endl;
				pass << "dble: [(" + passstr + ")]" << endl;
			}
			else {
				string dblefailstr = convertList(dblerslist);
				string mysqlfailstr = convertList(mysqlrslist);
				string failstr = "dble: [(" + dblefailstr + ")]\nmysql: [(" + mysqlfailstr + ")]";
				fail << exec << endl;
				fail << failstr << endl;
			}
		}
		idNum++;
	}
	delete mysql_stmt;
	delete dble_stmt;
	fail.close();
	pass.close();
	sqls.close();

	return 0;
}
