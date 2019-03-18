/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
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