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
        mysql_real_connect(new_conn, Host_Single_MySQL, TEST_USER, TEST_USER_PASSWD, "schema1", MYSQL_PORT, NULL, CLIENT_DEPRECATE_EOF);
    }else{
        mysql_real_connect(new_conn, Host_Test, TEST_USER, TEST_USER_PASSWD, "schema1", TEST_PORT,NULL, CLIENT_DEPRECATE_EOF);
	}
    if (new_conn == NULL) {
        printf("Error connecting to database: %s\n", mysql_error(new_conn));
        exit(1);
    }

	char sql[100];

    strcpy(sql, "set @@completion_type=2");
//    printf("query: %s\n", sql);
    myquery(mysql_query(new_conn, sql),new_conn);

    strcpy(sql, "drop table if exists tx_tb");
//    printf("query: %s\n", sql);
    myquery(mysql_query(new_conn, sql),new_conn);

    strcpy(sql, "create table tx_tb(id int)");
//    printf("query: %s\n", sql);
    myquery(mysql_query(new_conn, sql),new_conn);

    strcpy(sql, "set @@autocommit = 0");
//    printf("query: %s\n", sql);
    myquery(mysql_query(new_conn, sql),new_conn);

	strcpy(sql, "insert into tx_tb values(1)");
//    printf("query: %s\n", sql);
    myquery(mysql_query(new_conn, sql),new_conn);

	//case:Any active transactions are rolled back and autocommit mode is reset.
    if (mysql_rollback(new_conn)){
        fprintf(stderr, "Failed to rollback.  Error: %s\n", mysql_error(new_conn));
        exit(1);
    }else{
        printf("    *****pass! mysql_rollback success!*****\n");
        strcpy(sql, "select count(*) from tx_tb");
//        printf("query: %s\n", sql);
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

        strcpy(sql, "select count(*) from tx_tb/*master*/");
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

