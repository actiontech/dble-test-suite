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

	myquery(mysql_query(conn, "drop table if exists global_table1"), conn);
	myquery(mysql_query(conn, "create table global_table1(id int auto_increment primary key, name varchar(30))"), conn);
	myquery(mysql_query(conn, "insert into global_table1(name) values('a'),('b'),('c')"), conn);

	//mysql_insert_id
	unsigned long long ist_id = mysql_insert_id(conn);
	printf("    pass! mysql_insert_id:%llu\n", ist_id);
}
