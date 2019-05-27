/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
#include <stdlib.h>
#include <iostream>
#include<string>
#include<list>
using namespace std;



bool compareList(list<string> dblerslist, list<string> mysqlrslist, bool allow_diff_sequence) {
	if (dblerslist.size() != mysqlrslist.size()) {
		//cout << "not equal" << endl;
		return false;
	}

	if (allow_diff_sequence) {
		dblerslist.sort();
		mysqlrslist.sort();
	}

	list<string>::iterator iter1;
	list<string>::iterator iter2;
	for (iter1 = dblerslist.begin(), iter2 = mysqlrslist.begin(); iter1 != dblerslist.end(); iter1++, iter2++) {
		if (*iter1 != *iter2) {
			//cout << "not equal" << endl;
			return false;
			//break;
		}
	}
	return true;
}