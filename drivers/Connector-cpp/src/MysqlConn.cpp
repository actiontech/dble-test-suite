/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include <string>

#include "mysql_connection.h"
#include "mysql_driver.h"

#include <cppconn/driver.h>
#include <cppconn/exception.h>

//#include <cppconn/prepared_statement.h>
using namespace std;
using namespace sql;



Connection *createConn(char *hostName, const char *userName, const char *password) {
	mysql::MySQL_Driver *driver;
	Connection *con;
	try {
		//sql::Driver *driver;
		//driver = get_driver_instance();
		driver = mysql::get_mysql_driver_instance();
		con = driver->connect(hostName, userName, password);
		return con;
	}
	catch (SQLException &e) {
		cout << "Connect to " + string(hostName) + " failed!" << endl;
		cout << e.what() << endl;
		exit(1);
	}

}