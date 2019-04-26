//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_list_dbs(MYSQL *conn){
	printf("==>mysql_list_dbs && mysql_list_tables test suites \n");
	MYSQL_RES *res = mysql_list_dbs(conn, NULL);
	if (res){
		/* yes; show rows and free the result set */
		printf("    pass! mysql_list_dbs \n");
		if(IS_DEBUG) doPrintResult(conn, res);
		mysql_free_result(res);
	}
	else/* no result set or error */
	{
		printf("mysql_list_dbs get err, %s\n", mysql_error(conn));
		exit(1);
	}

	myquery(conn, "drop table if exists sharding_4_t1");
	myquery(conn, "create table sharding_4_t1(id int)");
	MYSQL_RES *res2 = mysql_list_tables(conn, "tb%");
	if (res){
		printf("    pass! mysql_list_tables: \n");
		/* yes; show rows and free the result set */
		if(IS_DEBUG) doPrintResult(conn, res2);
		mysql_free_result(res2);
	}
	else/* no result set or error */
	{
		printf("mysql_list_tables get err, %s\n", mysql_error(conn));
		exit(1);
	}

}
