/*
 * Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <ostream>
#include <string>
#include <boost/algorithm/string.hpp>
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

int client_exec(const char *sqlFile, const char *logPath, Connection *dbleConn, Connection *mysqlConn)
{
	ifstream sqls;
	ofstream pass;
	ofstream fail;
	string fileName;
	string line;
	int idNum = 1;
	Statement *dbleStmt;
	Statement *mysqlStmt;
	//ResultSetMetaData * 
	//����sql�ļ�����ȡlog�ļ���
	string sqlf = string(sqlFile);
	string sqlFileName = sqlf.substr(sqlf.rfind("/") + 1);
	sqlFileName = sqlFileName.substr(0, sqlFileName.find("."));
	string logPass = string(logPath) + "/" + sqlFileName + "_pass.log";
	string logFail = string(logPath) + "/" + sqlFileName + "_fail.log";
	cout << "logPass: " + logPass << endl;
	cout << "logFail: " + logFail << endl;


	try {
		sqls.open(sqlf, ios::in);
	}
	catch (exception e) {
		cout << "open file " + sqlf + " failed!" << endl;
		sqls.close();
		exit(1);
	}

	try {
		pass.open(logPass, ios::out | ios::trunc);
	}
	catch (exception e) {
		cout << "open file " + logPass + " failed!" << endl;
		pass.close();
		exit(1);
	}
	try {
		fail.open(logFail, ios::out | ios::trunc);
	}
	catch (exception e) {
		cout << "open file " + logFail + " failed!" << endl;
		fail.close();
		exit(1);
	}


	try {
		dbleStmt = dbleConn->createStatement();
	}
	catch (SQLException &e) {
		cout << e.what() << endl;
		exit(1);
	}

	try {
		mysqlStmt = mysqlConn->createStatement();
	}
	catch (SQLException &e) {
		cout << e.what() << endl;
		exit(1);
	}

	while (getline(sqls, line))
	{
		if (line.find('#') != 0) {
//			cout << line << endl;
			string exec = "===file:" + string(sqlFile) + ",id:" + to_string(idNum) + ",sql:" + line ;
			bool allow_diff = false;
			if (findSubstr(line,"allow_diff"))
			{
				allow_diff = true;
			}
			transform(line.begin(), line.end(), line.begin(), ::tolower);
			boost::trim(line);
			LISTSTRING dbleResultSetList;
			LISTSTRING mysqlResultSetList;
			//dble&mysql
			dbleResultSetList = exec_sql(dbleStmt, line);
			mysqlResultSetList = exec_sql(mysqlStmt, line);
			//compare rs
			bool sameResultSet = compareList(dbleResultSetList, mysqlResultSetList, allow_diff);
			if (sameResultSet) {
				string passString = convertListToString(dbleResultSetList);
				pass << exec << endl;
				pass << "dble: [(" + passString + ")]" << endl;
			}
			else {
				string dbleFailString = convertListToString(dbleResultSetList);
				string mysqlFailString = convertListToString(mysqlResultSetList);
				string failString = "dble: [(" + dbleFailString + ")]\nmysql: [(" + mysqlFailString + ")]";
				fail << exec << endl;
				fail << failString << endl;
			}
		}
		idNum++;
	}
	delete mysqlStmt;
	delete dbleStmt;
	fail.close();
	pass.close();
	sqls.close();

	return 0;
}
