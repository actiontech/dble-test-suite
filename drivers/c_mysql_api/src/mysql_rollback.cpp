//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_rollback(MYSQL* conn){
    printf("==> mysql_rollback test suites\n");

    MYSQL* new_conn = mysql_init(NULL);
    if(IS_DEBUG){
        mysql_real_connect(new_conn, HOST_MASTER, TEST_USER, TEST_USER_PASSWD, TEST_DB, MYSQL_PORT, NULL, CLIENT_DEPRECATE_EOF);
    }else{
        mysql_real_connect(new_conn, HOST_DBLE, TEST_USER, TEST_USER_PASSWD, TEST_DB, DBLE_PORT,NULL, CLIENT_DEPRECATE_EOF);
	}
    if (new_conn == NULL) {
        printf("Error connecting to database: %s\n", mysql_error(new_conn));
        exit(1);
    }

	char sql[100];

    strcpy(sql, "set @@completion_type=2");
    myquery(new_conn, sql);

    strcpy(sql, "drop table if exists sharding_4_t1");
    myquery(new_conn, sql);

    strcpy(sql, "create table sharding_4_t1(id int)");
    myquery(new_conn, sql);

    strcpy(sql, "set @@autocommit = 0");
    myquery(new_conn, sql);

	strcpy(sql, "insert into sharding_4_t1 values(1)");
    myquery(new_conn, sql);

	//case:Any active transactions are rolled back and autocommit mode is reset.
    if (mysql_rollback(new_conn)){
        fprintf(stderr, "Failed to rollback.  Error: %s\n", mysql_error(new_conn));
        exit(1);
    }else{
        printf("    *****pass! mysql_rollback success!*****\n");
        strcpy(sql, "select count(*) from sharding_4_t1");

        if(mysql_query(new_conn, sql)){
            const char * errmsg = mysql_error(new_conn);
            if(strstr(errmsg, "Lost connection to MySQL server during query") != NULL){
                printf("    pass! after rollback with settings @@completion_type=2, Error as expect: %s\n", errmsg);
            }else{
                printf("Err:%s\n is not as expected", errmsg);
                exit(1);
            }
        }else{
                printf("Expect err:Lost connection to MySQL server during query, but success\n");
                exit(1);
        }

        strcpy(sql, "select count(*) from sharding_4_t1/*master*/");
        if(mysql_query(conn, sql)){
        		printf("error! table create before is rollbacked ! Error:%s \n", mysql_error(conn));
        		exit(1);
        }else{
        		printf("    pass! table create before rollbacked is implicitly commited!\n");
        		MYSQL_RES * res=mysql_store_result(conn);
        	    mysql_free_result(res);
        }
    }
}

