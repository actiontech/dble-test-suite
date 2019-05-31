//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_real_query(MYSQL* conn){
	    printf("==> mysql_real_query test suites\n");
        MYSQL *mysql = mysql_init(NULL);
        if(IS_DEBUG){
            mysql_real_connect(mysql, HOST_MASTER, TEST_USER, TEST_USER_PASSWD, TEST_DB, MYSQL_PORT,NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
        }else{
            mysql_real_connect(mysql, HOST_DBLE, TEST_USER, TEST_USER_PASSWD, TEST_DB, DBLE_PORT, NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
        }

        if (mysql == NULL) {
            printf("Error connecting to database: %s\n", mysql_error(mysql));
            exit(1);
        }

        char sql[106];
//        sprintf(sql, "create table tttt(id int);insert into tttt values(1)");
        sprintf(sql, "drop table if exists sharding_4_t1;create table sharding_4_t1(id int);insert into sharding_4_t1 values(1)");
//        printf("%s\n", sql);
        if(mysql_real_query(mysql, sql, 105)){
                const char * err=mysql_error(mysql);
                printf("create table err: %s\n", err);
                exit(1);
        }else{
                printf("    pass! mysql_real_query mult-query success\n");
        }
}
