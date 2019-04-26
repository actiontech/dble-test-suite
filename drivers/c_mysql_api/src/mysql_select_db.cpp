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

	if(mysql_select_db(conn, "schema2")){
		printf("mysql_select_db got err:%s\n", mysql_error(conn));
		exit(1);
	}else{
		myquery(conn, "drop table if exists sharding_4_t2");
		myquery(conn, "create table sharding_4_t2(id int)");
        doQueryWithExpectInt(conn, "select count(*) from schema2.sharding_4_t2", 0);
        printf("    pass! create a table after mysql_select_db, then select from new_db.new_table success! \n");
	}
}
