//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_stat(MYSQL* conn){
	printf("==> mysql_stat test suites\n");

	const char *stat = mysql_stat(conn);
	printf("    pass! mysql_stat: %s\n", stat);
}
