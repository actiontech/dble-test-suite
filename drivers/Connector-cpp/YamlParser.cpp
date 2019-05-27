/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#include "yaml-cpp/yaml.h" 
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
#include "config.h"
using namespace std;
using namespace YAML;

Config YParse(string yamlpath) {
	Config cfg;
	string port;
	try {
		Node doc = LoadFile(yamlpath);
		cfg.MhostName = doc["cfg_dble"]["dble"]["ip"].as<string>();
		cfg.MhostPort = doc["cfg_dble"]["manager_port"].as<string>();
		cfg.MuserName = doc["cfg_dble"]["manager_user"].as<string>();
		cfg.Mpassword = doc["cfg_dble"]["manager_password"].as<string>();

		cfg.ChostName = doc["cfg_dble"]["dble"]["ip"].as<string>();
		cfg.ChostPort = doc["cfg_dble"]["client_port"].as<string>();
		cfg.CuserName = doc["cfg_dble"]["client_user"].as<string>();
		cfg.Cpassword = doc["cfg_dble"]["client_password"].as<string>();

		cfg.MysqlhostName = doc["cfg_mysql"]["compare_mysql"]["master1"]["ip"].as<string>();
		cfg.MysqlhostPort = doc["cfg_mysql"]["compare_mysql"]["master1"]["port"].as<string>();
		cfg.MysqluserName = doc["cfg_mysql"]["user"].as<string>();
		cfg.Mysqlpassword = doc["cfg_mysql"]["password"].as<string>();

		cfg.db = doc["cfg_sys"]["default_db"].as<string>();
		cfg.sqlpath = doc["cfg_sys"]["sql_source"].as<string>();

		cout <<"ChostName:" + cfg.ChostName << endl;
		cout << "MysqlhostName:" + cfg.MysqlhostName << endl;
		return cfg;
	}
	catch (exception &e) {
		cout << e.what() << endl;
		exit(1);
	}

}