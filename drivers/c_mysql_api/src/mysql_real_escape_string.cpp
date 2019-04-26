//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"


void case_mysql_real_escape_string(MYSQL* conn){
	printf("==>mysql_real_escape_string test suites\n");

	myquery(conn, "drop table if exists sharding_4_t1");
	myquery(conn, "create table sharding_4_t1(str1 varchar(50), str2 varchar(50))");

	char query[1000];
	char *end;

	end = strcpy(query,"INSERT INTO test_table VALUES('");
	end += mysql_real_escape_string(conn,end,"What is this",12);
	end = stpcpy(end,"','");
	end += mysql_real_escape_string(conn,end,"binary data: \0\r\n",16);
	end = stpcpy(end,"')");

	if (mysql_real_query(conn,query,(unsigned int) (end - query)))
	{
	    fprintf(stderr, "    pass! mysql_real_escape_string, Failed to insert row, Error: %s\n",
	           mysql_error(conn));
	}else{
		printf("Expect '%s', len:%d error, but success ! ", query, (unsigned int)(end - query));
	    exit(1);
	}

	end = stpcpy(query,"INSERT INTO test_table VALUES('");
	end += mysql_real_escape_string_quote(conn,end,"What is this",12,'\'');
	end = stpcpy(end,"','");
	end += mysql_real_escape_string_quote(conn,end,"binary data: \0\r\n",16,'\'');
	end = stpcpy(end,"')");

	if (mysql_real_query(conn,query,(unsigned int) (end - query)))
	{
	   fprintf(stderr, "Failed to insert row, Error: %s\n",
	           mysql_error(conn));
	   exit(1);
	}else{
		printf("    pass! mysql_real_escape_string_quote\n");
	}
}
