//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_insert_id(MYSQL* conn){
	printf("==>mysql_insert_id test suites\n");

	myquery(conn, "drop table if exists t1");
	myquery(conn, "create table t1(id int auto_increment primary key, name varchar(30))");
	myquery(conn, "insert into t1(name) values('a'),('b'),('c')");

	//mysql_insert_id
	unsigned long long ist_id = mysql_insert_id(conn);
	printf("    pass! mysql_insert_id:%llu\n", ist_id);
}
