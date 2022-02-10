/*
 * Copyright (C) 2016-2022 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#ifndef   __CPP_CONFIG_H__

#define   __CPP_CONFIG_H__

#include<string>
using namespace std;

class Config {
public:
	string managerHostName;
	string managerHostPort;
	string managerUserName;
	string managerPassword;
	string clientHostName;
	string clientHostPort;
	string clientUserName;
	string clientPassword;
	string mysqlHostName;
	string mysqlHostPort;
	string mysqlUserName;
	string mysqlPassword;
	string db;
	string sqlPath;
};

#endif