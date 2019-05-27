/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
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
	list<string> rslist;
	ResultSet *res;
	ResultSetMetaData *res_meta;
	try {
		if (findSubstr(line, "select") || findSubstr(line, "show") || findSubstr(line, "check") || findSubstr(line, "union") || findSubstr(line, "explain") || findSubstr(line, "desc") || findSubstr(line, "@b")) {
			res = stmt->executeQuery(line);
			string res_line;
			if (res->rowsCount() == 0) {
				rslist = {};
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
					rslist.push_back(res_line);
				}
			}
			delete res;
		}
		else if (findSubstr(line, "insert") || findSubstr(line, "update") || findSubstr(line, "delete")) {
			int count = stmt->executeUpdate(line);
			rslist.push_back(to_string(count));
		}
		else {
			bool success = stmt->execute(line);
			string boolstr;
			if (success) {
				boolstr = "true";
			}
			else {
				boolstr = "false";
			}
			rslist.push_back(boolstr);
		}
	}
	catch (SQLException &e) {
		string errMsg = e.what();
		string errCode = to_string(e.getErrorCode());
		string err = "[(" + errCode + ": " + errMsg + ")]";
		rslist.push_back(err);
	}
	return rslist;
}