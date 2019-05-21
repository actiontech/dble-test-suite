/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <ostream>
#include <string>
#include <boost/algorithm/string.hpp>
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

int manager_exec(const char *sqlFile, const char *logPath, Connection *con)
{
	ifstream sqls;
	ofstream pass;
	ofstream fail;
	string fileName;
	string line;
	int idNum = 1;
	Statement *stmt;
	ResultSet *res;
	ResultSetMetaData *resultSetMetaData;
	//ResultSetMetaData *
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

		pass.open(logPass, ios::out| ios::trunc);
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
		stmt = con->createStatement();
	}
	catch (SQLException &e) {
//		cout << e.what() << endl;
		exit(1);
	}

	while (getline(sqls, line)) // line�в�����ÿ�еĻ��з�
	{
//		cout << line << endl;
		if (line.find('#') != 0) {
			string exec = "===file:" + string(sqlFile) + ",id:" + to_string(idNum) + ",sql:" + line ;
			transform(line.begin(), line.end(), line.begin(), ::tolower);
			boost::trim(line);
			try {
				string rs_str;
				if (findSubstr(line, "select") || findSubstr(line, "show") || findSubstr(line, "check") || findSubstr(line, "file") || findSubstr(line, "log") || findSubstr(line, "dryrun")) {
					//if ((line.find("select")==0) || (line.find("show")==0) || (line.find("check")==0) || (line.find("file")==0) || (line.find("log")==0) || (line.find("dryrun")==0)) {
					LISTSTRING dbleResultSetList;
					res = stmt->executeQuery(line);
					string resultSetLine;
					//int rowCount = 0;
					if (res->rowsCount() == 0) {
						dbleResultSetList = {};
					}
					else {
						try {
							resultSetMetaData = res->getMetaData();
						}
						catch (SQLException &e) {
							cout << "getMetaData failed!" << endl;
							//cout << e.what() << endl;
						}
						int numcols = resultSetMetaData->getColumnCount();
						while (res->next()) {
							resultSetLine = "";
							for (int i = 1; i <= numcols; i++) {
								string col_str = res->getString(i);
								if (i != numcols) {
									resultSetLine.append(col_str + ",");
								}
								else {
									resultSetLine.append(col_str);
								}
							}
							dbleResultSetList.push_back(resultSetLine);
							//rowCount++;
						}
					}
					if (dbleResultSetList.size() == 0) {
						rs_str = " ";
					}
					else {
						rs_str = convertListToString(dbleResultSetList);
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
//				cout << "err:" + err << endl;
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