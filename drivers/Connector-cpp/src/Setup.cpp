/*
 * Copyright (C) 2016-2020 ActionTech.
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

int writeLoadData(string fileName) {
	ofstream loadFile;
	try {
		loadFile.open(fileName, ios::out | ios::app);
	}
	catch (exception e) {
		cout << "open file " + fileName + " failed!" << endl;
		loadFile.close();
		exit(1);
	}
	loadFile << "10,10,'Vicky',10" << endl;
	loadFile << "11,11,'����',11" << endl;

	loadFile.close();

	return 0;
}