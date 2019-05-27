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

Config YamlParse(string yamlPath) {
	Config cfg;
	string port;
	try {
		Node doc = LoadFile(yamlPath);
		cfg.managerHostName = doc["cfg_dble"]["dble"]["ip"].as<string>();
		cfg.managerHostPort = doc["cfg_dble"]["manager_port"].as<string>();
		cfg.managerUserName = doc["cfg_dble"]["manager_user"].as<string>();
		cfg.managerPassword = doc["cfg_dble"]["manager_password"].as<string>();

		cfg.clientHostName = doc["cfg_dble"]["dble"]["ip"].as<string>();
		cfg.clientHostPort = doc["cfg_dble"]["client_port"].as<string>();
		cfg.clientUserName = doc["cfg_dble"]["client_user"].as<string>();
		cfg.clientPassword = doc["cfg_dble"]["client_password"].as<string>();

		cfg.mysqlHostName = doc["cfg_mysql"]["compare_mysql"]["master1"]["ip"].as<string>();
		cfg.mysqlHostPort = doc["cfg_mysql"]["compare_mysql"]["master1"]["port"].as<string>();
		cfg.mysqlUserName = doc["cfg_mysql"]["user"].as<string>();
		cfg.mysqlPassword = doc["cfg_mysql"]["password"].as<string>();

		cfg.db = doc["cfg_sys"]["default_db"].as<string>();
		cfg.sqlPath = doc["cfg_sys"]["sql_source"].as<string>();

		cout << "clientHostName:" + cfg.clientHostName << endl;
		cout << "mysqlHostName:" + cfg.mysqlHostName << endl;
		return cfg;
	}
	catch (exception &e) {
		cout << e.what() << endl;
		exit(1);
	}

}