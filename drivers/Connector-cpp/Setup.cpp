/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <ostream>
#include <string>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h> 
#include <dirent.h>
using namespace std;

int WriteLoadData(string filename) {
	ofstream loadfile;
	try {
		loadfile.open(filename, ios::out | ios::app);
	}
	catch (exception e) {
		cout << "open file " + filename + " failed!" << endl;
		loadfile.close();
		exit(1);
	}
	loadfile << "10,10,'Vicky',10" << endl;
	loadfile << "11,11,'����',11" << endl;

	loadfile.close();

	return 0;
}