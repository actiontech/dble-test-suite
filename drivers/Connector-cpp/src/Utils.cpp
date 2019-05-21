/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include<string>
#include<list>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h> 
#include <dirent.h>
#include "ext.h"
#include <ctime>
using namespace std;

int createDir(const char *filePath)
{
	int mkdirFlag;
	int accessFlag = access(filePath, 00);
	if (accessFlag == 0) {
		rmdir(filePath);
	}
	try {
		mkdirFlag = mkdir(filePath, S_IRUSR | S_IWUSR | S_IXUSR | S_IRWXG | S_IRWXO);
	}
	catch (exception e) {
		cout << "Create directory " + string(filePath) + " failed!";
		return -1;
		exit(1);
	}
	return 0;
}

string convertListToString(list<string> lt) {
	string str;
	list<string>::iterator iter;
	for (iter = lt.begin(); iter != lt.end(); iter++)
	{
		str.append("(" + *iter + "), ");
	}
//	cout << str << endl;
	return str;
}

bool findSubstr(string str, string substr) {
	string::size_type idx;
	idx = str.find(substr);
	if (idx == string::npos) //doesn't exists
		return false;
	else
		return true;
}