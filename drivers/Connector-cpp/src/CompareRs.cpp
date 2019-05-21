/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include<string>
#include<list>
using namespace std;



bool compareList(list<string> dbleResultSetList, list<string> mysqlResultSetList, bool allow_diff) {
    if (allow_diff) {
//		dbleResultSetList.sort();
//		mysqlResultSetList.sort();
        return true;
	}
	if (dbleResultSetList.size() != mysqlResultSetList.size()) {
		//cout << "not equal" << endl;
		return false;
	}
	list<string>::iterator iter1;
	list<string>::iterator iter2;
	for (iter1 = dbleResultSetList.begin(), iter2 = mysqlResultSetList.begin(); iter1 != dbleResultSetList.end(); iter1++, iter2++) {
		if (*iter1 != *iter2) {
			//cout << "not equal" << endl;
			return false;
			//break;
		}
	}
	return true;
}