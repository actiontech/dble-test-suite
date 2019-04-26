//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_options4(MYSQL* conn){
	printf("==>mysql_options4 && mysql_ping test suites\n");

	MYSQL mysql;

	mysql_init(&mysql);
	mysql_options(&mysql,MYSQL_OPT_CONNECT_ATTR_RESET, 0);
	mysql_options4(&mysql,MYSQL_OPT_CONNECT_ATTR_ADD, "key1", "value1");
	mysql_options4(&mysql,MYSQL_OPT_CONNECT_ATTR_ADD, "key2", "value2");
	mysql_options4(&mysql,MYSQL_OPT_CONNECT_ATTR_ADD, "key3", "value3");
	mysql_options(&mysql,MYSQL_OPT_CONNECT_ATTR_DELETE, "key1");
	if(IS_DEBUG){
        mysql_real_connect(&mysql, HOST_MASTER, TEST_USER, TEST_USER_PASSWD, NULL, 0,NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
	}else{
        mysql_real_connect(&mysql, HOST_DBLE, TEST_USER, TEST_USER_PASSWD, NULL, 0,NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
	}

    if (&mysql == NULL) {
        printf("Error connecting to database: %s\n", mysql_error(&mysql));
        exit(1);
    }else{
    	printf("    pass! mysql_options4 passed.\n");
    }

    if(mysql_ping(&mysql)){
        printf("Error mysql_ping: %s\n", mysql_error(&mysql));
        exit(1);
    }else{
		printf("    pass! mysql_ping passed!\n");
    }
}
