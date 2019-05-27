/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include <cstdio>
#include <unistd.h>

using namespace std;

int RmFile(const char *filepath){
	try {
		int accessflag = access(filepath, F_OK);
		if (accessflag == 0) {
			remove(filepath);
		}
	}
	catch (exception e) {
		cout << "Remove file failed!";
		exit(1);
	}
	return 0;
 }