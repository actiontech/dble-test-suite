/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <ostream>
#include <string>
#include <algorithm> 
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

int manager_exec(const char *sqlfile, const char *logpath, Connection *con)
{
	ifstream sqls;
	ofstream pass;
	ofstream fail;
	string filename;
	string line;
	int idNum = 1;
	Statement *stmt;
	ResultSet *res;
	ResultSetMetaData *res_meta;
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
		stmt = con->createStatement();
	}
	catch (SQLException &e) {
		cout << e.what() << endl;
		exit(1);
	}

	while (getline(sqls, line)) // line�в�����ÿ�еĻ��з�
	{
		cout << line << endl;
		if (line.find('#') != 0) {
			string exec = "===File:" + string(sqlfile) + ",id:" + to_string(idNum) + ",sql:" + line + "===";
			transform(line.begin(), line.end(), line.begin(), ::tolower);
			try {
				string rs_str;
				if (findSubstr(line, "select") || findSubstr(line, "show") || findSubstr(line, "check") || findSubstr(line, "file") || findSubstr(line, "log") ||findSubstr(line, "dryrun")) {
					LISTSTRING dblerslist;
					res = stmt->executeQuery(line);
					string res_line;
					//int rowCount = 0;
					if (res->rowsCount() == 0) {
						dblerslist = {};
					}
					else {
						try {
							res_meta = res->getMetaData();
						}
						catch (SQLException &e) {
							cout << "getMetaData failed!" << endl;
							exit(1);
						}
						int numcols = res_meta->getColumnCount();
						while (res->next()) {
							res_line = "";
							for (int i = 1; i <= numcols; i++) {
								string col_str = res->getString(i);
								if (i != numcols) {
									res_line.append(col_str + ",");
								}
								else {
									res_line.append(col_str);
								}
							}
							dblerslist.push_back(res_line);
							//rowCount++;
						}
					}
					if (dblerslist.size() == 0) {
						rs_str = " ";
					}
					else {
						rs_str = convertList(dblerslist);
					}
					delete res;
				}
				else {
					bool success = stmt->execute(line);
					if (success) {
						rs_str = "true";
					}
					else {
						rs_str = "false";
					}
				}
				pass << exec << endl;
				pass << "dble: [" + rs_str + "]" << endl;
			}
			catch (SQLException &e) {
				string errMsg = e.what();
				string errCode = to_string(e.getErrorCode());
				string err = "dble: [(" + errCode + ": " + errMsg + ")]";
				cout << "err:" + err << endl;
				fail << exec << endl;
				fail << err << endl;
			}
		}
		idNum++;
	}
	delete stmt;
	fail.close();
	pass.close();
	sqls.close();

	return 0;
}