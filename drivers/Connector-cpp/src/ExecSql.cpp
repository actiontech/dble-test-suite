/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include <string>
#include <list>
#include <stdio.h>
#include <cstdio>

#include "mysql_connection.h"
#include "mysql_driver.h"
#include "cppconn/prepared_statement.h"
#include <cppconn/exception.h>
#include <cppconn/resultset.h>
#include <cppconn/statement.h>
#include "cppconn/metadata.h"
#include "ext.h"

using namespace std;
using namespace sql;

list<string> exec_sql(Statement *stmt, string line) {
	list<string> resultSetList;
	ResultSet *res;
	ResultSetMetaData *resultSetMetaData;
	try {
		if (findSubstr(line, "select") || findSubstr(line, "show") || findSubstr(line, "check") || findSubstr(line, "union") || findSubstr(line, "explain") || findSubstr(line, "desc") || findSubstr(line, "@b")) {
			//if ((line.find("select")==0) || (line.find("show")==0) || (line.find("check")==0) || (line.find("union")==0) || (line.find("explain")==0) || (line.find("desc")==0) || (line.find("@b")==0)) {
			res = stmt->executeQuery(line);
			string resultSetLine;
			if (res->rowsCount() == 0) {
				resultSetList = {};
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
					resultSetList.push_back(resultSetLine);
				}
			}
			delete res;
		}
		else if (findSubstr(line, "insert") || findSubstr(line, "update") || findSubstr(line, "delete")) {
			//else if ((line.find("insert")==0) || (line.find("update")==0) || (line.find("delete")==0)) {
			int count = stmt->executeUpdate(line);
			resultSetList.push_back(to_string(count));
		}
		else {
			bool success = stmt->execute(line);
			string boolString;
			if (success) {
				boolString = "true";
			}
			else {
				boolString = "false";
			}
			resultSetList.push_back(boolString);
		}
	}
	catch (SQLException &e) {
		string errMsg = e.what();
		string errCode = to_string(e.getErrorCode());
		string err = "[(" + errCode + ": " + errMsg + ")]";
		resultSetList.push_back(err);
	}
	return resultSetList;
}