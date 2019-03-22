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

int writeLoadData(string fileName);
int createDir(const char *filePath);
//sql::Connection *conn(const char *hostName, const char *userName, const char *password);
Connection* createConn(char *hostName, const char *userName, const char *password);
int manager_exec(const char *sqlFile, const char *logPath, Connection *con);
int client_exec(const char *sqlFile, const char *logPath, Connection *dbleConn, Connection *mysqlConn);
bool compareList(list<string> dbleResultSetList, list<string> mysqlResultSetList, bool allow_diff_sequence);
string convertListToString(list<string> lt);
list<string> exec_sql(Statement *stmt, string line);
bool findSubstr(string str, string substr);
Config YamlParse(string yamlPath);
int removeFile(const char *filePath);

#endif