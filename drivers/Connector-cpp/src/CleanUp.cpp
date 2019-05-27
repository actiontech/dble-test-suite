/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include <cstdio>
#include <unistd.h>

using namespace std;

int removeFile(const char *filePath){
	try {
		int accessFlag = access(filePath, F_OK);
		if (accessFlag == 0) {
			remove(filePath);
		}
	}
	catch (exception e) {
		cout << "Remove file failed!";
		exit(1);
	}
	return 0;
 }