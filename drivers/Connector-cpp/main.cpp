#include <cstdio>
#include "stdlib.h"
#include<iostream>
#include "ext.h"
#include <unistd.h>  
#include <stdio.h>
#include <string>
#include <string.h>
#include "mysql_connection.h"
#include "mysql_driver.h"
//#include <cppconn/driver.h>
//#include <cppconn/exception.h>
using namespace std;
using namespace sql;
#ifndef MAX_PATH  
#define MAX_PATH 1024  
#endif

int main(int argc, char *argv[])
{
	Connection *dbleManagerConn;
	Connection *dbleConn;
	Connection *mysqlConn;
	char *managerHostName;
	const char *managerUserName;
	const char *managerPassword;
	char *clientHostName;
	const char *clientUserName;
	const char *clientPassword;
	char *mysqlHostName;
	const char *mysqlUserName;
	const char *mysqlPassword;
	const char *clientSqlFile;
	const char *managerSqlFile;
	string sqlFileNameC;
	string sqlFileNameM;
	const char *sqlFile;
	//get current path
	char buffer[MAX_PATH];
	const char *currentPath = getcwd(buffer, MAX_PATH);
	//get current timestampt
//	unsigned long stime = time(0);
	string filename ="sql_logs";
	string path = string(currentPath) + '/' + filename;
	const char *logPath = path.c_str();
	createDir(logPath);
	Config cfg;
	cfg = YamlParse(string(argv[2]));
	//string(argv[3]) = "driver_test_manager.sql";
	if (string(argv[1]) == "test") {
		string managerDbleHost = "tcp://10.186.60.61:7171";
		managerHostName = new char[50];
		strcpy(managerHostName, managerDbleHost.c_str());
		managerUserName = "root";
		managerPassword = "111111";
		string clientDbleHost = "tcp://10.186.60.61:7131";
		clientHostName = new char[50];
		strcpy(clientHostName, clientDbleHost.c_str());
		clientUserName = "test";
		clientPassword = "111111";
		string mysqlHost = "tcp://10.186.60.61:7144";
		mysqlHostName = new char[50];
		strcpy(mysqlHostName, mysqlHost.c_str());
		mysqlUserName = "test";
		mysqlPassword = "111111";

		sqlFileNameM = string(currentPath) + "/assets/sql/driver_test_manager.sql";
		//sqlFileName = string(currentPath) + "/assets/sql/driver_test_client.sql";
		managerSqlFile = sqlFileNameM.c_str();
		//cout << string(sqlFile) << endl;
	}
	else {
		string managerDbleHost = "tcp://" + cfg.managerHostName + ":" + cfg.managerHostPort;
		managerHostName = new char[50];
		strcpy(managerHostName, managerDbleHost.c_str());
		managerUserName = cfg.managerUserName.c_str();
		managerPassword = cfg.managerPassword.c_str();
		string clientDbleHost = "tcp://" + cfg.clientHostName + ":" + cfg.clientHostPort;
		clientHostName = new char[50];
		strcpy(clientHostName, clientDbleHost.c_str());
		//clientHostName = clientDbleHost.c_str();
		clientUserName = cfg.clientUserName.c_str();
		clientPassword = cfg.clientPassword.c_str();
		string mysqlHost = "tcp://" + cfg.mysqlHostName + ":" + cfg.mysqlHostPort;
		mysqlHostName = new char[50];
		strcpy(mysqlHostName, mysqlHost.c_str());
		//mysqlHostName = mysqlHost.c_str();
		mysqlUserName = cfg.mysqlUserName.c_str();
		mysqlPassword = cfg.mysqlPassword.c_str();
		sqlFileNameC = string(currentPath)+ "/" + cfg.sqlPath + "/" + argv[3];
		sqlFileNameM = string(currentPath)+ "/" + cfg.sqlPath + "/" + argv[4];
		clientSqlFile = sqlFileNameC.c_str();
		managerSqlFile = sqlFileNameM.c_str();
//		cout << string(sqlFile) << endl;
		//cout << string(managerHostName) << endl;
		//cout << string(managerUserName) << endl;
		//cout << string(managerPassword) << endl;
	}
	string loadPath = string(currentPath) + "/test1.txt";
	const char *loadDataFile = loadPath.c_str();
	writeLoadData("test1.txt");
	cout << string(clientHostName) << endl;
//	cout << string(clientUserName) << endl;
//	cout << string(clientPassword) << endl;
	dbleConn = createConn(clientHostName, clientUserName, clientPassword);
	mysqlConn = createConn(mysqlHostName, mysqlUserName, mysqlPassword);

	client_exec(clientSqlFile, logPath, dbleConn, mysqlConn);
	delete dbleConn;
	delete mysqlConn;
	removeFile(loadDataFile);

	dbleManagerConn = createConn(managerHostName, managerUserName, managerPassword);
	manager_exec(managerSqlFile, logPath, dbleManagerConn);
	delete dbleManagerConn;
    exit(0);
}