/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#ifndef   __CPP_CONFIG_H__

#define   __CPP_CONFIG_H__

#include<string>
using namespace std;

class Config {
public:
	string MhostName;
	string MhostPort;
	string MuserName;
	string Mpassword;
	string ChostName;
	string ChostPort;
	string CuserName;
	string Cpassword;
	string MysqlhostName;
	string MysqlhostPort;
	string MysqluserName;
	string Mysqlpassword;
	string db;
	string sqlpath;
};

#endif