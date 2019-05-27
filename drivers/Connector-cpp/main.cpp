/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
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
	Connection *dbleMcon;
	Connection *dblecon;
	Connection *mysqlcon;
	char *MhostName;
	const char *MuserName;
	const char *Mpassword;
	char *ChostName;
	const char *CuserName;
	const char *Cpassword;
	char *MysqlhostName;
	const char *MysqluserName;
	const char *Mysqlpassword;
	string sqlfilename;
	const char *sqlfile;
	//get current path
	char buffer[MAX_PATH];
	const char *curpath = getcwd(buffer, MAX_PATH);
	//get current timestampt
	unsigned long stime = time(0);
	string strtime = to_string(stime);
	string path = string(curpath) + '/' + strtime;
	const char *logpath = path.c_str();
	createdir(logpath);
	Config cfg;
	cfg = YParse(string(argv[2]));
	//string(argv[3]) = "driver_test_manager.sql";
	if (string(argv[1]) == "test") {
		MhostName = "tcp://10.186.60.61:7171";
		MuserName = "root";
		Mpassword = "111111";
		ChostName = "tcp://10.186.60.61:7131";
		CuserName = "test";
		Cpassword = "111111";
		MysqlhostName = "tcp://10.186.60.61:7144";
		MysqluserName = "test";
		Mysqlpassword = "111111";

		sqlfilename = string(curpath) + "/assets/sql/driver_test_manager.sql";
		//sqlfilename = string(curpath) + "/assets/sql/driver_test_client.sql";
		sqlfile = sqlfilename.c_str();
		//cout << string(sqlfile) << endl;
	}
	else {
		string Mdblehost = "tcp://" + cfg.MhostName + ":" + cfg.MhostPort;
		MhostName = new char[50];
		strcpy(MhostName, Mdblehost.c_str());
		MuserName = cfg.MuserName.c_str();
		Mpassword = cfg.Mpassword.c_str();
		string Cdblehost = "tcp://" + cfg.ChostName + ":" + cfg.ChostPort;
		ChostName = new char[50];
		strcpy(ChostName, Cdblehost.c_str());
		//ChostName = Cdblehost.c_str();
		CuserName = cfg.CuserName.c_str();
		Cpassword = cfg.Cpassword.c_str();
		string Mysqlhost = "tcp://" + cfg.MysqlhostName + ":" + cfg.MysqlhostPort;
		MysqlhostName = new char[50];
		strcpy(MysqlhostName, Mysqlhost.c_str());
		//MysqlhostName = Mysqlhost.c_str();
		MysqluserName = cfg.MysqluserName.c_str();
		Mysqlpassword = cfg.Mysqlpassword.c_str();
		sqlfilename = string(curpath) + cfg.sqlpath.substr(1, cfg.sqlpath.length() - 1) + "/" + argv[3];
		sqlfile = sqlfilename.c_str();
		cout << string(sqlfile) << endl;
		cout << string(MhostName) << endl;
		cout << string(MuserName) << endl;
		cout << string(Mpassword) << endl;
	}


	if (findSubstr(sqlfilename, "manager")) {
		dbleMcon = createConn(MhostName, MuserName, Mpassword);
		manager_exec(sqlfile, logpath, dbleMcon);
		delete dbleMcon;
	}
	if (findSubstr(sqlfilename, "client")) {
		string loadpath = string(curpath) + "/test1.txt";
		const char *loadfile = loadpath.c_str();
		WriteLoadData("test1.txt");
		dblecon = createConn(ChostName, CuserName, Cpassword);
		mysqlcon = createConn(MysqlhostName, MysqluserName, Mysqlpassword);
		client_exec(sqlfile, logpath, dblecon, mysqlcon);
		delete dblecon;
		delete mysqlcon;
		RmFile(loadfile);
	}

	exit(0);
}