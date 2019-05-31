//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_row_seek(MYSQL* conn){
	printf("==>case: mysql_row_seek test suits\n");

	char sql[200];
	createAndFillTable(conn);

    strcpy(sql, "select * from sharding_4_t1");

    myquery(conn, sql);

    MYSQL_RES  *res;

    res=mysql_store_result(conn);
	MYSQL_ROW  row = mysql_fetch_row(res);
	MYSQL_ROW_OFFSET special_location;
	special_location = mysql_row_tell(res);

	mysql_row_seek(res, special_location);
	printf("    pass! mysql_row_seek pass\n");
	doPrintResult(conn, res);
    mysql_free_result(res);
}
