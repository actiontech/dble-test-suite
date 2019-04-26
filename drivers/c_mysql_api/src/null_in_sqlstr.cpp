//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_null_in_sql(){
	printf("==>mysql_real_query send queries end with null test suites\n");
	MYSQL* mysql = mysql_init(NULL);
	if(IS_DEBUG){
		mysql_real_connect(mysql, "172.100.9.4", TEST_USER, TEST_USER_PASSWD, TEST_DB, 3306,NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
	}else{
		mysql_real_connect(mysql, HOST_DBLE, TEST_USER, TEST_USER_PASSWD, TEST_DB, DBLE_PORT, NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
	}
	if (mysql == NULL) {
		printf("Error connecting to database: %s\n", mysql_error(mysql));
		exit(1);
	}

	//*****case1:multi-queries without ';' in the last query;
	char sql[50];
	sprintf(sql, "drop table if exists sharding_4_t1;create table sharding_4_t1(id int);create table sharding_4_t1(id int)");
	//	printf("%s\n", sql);
	int status = mysql_real_query(mysql, sql, 50);
	if(status){
		const char * err=mysql_error(mysql);
		printf("err: %s\n", err);
		exit(1);
	}else{
		printf("    pass! multi-queries without ';' in the last query success\n");
		printMultiRes(mysql, status);
	}

	//*******case2********;
	sprintf(sql, "create table t3(id int)\0;create table t4(id int)");
	//	printf("%s\n", sql);
	status = mysql_real_query(mysql, sql, 50);
	if(status){
		const char * err=mysql_error(mysql);
		printf("    pass! multi-queries without ';' in the last query, and queries before the last end with a \\0 fail, err: %s\n", err);
	}else{
		printf("multi-queries without ';' in the last query, and queries before the last end with a \\0 expect fail.\n");
		printMultiRes(mysql, status);
		exit(1);
	}

	//*******case3********
	sprintf(sql, "create table t5(id int);\0create table t6(id int)");
	//	printf("%s\n", sql);
	status = mysql_real_query(mysql, sql, 50);
	if(status){
		const char * err=mysql_error(mysql);
		printf("err: %s\n", err);
		exit(1);
	}else{
		printf("    pass! multi-queries without ';' in the last query, and last query start with \\0 success.\n");
		printMultiRes(mysql, status);
	}
	MYSQL* conn = mysql_init(NULL);
	if(IS_DEBUG){
		mysql_real_connect(conn, "172.100.9.4", TEST_USER, TEST_USER_PASSWD, TEST_DB, 3306,NULL, CLIENT_DEPRECATE_EOF);
	}else{
		mysql_real_connect(conn, HOST_DBLE, TEST_USER, TEST_USER_PASSWD, TEST_DB, DBLE_PORT, NULL, CLIENT_DEPRECATE_EOF);
	}
	if (conn == NULL) {
		printf("Error connecting to database: %s\n", mysql_error(conn));
		exit(1);
	}

	//*******case4********
	sprintf(sql, "select 1\0,2");
	//	printf("%s\n", sql);
	if(mysql_real_query(conn, sql, 50)){
		const char * err=mysql_error(conn);
		printf("    pass! 'select 1\\0,2', err: %s\n", err);
	}else{
		printf("expect fail\n");
		exit(1);
	}

	//*******case5********
	sprintf(sql, "select 1,\02");
//	printf("%s\n", sql);
	if(mysql_real_query(conn, sql, 50)){
		const char * err=mysql_error(conn);
		printf("    pass! 'select 1,\\02', err: %s\n", err);
	}else{
		printf("expect fail, but success\n");
		exit(1);
	}

	//*******case6********
	sprintf(sql, "select '1,\02'");
//	printf("%s\n", sql);
	if(mysql_real_query(conn, sql, 50)){
		const char * err=mysql_error(conn);
		printf("    pass! 'select '1,\\02'', err: %s\n", err);
	}else{
		printf("expect fail, but success\n");
		exit(1);
	}

	//*******case7********
	sprintf(sql, "\0select '1'");
//	printf("%s\n", sql);
	if(mysql_real_query(conn, sql, 50)){
		const char * err=mysql_error(conn);
		printf("    pass! '\\0select '1'', err: %s\n", err);
	}else{
		printf("expect fail, but success\n");
		exit(1);
	}
}
