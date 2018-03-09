//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_select_db(MYSQL* conn){
	printf("==>mysql_select_db test suites\n");

	myquery(mysql_query(conn, "drop database if exists test_db"),conn);
	myquery(mysql_query(conn, "create database test_db"),conn);
	if(mysql_select_db(conn, "test_db")){
		printf("mysql_select_db got err:%s\n", mysql_error(conn));
		exit(1);
	}else{
		myquery(mysql_query(conn, "create table test_db_tb(id int)"),conn);
        doQueryWithExpectInt(conn, "select count(*) from test_db.test_db_tb/*master*/", 0);
        printf("    pass! create a table after mysql_select_db, then select from new_db.new_table success! \n");
	}
}
