//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_thread_id(){
	printf("==>mysql_thread_id && mysql_warning_count test suites\n");
	MYSQL *mysql = getConn();
	unsigned long tid = mysql_thread_id(mysql);
//	printf("thread_id: %lu \n", tid);

	char sql[50];
	sprintf(sql, "kill %lu", tid);
	if(mysql_query(mysql, sql)){
//		printf("kill:%lu,\n", tid);

		const char * err=mysql_error(mysql);
		if(strcmp("Lost connection to MySQL server during query", err)==0 || strcmp("Query execution was interrupted",err)==0){
			printf("    pass! after kill thread_id by mysql_thread_id query get 'lost connection to ...'\n");
		}else{
			printf("kill thread_id fail, err: %s\n", err);
			exit(1);
		}

		unsigned int wc = mysql_warning_count(mysql);
		printf("    pass! mysql_warning_count: %u\n", wc);
	}else{
	    printf("    fail:expect after kill thread_id, conn be closed");
	    exit(1);
	}
}
