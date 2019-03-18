/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
#ifndef   __CPP_MYSQL_CONNECTOR_H__

#define   __CPP_MYSQL_CONNECTOR_H__

#include "mysql_connection.h"
#include <cppconn/driver.h>
#include <cppconn/statement.h>
#include <fstream>
#include<string>
#include<list>
#include "config.h"
using namespace std;
using namespace sql;

int WriteLoadData(string filename);
int createdir(const char *filepath);
//sql::Connection *conn(const char *hostName, const char *userName, const char *password);
Connection* createConn(char *hostName, const char *userName, const char *password);
int manager_exec(const char *sqlfile, const char *logpath, Connection *con);
int client_exec(const char *sqlfile, const char *logpath, Connection *dblecon, Connection *mysqlcon);
bool compareList(list<string> dblerslist, list<string> mysqlrslist, bool allow_diff_sequence);
string convertList(list<string> lt);
list<string> exec_sql(Statement *stmt, string line);
bool findSubstr(string str, string substr);
Config YParse(string yamlpath);
int RmFile(const char *filepath);

#endif